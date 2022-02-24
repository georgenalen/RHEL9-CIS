resource "aws_vpc" "Main" {
  cidr_block = var.main_vpc_cidr
  tags = var.instance_tags
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.Main.id
  tags = {
    Name      = "${var.namespace}-IGW"
  }
}

resource "aws_subnet" "publicsubnets" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = var.public_subnets
  tags = {
    Name = "${var.namespace}-publicsubnets"
  }
}

resource "aws_subnet" "privatesubnets" {
  vpc_id     = aws_vpc.Main.id
  cidr_block = var.private_subnets
  tags = {
    Name = "${var.namespace}-privatesubnets"
  }
}

resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }
  tags = {
    Name = "${var.namespace}-publicRT"
  }
}

resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.Main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NATgw.id
  }
  tags = {
    Name = "${var.namespace}-privateRT"
  }
}

resource "aws_route_table_association" "PublicRTassociation" {
  subnet_id      = aws_subnet.publicsubnets.id
  route_table_id = aws_route_table.publicRT.id
}

resource "aws_route_table_association" "PrivateRTassociation" {
  subnet_id      = aws_subnet.privatesubnets.id
  route_table_id = aws_route_table.privateRT.id
}

resource "aws_eip" "nateIP" {
  vpc  = true
}

resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.nateIP.id
  subnet_id     = aws_subnet.publicsubnets.id
  tags = {
    Name = "${var.namespace}-NATgw"
  }
}