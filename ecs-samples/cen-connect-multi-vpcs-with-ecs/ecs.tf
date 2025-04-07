
# 创建ECS实例
resource "alicloud_instance" "ecs" {
  for_each          = var.vpc_configs
  instance_name     = "${each.key}-ecs"
  image_id          = "ubuntu_18_04_64_20G_alibase_20190624.vhd"
  instance_type     = "ecs.e-c4m1.large"

  password          = var.ecs_password
  security_groups   = [alicloud_security_group.sg[each.key].id]
  vswitch_id        = values({ for k, v in alicloud_vswitch.vswitches : 
                             k => v.id if contains(split("-", k), each.key) })[0]
  
  system_disk_category = "cloud_essd"
  system_disk_size     = 20

  # 最佳实践：不分配公网IP，通过NAT网关访问
  internet_max_bandwidth_out = 0

  tags = {
    Environment = "Test"
    Network     = "Private"
  }
}