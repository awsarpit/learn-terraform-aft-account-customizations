data "aws_iam_policy_document" "AWSCloudFormationStackSetAdministrationRole_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      identifiers = ["cloudformation.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "AWSCloudFormationStackSetAdministrationRole" {
  assume_role_policy = data.aws_iam_policy_document.AWSCloudFormationStackSetAdministrationRole_assume_role_policy.json
  name               = "AWSCloudFormationStackSetAdministrationRole"
}

resource "aws_cloudformation_stack_set" "ec2-deploy" {
  administration_role_arn = aws_iam_role.AWSCloudFormationStackSetAdministrationRole.arn
  auto_deployment = {
    enabled = true
  }
  name = "ec2-deploy"

  parameters = {
    SubnetId = "",
    SecurityGroupIds = "",
    KeyName = "",
    ImageId = ""
  }

  template_body = file("../templates/ec2.yml")
}

data "aws_iam_policy_document" "AWSCloudFormationStackSetAdministrationRole_ExecutionPolicy" {
  statement {
    actions   = ["sts:AssumeRole"]
    effect    = "Allow"
    resources = ["arn:aws:iam::*:role/${aws_cloudformation_stack_set.ec2-deploy.execution_role_name}"]
  }
}

resource "aws_iam_role_policy" "AWSCloudFormationStackSetAdministrationRole_ExecutionPolicy" {
  name   = "ExecutionPolicy"
  policy = data.aws_iam_policy_document.AWSCloudFormationStackSetAdministrationRole_ExecutionPolicy.json
  role   = aws_iam_role.AWSCloudFormationStackSetAdministrationRole.name
}

