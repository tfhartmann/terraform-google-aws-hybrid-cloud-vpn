/**
 * This example configures a simple single region connection
 *
 * * Create the HA VPN gateway and a Cloud Router. This creates 2 public IP addresses on the GCP side.
 * * Create two AWS Virtual Private Gateways. This creates 4 public addresses on the AWS side.
 * * Create two AWS Site-to-Site VPN connections and customer gateways, one for each AWS Virtual Private Gateway. Specify a non-overlapping link-local Tunnel IP Range for each tunnel, 4 total. For example, 169.254.1.4/30.
 * * Download the AWS configuration files for the generic device type.
 * * Create four VPN tunnels on the HA VPN gateway.
 * * Configure BGP sessions on the Cloud Router using the BGP IP addresses from the downloaded AWS configuration files.
 *
 */

terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "6.12.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "google-beta" {
  project = "project"
  region  = "us-central1"
}

provider "aws" {
  region = "us-east-1"
}

module "tgw-us-east-1" {
  source          = "terraform-aws-modules/transit-gateway/aws"
  version         = "2.12.2"
  name            = "tgw-example-us-east-1"
  description     = "TGW example shared with several other AWS accounts"
  amazon_side_asn = "64512"

  enable_auto_accept_shared_attachments = true
  ram_allow_external_principals         = true

  tags = {
    Purpose = "tgw example"
  }
}

module "cb-us-east-1" {
  source             = "github.com/spotify/terraform-google-aws-hybrid-cloud-vpn"
  transit_gateway_id = module.tgw-us-east-1.ec2_transit_gateway_id
  google_network     = default
  amazon_side_asn    = 64512
  google_side_asn    = 65534
}
