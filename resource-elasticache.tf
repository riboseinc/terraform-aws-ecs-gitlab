resource "aws_elasticache_subnet_group" "main" {
  name       = "${var.prefix}"
  subnet_ids = ["${var.subnets}"]
}

resource "aws_elasticache_cluster" "main" {
  engine            = "redis"
  engine_version    = "${var.elasticache["version"]}"
  port              = 6379
  cluster_id        = "${var.prefix}"
  node_type         = "${var.elasticache["node_type"]}"
  num_cache_nodes   = 1
  subnet_group_name = "${aws_elasticache_subnet_group.main.name}"

  security_group_ids = [
    "${aws_security_group.allow_all_egress.id}",
    "${aws_security_group.allow_redis.id}",
  ]
}
