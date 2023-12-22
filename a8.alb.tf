##how to deploy an alb in aws. 
##first we will create the target group
resource "aws_lb_target_group" "front-lb" {
  name     = "tf-example-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.this.id
  health_check {
    enabled = true 
    healthy_threshold = 3 
    interval = 10 
    matcher = 200 
    path = "/"
    protocol = "HTTP"
    timeout = 3 
    unhealthy_threshold = 2
  }
}






####attach all the instance behind the target group

##before we create the lb we need to create a listener

###create teh load balancer