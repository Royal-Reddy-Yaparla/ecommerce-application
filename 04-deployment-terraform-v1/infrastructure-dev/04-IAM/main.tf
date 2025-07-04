# IAM Role for EC2 to access SSM Parameter Store
resource "aws_iam_role" "access_mysql_creds" {
  name = "EcomMysqlCredentialAccess"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project}-${var.environment}-${var.role_name}"
    }
  )
}

# IAM Role Policy to access specific SSM parameters
resource "aws_iam_role_policy" "access_ssm_mysql_password" {
  name = "AllowSSMMySQLCreds"
  role = aws_iam_role.access_mysql_creds.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:DescribeParameters"
        ]
        Resource = "arn:aws:ssm:us-east-1:801333664304:parameter/ecom/dev/mysql/mysql_root_password"
      }
    ]
  })
}

# Instance profile for EC2 to use the IAM role
resource "aws_iam_instance_profile" "mysql_profile" {
  name = "EcomMysqlCredentialAccess" # Must match what you use in EC2
  role = aws_iam_role.access_mysql_creds.name
}
