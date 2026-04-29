#S3 Bucket
resource "aws_s3_bucket" "project_bucket" {
  bucket = "salah-project-storage-2026"

  tags = {
    Name = "Project_Bucket"
  }
}

#S3 Public Access Block
resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.project_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#DynamoDB Table
resource "aws_dynamodb_table" "project_table" {
  name           = "ProjectData"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ID"

  attribute {
    name = "ID"
    type = "S"
  }

  tags = {
    Name = "Project_Table"
  }
}