provider "aws" {
  profile    = "default"
  region     = var.aws_region
}

# one vpc to hold them all, and in the cloud bind them
resource "aws_vpc" "django-app" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "django-app-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.django-app.id
  tags = {
    Name = "django-app-igw"
  }
}

# create one public subnet per availability zone
resource "aws_subnet" "public" {
  availability_zone       = element(var.azs,count.index)
  cidr_block              = element(var.public_subnets_cidr,count.index)
  count                   = length(var.azs)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.django-app.id
  tags = {
    Name = "django-app_subnet-pub-${count.index}"
  }
}

# create one private subnet per availability zone
resource "aws_subnet" "private" {
  availability_zone       = element(var.azs,count.index)
  cidr_block              = element(var.private_subnets_cidr,count.index)
  count                   = length(var.azs)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.django-app.id
  tags = {
    Name = "django-app_subnet-priv-${count.index}"
  }
}
  
# dynamic list of the public subnets created above
data "aws_subnet_ids" "public" {
  depends_on = ["aws_subnet.public"]
  vpc_id = aws_vpc.django-app.id
}

# dynamic list of the private subnets created above
data "aws_subnet_ids" "private" {
  depends_on = ["aws_subnet.private"]
  vpc_id = aws_vpc.django-app.id
}

locals {                                                            
  subnet_ids_string = join(",", data.aws_subnet_ids.public.ids)
  subnet_ids_list = split(",", local.subnet_ids_string)             
}   

# Define the route table and associate it with the IGW we just created
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.django-app.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "Public route table for django resume app dev"
  }
}

# add public gateway to the route table
resource "aws_route" "public" {
  gateway_id             = aws_internet_gateway.gw.id
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public.id
}

# associate route table with vpc
resource "aws_main_route_table_association" "public" {
  vpc_id         = aws_vpc.django-app.id
  route_table_id = aws_route_table.public.id
}

# and associate route table with each subnet
resource "aws_route_table_association" "public" {
  count          = length(var.azs)
  subnet_id             = local.subnet_ids_list[count.index]                                    
  route_table_id = aws_route_table.public.id
}

# create elastic IP (EIP) to assign it the NAT Gateway 
resource "aws_eip" "django-app_eip" {
  count    = length(var.azs)
  vpc      = true
  depends_on = ["aws_internet_gateway.gw"]
}

# create NAT Gateways
# make sure to create the nat in a internet-facing subnet (public subnet)
resource "aws_nat_gateway" "django-app" {
    count    = length(var.azs)
    allocation_id = element(aws_eip.django-app_eip.*.id, count.index)
    subnet_id = element(aws_subnet.public.*.id, count.index)
    depends_on = ["aws_internet_gateway.gw"]
}

# for each of the private ranges, create a "private" route table.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.django-app.id
  count = length(var.azs)
  tags = { 
    Name = "private_subnet_route_table_${count.index}"
  }
}

# add a nat gateway to each private subnet's route table
resource "aws_route" "private_nat_gateway_route" {
  count = length(var.azs)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  depends_on = ["aws_route_table.private"]
  nat_gateway_id = element(aws_nat_gateway.django-app.*.id, count.index)
}

