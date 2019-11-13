provider "aws" {}

resource "aws_security_group" "web-server-sg" {
  name        = "WebServerSG"
  description = "Allow ssh (port 22) and http (port 8080)"

  ingress {
    # ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] #TODO make configurable & safer
  }

  ingress {
    # http port 8080
    from_port = 8080
    to_port   = 8080
  }
}
