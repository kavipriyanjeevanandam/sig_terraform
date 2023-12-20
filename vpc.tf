# Define the AWS provider
provider "aws" {
  region = "ap-south-1"
}
# Create the hub VPC
resource "aws_vpc" "SIG_vpc" {
  cidr_block = "172.17.42.0/24"
  tags = {
    Name = "SIG_hub"
  }
}

# Create Internet Gateway for the spoke VPC
resource "aws_internet_gateway" "SIG_igw" {
  vpc_id = aws_vpc.SIG_vpc.id
  tags = {
    Name = "SIG_igw"
  }
}
# Create a subnet in the hub VPC for management
resource "aws_subnet" "SIG_subnet" {
  vpc_id                  = aws_vpc.SIG_vpc.id
  cidr_block              = "172.17.42.0/27"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "SIG_management_subnet"
  }
}

resource "aws_subnet" "SIG_firewall_subnet" {
  vpc_id                  = aws_vpc.SIG_vpc.id
  cidr_block              =  "172.17.42.96/27" 
  availability_zone       = "ap-south-1a"
  tags = {
    Name = "SIG_firewall_subnet"
  }
}

resource "aws_route_table" "SIG_subnet_rt" {
  vpc_id = aws_vpc.SIG_vpc.id
}

resource "aws_route_table_association" "SIG_subnet_association" {
  subnet_id      = aws_subnet.SIG_subnet.id
  route_table_id = aws_route_table.SIG_subnet_rt.id
}

# resource "aws_route" "SIG_subnet_to_firewall" {
#   route_table_id         = aws_route_table.SIG_subnet_rt.id
#   destination_cidr_block = "0.0.0.0/0"
#   vpc_endpoint_id        = aws_networkfirewall_firewall.SIG_firewall.firewall_status[0].sync_states[0].attachment[0].endpoint_id
# }


resource "aws_route_table" "SIG_igw_rt" {
  vpc_id = aws_vpc.SIG_vpc.id
}
resource "aws_route_table_association" "SIG_igw_rt_association" {
  gateway_id     = aws_internet_gateway.SIG_igw.id
  route_table_id = aws_route_table.SIG_igw_rt.id
}

# resource "aws_route" "SIG_igw_to_firewall" {
#   route_table_id         = aws_route_table.SIG_igw_rt.id
#   destination_cidr_block = "172.17.42.0/27"
#  vpc_endpoint_id        = aws_networkfirewall_firewall.SIG_firewall.firewall_status[0].sync_states[0].attachment[0].endpoint_id
# }


resource "aws_route_table" "SIG_firewall_rt" {
  vpc_id = aws_vpc.SIG_vpc.id
}
resource "aws_route_table_association" "SIG_firewall_rt_association" {
  subnet_id     = aws_subnet.SIG_firewall_subnet.id
  route_table_id = aws_route_table.SIG_firewall_rt.id
}

resource "aws_route" "SIG_firewall_to_igw" {
  route_table_id         = aws_route_table.SIG_igw_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.SIG_igw.id
}


