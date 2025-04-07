terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = ">=1.209.0"
    }
  }
}

provider "alicloud" {
  region = "eu-central-1"
}

# define a dict of vpc configurations
variable "vpc_configs" {
  default = {
    vpc1 = {
      cidr        = "10.1.0.0/16"
      vsw_cidrs   = ["10.1.1.0/24", "10.1.2.0/24"]
      zones       = ["eu-central-1a", "eu-central-1c"]
      ecs_zone    = "eu-central-1a"
    }
    vpc2 = {
      cidr        = "10.2.0.0/16"
      vsw_cidrs   = ["10.2.1.0/24", "10.2.2.0/24"]
      zones       = ["eu-central-1a", "eu-central-1c"]
      ecs_zone    = "eu-central-1c"
    }
  }
}

variable "ecs_password" {
  default = "Alibaba123"
}