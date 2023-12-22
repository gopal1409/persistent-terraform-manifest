resource "aws_launch_template" "autoscaling-template" {
  name = "my-launch-template"
  description = "MY launch template"
  image_id =  data.aws_ami.amzlinux2.id 
  instance_type = var.instance_type

  vpc_security_group_ids = [ aws_security_group.allow_http.id ]
  user_data = filebase64("${path.module}/app/app.sh")
  ebs_optimized = true 

  monitoring {
    enabled = true 
  }
  update_default_version = true 
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = 20 
      delete_on_termination = true 
      volume_type = "gp2"
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "myasg"
    }
  }
}