
#This file will deploy the basic version of ECS use case:
# 1. Creates 1 VPC
# 2. Creates 2 VSwitchs
# 3. Creates 1 security group with 2 rules
# 4. Creates 2 ECS instances

variable "region" {
  default = "eu-central-1"
}

provider "alicloud" {
  region = var.region
}

variable "instance_name" {
  default = "terraform-test"
}

variable "instance_type" {
  default = "ecs.e-c4m1.large"
}

data "alicloud_zones" "default" {
  available_disk_category     = "cloud_essd"
  available_resource_creation = "VSwitch"
  available_instance_type     = var.instance_type
}

resource "alicloud_vpc" "vpc" {
  vpc_name   = var.instance_name
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "vsw" {
  count        = 2
  vswitch_name = "vswitch-${count.index}"
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = cidrsubnet(alicloud_vpc.vpc.cidr_block, 8, count.index + 1)
  zone_id      = count.index == 0 ? "eu-central-1a" : "eu-central-1c"
}

resource "alicloud_security_group" "default" {
  security_group_name   = var.instance_name
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_security_group_rule" "http" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}

variable "image_id" {
  default = "ubuntu_18_04_64_20G_alibase_20190624.vhd"
}

variable "internet_bandwidth" {
  default = "10"
}

variable "password" {
  default = "Alibaba123"
}

variable "ecs_count" {
  default = 2
}

resource "alicloud_instance" "instances" {
  count                      = var.ecs_count
  instance_name              = "ecs-${count.index}"
  availability_zone          = count.index == 0 ? "eu-central-1a" : "eu-central-1c"
  
  password                   = var.password
  instance_type              = var.instance_type
  image_id                   = var.image_id

  system_disk_category       = "cloud_essd"
  system_disk_size           = 20 

  vswitch_id                 = element(alicloud_vswitch.vsw.*.id, count.index)
  security_groups            = [alicloud_security_group.default.id]
  internet_max_bandwidth_out = var.internet_bandwidth
}

output "VSWCount" {
  value = alicloud_vswitch.vsw.*.id
}