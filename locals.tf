locals {
  default_tags = {
    env   = "${var.environment}"
    stack = "${var.stack}"
  }

  name_prefix = "${var.name_prefix != "" ? "${var.name_prefix}-" : ""}"

  server_name = "${coalesce(var.custom_name, "${local.name_prefix}${var.stack}-${var.client_name}-${var.location_short}-${var.environment}-sql")}"
}
