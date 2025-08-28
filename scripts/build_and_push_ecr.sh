#!/usr/bin/env bash
set -euo pipefail

AWS_REGION="us-east-1"
APPS=(app-1 app-2 app-3)

TAG="${1:-$(git rev-parse --short HEAD 2>/dev/null || date +%Y%m%d%H%M%S)}"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
ECR="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "Region: ${AWS_REGION}  Account: ${ACCOUNT_ID}  Tag: ${TAG}"

# Login to ECR
aws ecr get-login-password --region "$AWS_REGION" \
| docker login --username AWS --password-stdin "$ECR"

# Build and push each app
for app in "${APPS[@]}"; do
  APP_DIR="apps/${app}"
  REPO_URI="${ECR}/${app}"

  if [[ ! -f "${APP_DIR}/Dockerfile" ]]; then
    echo "Skip ${app}: no Dockerfile in ${APP_DIR}"
    continue
  fi

  # Make sure repo exists
  aws ecr describe-repositories --region "$AWS_REGION" --repository-names "$app" >/dev/null 2>&1 \
    || { echo "ECR repo ${app} missing — run Terraform."; exit 1; }

  echo "=== Building $app -> $REPO_URI:$TAG ==="
  docker build -t "$REPO_URI:$TAG" "$APP_DIR"
  docker tag "$REPO_URI:$TAG" "$REPO_URI:latest"

  docker push "$REPO_URI:$TAG"
  docker push "$REPO_URI:latest"
done

echo "Done. Use tag: $TAG in your K8s manifests."
