locals {
  dns_name               = "${join("", aws_efs_file_system.default.*.id)}.efs.${var.region}.amazonaws.com"
  security_group_enabled = var.security_group_enabled
}

resource "aws_efs_file_system" "default" {
  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )

  encrypted                       = var.encrypted
  kms_key_id                      = var.kms_key_id
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode

  dynamic "lifecycle_policy" {
    for_each = var.transition_to_ia == "" ? [] : [1]
    content {
      transition_to_ia = var.transition_to_ia
    }
  }
}

resource "aws_efs_mount_target" "default" {
  count          = length(var.subnets) > 0 ? length(var.subnets) : 0
  file_system_id = join("", aws_efs_file_system.default.*.id)
  ip_address     = var.mount_target_ip_address
  subnet_id      = var.subnets[count.index]
  security_groups = compact(
    sort(concat(
      [module.security_group.security_group_id],
      var.security_groups
    ))
  )
}

resource "aws_efs_access_point" "default" {
  for_each = var.access_points

  file_system_id = join("", aws_efs_file_system.default.*.id)

  posix_user {
    gid = var.access_points[each.key]["posix_user"]["gid"]
    uid = var.access_points[each.key]["posix_user"]["uid"]
    # Just returning null in the lookup function gives type errors and is not omitting the parameter, this work around ensures null is returned.
    secondary_gids = lookup(lookup(var.access_points[each.key], "posix_user", {}), "secondary_gids", null) == null ? null : null
  }

  root_directory {
    path = "/${each.key}"
    creation_info {
      owner_gid   = var.access_points[each.key]["creation_info"]["gid"]
      owner_uid   = var.access_points[each.key]["creation_info"]["uid"]
      permissions = var.access_points[each.key]["creation_info"]["permissions"]
    }
  }

  tags = var.tags
}

module "security_group" {
  source = "git::git@scm.capside.com:terraform/aws/terraform-aws-security-group.git?ref=ntt/1.0.0"

  name   = format("sec-%s", var.name)
  use_name_prefix = false
  
  vpc_id = var.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 2049
      to_port     = 2049
      protocol    = "tcp"
      description = "EFS incomming traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = "-1"
      description = "Allow all egress traffic"
    }
  ]

  tags = var.tags
}

