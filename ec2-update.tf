###in the particular region find out all the az is allowed to me
data "aws_availability_zones" "my_az" {
  filter {
    name = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}
###there will be multiple values this is like an list of values. 
#once we get the list of value
resource "aws_instance" "ec2demo" {
  count                  = length(var.subnet_cidr_private)
  ami                    = data.aws_ami.amzlinux2.id 
  ###instance type is like hardocding the instance. we need to make our code readable standardized
  ##to call a variable var  name of the variables
  instance_type          = var.instance_type
  #vpc_security_group_ids = [aws_security_group.sg-webserver.id]
  subnet_id              = element(aws_subnet.private.*.id, count.index)
  user_data              = file("${path.module}/app/app.sh")
  vpc_security_group_ids = [ aws_security_group.allow_http.id ]
  ###refrence=resource+resourcelabel.id 
  associate_public_ip_address = true
  #for_each = toset(data.aws_availability_zones.my_az.names)
  #availability_zone = each.key
  tags = {
     Name = "app-server-${count.index + 1}"
  }
}
#ate one sg inside that i wantt to add multiple rule
##the above bnlock will create the ec2 instance in aws. 
###once create the refrence to the ec2 instance is stored in terraform.tfstate file. 
