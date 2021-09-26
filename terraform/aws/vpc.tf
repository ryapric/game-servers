###########################
# Core / Shared
###########################
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" : "ryapric/game-servers"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

#####################################
# Public
#####################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_subnet" "public" {
  count = local.n_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "ryapric/game-servers_public"
  }
}

resource "aws_route_table_association" "public" {
  count = local.n_subnets

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

######################################
# Private
######################################
resource "aws_eip" "nat_gateway" {
  count = local.use_private_subnets

  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "main" {
  count = local.use_private_subnets

  allocation_id = aws_eip.nat_gateway[0].id
  subnet_id     = aws_subnet.public[0].id # just use the first one
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  count = local.use_private_subnets

  vpc_id = aws_vpc.main.id
}

resource "aws_route" "private" {
  count = local.use_private_subnets

  route_table_id         = aws_route_table.private[0].id
  nat_gateway_id         = aws_nat_gateway.main[0].id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_subnet" "private" {
  count = local.use_private_subnets == 1 ? local.n_subnets : 0

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${local.n_subnets + count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "ryapric/game-servers_private"
  }
}

resource "aws_route_table_association" "private" {
  count = local.use_private_subnets == 1 ? local.n_subnets : 0

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}
