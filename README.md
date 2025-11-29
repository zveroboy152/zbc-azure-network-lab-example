# Terraform: Azure Hub/VPN/Firewall Lab

This folder builds a small two-region Azure environment with a site-to-site VPN gateway in West US, an Azure Firewall in West US 3, VNet peering (gateway transit), and one Ubuntu VM in each VNet. Remote state is expected to live in an Azure Storage account.

## Topology

- **West US 3 VNet (`uswest3_vnet_address_space`)**: `default` subnet, `vm-subnet` for workloads, `AzureFirewallSubnet`, and `AzureFirewallManagementSubnet` for the Basic firewall. A route table forces 0/0 through the firewall and sends on-prem prefixes toward the VPN gateway via VNet peering.
- **West US VNet (`uswest1_vnet_address_space`)**: `GatewaySubnet` for a VPN gateway, plus a `vm-subnet` for a VM.
- **Connectivity**: VNet peering is configured; West US advertises the gateway (allow_gateway_transit) and West US 3 uses the remote gateway (use_remote_gateways). This enables West US 3 + on-prem reachability through the West US VPN gateway.
- **Firewall policy**: Basic SKU with a rule collection that currently allows all outbound traffic from both VNets.

## Files

- `main.tf` / `network.tf` / `compute.tf` / `azure-firewall-rules.tf` / `variables.tf` / `outputs.tf` – Core Terraform configuration.
- `terraform.tfvars` – Sample values for subscription, CIDRs, VM sizes, VPN, and firewall objects. Replace or override it with your own values.
- `create-state-storage.ps1` – Helper script to stand up an Azure Storage account + container for remote state.

## Prerequisites

- Terraform 1.5+ and the AzureRM provider (`~> 3.80`).
- An Azure subscription and permissions to create resource groups, VNets, gateways, and firewall resources.
- Azure CLI authenticated (`az login`) or environment variables set for the AzureRM provider.

## Remote State (recommended)

Provision storage for state:

```powershell
cd azure/terraform
.\create-state-storage.ps1 `
  -SubscriptionId "<subscription-guid>" `
  -ResourceGroupName "rg-terraform-state" `
  -Location "westus3" `
  -StorageAccountName "tfhomelabstate01" `
  -ContainerName "tfstate"
```

Capture the access key and place it in a backend config file (example):

```hcl
resource_group_name  = "rg-terraform-state"
storage_account_name = "tfhomelabstate01"
container_name       = "tfstate"
key                  = "homelab/terraform.tfstate"
subscription_id      = "<subscription-guid>"
access_key           = "<storage-account-key>"
```

Initialize Terraform using that backend file:

```bash
terraform init -backend-config=backend.hcl
```

> The backend block in `main.tf` is populated with placeholder values; override them via `-backend-config` during `terraform init`.

## Configure Variables

Copy `terraform.tfvars.example` to `terraform.tfvars` and update CIDRs, names, regions, and VPN settings. Secrets in the example file (VM admin passwords, VPN shared key) are placeholders only—inject real secrets via a private `terraform.tfvars` that stays out of version control (already gitignored), environment variables, or Azure Key Vault.

Key variables:

- `subscription_id`, `network_resource_group_name`, `resource_group_location`
- `uswest3_*` for the West US 3 VNet, firewall, route table, and VM
- `uswest1_*` for the West US VNet, VPN gateway, and VM
- `local_network_gateway_*` and `vpn_connection_*` for on-prem connectivity
- `tags` map applied to all resources

## Deploy

```bash
cd azure/terraform
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Outputs include the VNet IDs, VPN gateway ID, and allocated VPN gateway public IP. Destroy with `terraform destroy -var-file=terraform.tfvars`.

## Notes

- BGP is not enabled on the VPN gateway. If you want dynamic route exchange, add `bgp_settings` and `enable_bgp = true` to the gateway and local network gateway.
- The West US 3 route table installs only the first prefix from `local_network_gateway_address_spaces`; add a `for_each` in `network.tf` if you need multiple on-prem prefixes.
- The Azure Firewall Basic policy currently allows all outbound traffic. Tighten `azure-firewall-rules.tf` to meet your egress requirements and add logging as needed.
- Route table associations in West US 3 send all traffic to the firewall; if you add subnets, associate them explicitly or expect system routing.
