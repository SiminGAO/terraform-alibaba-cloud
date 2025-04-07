# 创建CEN并连接VPC
resource "alicloud_cen_instance" "main" {
  cen_instance_name = "multi-vpc-cen"
}

resource "alicloud_cen_transit_router" "tr" {
  cen_id = alicloud_cen_instance.main.id
}

resource "alicloud_cen_transit_router_vpc_attachment" "vpc_attach" {
  for_each = alicloud_vpc.main
  transit_router_id = alicloud_cen_transit_router.tr.transit_router_id
  vpc_id            = each.value.id
  zone_mappings {
    zone_id    = var.vpc_configs[each.key].zones[0]
    vswitch_id = [for vsw in alicloud_vswitch.vswitches : vsw.id if vsw.vpc_id == each.value.id][0]
  }
  zone_mappings {
    zone_id    = var.vpc_configs[each.key].zones[1]
    vswitch_id = [for vsw in alicloud_vswitch.vswitches : vsw.id if vsw.vpc_id == each.value.id][1]
  }
}

# 输出重要信息
output "cen_id" {
  value = alicloud_cen_instance.main.id
}

output "ecs_private_ips" {
  value = {
    for k, v in alicloud_instance.ecs : k => v.private_ip
  }
}
