# ReductrAI Helm Chart

Official Helm chart for deploying ReductrAI on Kubernetes - the AI SRE Proxy that provides full observability at 10% of the cost.

## TL;DR

```bash
helm repo add reductrai https://reductrai.github.io/helm-charts
helm install reductrai reductrai/reductrai \
  --set license.key=YOUR_LICENSE_KEY \
  --set backends.datadog.apiKey=YOUR_DATADOG_KEY
```

## Introduction

ReductrAI is an intelligent proxy that sits between your applications and monitoring services (Datadog, New Relic, Prometheus, etc.). It:

- **Stores 100% of data locally** (compressed at 89% ratio)
- **Forwards 10% sampled data** to expensive monitoring services
- **Reduces monitoring costs by 90%** while maintaining full visibility
- **Provides AI-powered queries** against the complete dataset

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PersistentVolume provisioner (for data storage)
- ReductrAI license key ([get demo license](https://reductrai.com))

## Installing the Chart

### Basic Installation

```bash
helm install reductrai reductrai/reductrai \
  --set license.key=RF-DEMO-2025
```

### With Datadog Integration

```bash
helm install reductrai reductrai/reductrai \
  --set license.key=RF-DEMO-2025 \
  --set backends.datadog.enabled=true \
  --set backends.datadog.apiKey=YOUR_DATADOG_KEY
```

### With Custom Values File

```bash
# Create custom-values.yaml
cat > custom-values.yaml <<EOF
license:
  key: RF-DEMO-2025

proxy:
  replicas: 5
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10

storage:
  size: 500Gi
  storageClass: fast-ssd

backends:
  datadog:
    enabled: true
    apiKey: YOUR_DATADOG_KEY

ingress:
  enabled: true
  className: nginx
  hosts:
    - host: reductrai.example.com
      paths:
        - path: /
          pathType: Prefix
          service: dashboard
          port: 5173
EOF

helm install reductrai reductrai/reductrai -f custom-values.yaml
```

## Uninstalling the Chart

```bash
helm uninstall reductrai
```

This removes all Kubernetes resources associated with the chart.

## Configuration

The following table lists the configurable parameters and their default values.

### License Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `license.key` | ReductrAI license key (REQUIRED) | `""` |

### Proxy Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `proxy.image.repository` | Proxy image repository | `reductrai/proxy` |
| `proxy.image.tag` | Proxy image tag | `latest` |
| `proxy.image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `proxy.replicas` | Number of proxy replicas | `3` |
| `proxy.service.type` | Proxy service type | `ClusterIP` |
| `proxy.service.port` | Proxy service port | `8080` |
| `proxy.resources.requests.memory` | Memory request | `512Mi` |
| `proxy.resources.requests.cpu` | CPU request | `500m` |
| `proxy.resources.limits.memory` | Memory limit | `2Gi` |
| `proxy.resources.limits.cpu` | CPU limit | `2000m` |
| `proxy.autoscaling.enabled` | Enable HPA | `true` |
| `proxy.autoscaling.minReplicas` | Minimum replicas | `3` |
| `proxy.autoscaling.maxReplicas` | Maximum replicas | `10` |
| `proxy.autoscaling.targetCPUUtilizationPercentage` | Target CPU % | `70` |
| `proxy.autoscaling.targetMemoryUtilizationPercentage` | Target memory % | `80` |
| `proxy.compression.enabled` | Enable compression | `true` |
| `proxy.compression.level` | Compression level | `heavy` |

### Dashboard Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `dashboard.enabled` | Enable dashboard | `true` |
| `dashboard.image.repository` | Dashboard image repository | `reductrai/dashboard` |
| `dashboard.image.tag` | Dashboard image tag | `latest` |
| `dashboard.replicas` | Number of dashboard replicas | `2` |
| `dashboard.service.type` | Dashboard service type | `ClusterIP` |
| `dashboard.service.port` | Dashboard service port | `5173` |
| `dashboard.resources.requests.memory` | Memory request | `256Mi` |
| `dashboard.resources.requests.cpu` | CPU request | `250m` |
| `dashboard.resources.limits.memory` | Memory limit | `512Mi` |
| `dashboard.resources.limits.cpu` | CPU limit | `500m` |
| `dashboard.autoscaling.enabled` | Enable HPA | `false` |

### AI Query Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `aiQuery.enabled` | Enable AI query service | `true` |
| `aiQuery.image.repository` | AI query image repository | `reductrai/ai-query` |
| `aiQuery.image.tag` | AI query image tag | `latest` |
| `aiQuery.replicas` | Number of AI query replicas | `1` |
| `aiQuery.service.port` | AI query service port | `8081` |
| `aiQuery.model` | LLM model to use | `llama2:7b` |
| `aiQuery.resources.requests.memory` | Memory request | `4Gi` |
| `aiQuery.resources.requests.cpu` | CPU request | `2000m` |
| `aiQuery.resources.limits.memory` | Memory limit | `8Gi` |
| `aiQuery.resources.limits.cpu` | CPU limit | `4000m` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `storage.enabled` | Enable persistent storage | `true` |
| `storage.size` | PVC size | `100Gi` |
| `storage.storageClass` | Storage class name | `""` (default) |
| `storage.accessMode` | Access mode | `ReadWriteOnce` |

### Ingress Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable ingress | `false` |
| `ingress.className` | Ingress class name | `nginx` |
| `ingress.annotations` | Ingress annotations | `{}` |
| `ingress.hosts` | Ingress hosts configuration | See values.yaml |
| `ingress.tls` | TLS configuration | `[]` |

### Backend Integrations

| Parameter | Description | Default |
|-----------|-------------|---------|
| `backends.datadog.enabled` | Enable Datadog integration | `false` |
| `backends.datadog.apiKey` | Datadog API key | `""` |
| `backends.datadog.endpoint` | Datadog endpoint | `https://api.datadoghq.com` |
| `backends.newrelic.enabled` | Enable New Relic integration | `false` |
| `backends.newrelic.apiKey` | New Relic API key | `""` |
| `backends.prometheus.enabled` | Enable Prometheus integration | `false` |
| `backends.prometheus.endpoint` | Prometheus endpoint | `""` |
| `backends.otlp.enabled` | Enable OTLP integration | `false` |
| `backends.otlp.endpoint` | OTLP endpoint | `""` |

## Usage Examples

### Minimal Production Setup

```yaml
license:
  key: YOUR_LICENSE_KEY

proxy:
  replicas: 5
  autoscaling:
    enabled: true
    minReplicas: 5
    maxReplicas: 20

storage:
  size: 500Gi

backends:
  datadog:
    enabled: true
    apiKey: YOUR_DATADOG_KEY
```

### High Availability Setup

```yaml
license:
  key: YOUR_LICENSE_KEY

proxy:
  replicas: 10
  autoscaling:
    enabled: true
    minReplicas: 10
    maxReplicas: 50
  resources:
    requests:
      memory: 1Gi
      cpu: 1000m
    limits:
      memory: 4Gi
      cpu: 4000m

dashboard:
  replicas: 3
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10

storage:
  size: 1Ti
  storageClass: fast-ssd

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: reductrai.example.com
      paths:
        - path: /
          pathType: Prefix
          service: dashboard
          port: 5173
  tls:
    - secretName: reductrai-tls
      hosts:
        - reductrai.example.com

backends:
  datadog:
    enabled: true
    apiKey: YOUR_DATADOG_KEY
```

### Multi-Backend Setup

```yaml
license:
  key: YOUR_LICENSE_KEY

backends:
  datadog:
    enabled: true
    apiKey: YOUR_DATADOG_KEY

  newrelic:
    enabled: true
    apiKey: YOUR_NEWRELIC_KEY

  prometheus:
    enabled: true
    endpoint: http://prometheus:9090
```

## Accessing ReductrAI

After installation, get the service endpoints:

```bash
# Get all services
kubectl get svc -l app.kubernetes.io/name=reductrai

# Port-forward to access dashboard locally
kubectl port-forward svc/reductrai-dashboard 5173:5173

# Access dashboard at http://localhost:5173
```

### Pointing Your Applications to ReductrAI

Update your application configuration to send metrics to ReductrAI instead of directly to your monitoring service:

**Before (direct to Datadog):**
```bash
DD_AGENT_HOST=api.datadoghq.com
DD_AGENT_PORT=443
```

**After (through ReductrAI):**
```bash
DD_AGENT_HOST=reductrai-proxy.default.svc.cluster.local
DD_AGENT_PORT=8080
```

## Troubleshooting

### Pods Not Starting

```bash
# Check pod status
kubectl get pods -l app.kubernetes.io/name=reductrai

# Check pod logs
kubectl logs -l app.kubernetes.io/name=reductrai-proxy
kubectl logs -l app.kubernetes.io/name=reductrai-dashboard
kubectl logs -l app.kubernetes.io/name=reductrai-ai-query

# Describe pod for events
kubectl describe pod <pod-name>
```

### Storage Issues

```bash
# Check PVC status
kubectl get pvc -l app.kubernetes.io/name=reductrai

# Check PV
kubectl get pv

# Describe PVC for events
kubectl describe pvc reductrai-data
```

### Service Not Accessible

```bash
# Test proxy health from within cluster
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://reductrai-proxy:8080/health

# Check service endpoints
kubectl get endpoints reductrai-proxy
```

### High Memory Usage

If proxy pods are using too much memory, adjust the compression level:

```yaml
proxy:
  compression:
    level: medium  # or 'light' for lower memory usage
```

## Upgrading

### Upgrading the Chart

```bash
helm upgrade reductrai reductrai/reductrai -f custom-values.yaml
```

### Rolling Back

```bash
# List releases
helm history reductrai

# Rollback to previous version
helm rollback reductrai
```

## Performance Tuning

### For High Throughput (>100k req/s)

```yaml
proxy:
  replicas: 20
  autoscaling:
    enabled: true
    minReplicas: 20
    maxReplicas: 100
  resources:
    requests:
      memory: 2Gi
      cpu: 2000m
    limits:
      memory: 8Gi
      cpu: 8000m
```

### For Cost Optimization

```yaml
proxy:
  replicas: 2
  autoscaling:
    enabled: true
    minReplicas: 2
    maxReplicas: 5
  compression:
    level: heavy  # Maximum compression
```

## Security Considerations

This chart follows Kubernetes security best practices:

- Non-root containers by default
- Read-only root filesystem
- No privilege escalation
- Dropped all capabilities
- No secrets needed (apps send their own API keys in headers)

## Support

- Documentation: https://docs.reductrai.com
- GitHub: https://github.com/reductrai/helm-charts
- Email: support@reductrai.com
- Enterprise Support: enterprise@reductrai.com

## License

This chart deploys ReductrAI which requires a valid license key.

- Demo license: `RF-DEMO-2025` (for testing only)
- Production licenses: https://reductrai.com/pricing
