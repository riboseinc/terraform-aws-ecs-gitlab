# AWS GitLab Deployment

## Authentication

Create a profile in `~/.aws/credentials`, eg:
```
[ribose]
aws_access_key_id = AKIA***
aws_secret_access_key = n3**b
```

## Terraform Usage

```
export AWS_PROFILE="ribose"
export AWS_DEFAULT_REGION="eu-west-1"
terraform plan
```

## Troubleshooting

In order to spin up a test EC2 instance and check the system, you can define a terraform variable `test=true`
