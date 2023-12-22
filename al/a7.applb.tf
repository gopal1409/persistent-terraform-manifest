###we need to create a lb
###create target group
resource "aws_lb_target_group" "front" {
  name = "appliccation-front"
  port = 80
  protocol = "HTTP"
  vpc_id = aws_vpc.this.id 
  health_check {
    enabled = true 
    healthy_threshold = 3
    interval = 10   
    matcher = 200 
    path = "/"
    port = "traffic-port"
    protocol = "HTTP"
    timeout = 3
    unhealthy_threshold = 2
  }
}
###attach the target group
resource "aws_lb_target_group_attachment" "attach-app1" {
    ###we are finding how many instance 2 instance are there
  count = length(aws_instance.ec2demo)
  target_group_arn = aws_lb_target_group.front.arn 
  ##3attaching the same with my target id using element
  target_id = element(aws_instance.ec2demo.*.id,count.index)
  port = 80
}
##listnet
resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front.arn 
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.front.arn
  }
}

resource "aws_lb" "front" {
  name = "front"
  internal = false 
  load_balancer_type = "application"
  security_groups = [aws_security_group.allow_http.id]
  subnets = [for subnet in aws_subnet.private : subnet.id]
  enable_deletion_protection = false 
}
##create lb