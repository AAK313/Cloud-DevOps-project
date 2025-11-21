
# (Requires data source aws_availability_zones)
data "aws_availability_zones" "available" {}

locals {
  eks_tags = var.eks_cluster_name != "" ? {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
  } : {}
  
  public_eks_tags = var.eks_cluster_name != "" ? {
    "kubernetes.io/role/elb" = "1"
  } : {}
  
  private_eks_tags = var.eks_cluster_name != "" ? {
    "kubernetes.io/role/internal-elb" = "1"
  } : {}
}

resource "aws_vpc" "myvpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  })
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.myvpc.id

  tags = merge(var.tags, {
    Name = "${var.environment}-igw"
  })
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.myvpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.environment}-public"
    Tier = "public"
  }, local.eks_tags, local.public_eks_tags)
}

# Private subnet 1 (AZ = var.availability_zone)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(var.tags, {
    Name = "${var.environment}-private-1"
    Tier = "private"
  }, local.eks_tags, local.private_eks_tags)
}

# Private subnet 2 (picked from available AZs; must be different AZ)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = var.private_subnet_cidr_2
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = merge(var.tags, {
    Name = "${var.environment}-private-2"
    Tier = "private"
  }, local.eks_tags, local.private_eks_tags)
}

resource "aws_eip" "NAT" {
  domain = "vpc"

  depends_on = [aws_internet_gateway.this]

  tags = merge(var.tags, {
    Name = "${var.environment}-NAT-eip"
  })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.NAT.id
  subnet_id     = aws_subnet.public.id

  tags = merge(var.tags, {
    Name = "${var.environment}-NAT"
  })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.myvpc.id

  tags = merge(var.tags, {
    Name = "${var.environment}-public-rt"
  })
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.myvpc.id

  tags = merge(var.tags, {
    Name = "${var.environment}-private-rt"
  })
}

resource "aws_route" "private_outbound" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

# associate route table with BOTH private subnets
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# NACLs (optional)
resource "aws_network_acl" "public" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-public-nacl"
  })
}

resource "aws_network_acl" "private" {
  vpc_id = aws_vpc.myvpc.id

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = var.vpc_cidr
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(var.tags, {
    Name = "${var.environment}-private-nacl"
  })
}

resource "aws_network_acl_association" "public" {
  network_acl_id = aws_network_acl.public.id
  subnet_id      = aws_subnet.public.id
}

resource "aws_network_acl_association" "private_1" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.private_1.id
}

resource "aws_network_acl_association" "private_2" {
  network_acl_id = aws_network_acl.private.id
  subnet_id      = aws_subnet.private_2.id
}
