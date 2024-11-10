data "aws_caller_identity" "current" {}
locals {
  principal_root_arn     = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  principal_logs_arn     = "logs.${var.region}.amazonaws.com"
  vpc_flow_log_group_arn = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/${var.name}-vpc-flow-logs"
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key
resource "aws_kms_key" "custom_kms_key" {
  description             = "KMS key for ${var.name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias
resource "aws_kms_alias" "key" {
  name          = "alias/${var.name}"
  target_key_id = aws_kms_key.custom_kms_key.id
}
#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key_policy
resource "aws_kms_key_policy" "encrypt_app" {
  key_id = aws_kms_key.custom_kms_key.id
  policy = jsonencode({
    Id = "${var.name}-encryption-rest"
    Statement = [
      {
        Action = "kms:*"
        Effect = "Allow"
        Principal = {
          AWS = "${local.principal_root_arn}"
        }
        Resource = "*"
        Sid      = "Enable IAM User Permissions"
      },
      {
        Effect : "Allow",
        Principal : {
          Service : "${local.principal_logs_arn}"
        },
        Action : [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ],
        Resource : "*",
        Condition : {
          ArnEquals : {
            "kms:EncryptionContext:aws:logs:arn" : [local.vpc_flow_log_group_arn]
          }
        }
      }
    ]
    Version = "2012-10-17"
  })
}