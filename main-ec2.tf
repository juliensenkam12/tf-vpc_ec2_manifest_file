provider "aws" {
  region = "us-west-1"
  access_key = "**************"
  secret_key = "********************************"
}

resource "aws_instance" "demo-server" {
  ami           = "ami-0da7657fe73215c0c"
  instance_type = "t2.micro"
  key_name      = "rtp-03"
subnet_id       = aws_subnet.demo-subnet.id
vpc_security_group_ids = [aws_security_group.demo-vpc-sg.id]

}

// create VPC
resource "aws_vpc" "demo_vpc" {
  cidr_block = "10.10.0.0/16"
}

// create a subnet
resource "aws_subnet" "demo-subnet" {
  vpc_id     = aws_vpc.demo_vpc.id
  cidr_block = "10.10.1.0/24"

  tags = {
    Name = "demo_subnet"
  }
}

// create internet gateway
resource "aws_internet_gateway" "demo_igw" {
  vpc_id = aws_vpc.demo_vpc.id

  tags = {
    Name = "demo_igw"
  }
}

// create route table
resource "aws_route_table" "demo-rt" {
  vpc_id = aws_vpc.demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo_igw.id
  }


  tags = {
    Name = "demo-rt"
  }
}

//assoicate subnet with route table
resource "aws_route_table_association" "demo-rt_association" {
  subnet_id      = aws_subnet.demo-subnet.id
  route_table_id = aws_route_table.demo-rt.id
}


// create a security group
resource "aws_security_group" "demo-vpc-sg" {
  name        = "demo-vpc-sg"
  vpc_id      = aws_vpc.demo_vpc.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}
