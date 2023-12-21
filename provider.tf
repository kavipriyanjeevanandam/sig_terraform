# Define the AWS provider
provider "aws" {
  region = "ap-south-1"
}

# terraform {
#   backend "s3" {
#     bucket         = "s3-bucket-name"
#     key            = "statefile.tfstate"
#     region         = "ap-south-1"
#     encrypt        = true
#     dynamodb_table = "dynamodb-lock-table"
#   }
# }