# https://docs.aws.amazon.com/glue/latest/dg/set-up-vpc-dns.html
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#enable_dns_support
  enable_dns_support = true
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc#enable_dns_hostnames
  enable_dns_hostnames = true
  #checkov:skip=CKV2_AWS_11: Not creating a flow log for this VPC
  tags = {
    "Name" = "app-3"
  }
}
data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "private" {
  count             = length(var.subnet_cidr_private)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_private[count.index]
  availability_zone = data.aws_availability_zones.available.names[(count.index) % length(data.aws_availability_zones.available.names)]
  tags = {
    "Name" = "app-3-private-${count.index + 1}"
  }
}
resource "aws_subnet" "public" {
  count             = length(var.subnet_cidr_public)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_public[count.index]
  availability_zone = data.aws_availability_zones.available.names[(count.index) % length(data.aws_availability_zones.available.names)]
  tags = {
    "Name" = "app-3-public-${count.index + 1}"
  }
}
resource "aws_route_table" "private" {
  count  = length(var.subnet_cidr_private)
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "app-3-route-table-${count.index + 1}"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "app-3-public"
  }
}
resource "aws_route_table_association" "private" {
  count          = length(var.subnet_cidr_private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private[count.index].id
}
resource "aws_route_table_association" "public" {
  count          = length(var.subnet_cidr_public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_internet_gateway" "this-igw" {
  vpc_id = aws_vpc.this.id
  tags = {
    "Name" = "app-3-gateway"
  }
}
resource "aws_route" "internet-route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this-igw.id
}
resource "aws_eip" "nat_gateway" {
  count  = length(var.subnet_cidr_public)
  domain = "vpc"
  #checkov:skip=CKV2_AWS_19: The IP is attached to the NAT gateway
}
resource "aws_nat_gateway" "public" {
  count         = length(var.subnet_cidr_public)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  allocation_id = aws_eip.nat_gateway[count.index].id
  depends_on    = [aws_internet_gateway.this-igw]
  tags = {
    "Name" = "app-3-NAT-${count.index + 1}"
  }
}
resource "aws_route" "private-route" {
  count                  = length(var.subnet_cidr_private)
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.private[count.index].id
  nat_gateway_id         = aws_nat_gateway.public[count.index].id
}