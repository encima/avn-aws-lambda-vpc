provider "aiven" {
  api_token = var.aiven_api_token
}

data "aiven_project" "prj" {
  project = "chrisg-demo"
}

resource "aiven_project_vpc" "avn-vpc" {
  project      = data.aiven_project.prj.project
  cloud_name   = "aws-ap-southeast-1"
  network_cidr = "10.0.0.0/24"
  timeouts {
    create = "5m"
  }
}
resource "aiven_aws_vpc_peering_connection" "foo" {
  vpc_id         = aiven_project_vpc.avn-vpc.id
  aws_account_id = "736843629772"
  aws_vpc_id     = aws_vpc.client_vpc.id
  aws_vpc_region = "ap-southeast-1"
  timeouts {
    create = "10m"
  }
  depends_on = [
    aiven_project_vpc.avn-vpc,
    aws_vpc.client_vpc
  ]
}