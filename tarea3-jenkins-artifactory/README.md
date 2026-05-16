# Tarea 3 — Jenkins CI/CD + JFrog Artifactory OSS

**Alumno:** Javier López Ramos (JJLR) | **UAX DevOps 2026**

## Infraestructura

| Componente | Detalle |
|---|---|
| VM | `dev-vm-devops-git-jjlr` — Azure Standard_D2s_v3 — Ubuntu 22.04 |
| Jenkins | 2.492.3 — `http://20.82.113.249:8080` |
| JFrog Artifactory OSS | 7.x — `http://localhost:8082` |
| Maven | 3.9.6 — `/opt/apache-maven-3.9.6/` |
| Java | OpenJDK 17 |
| Proyecto | `maven-demo-jjlr` — `/opt/maven-demo-jjlr/` |

## Comandos ejecutados

```bash
# Instalar Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list
sudo apt update && sudo apt install -y jenkins
sudo systemctl enable jenkins && sudo systemctl start jenkins

# Instalar Maven 3.9.6
wget https://downloads.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz -P /tmp
sudo tar xzf /tmp/apache-maven-3.9.6-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.9.6/bin/mvn /usr/local/bin/mvn

# Instalar JFrog Artifactory OSS via Docker
sudo docker run -d --name artifactory \
  -p 8082:8082 -p 8081:8081 \
  -v artifactory-data:/var/opt/jfrog/artifactory \
  releases-docker.jfrog.io/jfrog/artifactory-oss:latest

# Pipeline Jenkins (6 stages):
# Checkout → Build → Test → Package → Deploy to Artifactory → Verificacion
```

## Pipeline resultado

- **Job:** `tarea3-pipeline-jjlr`
- **Build:** #3 — SUCCESS
- **Stages:** Checkout → Build → Test → Package → Deploy to Artifactory → Verificacion
- **Artefacto:** `maven-demo-1.0-SNAPSHOT.jar` publicado en `libs-snapshot-local`

## Screenshots

| # | Descripción |
|---|---|
| `01_jenkins_jobs.png` | Vista de jobs en Jenkins dashboard |
| `02_build_success.png` | Build #3 SUCCESS con todos los stages |
| `03_console_log.png` | Console output con deploy a Artifactory |
