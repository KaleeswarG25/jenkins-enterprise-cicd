#!/usr/bin/env bash
set -euo pipefail

: "${AWS_DEFAULT_REGION:?AWS_DEFAULT_REGION is required}"
: "${EKS_CLUSTER_NAME:?EKS_CLUSTER_NAME is required}"
: "${ECR_REPOSITORY_URI:?ECR_REPOSITORY_URI is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"

echo "Checking AWS identity..."
aws sts get-caller-identity

echo "Configuring kubectl..."
aws eks update-kubeconfig \
  --region "${AWS_DEFAULT_REGION}" \
  --name "${EKS_CLUSTER_NAME}"

echo "Checking EKS access..."
kubectl get nodes

echo "Checking pre-created namespace..."
kubectl get namespace cloudcart

IMAGE_URI="${ECR_REPOSITORY_URI}:${IMAGE_TAG}"

echo "Applying application Deployment with image ${IMAGE_URI}..."
sed "s|REPLACE_WITH_ECR_IMAGE|${IMAGE_URI}|g" \
  k8s/deployment.yaml | kubectl apply -f -

echo "Applying Service..."
kubectl apply -f k8s/service.yaml

echo "Waiting for rollout..."
kubectl rollout status deployment/cloudcart-api \
  --namespace cloudcart \
  --timeout=5m

kubectl get deployment,service,pods --namespace cloudcart
