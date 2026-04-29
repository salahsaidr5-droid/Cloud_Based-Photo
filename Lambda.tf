# Archive Lambda Code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "index.py"
  output_path = "lambda_function.zip"
}

# Lambda Function
resource "aws_lambda_function" "project_lambda" {
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "ProjectProcessor"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  vpc_config {
    subnet_ids         = [aws_subnet.Lambda.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.project_bucket.id
      TABLE_NAME  = aws_dynamodb_table.project_table.name
      DOMAIN_NAME = aws_cloudfront_distribution.s3_distribution.domain_name
    }
  }

  tags = {
    Name = "Project_Lambda"
  }
}