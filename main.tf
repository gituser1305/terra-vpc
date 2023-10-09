variable "region" {
  default     = "ap-southeast-1" # Change to your desired region
  description = "AWS region"
}

# Create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" # Replace with your desired VPC CIDR block
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "my-vpc"
  }
  
}

# Create Subnets within the VPC
resource "aws_subnet" "my_subnet_1" {
  #count             = 1
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24" # Customize CIDR blocks as needed
  availability_zone = "ap-southeast-1a" # Replace with your desired availability zones
  tags = {
    "Name" = "my-subnet-1"
  }
}

resource "aws_subnet" "my_subnet_2" {
  #count             = 1
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24" # Customize CIDR blocks as needed
  availability_zone = "ap-southeast-1b" # Replace with your desired availability zones
  tags = {
    "Name" = "my-subnet-2"
  }
}

# Create an Elastic IP (EIP)
resource "aws_eip" "my_eip" {
  instance = "" # You can specify the ID of an instance to associate with the EIP, or leave it empty if not needed
}

# Create a NAT Gateway
resource "aws_nat_gateway" "my_nat_gateway" {
  allocation_id = aws_eip.my_eip.id  # "eipalloc-05bc9ccd6540a5042" # Replace with the ID of your Elastic IP (EIP)
  subnet_id     = aws_subnet.my_subnet_1.id #  "subnet-0ec8b22ecab115229" # Replace with the ID of your public subnet
}

# Create an Internet Gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create a Default Route to the Internet Gateway
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

# Associate the Route Table with Public Subnets
resource "aws_route_table_association" "subnet_association_1" {
  subnet_id      = aws_subnet.my_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_association_2" {
  subnet_id      = aws_subnet.my_subnet_2.id
  route_table_id = aws_route_table.public.id
}