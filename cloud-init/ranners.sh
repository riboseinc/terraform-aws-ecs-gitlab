#!/bin/bash -x

yum update -y
yum install -y docker

curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.rpm.sh | sudo bash
yum install -y gitlab-runner

chkconfig docker on
chkconfig gitlab-runner on
service docker start

mkdir -p /etc/gitlab-runner
cat > /etc/gitlab-runner/config.toml <<- EOM
concurrent = ${GITLAB_CONCURRENT_JOB}
check_interval = ${GITLAB_CHECK_INTERVAL}
EOM

gitlab-runner register --non-interactive \
                       --name `hostname` \
                       --url "${GITLAB_RUNNER_URL}" \
                       --registration-token "${GITLAB_RUNNER_TOKEN}" \
                       --run-untagged \
                       --docker-image "${GITLAB_IMAGE}" \
                       --leave-runner \
                       --cache-type s3 \
                       --cache-s3-bucket-name "${GITLAB_CACHE_BUCKET_NAME}" \
                       --cache-s3-bucket-location "${REGION}" \
                       --cache-s3-cache-path "/" \
                       --cache-cache-shared \
                       --executor docker