# DevOps UAX 2026 — Javier López Ramos (JJLR)

Repositorio de tareas del módulo **Modelo DevOps de Integración Continua** — Universidad Alfonso X el Sabio (UAX), Mayo 2026.

## Estructura del repositorio

| Carpeta | Tarea | Herramienta | Descripción |
|---------|-------|-------------|-------------|
| `tarea3-jenkins-artifactory/` | Tarea 3 | Jenkins 2.492.3 | Pipeline CI con Maven + JFrog Artifactory |
| `tarea4-sonarqube/` | Tarea 4 | SonarQube 12.30 | Análisis de calidad de código con Jenkins |
| `tarea5-ansible/` | Tarea 5 | Ansible 2.10.8 | Aprovisionamiento Apache Tomcat 10.1.24 |
| `tarea6-terraform/` | Tarea 6 | Terraform 1.9.8 | IaC: VM Azure con AzureRM Provider ~> 4.0 |
| `tarea7-docker/` | Tarea 7 | Docker 29.1.3 | Containerización Flask App + Jenkins Pipeline |
| `tarea8-kubernetes/` | Tarea 8 | k3s v1.35.4 | Orquestación Kubernetes + Jenkins Pipeline |

## Tecnologías utilizadas

- **CI/CD:** Jenkins 2.492.3
- **Calidad:** SonarQube 12.30.0 Community Edition
- **IaC:** Terraform 1.9.8 + AzureRM Provider ~> 4.0
- **Config Mgmt:** Ansible 2.10.8
- **Containers:** Docker 29.1.3 + Python Flask 3.0.0
- **Orquestación:** Kubernetes k3s v1.35.4
- **Cloud:** Microsoft Azure (West Europe)

## Infraestructura Azure

- **Suscripción:** `33b67b58-295c-435c-8a86-9aaffe6fa0d5`
- **Resource Group:** `dev-rg-devops-jesus-lopez-ramos`
- **VM Principal (Jenkins):** `dev-vm-devops-git-jjlr` — Standard_D2s_v3 — Ubuntu 22.04 LTS

## Autor

**Javier López Ramos (JJLR)**  
Máster Big Data & IA — UAX  
Mayo 2026
