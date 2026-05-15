# Tarea 5 — Ansible: Aprovisionamiento Apache Tomcat

**Alumno:** Javier López Ramos (JJLR) | **UAX DevOps 2026**

## Infraestructura

| Componente | Detalle |
|---|---|
| Control Node | `dev-vm-devops-git-jjlr` — Jenkins VM — Ansible 2.10.8 |
| Target Node | `dev-vm-devops-tomcat-jjlr` — IP pública `20.107.30.54` — privada `10.0.0.4` |
| Ansible | 2.10.8 (Ubuntu 22.04) |
| Tomcat | Apache Tomcat 10.1.24 |
| Java | OpenJDK 17 |
| Comunicación | SSH con clave privada `~/.ssh/tomcat-key.pem` |

## Comandos ejecutados

```bash
# Instalar Ansible en el control node (Jenkins VM)
sudo apt update && sudo apt install -y ansible
ansible --version  # 2.10.8

# Crear directorio de trabajo
mkdir -p /home/azureuser/ansible-tarea5
cd /home/azureuser/ansible-tarea5

# Inyectar clave SSH en la VM Tomcat (via az vm run-command)
az vm run-command invoke \
  -g dev-rg-devops-jesus-lopez-ramos \
  -n dev-vm-devops-tomcat-jjlr \
  --command-id RunShellScript \
  --scripts "echo 'SSH_PUBLIC_KEY' >> /home/azureuser/.ssh/authorized_keys"

# Ejecutar el playbook
ansible-playbook -i inventory.ini tomcat.yml -v

# Verificar Tomcat en ejecución
ansible tomcat_servers -i inventory.ini -m shell -a "sudo systemctl status tomcat"
ansible tomcat_servers -i inventory.ini -m uri -a "url=http://localhost:8080/ status_code=200"
```

## Playbook: tomcat.yml (13 tasks)

| Task | Módulo | Descripción |
|---|---|---|
| 1 | `apt` | Actualizar cache de paquetes |
| 2 | `apt` | Instalar OpenJDK 17 |
| 3 | `group` | Crear grupo `tomcat` |
| 4 | `user` | Crear usuario `tomcat` (shell=/bin/false) |
| 5 | `get_url` | Descargar Tomcat 10.1.24 desde Apache |
| 6 | `unarchive` | Extraer en `/opt/apache-tomcat-10.1.24/` |
| 7 | `file` | Crear symlink `/opt/tomcat -> /opt/apache-tomcat-10.1.24` |
| 8 | `file` | Permisos en directorios bin/ y webapps/ |
| 9 | `copy` | Crear archivo systemd `tomcat.service` |
| 10 | `systemd` | Reload daemon |
| 11 | `systemd` | Habilitar e iniciar servicio Tomcat |
| 12 | `wait_for` | Esperar puerto 8080 disponible |
| 13 | `debug` | Mostrar URL de acceso |

## Resultado

- **Tomcat 10.1.24** corriendo como servicio systemd en `http://10.0.0.4:8080`
- **2 plays, 13 tasks** — `ok=13 changed=10 unreachable=0 failed=0`
- Página de bienvenida de Tomcat verificada via HTTP

## Problema encontrado y solución

**Problema:** El symlink `/opt/tomcat` fallaba porque el directorio home del usuario tomcat ya existía en esa ruta.  
**Solución:**  
```bash
sudo mv /opt/tomcat /opt/tomcat-home
sudo ln -sfn /opt/apache-tomcat-10.1.24 /opt/tomcat
sudo systemctl restart tomcat
```

## Screenshots

| # | Descripción |
|---|---|
| `01_ansible_run.png` | Ejecución del playbook — 13 tasks OK |
| `02_tomcat_home.png` | Página de bienvenida Tomcat 10.1.24 en http://10.0.0.4:8080 |
| `03_ansible_files.png` | Estructura de archivos inventory.ini y tomcat.yml |
| `04_tomcat_status.png` | `systemctl status tomcat` — Active (running) |
