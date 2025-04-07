# 创建VPC和vSwitch
resource "alicloud_vpc" "main" {
  for_each    = var.vpc_configs
  vpc_name    = "${each.key}-vpc"
  cidr_block  = each.value.cidr
}

resource "alicloud_vswitch" "vswitches" {
  for_each     = { for idx, config in flatten([for k, v in var.vpc_configs : [
                   for i, cidr in v.vsw_cidrs : {
                     key = "${k}-vsw${i}"
                     vpc_key = k
                     cidr = cidr
                     zone = v.zones[i]
                   }
                 ]]) : config.key => config }
  vswitch_name = each.key
  vpc_id       = alicloud_vpc.main[each.value.vpc_key].id
  cidr_block   = each.value.cidr
  zone_id      = each.value.zone
}

# 创建安全组（遵循最小权限原则）
resource "alicloud_security_group" "sg" {
  for_each                   = var.vpc_configs
  security_group_name        = "${each.key}-sg"
  vpc_id                     = alicloud_vpc.main[each.key].id
}

resource "alicloud_security_group_rule" "ingress" {
  for_each          = alicloud_security_group.sg
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = each.value.id
  cidr_ip           = "0.0.0.0/0" # 生产环境应限制为管理IP段
}

resource "alicloud_security_group_rule" "icmp" {
  for_each          = alicloud_security_group.sg
  type              = "ingress"
  ip_protocol       = "icmp"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = each.value.id
  cidr_ip           = "0.0.0.0/0"
}