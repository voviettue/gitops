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
    sudo apt-get install -y nginx virtualbox
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo install minikube-linux-amd64 /usr/local/bin/minikube
    EOF

  connection {
    type     = "ssh"
    user     = "ubuntu"
    host     = self.public_ip_address
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
}

resource "aws_lightsail_static_ip" "instance" {
  name = "${var.instance_name}"
}

resource "aws_lightsail_static_ip_attachment" "instance" {
  static_ip_name = aws_lightsail_static_ip.instance.id
  instance_name  = aws_lightsail_instance.instance.id
}

resource "aws_lightsail_key_pair" "instance" {
  name = "${var.instance_name}"
}

resource "null_resource" "boot" {
  triggers = {
    manager_id = aws_lightsail_instance.instance.public_ip_address
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    host        = aws_lightsail_static_ip.instance.public_ip
    private_key = aws_lightsail_key_pair.instance.private_key
  }

  provisioner "file" {
    source      = "./nginx.conf"
    destination = "/home/ubuntu/default.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /home/ubuntu/default.conf /etc/nginx/conf.d/default.conf"
      "sudo minikube start --profile ${var.instance_name} --cpu 3 --memory 12g --disk-size 40g --adons merics-server",
      "flux bootstrap gitlab --driver=virtualbox --owner=cate2/gigapress --repository=gitops --branch=master --context=${var.instance_name} --path=clusters/${var.instance_name}"
    ]
  }
}
