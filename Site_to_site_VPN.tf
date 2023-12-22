# Create a Virtual Private Gateway (VPG)
resource "aws_vpn_gateway" "hub_vpn_gateway" {
  vpc_id = aws_vpc.SIG_vpc.id
  tags = {
    Name = "SIG VPN Gateway"
  }
}

# Attach the VPG to the Hub VPC
resource "aws_vpn_gateway_attachment" "hub_vpn_attachment" {
  vpc_id         = aws_vpc.SIG_vpc.id
  vpn_gateway_id = aws_vpn_gateway.hub_vpn_gateway.id
}

# Create a Customer Gateway (representing the other VPC)
resource "aws_customer_gateway" "other_vpc_customer_gateway" {
  bgp_asn    = 65000            # BGP ASN
  ip_address = "20.204.6.140" # Public IP address of the other VPC's VPN endpoint
  type       = "ipsec.1"
  tags = {
    Name = "SIG Customer Gateway"
  }
}

# Create a VPN Connection
resource "aws_vpn_connection" "SIG_vpc_to_other_vpc_vpn_connection" {
  customer_gateway_id = aws_customer_gateway.other_vpc_customer_gateway.id
  vpn_gateway_id      = aws_vpn_gateway.hub_vpn_gateway.id
  type                = "ipsec.1"
  static_routes_only = true
}
resource "aws_vpn_connection_route" "ip_prefix" {
  destination_cidr_block = "10.220.1.0/24"  # IP Prefix
  vpn_connection_id      = aws_vpn_connection.SIG_vpc_to_other_vpc_vpn_connection.id
}


resource "aws_route_table" "SIG_vpg_rt" {
  vpc_id = aws_vpc.SIG_vpc.id
  tags = {
    Name = "SIG_vpg_rt"
  }
}
resource "aws_route_table_association" "SIG_vpg_rt_association" {
  gateway_id     = aws_vpn_gateway.hub_vpn_gateway.id
  route_table_id = aws_route_table.SIG_vpg_rt.id
}

resource "aws_route" "SIG_vpg_to_firewall" {
  route_table_id         = aws_route_table.SIG_vpg_rt.id
  destination_cidr_block = "172.17.42.0/27"
 vpc_endpoint_id        = element([for ss in tolist(aws_networkfirewall_firewall.SIG_firewall.firewall_status[0].sync_states) : ss.attachment[0].endpoint_id if ss.attachment[0].subnet_id == aws_subnet.SIG_firewall_subnet.id],0)
 depends_on = [aws_networkfirewall_firewall.SIG_firewall]
}
