# DevOps UAX 2026 — Jesus Javier López Ramos (JJLR)

Repositorio de evidencias del curso DevOps — Universidad Alfonso X el Sabio 2026.  
Contiene la infraestructura real desplegada, pipelines Jenkins, código y screenshots de cada tarea.

---

## Resumen de Tareas

| Tarea | Tecnología | Estado | Pipeline |
|---|---|---|---|
| [Tarea 3](./tarea3-jenkins-artifactory/) | Jenkins CI/CD + JFrog Artifactory OSS | Completada | Build #3 SUCCESS |
| [Tarea 4](./tarea4-sonarqube/) | SonarQube — Análisis de Calidad | Completada | Build #3 SUCCESS |
| [Tarea 5](./tarea5-ansible/) | Ansible — Aprovisionamiento Tomcat | Completada | 13 tasks OK |
| [Tarea 6](./tarea6-terraform/) | Terraform IaC — Azure Infrastructure | Completada | 7 resources created |
| [Tarea 7](./tarea7-docker/) | Docker — Contenedorización Flask | Completada | Build #2 SUCCESS |
| [Tarea 8](./tarea8-kubernetes/) | Kubernetes (k3s) — Orquestación | Completada | Build #2 SUCCESS |

---

## Infraestructura Azure

| Recurso | Nombre | IP Pública | IP Privada |
|---|---|---|---|
| VM Jenkins (control) | `dev-vm-devops-git-jjlr` | `20.82.113.249` | `10.0.0.5` |
| VM Tomcat (target) | `dev-vm-devops-tomcat-jjlr` | `20.107.30.54` | `10.0.0.4` |
| VM SonarQube | `dev-vm-devops-sonar-jjlr` | `20.126.14.82` | `10.0.0.4` |
| Resource Group | `dev-rg-devops-jesus-lopez-ramos` | — | — |
| Subscription | `33b67b58-295c-435c-8a86-9aaffe6fa0d5` | — | — |

**Nota:** Azure hairpin NAT — las VMs en el mismo VNet deben comunicarse por IP privada, no por IP pública.

---

## Tarea 3 — Jenkins CI/CD + JFrog Artifactory

- **VM:** `dev-vm-devops-git-jjlr` — Jenkins 2.492.3 + Artifactory OSS 7.x (Docker)
- **Pipeline:** 6 stages — Checkout → Build → Test → Package → Deploy to Artifactory → Verificacion
- **Artefacto:** `maven-demo-1.0-SNAPSHOT.jar` publicado en `libs-snapshot-local`
- **Resultado:** Build #3 SUCCESS

[Ver código y detalles →](./tarea3-jenkins-artifactory/)

---

## Tarea 4 — SonarQube: Análisis de Calidad

- **SonarQube:** 12.30.0 Community Edition en Docker (`dev-vm-devops-sonar-jjlr`)
- **Pipeline:** 6 stages — Checkout → Build → Test → SonarQube Analysis → Quality Gate → Package
- **Resultado del análisis:** Quality Gate PASSED — 0 Bugs, 0 Vulnerabilities, Rating A
- **Fix clave:** Usar IP privada `10.0.0.4:9000` (hairpin NAT de Azure)

[Ver código y detalles →](./tarea4-sonarqube/)

---

## Tarea 5 — Ansible: Aprovisionamiento Apache Tomcat

- **Control node:** VM Jenkins — Ansible 2.10.8
- **Target node:** `dev-vm-devops-tomcat-jjlr` — Ubuntu 22.04
- **Playbook:** 13 tasks — Instalar OpenJDK 17 + Tomcat 10.1.24 como servicio systemd
- **Resultado:** `ok=13 changed=10 unreachable=0 failed=0` — Tomcat en `http://10.0.0.4:8080`

[Ver código y detalles →](./tarea5-ansible/)

---

## Tarea 6 — Terraform: Infraestructura Azure como Código

- **Terraform:** 1.9.8 + AzureRM Provider v4.28.0
- **Recursos:** 7 creados (VNet, Subnet, NSG, Public IP, NIC, VM Ubuntu 22.04 Standard_D2s_v3)
- **Fix clave:** Usar `data "azurerm_resource_group"` (Azure Policy no permite crear nuevos RGs)
- **Outputs:** VM `tf-jjlr-vm` — Public IP `52.157.138.103` — Private IP `10.1.1.4`

[Ver código y detalles →](./tarea6-terraform/)

---

## Tarea 7 — Docker: Contenedorización

- **Docker Engine:** 29.1.3 en VM Jenkins
- **Imagen:** `python:3.11-slim` + Flask 3.0.0 → `tarea7-jjlr:latest` (210 MB)
- **Pipeline:** 6 stages — Build → Inspect → Run → Integration Test → Cleanup
- **Endpoints:** `GET /` (HTML) + `GET /health` (JSON)

[Ver código y detalles →](./tarea7-docker/)

---

## Tarea 8 — Kubernetes: Orquestación con k3s

- **k3s:** v1.35.4+k3s1 — single-node cluster en VM Jenkins
- **Deployment:** 2 réplicas con liveness + readiness probes
- **Service:** NodePort 30080 → puerto 5000 del contenedor
- **Fix clave:** Importar imagen Docker a containerd de k3s + `imagePullPolicy: Never`

[Ver código y detalles →](./tarea8-kubernetes/)

---

## Stack Tecnológico

| Herramienta | Versión |
|---|---|
| Azure CLI | 2.x |
| Jenkins | 2.492.3 |
| Maven | 3.9.6 |
| Java / OpenJDK | 17 |
| JFrog Artifactory OSS | 7.x |
| SonarQube | 12.30.0 Community |
| Ansible | 2.10.8 |
| Apache Tomcat | 10.1.24 |
| Terraform | 1.9.8 |
| AzureRM Provider | v4.28.0 |
| Docker Engine | 29.1.3 |
| Flask | 3.0.0 |
| k3s | v1.35.4+k3s1 |
| containerd | 2.2.3-k3s1 |

---

*Alumno: Javier López Ramos (JJLR) | UAX DevOps 2026*
