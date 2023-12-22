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
resource "aws_lb_target_group_attachment" "attach-app-servers" {
  ##this resourceneed to be itreated multiple times
  count = length(aws_instance.ec2demo)
  target_group_arn = aws_lb_target_group.front-lb.arn
  ###now this target group need to be iterated
  target_id = element(aws_instance.ec2demo.*.id,count.index)
  port = 80
}
##before we create the lb we need to create a listener

###create teh load balancer