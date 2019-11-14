variable "public_key" {
  type        = "string"
  description = "Public key will be added to Jenkins instance ~/.ssh/authorized_keys"
}

variable "web-server-sg-ingress-ssh-cidr_blocks" {
  type    = list
  default = ["0.0.0.0/0"]
}

variable "web-server-sg-ingress-http-cidr_blocks" {
  type    = list
  default = ["0.0.0.0/0"]
}
