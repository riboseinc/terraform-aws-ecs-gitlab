#!/bin/bash
aws ec2 describe-instances \
  --filter  "Name=tag:created-by,Values=gitlab-ci-runners" \
            "Name=instance-state-code,Values=0,16,32,65,80" \
  --query 'Reservations[].Instances[].[InstanceId]' \
  --output text | \

  while read line; do
      aws ec2 terminate-instances --instance-ids $line
  done
