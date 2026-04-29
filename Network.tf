resource "aws_vpc" "Terraform_Project_CBp" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Terraform_Test_Salah"
  }
}

data "aws_availability_zones" "availability" {}

resource "aws_subnet" "Lambda" {
  vpc_id            = aws_vpc.Terraform_Project_CBp.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.availability.names[0]
  tags = {
    Name = "Lambda"
  }
}

resource "aws_route_table" "private_Lambda" {
  vpc_id = aws_vpc.Terraform_Project_CBp.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.Lambda.id
  route_table_id = aws_route_table.private_Lambda.id
}

data "aws_vpc_endpoint_service" "s3" {
  service      = "s3"
  service_type = "Gateway"
}

data "aws_vpc_endpoint_service" "dynamodb" {
  service      = "dynamodb"
  service_type = "Gateway"
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.Terraform_Project_CBp.id
  service_name      = data.aws_vpc_endpoint_service.s3.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_Lambda.id]

  tags = {
    Name = "S3-Endpoint"
  }
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id            = aws_vpc.Terraform_Project_CBp.id
  service_name      = data.aws_vpc_endpoint_service.dynamodb.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private_Lambda.id]

  tags = {
    Name = "DynamoDB-Endpoint"
  }
}