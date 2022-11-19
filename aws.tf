provider "aws" {
  region = var.aws_region
}

data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

resource "aws_vpc" "client_vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true # Internal domain name
  enable_dns_hostnames = true # Internal host name
  tags = {
    Name = var.tag
  }
}

resource "aws_subnet" "public_subnets" { # Creating Public Subnets
  vpc_id                  = aws_vpc.client_vpc.id
  count                   = var.public_subnet_count
  cidr_block              = "10.0.${count.index + 2}.0/24"
  map_public_ip_on_launch = true # This makes the subnet public
  tags = {
    Name = var.tag
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id            = aws_vpc.client_vpc.id
  count             = var.private_subnet_count
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = var.tag
  }
}

resource "aws_internet_gateway" "client_internet_gateway" {
  vpc_id = aws_vpc.client_vpc.id

  tags = {
    Name = var.tag
  }
}

resource "aws_route_table" "client_route_table" {
  vpc_id = aws_vpc.client_vpc.id

  route {
    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.client_internet_gateway.id
  }
}

resource "aws_route_table_association" "client_route_table_subnet_association" {
  count          = 2
  route_table_id = aws_route_table.client_route_table.id
  subnet_id      = aws_subnet.public_subnets.*.id[count.index]
}

resource "aws_route_table" "aiven_route_table" {
  vpc_id = aws_vpc.client_vpc.id

  route {
    cidr_block = "10.0.0.0/24"
    vpc_peering_connection_id = aiven_aws_vpc_peering_connection.foo.aws_vpc_peering_connection_id
  }
}

resource "aws_route_table_association" "aiven_route_table_subnet_association" {
  count          = 2
  route_table_id = aws_route_table.aiven_route_table.id
  subnet_id      = aws_subnet.private_subnets.*.id[count.index]
}


# Endpoints for Services
resource "aws_vpc_endpoint" "sts" {
  vpc_id       = aws_vpc.client_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.sts"

  tags = {
    Name = var.tag
  }
}

resource "aws_vpc_endpoint" "sm" {
  vpc_id       = aws_vpc.client_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.secretsmanager"

  tags = {
    Name = var.tag
  }
}

resource "aws_vpc_endpoint" "lambda" {
  vpc_id       = aws_vpc.client_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.lambda"

  tags = {
    Name = var.tag
  }
}
