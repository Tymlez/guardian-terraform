variable "hash_script" {
  description = "Path to script to generate hash of source contents"
  type        = string
  default     = ""
}

variable "push_script" {
  description = "Path to script to build and push Docker image"
  type        = string
  default     = ""
}

#variable "image_name" {
#  description = "Name of Docker image"
#  type        = string
#}
#
variable "source_path" {
  description = "Path to Docker image source"
  type        = string
  default     = "./modules/guardian"
}

variable "tag" {
  description = "Tag to use for deployed Docker image"
  type        = string
  default     = "latest"
}

variable "docker_compose_cmd" {
  description = "Your docker compose command based on version installed (docker-compose vs docker compose)"
  type        = string
  default     = "docker-compose"
}

variable "docker_hub_username" {
  description = "Your docker hub username"
  type        = string
}

variable "docker_hub_password" {
  description = "Your docker hub username"
  type        = string
}

variable "docker_hub_repository" {
   description  = "Your docker hub repository"
    type        = string
}