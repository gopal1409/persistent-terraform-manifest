resource "aws_security_group" "alb_security_group" {
  name        = "${var.environment}-alb-security-group"
  description = "allow-alb-sg"
  vpc_id      = aws_vpc.vpc.id 

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.environment}-alb-security-group"
  }
}

resource "aws_security_group" "asg_security_group" {
  name        = "${var.environment}-asg-security-group"
  description = "allow-asg-sg"
  vpc_id      = aws_vpc.vpc.id 

  ingress {
    description      = "HTTP from ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups = [aws_security_group.alb_security_group.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.environment}-asg-security-group"
  }
}