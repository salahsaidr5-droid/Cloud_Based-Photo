🚀 AWS Serverless & Zero-Cost Architecture (Terraform)
📌 What is this about?
I built a fully automated, serverless system on AWS using Terraform. The main challenge wasn't just making it work, but making it secure and basically free by staying within the AWS Free Tier limits.
![Architecture Diagram](Screenshot%20from%202026-04-29%2004-52-16.png)

🏗️ The Tech Stack
CloudFront & S3: For fast static content delivery.

API Gateway & Lambda: The logic layer (Serverless).

DynamoDB: For the database.

VPC & Endpoints: The networking backbone.

🔐 The "Private Lambda" Choice
I didn't just throw the Lambda function out there. I tucked it inside a Private Subnet.

Why? Because even in serverless, security matters. Keeping it private means no direct internet exposure, reducing the attack surface.

The Pro Way: This is how real production environments are built.

💰 Killing the Costs (Cost Optimization)
The goal was simple: $0 monthly bill.

Strictly Serverless: Used Lambda and DynamoDB because you only pay when someone actually uses the app. No idle servers wasting money.

No NAT Gateway: This is the big one. NAT Gateways cost about $30/month just to exist. I replaced them with VPC Endpoints (Interface & Gateway types) to let the Lambda talk to S3 and DynamoDB privately and for free.

Free Tier Maximization: Optimized every service to fit within the 1M free requests and 5GB storage limits.

🔄 How it works
Users hit the CloudFront URL.

S3 handles the frontend stuff.

API Gateway catches the backend requests and triggers the Lambda.

The Lambda does its job, talks to DynamoDB via a private tunnel (VPC Endpoint), and stays completely hidden from the public internet.

⚙️ To Run This
Just the standard Terraform flow:

Bash
terraform init
terraform apply
No manual clicking in the console, everything is defined in the code.
