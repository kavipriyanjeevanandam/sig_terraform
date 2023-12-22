resource "aws_ec2_client_vpn_endpoint" "my_client_vpn" {
  server_certificate_arn = "arn:aws:acm:us-east-1:833364529536:certificate/a285ab16-8dc7-4b2c-9fa5-de6be7f7a40c"  # server certificate ARN
  client_cidr_block      = "10.0.0.0/16"
  vpc_id                 = aws_vpc.SIG_vpc.id
  split_tunnel = true
  authentication_options {
    type          = "certificate-authentication"
    root_certificate_chain_arn = "arn:aws:acm:us-east-1:833364529536:certificate/a285ab16-8dc7-4b2c-9fa5-de6be7f7a40c"  #  root certificate ARN
  }
  connection_log_options {
    enabled       = false
  }
  tags = {
     Name = "SIG_Point_to_Site"
  }
}

resource "aws_ec2_client_vpn_network_association" "my_network_association" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  subnet_id              = aws_subnet.SIG_subnet.id
  depends_on = [ aws_ec2_client_vpn_endpoint.my_client_vpn ]
}

resource "aws_ec2_client_vpn_authorization_rule" "SIG_subnet_authorization_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.my_client_vpn.id
  target_network_cidr   = aws_subnet.SIG_subnet.cidr_block # replace with your VPC subnet CIDR block
  authorize_all_groups   = true
  depends_on = [ aws_ec2_client_vpn_endpoint.my_client_vpn ]
}


