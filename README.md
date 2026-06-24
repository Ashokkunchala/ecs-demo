![GitHub repo size](https://img.shields.io/github/repo-size/Ashokkunchala/ecs-demo?style=for-the-badge)
![GitHub stars](https://img.shields.io/github/stars/Ashokkunchala/ecs-demo?style=social)
![GitHub forks](https://img.shields.io/github/forks/Ashokkunchala/ecs-demo?style=social)
![GitHub license](https://img.shields.io/github/license/Ashokkunchala/ecs-demo)
![GitHub last commit](https://img.shields.io/github/last-commit/Ashokkunchala/ecs-demo)
![GitHub issues](https://img.shields.io/github/issues/Ashokkunchala/ecs-demo)
![GitHub pull requests](https://img.shields.io/github/issues-pr/Ashokkunchala/ecs-demo)
![CI](https://github.com/Ashokkunchala/ecs-demo/actions/workflows/ci.yml/badge.svg)

# ECS Demo Application

A sample project demonstrating how to deploy a containerized application on **Amazon Elastic Container Service (ECS)** using **AWS Fargate**.

## 📋 Overview

This repository contains:
- A simple Python Flask application
- Dockerfile for containerization
- Terraform scripts to provision ECS cluster, service, load balancer, and IAM roles
- GitHub Actions CI/CD pipeline for automated deployment

## 🚀 Features

- Containerized Python web app
- **ECS Fargate** (serverless containers) – no EC2 management
- Application Load Balancer for traffic distribution
- Auto Scaling based on CPU utilization
- Infrastructure as Code with Terraform
- GitHub Actions workflow for build, test, and deploy
- CloudWatch logging and monitoring

## 🛠️ Technology Stack

<div align="left">
  <img src="https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white" alt="docker"/>
  <img src="https://img.shields.io/badge/amazon%20ecs-%23FF9900.svg?style=for-the-badge&logo=amazon&logoColor=white" alt="amazon ecs"/>
  <img src="https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white" alt="terraform"/>
  <img src="https://img.shields.io/badge/aws-%23FF9900.svg?style=for-the-badge&logo=amazonaws&logoColor=white" alt="aws"/>
  <img src="https://img.shields.io/badge/githubactions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white" alt="githubactions"/>
  <img src="https://img.shields.io/badge/python-%23777BB4.svg?style=for-the-badge&logo=python&logoColor=white" alt="python"/>
  <img src="https://img.shields.io/badge/postgres-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white" alt="postgres"/>
  <img src="https://img.shields.io/badge/cloudwatch-%23864FCD.svg?style=for-the-badge&logo=amazonaws&logoColor=white" alt="cloudwatch"/>
</div>

## 📁 Project Structure

```
ecs-demo/
├── .github/
│   └── workflows/
│       └── ci.yml               # CI/CD pipeline
├── app/
│   ├── app.py                   # Flask app
│   └── requirements.txt
├── terraform/
│   ├── main.tf                  # ECS cluster, service, ALB, IAM
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
├── Dockerfile
└── README.md
```

## 🚦 How to Deploy

1. **Clone the repo**
   ```bash
   git clone https://github.com/Ashokkunchala/ecs-demo.git
   cd ecs-demo
   ```

2. **Configure AWS credentials** (via `aws configure` or environment variables)

3. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

4. **Review and apply**
   ```bash
   terraform plan -out=tfplan
   terraform apply tfplan
   ```

5. **Push changes** to trigger the GitHub Actions pipeline (automatically builds Docker image, pushes to ECR, updates service)

## 📊 Monitoring & Logging

- **CloudWatch Logs** – application logs
- **CloudWatch Metrics** – CPU, memory, request count
- **ALB Access Logs** – traffic inspection
- Optional: Container Insights for deeper ECS metrics

## 💰 Cost Optimization

- **Fargate pricing** – pay only for vCPU‑seconds and GB‑seconds used
- **Auto Scaling** – adjusts task count based on load
- **Spot Instances** (if using EC2 launch type) – up to 90% savings
- **Right‑sizing** – task CPU/memory tuned via Terraform variables

## 📄 License

MIT License – see [LICENSE](LICENSE) for details.

---

**Created by**: Ashok Kunchala (DevOps Engineer)  
**GitHub**: [@Ashokkunchala](https://github.com/Ashokkunchala)  
**LinkedIn**: [linkedin.com/in/ashok-kunchala-127820217](https://www.linkedin.com/in/ashok-kunchala-127820217/)
