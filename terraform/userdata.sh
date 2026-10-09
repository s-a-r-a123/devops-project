
#!/bin/bash

set -euo pipefail

exec > >(tee /var/log/userdata.log | logger -t user-data -s 2>/dev/console) 2>&1

export AWS_DEFAULT_REGION="ap-southeast-2"

apt-get update -y
apt-get install -y docker.io awscli jq

systemctl enable --now docker

until docker info >/dev/null 2>&1
do
    sleep 2
done

SECRET_JSON="$(aws secretsmanager get-secret-value \
    --secret-id ghcr-read-token \
    --query SecretString \
    --output text)"

GHCR_USER="$(printf '%s' "$SECRET_JSON" | jq -er '.username')"
GHCR_TOKEN="$(printf '%s' "$SECRET_JSON" | jq -er '.token')"

printf '%s' "$GHCR_TOKEN" | docker login ghcr.io \
    --username "$GHCR_USER" \
    --password-stdin

unset GHCR_TOKEN SECRET_JSON

docker pull "${ghcr_image}"

docker rm -f devops-project 2>/dev/null || true

docker run -d \
    --name devops-project \
    --restart unless-stopped \
    -p 80:80 \
    "${ghcr_image}"

docker logout ghcr.io
docker ps
