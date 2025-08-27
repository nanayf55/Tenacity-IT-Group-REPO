# VPC
resource "aws_vpc" "prod_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Prod-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "Prod-igw"
  }
}

# Public Subnets
resource "aws_subnet" "prod_pub_sub1" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Prod-pub-sub1"
  }
}

resource "aws_subnet" "prod_pub_sub2" {
  vpc_id                  = aws_vpc.prod_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Prod-pub-sub2"
  }
}

# Private Subnets
resource "aws_subnet" "prod_priv_sub1" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Prod-priv-sub1"
  }
}

resource "aws_subnet" "prod_priv_sub2" {
  vpc_id            = aws_vpc.prod_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Prod-priv-sub2"
  }
}

# Public Route Table
resource "aws_route_table" "prod_pub_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "Prod-pub-route-table"
  }
}

# Route for Internet Gateway
resource "aws_route" "prod_igw_association" {
  route_table_id         = aws_route_table.prod_pub_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.prod_igw.id
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "pub_sub1_assoc" {
  subnet_id      = aws_subnet.prod_pub_sub1.id
  route_table_id = aws_route_table.prod_pub_route_table.id
}

resource "aws_route_table_association" "pub_sub2_assoc" {
  subnet_id      = aws_subnet.prod_pub_sub2.id
  route_table_id = aws_route_table.prod_pub_route_table.id
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
}
# NAT Gateway
resource "aws_nat_gateway" "prod_nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.prod_pub_sub1.id

  tags = {
    Name = "Prod-Nat-gateway"
  }
}

# Private Route Table
resource "aws_route_table" "prod_priv_route_table" {
  vpc_id = aws_vpc.prod_vpc.id

  tags = {
    Name = "Prod-priv-route-table"
  }
}

# Route for NAT Gateway
resource "aws_route" "prod_nat_association" {
  route_table_id         = aws_route_table.prod_priv_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.prod_nat_gateway.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "priv_sub1_assoc" {
  subnet_id      = aws_subnet.prod_priv_sub1.id
  route_table_id = aws_route_table.prod_priv_route_table.id
}

resource "aws_route_table_association" "priv_sub2_assoc" {
  subnet_id      = aws_subnet.prod_priv_sub2.id
  route_table_id = aws_route_table.prod_priv_route_table.id
}