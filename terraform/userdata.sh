#!/bin/bash

set -e

exec > >(tee /var/log/userdata.log | logger -t user-data -s 2>/dev/console) 2>&1

apt-get update -y
apt-get upgrade -y

apt-get install -y docker.io

systemctl enable docker
systemctl start docker

usermod -aG docker ubuntu || true

until docker info >/dev/null 2>&1
do
    sleep 2
done

docker pull "${ghcr_image}"

docker rm -f devops-project 2>/dev/null || true

docker run -d \
    --name devops-project \
    --restart unless-stopped \
    -p 80:80 \
    "${ghcr_image}"

sleep 5

docker ps