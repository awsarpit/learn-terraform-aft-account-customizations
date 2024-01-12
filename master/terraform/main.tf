resource "aws_cloudformation_stack_set" "ec2-deploy" {
  auto_deployment {
    enabled                          = true
    retain_stacks_on_account_removal = false
  }
  name = "ec2-deploy"

  parameters = {
    SubnetId = "",
    SecurityGroupIds = "",
    KeyName = "",
    ImageId = ""
  }

  permission_model = "SERVICE_MANAGED"
  
  capabilities = ["CAPABILITY_IAM","CAPABILITY_NAMED_IAM","CAPABILITY_AUTO_EXPAND"]

  template_body = file("../templates/ec2.yml")
}
