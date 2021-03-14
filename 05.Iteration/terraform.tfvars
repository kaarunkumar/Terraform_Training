server_location       = "westus2"
tftrain_akrg          = "tftrain_akrg"
resource_prefix       = "testtf-server"
server_address_space  = "1.0.0.0/22"
server_address_prefix = "1.0.1.0/24"
server_name           = "testtf"
environment           = "development"
server_count          = 2
server_subnets        = {
  testtf-server           = "1.0.1.0/24"
  AzureBastionSubnet      = "1.0.2.0/24"
}