
# Create EC2 instances in the hub and spoke subnets
resource "aws_instance" "hub_ec2_instance" {
  ami             = "ami-0645cf88151eb2007" # RedHat AMI
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.SIG_subnet.id
  key_name        = "oskeypair"
  security_groups = [aws_security_group.SIG_vpc_sg.id]
  tags = {
    Name = "SIG_Hub_management_EC2"
  }
}