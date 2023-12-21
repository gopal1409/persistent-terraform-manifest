resource "aws_instance" "ec2demo" {

  ami                    = data.aws_ami.amzlinux2.id 
  ###instance type is like hardocding the instance. we need to make our code readable standardized
  ##to call a variable var  name of the variables
  instance_type          = var.instance_type
  #vpc_security_group_ids = [aws_security_group.sg-webserver.id]
  subnet_id              = "subnet-09f995142f08515ea"
  user_data              = file("${path.module}/app/app.sh")
  vpc_security_group_ids = [ aws_security_group.allow_http.id ]
  associate_public_ip_address = true
  tags = {
    Name = "myec2-instance"
  }
}
#ate one sg inside that i wantt to add multiple rule
##the above bnlock will create the ec2 instance in aws. 
###once create the refrence to the ec2 instance is stored in terraform.tfstate file. 
