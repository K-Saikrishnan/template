variable "gh_token" {
  description = "GitHub PAT"
  type        = string
  sensitive   = true
}

variable "docker_hub_user" {
  description = "Docker Hub User"
  type        = string
  sensitive   = true
}

variable "docker_hub_pat" {
  description = "Docker Hub PAT"
  type        = string
  sensitive   = true
}
