# ECS Demo Application

A sample project demonstrating how to deploy a containerized application on Amazon Elastic Container Service (ECS) using AWS Fargate.

## 📋 Overview

This repository contains:
- A simple Python Flask application
- Dockerfile for containerization
- Terraform scripts to provision ECS cluster, service, load balancer, and IAM roles
- CI/CD pipeline using GitHub Actions

## 🚀 Features

- Containerized Python web app
- ECS Fargate (serverless containers)
- Application Load Balancer
- Auto Scaling configurations
- Infrastructure as Code with Terraform
- GitHub Actions workflow for automated deployment

## 🛠️ Technologies Used

- **Containerization**: Docker
- **Orchestration**: Amazon ECS (Fargate launch type)
- **Infrastructure**: Terraform, AWS
- **CI/CD**: GitHub Actions
- **Language**: Python (Flask)
- **Monitoring**: CloudWatch integration

## 📁 Project Structure



## 🚦 How to Deploy

1. Clone the repository
2. Configure AWS credentials
3. Initialize Terraform: [0m[1mTerraform initialized in an empty directory![0m

The directory has no Terraform configuration files. You may begin working
with Terraform immediately by creating Terraform configuration files.[0m
4. Review and apply: 
5. Push changes to trigger GitHub Actions pipeline

## 📊 Monitoring & Logging

- CloudWatch Logs for application logs
- CloudWatch Metrics for CPU/Memory utilization
- ALB access logs for traffic analysis

## 💰 Cost Optimization

- Fargate pricing: pay only for vCPU and memory consumed
- Auto Scaling to match demand
- Spot instances option for worker tasks (if using EC2 launch type)

## 📄 License

MIT License - feel free to use and modify!

---

**Created by**: Ashok Kunchala (DevOps Engineer)
**GitHub**: [@Ashokkunchala](https://github.com/Ashokkunchala)
