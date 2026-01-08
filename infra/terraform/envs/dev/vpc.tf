resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-vpc"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-igw"
  }
}

# Subnets públicas
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.project}-public-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }
}

# Subnets privadas
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                              = "${var.project}-private-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# Elastic IP para NAT
#resource "aws_eip" "nat" {
#  domain = "vpc"
#}

# NAT Gateway (uno solo para ahorrar costo)
#resource "aws_nat_gateway" "this" {
#  allocation_id = aws_eip.nat.id
#  subnet_id     = aws_subnet.public[0].id

#  depends_on = [aws_internet_gateway.this]

#  tags = {
#    Name = "${var.project}-nat"
#  }
#}

# Route table pública
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.project}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route table privada (sin NAT: solo ruta local implícita)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project}-private-rt"
  }
}


#resource "aws_route_table_association" "private" {
#  count          = length(aws_subnet.private)
#  subnet_id      = aws_subnet.private[count.index].id
#  route_table_id = aws_route_table.private.id
#}
