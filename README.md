# 🚀 Serverless AWS Architecture using Terraform

## 📌 Overview

This project demonstrates a secure and cost-optimized serverless architecture on AWS using Terraform.

The main goal was to build a scalable system while **minimizing cost using AWS Free Tier and efficient architecture design**.

---

## 🏗️ Architecture Components

![Architecture Diagram](Screenshot%20from%202026-04-29%2004-52-16.png)
* CloudFront (CDN)
* S3 (Static Storage)
* API Gateway
* Lambda (inside private subnet)
* DynamoDB
* VPC (Private Subnet)
* VPC Endpoints
* Security Groups

---

## 🔐 Why Lambda in a Private Subnet?

I deployed Lambda inside a private subnet for:

* **Security**: No direct internet access reduces attack surface
* **Controlled access**: Lambda communicates only with AWS services via VPC Endpoints
* **Best practice** for production-grade architectures

---

## 💰 Cost Optimization Strategy

This architecture is designed to **stay within AWS Free Tier as much as possible**:

### 1. Serverless Services

* Lambda, API Gateway, and DynamoDB are **pay-per-use**
* No always-running servers (unlike EC2)

### 2. Using Free Tier

* AWS Lambda: 1M free requests/month
* API Gateway: free tier available
* DynamoDB: free read/write capacity
* S3: 5GB free storage
* CloudFront: free data transfer (limited)

### 3. Avoiding Expensive Components

* ❌ No EC2 instances (always cost money)
* ❌ No NAT Gateway (very expensive)
* ✅ Used **VPC Endpoints** instead

### 4. VPC Endpoints Instead of NAT Gateway

* Lambda accesses S3 and DynamoDB **privately**
* Avoids NAT Gateway cost (~$30+/month)
* Improves security and reduces latency

---

## 🔄 Architecture Flow

1. User accesses the application via CloudFront
2. Static content is served from S3
3. API requests go to API Gateway
4. API Gateway triggers Lambda
5. Lambda processes logic and interacts with DynamoDB
6. All internal communication happens inside a secure VPC

---

## ⚙️ Deployment

```bash
terraform init
terraform plan
terraform apply
```

---

## 📸 Architecture Diagram

(Add your diagram here)

---

## 👨‍💻 Author

Salah Said
