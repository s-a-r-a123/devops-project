resource "aws_iam_role" "ec2_ghcr" {
  name = "${var.project_name}-ec2-ghcr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "read_ghcr_secret" {
  name = "${var.project_name}-read-ghcr-secret"
  role = aws_iam_role.ec2_ghcr.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:ghcr-read-token-*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_ghcr" {
  name = "${var.project_name}-ec2-ghcr-profile"
  role = aws_iam_role.ec2_ghcr.name
}

resource "aws_instance" "web_1" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.public_1.id
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_ghcr.name

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data = templatefile(
    "${path.module}/userdata.sh",
    {
      ghcr_image  = var.ghcr_image
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
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_type
  subnet_id            = aws_subnet.public_2.id
  key_name             = var.key_name
  iam_instance_profile = aws_iam_instance_profile.ec2_ghcr.name

  vpc_security_group_ids = [
    aws_security_group.web.id
  ]

  user_data = templatefile(
    "${path.module}/userdata.sh",
    {
      ghcr_image  = var.ghcr_image
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