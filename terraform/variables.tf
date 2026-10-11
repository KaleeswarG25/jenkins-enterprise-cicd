variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project naming prefix"
  type        = string
  default     = "cloudcart"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Use dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "VPC address range"
  type        = string
  default     = "10.20.0.0/16"
}

variable "cluster_version" {
  description = "Kubernetes version supported by EKS in the chosen region"
  type        = string
  default     = "1.33"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "desired_nodes" {
  type    = number
  default = 2
}

variable "min_nodes" {
  type    = number
  default = 1
}

variable "max_nodes" {
  type    = number
  default = 3
}

variable "jenkins_role_arn" {
  description = "Optional IAM role ARN used by Jenkins for EKS deployment access"
  type        = string
  default     = ""
}
