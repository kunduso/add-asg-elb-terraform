#https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log
resource "aws_flow_log" "network_flow_logging" {
  iam_role_arn    = aws_iam_role.vpc_flow_log_role.arn
  log_destination = aws_cloudwatch_log_group.network_flow_logging.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id
}

resource "aws_cloudwatch_log_group" "network_flow_logging" {
  name = "${var.name}-vpc-flow-logs"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "vpc_flow_log_role" {
  name               = "${var.name}-vpc-flow-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "vpc_flow_log_policy_document" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]
    resources = [aws_cloudwatch_log_group.network_flow_logging.arn]
  }
}

resource "aws_iam_role_policy" "vpc_flow_log_role_policy" {
  name   = "${var.name}-vpc-flow-policy"
  role   = aws_iam_role.vpc_flow_log_role.id
  policy = data.aws_iam_policy_document.vpc_flow_log_policy_document.json
}