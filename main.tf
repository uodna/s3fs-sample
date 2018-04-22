provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "main" {
  cidr_block       = "10.1.0.0/16"
  enable_dns_hostnames = "true"

  tags {
    Name = "main"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.main.id}"

  tags {
    Name = "main"
  }
}

resource "aws_route_table" "r" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "main"
  }
}

resource "aws_subnet" "main_a" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.1.0.0/24"
  map_public_ip_on_launch = "true"

  tags {
    Name = "main_a"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = "${aws_subnet.main_a.id}"
  route_table_id = "${aws_route_table.r.id}"
}

data "aws_ami" "centos6" {
  most_recent = true

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  name_regex = "^CentOS Linux 6"
  owners = ["679593333241"]
}

resource "aws_instance" "web" {
  ami           = "${data.aws_ami.centos6.id}"
  instance_type = "t2.micro"
  key_name = "MyKeyPair"
  subnet_id = "${aws_subnet.main_a.id}"

  tags {
    Name = "Web1"
  }
}
