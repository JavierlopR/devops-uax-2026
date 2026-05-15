# Tarea 6 — Terraform IaC: Infraestructura Azure

**Alumno:** Javier López Ramos (JJLR) | **UAX DevOps 2026**

## Infraestructura provisionada

| Recurso Terraform | Nombre Azure | Descripción |
|---|---|---|
| `data.azurerm_resource_group` | `dev-rg-devops-jesus-lopez-ramos` | RG existente (data source) |
| `azurerm_virtual_network` | `tf-jjlr-vnet` | VNet 10.1.0.0/16 |
| `azurerm_subnet` | `tf-jjlr-subnet` | Subred 10.1.1.0/24 |
| `azurerm_network_security_group` | `tf-jjlr-nsg` | Regla SSH puerto 22 inbound |
| `azurerm_subnet_network_security_group_association` | `nsg_assoc` | Asociación Subnet ↔ NSG |
| `azurerm_public_ip` | `tf-jjlr-pip` | IP pública estática Standard |
| `azurerm_network_interface` | `tf-jjlr-nic` | NIC con IP privada dinámica |
| `azurerm_linux_virtual_machine` | `tf-jjlr-vm` | Ubuntu 22.04 LTS Gen2 — Standard_D2s_v3 |

## Comandos ejecutados

```bash
# Instalar Terraform 1.9.8 (Windows)
winget install HashiCorp.Terraform

# Inicializar provider AzureRM
cd C:\Users\javie\AppData\Local\Temp\tf-tarea6\
terraform init

# Ver plan de ejecución (7 recursos a crear)
terraform plan

# Aplicar infraestructura
terraform apply -auto-approve

# Outputs obtenidos:
# private_ip     = "10.1.1.4"
# public_ip      = "52.157.138.103"
# resource_group = "dev-rg-devops-jesus-lopez-ramos"
# vm_name        = "tf-jjlr-vm"

# Destruir infraestructura
terraform destroy -auto-approve
# Destroy complete! Resources: 7 destroyed.
```

## Versiones

| Herramienta | Versión |
|---|---|
| Terraform | 1.9.8 (Windows) |
| AzureRM Provider | hashicorp/azurerm v4.28.0 |
| Azure CLI | 2.x (autenticación via `az login`) |

## Problema encontrado y solución

**Problema 1:** Error 403 al intentar crear un Resource Group nuevo — Azure Policy de la suscripción UAX no permite crear nuevos RGs.  
**Solución:** Usar `data "azurerm_resource_group"` en vez de `resource`, referenciando el RG existente.

**Problema 2:** Token MSAL de Azure CLI no compatible entre Windows y Linux.  
**Solución:** Ejecutar Terraform desde Windows donde `az login` ya estaba autenticado.

## Screenshots

| # | Descripción |
|---|---|
| `01_terraform_plan.png` | `terraform plan` — 7 recursos a crear |
| `02_terraform_apply.png` | `terraform apply` — Apply complete! 7 added |
| `03_terraform_init.png` | `terraform init` — Provider AzureRM v4.28.0 |
| `04_main_tf.png` | Código fuente main.tf con sintaxis HCL |
| `05_terraform_destroy.png` | `terraform destroy` — 7 destroyed |
