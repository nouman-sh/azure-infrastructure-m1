Sure! Here’s a clean, professional README.md template tailored to your mini project with the Azure Terraform architecture you described:

````markdown
# Mini Project 1 - Production Grade Azure Infrastructure with Terraform

## Project Overview

This project demonstrates the deployment of a production-grade Azure infrastructure using Terraform.
The infrastructure includes a secure, scalable Virtual Machine Scale Set (VMSS) behind a public Load Balancer,
 with autoscaling and network security best practices.

## Architecture

- **Resource Group:** A single resource group to contain all resources.
- **Virtual Network (VNet):** Address space `10.0.0.0/16`.
- **Subnet:** One subnet within the VNet.
- **Network Security Group (NSG):** Attached to the subnet to restrict inbound traffic only from the Load Balancer.
- **Virtual Machine Scale Set (VMSS):**  
  - Deployed inside the subnet.  
  - Minimum 1 VM, maximum 5 VMs.  
  - Autoscaling rules based on CPU utilization (scale out if CPU > 80% for 5 minutes, scale in if CPU < 10% for 2 minutes).
- **Load Balancer:**  
  - Public-facing with a Public IP.  
  - Listens on ports 80 (HTTP) and 443 (HTTPS).  
  - Balances traffic across VMSS instances.
- **NAT Gateway:** Attached to the subnet for outbound internet connectivity of VMs.

## Prerequisites

- Terraform CLI installed ([Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli))
- An Azure subscription with necessary permissions
- Azure CLI installed and logged in (`az login`)

## How to Use

1. Clone this repository:

   ```bash
   git clone <repository-url>
   cd <repository-folder>
````

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Review and customize variables in `variables.tf` (if available).

4. Validate the Terraform plan:

   ```bash
   terraform plan
   ```

5. Apply the Terraform configuration:

   ```bash
   terraform apply
   ```

6. Confirm and wait for the deployment to complete.

## Project Structure

* provider.tf — Terraform provider configuration for Azure.

* vnet.tf — Resource group, Virtual Network, Load Balancer, Network Security Group, and related networking resources.

* vmss.tf — Virtual Machine Scale Set definition and configuration.

* autoscaling.tf — Autoscaling rules and settings for the VMSS.

* backend.tf — Remote backend configuration to securely store Terraform state files.

## Notes
* Autoscaling is configured to maintain performance and cost-efficiency.

* Network Security Group restricts access only to traffic from the Load Balancer for enhanced security.

* NAT Gateway allows VMs to securely download updates and packages from the internet.

* Remote backend ensures your Terraform state is preserved and shared safely.

## Author

Nouman Shariff
