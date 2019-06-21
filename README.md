## Terraform module to setup Gitlab ECS task

This module helps you create Gitlab ECS task service and the related task role, assuming that:

* you have created a ECS cluster
* you have created a VPC
* you have created primary subnet and secondary subnet for VPC
* you have created a SSL certificate for external ELB
* and of course, your AWS account provides you access to all these resources necessary.

## Terraform Usage

```
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_DEFAULT_REGION="us-west-1"
terraform init
terraform apply
```

## Sample Usage

You can literally copy and paste the following example, change the following attributes, and you're ready to go:

#### Variables

* `gitlab_domain`: application domain name
* `prefix`: Prefix for resource names
* `aws_ecs_cluster_id`: Arn of your ECS cluster
* `vpc_id`: ID of your VPC
* `subnets`: A list of subnets' IDs in the VPC. Minimum 2 subnets should be given
* `certificate_self_signed`: Self signed certificate can be generated. Boolean. If false `certificate_arn` should be set
* `certificate_arn`: Arn of your SSL certificate. Should be set if certificate_self_signed is false

#### Outputs

* `gitlab_root_password`: initially created password for the root user
* `gitlab_web_endpoint`: GitLab URL

```hcl
# include this module and enter the values of input variables
module "ecs-gitlab" {
  source              = "riboseinc/ecs-gitlab/aws"
  gitlab_domain       = "gitlab.example.com"
  prefix              = "ribose"
  aws_ecs_cluster_id  = "arn:..."
  vpc_id              = "vpc-1234567"
  subnets             = ["subnet-1234567","subnet-7654321"]
  certificate_arn     = "arn:..."
}

output "Root_Password" {
  value = module.ecs-gitlab.gitlab_root_password
}

output "Gitlab_Address" {
  value = module.ecs-gitlab.gitlab_web_endpoint
}
```
