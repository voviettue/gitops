resource "aws_lightsail_instance" "instance" {
  name              = var.instance_name
  availability_zone = var.availability_zone
  blueprint_id      = var.instance_blueprint
  bundle_id         = var.instance_type
  key_pair_name     = aws_lightsail_key_pair.instance.name

  user_data = <<EOF
    #!/bin/bash
    echo 'eval "$(agent-ssh)"' >> ~/.bashrc
    sudo apt-get update -y
    sudo apt-get install -y nginx docker.io
    sudo usermod -aG docker $USER && newgrp docker
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    curl -s https://fluxcd.io/install.sh | sudo bash
    EOF

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = self.public_ip_address
    private_key = aws_lightsail_key_pair.instance.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "echo '${aws_lightsail_key_pair.instance.private_key}' > ~/.ssh/id_rsa",
      "chmod 400 ~/.ssh/id_rsa",
      "mkdir /home/ubuntu/playbooks",
    ]
  }
}

resource "aws_lightsail_instance_public_ports" "instance" {
  instance_name = aws_lightsail_instance.instance.name

  port_info {
    protocol  = "tcp"
    from_port = 9022
    to_port   = 9022
  }

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }
}

resource "aws_lightsail_static_ip" "instance" {
  name = "ip-${var.instance_name}"
}

resource "aws_lightsail_static_ip_attachment" "instance" {
  static_ip_name = aws_lightsail_static_ip.instance.id
  instance_name  = aws_lightsail_instance.instance.id
}

resource "aws_lightsail_key_pair" "instance" {
  name = "lg_${var.instance_name}"
}

resource "null_resource" "boot" {
  triggers = {
    manager_id = aws_lightsail_instance.instance.public_ip_address
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_lightsail_static_ip.instance.ip_address
    private_key = aws_lightsail_key_pair.instance.private_key
  }

  provisioner "file" {
    source      = "./nginx.conf"
    destination = "/home/ubuntu/default.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /home/ubuntu/default.conf /etc/nginx/nginx.conf",
      "minikube start --profile=${var.instance_name} --cpus=3 --memory=12g --disk-size=40g --addons merics-server --driver=docker",
      # "flux bootstrap gitlab --context=${var.instance_name} --owner=cate2/gigapress --path=clusters/${var.instance_name} --repository=gitops --branch=master --components-extra=image-reflector-controller,image-automation-controller"
    ]
  }
}
