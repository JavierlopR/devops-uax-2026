# Tarea 7 — Docker: Contenedorización de Aplicación Flask

**Alumno:** Javier López Ramos (JJLR) | **UAX DevOps 2026**

## Infraestructura

| Componente | Detalle |
|---|---|
| VM | `dev-vm-devops-git-jjlr` — Azure Standard_D2s_v3 — Ubuntu 22.04 |
| Docker Engine | 29.1.3 |
| Imagen base | `python:3.11-slim` |
| Imagen construida | `tarea7-jjlr:latest` — 210 MB |
| Aplicación | Flask 3.0.0 — Python 3.11 |
| Puerto app | 5000 (contenedor) → 5001 (host) |
| Jenkins | 2.492.3 — `http://20.82.113.249:8080` |

## Aplicación Flask

La aplicación expone dos endpoints:

| Endpoint | Descripción | Respuesta |
|---|---|---|
| `GET /` | Página principal HTML | Muestra hostname del contenedor y timestamp |
| `GET /health` | Health check JSON | `{"status": "OK", "service": "tarea7-jjlr", "version": "1.0.0"}` |

## Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

EXPOSE 5000

CMD ["python", "app.py"]
```

## requirements.txt

```
flask==3.0.0
```

## Comandos ejecutados

```bash
# Instalar Docker en la VM Jenkins
sudo apt update
sudo apt install -y docker.io
sudo systemctl enable docker && sudo systemctl start docker
sudo usermod -aG docker jenkins
sudo usermod -aG docker azureuser

# Crear directorio de la aplicación
mkdir -p /var/lib/jenkins/workspace/tarea7-app
cd /var/lib/jenkins/workspace/tarea7-app

# Crear archivos de la aplicación (app.py, Dockerfile, requirements.txt)
# (ver archivos en este directorio)

# Construir imagen manualmente (para prueba inicial)
docker build -t tarea7-jjlr:latest .

# Verificar imagen construida
docker images tarea7-jjlr:latest
# REPOSITORY      TAG       IMAGE ID       CREATED         SIZE
# tarea7-jjlr    latest    a3f8b2c91d4e   2 minutes ago   210MB

# Correr contenedor en prueba manual
docker run -d --name tarea7-test -p 5001:5000 tarea7-jjlr:latest

# Verificar health check
curl http://localhost:5001/health
# {"status": "OK", "service": "tarea7-jjlr", "version": "1.0.0"}

# Verificar página principal
curl http://localhost:5001/
# <html>...<h1>Tarea 7 - DevOps UAX JJLR</h1>...hostname...timestamp...</html>

# Inspeccionar imagen
docker inspect --format "OS: {{.Os}} | Arch: {{.Architecture}}" tarea7-jjlr:latest
# OS: linux | Arch: amd64

# Limpiar
docker stop tarea7-test && docker rm tarea7-test
```

## Pipeline Jenkins

- **Job:** `tarea7-pipeline-jjlr`
- **Build:** #2 — ✅ SUCCESS
- **Stages:** Checkout → Build Docker Image → Inspect Image → Run Container → Integration Test → Cleanup

### Output del pipeline (extracto)

```
[Build Docker Image] Successfully built a3f8b2c91d4e
[Build Docker Image] Successfully tagged tarea7-jjlr:latest
[Run Container] 8f3a1c9d2b4e... (container ID)
[Integration Test] {"status": "OK", "service": "tarea7-jjlr", "version": "1.0.0"}
[Integration Test] === HEALTH CHECK EXITOSO ===
[Cleanup] tarea7-container-jjlr
PIPELINE TAREA 7 EXITOSO - Imagen Docker construida y verificada
```

## Problema encontrado y solución

**Problema:** SyntaxError en `app.py` al usar f-strings con `strftime('%Y-%m-%d %H:%M:%S')` — las comillas simples dentro de f-strings se perdían al escribir el archivo via heredoc en bash.  
**Solución:** Reescribir la app usando concatenación de strings en lugar de f-strings, eliminando la ambigüedad de comillas en bash.

## Screenshots

| # | Descripción |
|---|---|
| `01_jenkins_pipeline.png` | Pipeline `tarea7-pipeline-jjlr` — Build #2 SUCCESS |
| `02_console_output.png` | Console output — Build exitoso con health check OK |
| `03_docker_info.png` | `docker images` — tarea7-jjlr:latest 210MB |
| `04_dockerfile.png` | Código fuente Dockerfile y app.py |
