resource "aws_iam_role" "mysql" {

  name = "${local.common_name}-mysql"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = merge(
    local.common_tags,
    {
      Name = "${local.common_name}-mysql"
    }
  )

}


resource "aws_iam_policy" "mysql" {

  name        = "${local.common_name}-mysql"
  description = "Mysql policy to accces the root password from aws parameter"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "GetMysqlPassword"
        Effect   = "Allow"
        Action   = "ssm:GetParameter"
        Resource = "arn:aws:ssm:us-east-1:608470589610:parameter/roboshop/${var.environment}/mysql_root_password"
      },
      {
        Sid      = "DescribeParameters"
        Effect   = "Allow"
        Action   = "ssm:DescribeParameters"
        Resource = "*"
      },
      {
        Sid      = "DecryptSecureString"
        Effect   = "Allow"
        Action   = "kms:Decrypt"
        Resource = "*"
      }
    ]
  })

}

resource "aws_iam_role_policy_attachment" "mysql" {

  role       = aws_iam_role.mysql.name
  policy_arn = aws_iam_policy.mysql.arn

}

resource "aws_iam_instance_profile" "mysql" {

  name = "${local.common_name}-mysql"
  role = aws_iam_role.mysql.name
}
