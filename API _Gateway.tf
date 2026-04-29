resource "aws_api_gateway_rest_api" "project_api" {
  name        = "ProjectAPI"
  description = "API Gateway for Lambda Integration"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.project_api.id
  parent_id   = aws_api_gateway_rest_api.project_api.root_resource_id
  path_part   = "data"
}

resource "aws_api_gateway_method" "proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.project_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.project_api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.proxy_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.project_lambda.invoke_arn
}

resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.project_api.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id = aws_api_gateway_rest_api.project_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_method.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = jsonencode({ statusCode = 200 })
  }
}

resource "aws_api_gateway_method_response" "options_200" {
  rest_api_id = aws_api_gateway_rest_api.project_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.project_api.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_200.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.project_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.project_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "project_deploy" {
  depends_on  = [aws_api_gateway_integration.lambda_integration, aws_api_gateway_integration.options_integration]
  rest_api_id = aws_api_gateway_rest_api.project_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.proxy.id,
      aws_api_gateway_method.proxy_method.id,
      aws_api_gateway_integration.lambda_integration.id,
      aws_api_gateway_method.options_method.id,
      aws_api_gateway_integration.options_integration.id
    ]))
  }
}

resource "aws_api_gateway_stage" "project_stage" {
  deployment_id = aws_api_gateway_deployment.project_deploy.id
  rest_api_id   = aws_api_gateway_rest_api.project_api.id
  stage_name    = "prod"
}

output "api_url" {
  value = "${aws_api_gateway_stage.project_stage.invoke_url}/data"
}