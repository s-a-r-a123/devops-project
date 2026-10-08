#!/usr/bin/env bash

set -euo pipefail

PROJECT_NAME="cute-devops"

AWS_REGION="${AWS_REGION:-ap-southeast-2}"

GHCR_USERNAME="${GHCR_USERNAME:-}"
GHCR_TOKEN="${GHCR_TOKEN:-}"

GITHUB_USERNAME="${GITHUB_USERNAME:-$GHCR_USERNAME}"

IMAGE_NAME="${IMAGE_NAME:-cute-devops}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

GHCR_IMAGE="ghcr.io/${GHCR_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"

for command in docker git terraform aws
do
    if ! command -v "$command" >/dev/null 2>&1
    then
        echo "❌ $command is not installed."
        exit 1
    fi
done

aws sts get-caller-identity

if [[ -z "$GHCR_USERNAME" ]]
then
    read -rp "Enter your GitHub username: " GHCR_USERNAME

    GHCR_IMAGE="ghcr.io/${GHCR_USERNAME}/${IMAGE_NAME}:${IMAGE_TAG}"
fi

if [[ -z "$GHCR_TOKEN" ]]
then
    read -rsp "Enter your GitHub/GHCR token: " GHCR_TOKEN
    echo ""
fi

echo "$GHCR_TOKEN" | docker login ghcr.io \
    -u "$GHCR_USERNAME" \
    --password-stdin

docker build \
    -t "$GHCR_IMAGE" \

docker push "$GHCR_IMAGE"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1
then
    git init
    git branch -M main
fi

git add .

if ! git diff --cached --quiet
then
    git commit -m "Deploy cute DevOps infrastructure"
fi

if git remote get-url origin >/dev/null 2>&1
then
    git push -u origin main
else
    echo ""
    echo "❌ No GitHub remote configured."
    echo ""
    echo "Run:"
    echo ""
    echo "git remote add origin https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}.git"
    echo ""
    exit 1
fi

read -rp "Enter your EC2 key pair name: " EC2_KEY_NAME

export TF_VAR_key_name="$EC2_KEY_NAME"
export TF_VAR_aws_region="$AWS_REGION"
export TF_VAR_project_name="$PROJECT_NAME"
export TF_VAR_ghcr_image="$GHCR_IMAGE"

cd terraform

terraform init

terraform fmt

terraform validate

terraform plan

terraform apply -auto-approve

echo "$GHCR_IMAGE"

echo "Server 1:"
terraform output -raw server_1_url

echo "Server 2:"
terraform output -raw server_2_url

terraform output server_1_public_ip
terraform output server_2_public_ip
