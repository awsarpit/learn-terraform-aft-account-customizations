resource "aws_cloudformation_stack_set" "ec2-deploy" {
  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }
  name = "ec2-deploy"

  parameters = {
    SubnetId = "subnet-08bb2534bb0f9b445",
    SecurityGroupIds = "sg-09532d763841e1a44",
    KeyName = "ap-south-1",
    ImageId = "ami-0d3f444bc76de0a79"
  }

  permission_model = "SERVICE_MANAGED"

  capabilities = ["CAPABILITY_IAM","CAPABILITY_NAMED_IAM","CAPABILITY_AUTO_EXPAND"]

  template_body = file("../templates/ec2.yml")
}

resource "aws_cloudformation_stack_set_instance" "ec2-deploy-instance" {
  deployment_targets     = {
    organizational_unit_ids = "ou-cjb1-2svsbfk4"
  }
  region         = "ap-south-1"
  stack_set_name = aws_cloudformation_stack_set.ec2-deploy.name
}



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

resource "aws_cloudformation_stack_set" "sqs-deploy" {
  administration_role_arn = aws_iam_role.AWSCloudFormationStackSetAdministrationRole.arn
  name = "sqs-deploy"

  parameters = {}

  template_body = file("../templates/sqs.yml")
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
