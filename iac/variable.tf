variable "region" {
  default = "eu-north-1"
  type    = string
}

variable "availability_zone" {
  default = "eu-north-1a"
  type    = string
}

variable "instance_name" {
  default = "cluster-manager"
  type    = string
}

variable "instance_blueprint" {
  default = "xlarge_2_3"
  type    = string
}

variable "instance_type" {
  default = "ubuntu_20_04"
  type    = string
}

