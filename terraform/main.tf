data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  name = "${var.project_name}-${var.environment}"
  azs  = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.5.1"
  name = local.name
  cidr = var.vpc_cidr
  azs = local.azs
  public_subnets = ["10.20.1.0/24", "10.20.2.0/24"]
  private_subnets = ["10.20.11.0/24", "10.20.12.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_ecr_repository" "app" {
  name = local.name
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration { scan_on_push = true }
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name
  policy = jsonencode({rules=[{rulePriority=1,description="Keep latest 20 images",selection={tagStatus="any",countType="imageCountMoreThan",countNumber=20},action={type="expire"}}]})
}

resource "aws_ecs_cluster" "app" {
  name = local.name
  setting { name = "containerInsights" value = "enhanced" }
}

resource "aws_cloudwatch_log_group" "app" {
  name = "/ecs/${local.name}"
  retention_in_days = 14
}

data "aws_iam_policy_document" "task_assume" {
  statement {
    effect = "Allow"
    principals { type = "Service" identifiers = ["ecs-tasks.amazonaws.com"] }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "execution" {
  name = "${local.name}-execution"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
}
resource "aws_iam_role_policy_attachment" "execution" {
  role = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role" "task" {
  name = "${local.name}-task"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json
}

resource "aws_ecs_task_definition" "app" {
  family = local.name
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = var.task_cpu
  memory = var.task_memory
  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn = aws_iam_role.task.arn
  container_definitions = jsonencode([{
    name = local.name
    image = var.container_image != "" ? var.container_image : "${aws_ecr_repository.app.repository_url}:latest"
    essential = true
    portMappings = [{containerPort=var.container_port,hostPort=var.container_port,protocol="tcp"}]
    environment = [{name="APP_NAME",value=var.project_name},{name="APP_VERSION",value="1.0.0"},{name="PORT",value=tostring(var.container_port)}]
    logConfiguration = {logDriver="awslogs",options={"awslogs-group"=aws_cloudwatch_log_group.app.name,"awslogs-region"=var.aws_region,"awslogs-stream-prefix"="app"}}
    healthCheck = {command=["CMD-SHELL","python -c \"import urllib.request; urllib.request.urlopen('http://127.0.0.1:${var.container_port}/health',timeout=3)\""],interval=30,timeout=5,retries=3,startPeriod=15}
  }])
}

resource "aws_security_group" "alb" {
  name = "${local.name}-alb"
  vpc_id = module.vpc.vpc_id
  ingress { from_port=80 to_port=80 protocol="tcp" cidr_blocks=["0.0.0.0/0"] }
  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}
resource "aws_security_group" "ecs" {
  name = "${local.name}-ecs"
  vpc_id = module.vpc.vpc_id
  ingress { from_port=var.container_port to_port=var.container_port protocol="tcp" security_groups=[aws_security_group.alb.id] }
  egress { from_port=0 to_port=0 protocol="-1" cidr_blocks=["0.0.0.0/0"] }
}

resource "aws_lb" "app" {
  name = local.name
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb.id]
  subnets = module.vpc.public_subnets
}
resource "aws_lb_target_group" "app" {
  name = local.name
  port = var.container_port
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = module.vpc.vpc_id
  health_check { path="/health" protocol="HTTP" matcher="200" interval=30 timeout=5 healthy_threshold=2 unhealthy_threshold=3 }
}
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port = 80
  protocol = "HTTP"
  default_action { type="forward" target_group_arn=aws_lb_target_group.app.arn }
}

resource "aws_ecs_service" "app" {
  name = local.name
  cluster = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count = var.desired_count
  launch_type = "FARGATE"
  platform_version = "LATEST"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent = 200
  health_check_grace_period_seconds = 60
  enable_execute_command = true
  network_configuration { subnets=module.vpc.private_subnets security_groups=[aws_security_group.ecs.id] assign_public_ip=false }
  load_balancer { target_group_arn=aws_lb_target_group.app.arn container_name=local.name container_port=var.container_port }
  depends_on = [aws_iam_role_policy_attachment.execution, aws_lb_listener.http]
}

resource "aws_appautoscaling_target" "ecs" {
  max_capacity = var.max_capacity
  min_capacity = var.min_capacity
  resource_id = "service/${aws_ecs_cluster.app.name}/${aws_ecs_service.app.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace = "ecs"
}
resource "aws_appautoscaling_policy" "cpu" {
  name = "${local.name}-cpu"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value = 60
    scale_in_cooldown = 60
    scale_out_cooldown = 60
    predefined_metric_specification { predefined_metric_type = "ECSServiceAverageCPUUtilization" }
  }
}
resource "aws_appautoscaling_policy" "memory" {
  name = "${local.name}-memory"
  policy_type = "TargetTrackingScaling"
  resource_id = aws_appautoscaling_target.ecs.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs.scalable_dimension
  service_namespace = aws_appautoscaling_target.ecs.service_namespace
  target_tracking_scaling_policy_configuration {
    target_value = 70
    scale_in_cooldown = 60
    scale_out_cooldown = 60
    predefined_metric_specification { predefined_metric_type = "ECSServiceAverageMemoryUtilization" }
  }
}
