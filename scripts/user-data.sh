#!/bin/bash

stop ecs
yum update -y
yum install -y nfs-utils aws-cli
mkdir /efs
echo '${efs_address}:/ /efs nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0' >>  /etc/fstab
echo ECS_CLUSTER=${ecs_cluster} >> /etc/ecs/ecs.config
mount -a
service docker restart
start ecs
