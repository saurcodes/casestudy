# vpc.tf
resource "aws_vpc" "zantac_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.zantac_vpc.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.zantac_vpc.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Tier        = "Public"
  }
}

# Create application subnets
resource "aws_subnet" "application" {
  count                   = length(var.application_subnets_cidr)
  vpc_id                  = aws_vpc.zantac_vpc.id
  cidr_block              = element(var.application_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-application-subnet-${count.index + 1}"
    Environment = var.environment
    Tier        = "Application"
  }
}

# Create database subnets
resource "aws_subnet" "database" {
  count                   = length(var.database_subnets_cidr)
  vpc_id                  = aws_vpc.zantac_vpc.id
  cidr_block              = element(var.database_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.environment}-database-subnet-${count.index + 1}"
    Environment = var.environment
    Tier        = "Database"
  }
}

# Route tables for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.zantac_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = var.environment
  }
}

# Route table associations for public subnets
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Create NAT Gateway
resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name        = "${var.environment}-nat-eip"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = element(aws_subnet.public.*.id, 0)

  tags = {
    Name        = "${var.environment}-nat-gateway"
    Environment = var.environment
  }

  depends_on = [aws_internet_gateway.igw]
}

# Route tables for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.zantac_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = var.environment
  }
}

# Route table associations for application and database subnets
resource "aws_route_table_association" "application" {
  count          = length(var.application_subnets_cidr)
  subnet_id      = element(aws_subnet.application.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "database" {
  count          = length(var.database_subnets_cidr)
  subnet_id      = element(aws_subnet.database.*.id, count.index)
  route_table_id = aws_route_table.private.id
}