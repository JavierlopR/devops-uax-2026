# Tarea 4 — SonarQube: Análisis de Calidad de Código

**Alumno:** Javier López Ramos (JJLR) | **UAX DevOps 2026**

## Infraestructura

| Componente | Detalle |
|---|---|
| SonarQube | 12.30.0 Community Edition — Docker container |
| VM SonarQube | `dev-vm-devops-sonar-jjlr` — IP pública `20.126.14.82` — privada `10.0.0.4` |
| VM Jenkins | `dev-vm-devops-git-jjlr` — IP pública `20.82.113.249` |
| Plugin | SonarQube Scanner for Jenkins 2.17 |
| Análisis | maven-demo-jjlr — Java 17 |

## Comandos ejecutados

```bash
# Desplegar SonarQube en Docker (VM sonar)
sudo docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
  sonarqube:community

# Configurar credencial token en Jenkins (via Groovy script)
# Token generado en SonarQube UI: Administration > Security > Users > Tokens

# Configurar SonarQube server en Jenkins
# IMPORTANTE: usar IP privada (10.0.0.4) por hairpin NAT de Azure
# (Las VMs en el mismo VNet no pueden usar la IP pública entre sí)
sudo tee /var/lib/jenkins/hudson.plugins.sonar.SonarGlobalConfiguration.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<hudson.plugins.sonar.SonarGlobalConfiguration plugin="sonar@2.17">
  <installations>
    <hudson.plugins.sonar.SonarInstallation>
      <name>SonarQube</name>
      <serverUrl>http://10.0.0.4:9000</serverUrl>
      <credentialsId>sonarqube-token</credentialsId>
    </hudson.plugins.sonar.SonarInstallation>
  </installations>
</hudson.plugins.sonar.SonarGlobalConfiguration>
EOF

sudo systemctl restart jenkins
```

## Resultados del análisis

| Métrica | Resultado |
|---|---|
| Quality Gate | ✅ PASSED |
| Bugs | 0 |
| Vulnerabilities | 0 |
| Code Smells | 1 |
| Security Rating | A |
| Maintainability Rating | A |
| Reliability Rating | A |

## Pipeline resultado

- **Job:** `tarea4-pipeline-jjlr`
- **Build:** #3 — ✅ SUCCESS
- **Stages:** Checkout → Build → Test → SonarQube Analysis → Quality Gate → Package

## Problema encontrado y solución

**Problema:** `withSonarQubeEnv` fallaba con la IP pública `20.126.14.82` — Azure aplica hairpin NAT y las VMs del mismo VNet no pueden comunicarse por IP pública.  
**Solución:** Usar IP privada `10.0.0.4:9000` en la configuración de Jenkins y en el Jenkinsfile.

## Screenshots

| # | Descripción |
|---|---|
| `01_sonar_config.png` | Configuración SonarQube Server en Jenkins |
| `02_sonar_dashboard.png` | Dashboard SonarQube con Quality Gate PASSED |
| `03_sonar_project.png` | Análisis detallado del proyecto maven-demo-jjlr |
