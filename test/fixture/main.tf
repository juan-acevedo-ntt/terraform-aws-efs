provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "sn1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
}

resource "aws_subnet" "sn2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1b"
}

module "efs" {
  source = "../../"

  region  = "eu-west-1"
  vpc_id  = aws_vpc.main.id
  subnets = [aws_subnet.sn1.id,aws_subnet.sn2.id]

  name = "efstest-${var.attributes}"
}