
resource "aws_instance" "web_1" {

  ami = "ami-020728ad6199d7fa0"

  instance_type = var.instance_type

  subnet_id = aws_subnet.public_1.id

  key_name = var.key_name

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data = templatefile(
    "${path.module}/userdata.sh",
    {
      ghcr_image = var.ghcr_image
      server_name = "Server 1"
    }
  )

  user_data_replace_on_change = true

  tags = {
    Name    = "${var.project_name}-server-1"
    Server  = "web-1"
    Project = var.project_name
  }
}

resource "aws_instance" "web_2" {

  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  subnet_id = aws_subnet.public_2.id

  key_name = var.key_name

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data = templatefile(
    "${path.module}/userdata.sh",
    {
      ghcr_image = var.ghcr_image
      server_name = "Server 2"
    }
  )

  user_data_replace_on_change = true

  tags = {
    Name    = "${var.project_name}-server-2"
    Server  = "web-2"
    Project = var.project_name
  }
}