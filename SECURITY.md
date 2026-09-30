# Security

Do not commit AWS access keys, secret keys, session tokens, Terraform state, tfvars files, or application secrets.

GitHub Actions uses AWS IAM OIDC and a short-lived role. Configure the repository/environment secret AWS_DEPLOY_ROLE_ARN and scope that role to only the resources required by this project.
