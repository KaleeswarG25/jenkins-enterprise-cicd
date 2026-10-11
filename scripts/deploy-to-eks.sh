#!/usr/bin/env bash
set -euo pipefail

: "${AWS_DEFAULT_REGION:?AWS_DEFAULT_REGION is required}"
: "${EKS_CLUSTER_NAME:?EKS_CLUSTER_NAME is required}"
: "${ECR_REPOSITORY_URI:?ECR_REPOSITORY_URI is required}"
: "${IMAGE_TAG:?IMAGE_TAG is required}"

aws sts get-caller-identity

aws eks update-kubeconfig \
  --region "${AWS_DEFAULT_REGION}" \
  --name "${EKS_CLUSTER_NAME}"

kubectl get nodes

kubectl create namespace cloudcart \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f k8s/service.yaml

kubectl set image deployment/cloudcart-api \
  cloudcart-api="${ECR_REPOSITORY_URI}:${IMAGE_TAG}" \
  --namespace cloudcart

kubectl rollout status deployment/cloudcart-api \
  --namespace cloudcart \
  --timeout=5m

kubectl get deployment,service,pods --namespace cloudcart
