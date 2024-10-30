

region             = "us-east-1"

vpcs               = ["10.0.0.0/16", "10.1.0.0/16"]

subnets = [
  { public_cidr  = "10.0.1.0/24", private_cidr = "10.0.2.0/24" },
  { public_cidr  = "", private_cidr = "10.1.1.0/24" }
]

availability_zone = "us-east-1a"
