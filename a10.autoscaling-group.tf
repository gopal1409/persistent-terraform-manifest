resource "aws_autoscaling_group" "bar" {
  name                      = "autoscaling-terraform-group"
  max_size                  = 4
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  vpc_zone_identifier = [for subnet in aws_subnet.private : subnet.id]
  target_group_arns = [ aws_lb_target_group.front-lb.arn ]
  force_delete              = true
  launch_template {
    id = aws_launch_template.autoscaling-template.id 
    version = aws_launch_template.autoscaling-template.latest_version
  }
}