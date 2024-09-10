resource "aws_vpc" "dev" {
  cidr_block = "172.32.0.0/16"

  tags = {
    Name = "dev"
  }
}

##### Subnets
resource "aws_subnet" "dev_private_1" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = "172.32.0.0/18"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "dev private 1"
  }
}
resource "aws_subnet" "dev_private_2" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = "172.32.64.0/18"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "dev private 2"
  }
}

resource "aws_subnet" "dev_public_1" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = "172.32.128.0/18"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "dev public 1"
  }
}
resource "aws_subnet" "dev_public_2" {
  vpc_id            = aws_vpc.dev.id
  cidr_block        = "172.32.192.0/18"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "dev public 2"
  }
}
###############

resource "aws_internet_gateway" "dev" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "dev"
  }
}

##### Nat GW
resource "aws_eip" "dev_natgw" {
  domain = "vpc"

  tags = {
    Name = "dev nat gateway"
  }
  depends_on = [aws_internet_gateway.dev]
}
resource "aws_nat_gateway" "dev" {
  allocation_id = aws_eip.dev_natgw.id
  subnet_id     = aws_subnet.dev_public_1.id

  tags = {
    Name = "dev"
  }
  depends_on = [aws_internet_gateway.dev]
}
###############

##### Subnet routes
resource "aws_route_table" "dev_private" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.dev.id
  }
  route {
    cidr_block = "172.32.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "dev private"
  }
}
resource "aws_route_table_association" "dev_private_1" {
  subnet_id      = aws_subnet.dev_private_1.id
  route_table_id = aws_route_table.dev_private.id
}
resource "aws_route_table_association" "dev_private_2" {
  subnet_id      = aws_subnet.dev_private_2.id
  route_table_id = aws_route_table.dev_private.id
}

resource "aws_route_table" "dev_public" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev.id
  }
  route {
    cidr_block = "172.32.0.0/16"
    gateway_id = "local"
  }

  tags = {
    Name = "dev public"
  }
}
resource "aws_route_table_association" "dev_public_1" {
  subnet_id      = aws_subnet.dev_public_1.id
  route_table_id = aws_route_table.dev_public.id
}
resource "aws_route_table_association" "dev_public_2" {
  subnet_id      = aws_subnet.dev_public_2.id
  route_table_id = aws_route_table.dev_public.id
}
###############

# Default security group allowing only intra vpc traffic
resource "aws_security_group" "default" {
  name   = "dev-default"
  vpc_id = aws_vpc.dev.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self        = "false"
    cidr_blocks = ["172.32.0.0/16"]
    description = "vpc traffic"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["172.32.0.0/16"]
  }
}
