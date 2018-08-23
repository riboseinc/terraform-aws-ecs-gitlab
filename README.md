# AWS GitLab Deployment

## Authentication

Create a profile in `~/.aws/credentials`, eg:
```
[ribose]
aws_access_key_id = AKIA***
aws_secret_access_key = n3**b
```

## Terraform Usage

Take a look at [variables](vars.tf) before proceed further

```
export AWS_PROFILE="ribose"
export AWS_DEFAULT_REGION="eu-west-1"
terraform init
terraform apply
```
