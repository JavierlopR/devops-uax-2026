# Tarea 8 — Kubernetes: Orquestación con k3s

**Alumno:** Javier López Ramos (JJLR) | **UAX DevOps 2026**

## Infraestructura

| Componente | Detalle |
|---|---|
| VM | `dev-vm-devops-git-jjlr` — Azure Standard_D2s_v3 — Ubuntu 22.04 |
| Kubernetes | k3s v1.35.4+k3s1 |
| Container Runtime | containerd 2.2.3-k3s1 |
| kubectl | v1.35.4+k3s1 |
| Imagen | `tarea7-jjlr:latest` (importada desde Docker a containerd) |
| Replicas | 2 pods |
| Acceso | NodePort 30080 |
| Jenkins | 2.492.3 — `http://20.82.113.249:8080` |

## Comandos ejecutados

```bash
# Instalar k3s (single-node cluster)
curl -sfL https://get.k3s.io | sh -

# Verificar instalación
sudo k3s kubectl get nodes
# NAME                    STATUS   ROLES                  AGE   VERSION
# dev-vm-devops-git-jjlr  Ready    control-plane,master   30s   v1.35.4+k3s1

# Configurar kubeconfig para azureuser y jenkins
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
sudo mkdir -p /var/lib/jenkins/.kube
sudo cp /etc/rancher/k3s/k3s.yaml /var/lib/jenkins/.kube/config
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config

# Verificar acceso con kubectl
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes -o wide
kubectl cluster-info

# IMPORTANTE: k3s usa containerd, NO el Docker daemon
# Hay que importar la imagen Docker al registro de containerd de k3s
docker save tarea7-jjlr:latest | sudo k3s ctr images import -

# Verificar imagen importada en containerd
sudo k3s ctr images list | grep tarea7
# docker.io/library/tarea7-jjlr:latest

# Crear directorio de manifests
mkdir -p /var/lib/jenkins/workspace/tarea8-manifests

# Aplicar manifests de Kubernetes
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Verificar despliegue
kubectl rollout status deployment/tarea8-deployment-jjlr --timeout=90s
# deployment "tarea8-deployment-jjlr" successfully rolled out

kubectl get pods -l app=tarea8-jjlr -o wide
# NAME                                      READY   STATUS    RESTARTS   AGE   IP
# tarea8-deployment-jjlr-7d9f8c6b5-xk2pq   1/1     Running   0          45s   10.42.0.8
# tarea8-deployment-jjlr-7d9f8c6b5-m3nt7   1/1     Running   0          45s   10.42.0.9

kubectl get service tarea8-service-jjlr
# NAME                   TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
# tarea8-service-jjlr    NodePort   10.43.87.42   <none>        80:30080/TCP   60s

# Verificar aplicación via NodePort
curl http://localhost:30080/health
# {"status": "OK", "service": "tarea7-jjlr", "version": "1.0.0"}

# Limpiar recursos
kubectl delete -f service.yaml
kubectl delete -f deployment.yaml
```

## Manifests de Kubernetes

### deployment.yaml

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tarea8-deployment-jjlr
  labels:
    app: tarea8-jjlr
spec:
  replicas: 2
  selector:
    matchLabels:
      app: tarea8-jjlr
  template:
    metadata:
      labels:
        app: tarea8-jjlr
    spec:
      containers:
      - name: tarea8-container-jjlr
        image: tarea7-jjlr:latest
        imagePullPolicy: Never          # imagen local en containerd (k3s)
        ports:
        - containerPort: 5000
        livenessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 10
          periodSeconds: 30
        readinessProbe:
          httpGet:
            path: /health
            port: 5000
          initialDelaySeconds: 5
          periodSeconds: 10
```

### service.yaml

```yaml
apiVersion: v1
kind: Service
metadata:
  name: tarea8-service-jjlr
spec:
  selector:
    app: tarea8-jjlr
  type: NodePort
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5000
    nodePort: 30080
```

## Pipeline Jenkins

- **Job:** `tarea8-pipeline-jjlr`
- **Build:** #2 — ✅ SUCCESS
- **Stages:** Checkout Manifests → Verify Cluster → Deploy Application → Verify Deployment → Integration Test → Cleanup

### Output del pipeline (extracto)

```
[Verify Cluster] NAME                    STATUS   ROLES                  AGE
[Verify Cluster] dev-vm-devops-git-jjlr  Ready    control-plane,master   2d
[Deploy Application] deployment.apps/tarea8-deployment-jjlr created
[Deploy Application] service/tarea8-service-jjlr created
[Verify Deployment] deployment "tarea8-deployment-jjlr" successfully rolled out
[Verify Deployment] tarea8-deployment-jjlr-7d9f8c6b5-xk2pq   1/1   Running
[Verify Deployment] tarea8-deployment-jjlr-7d9f8c6b5-m3nt7   1/1   Running
[Integration Test] {"status": "OK", "service": "tarea7-jjlr", "version": "1.0.0"}
[Integration Test] === KUBERNETES INTEGRATION TEST EXITOSO ===
PIPELINE TAREA 8 EXITOSO - Aplicacion desplegada en Kubernetes correctamente
```

## Problemas encontrados y soluciones

**Problema 1:** k3s usa `containerd` como runtime, no el Docker daemon. Al ejecutar `kubectl apply`, los pods quedaban en `ErrImageNeverPull` porque la imagen `tarea7-jjlr:latest` existía en Docker pero no en el registro de containerd de k3s.  
**Solución:** Importar la imagen explícitamente a containerd:
```bash
docker save tarea7-jjlr:latest | sudo k3s ctr images import -
```
Y usar `imagePullPolicy: Never` en el Deployment para forzar uso de imagen local.

**Problema 2:** Jenkins no podía leer el kubeconfig de k3s (`/etc/rancher/k3s/k3s.yaml`) — permisos solo para root.  
**Solución:**
```bash
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
sudo cp /etc/rancher/k3s/k3s.yaml /var/lib/jenkins/.kube/config
sudo chown jenkins:jenkins /var/lib/jenkins/.kube/config
```

## Screenshots

| # | Descripción |
|---|---|
| `01_jenkins_pipeline.png` | Pipeline `tarea8-pipeline-jjlr` — Build #2 SUCCESS |
| `02_console_output.png` | Console output — kubectl apply + rollout status + health check |
| `03_k8s_resources.png` | `kubectl get pods,svc` — 2 pods Running, NodePort 30080 |
| `04_manifests.png` | Archivos deployment.yaml y service.yaml |
