###lets crete an alb
resource "aws_alb" "alb" {
  name = "${var.environment}-alb"
  internal = false 
  load_balancer_type = "application"
  security_groups = [aws_security_group.alb_security_group.id]
  subnets = [ for i in aws_subnet.public_subnet : i.id ]

  tags = {
    Name = "${var.environment}-alb"
  }
}

##create the target group 
resource "aws_alb_target_group" "target_group" {
  name = "${var.environment}-alb-targetgrp"
  port = 80 
  protocol = "HTTP"
  vpc_id = aws_vpc.vpc.id 
  health_check {
    path = "/"
    matcher = 200 
  }
  tags = {
    Name = "${var.environment}-alb-target-grp"
  }
}

##FINALLY WE WILL CREATE THE LISTENER
resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_alb.alb.arn 
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.target_group.arn 
  }
  tags = {
    Name = "${var.environment}-alb-listener"
  }
}