resource "aws_instance" "ec2demo" {
  ami = "ami-079db87dc4c10ac91"
  instance_type = "t2.micro"
  subnet_id = "subnet-09f995142f08515ea"
}