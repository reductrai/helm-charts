# ReductrAI Helm Charts

Official Helm charts for deploying ReductrAI on Kubernetes.

## Prerequisites

- Kubernetes 1.21+
- Helm 3.8+
- Valid ReductrAI license key

## Quick Start

```bash
# Add ReductrAI Helm repository
helm repo add reductrai https://charts.reductrai.com
helm repo update

# Install ReductrAI
helm install reductrai reductrai/reductrai \
  --set license.key=YOUR_LICENSE_KEY \
  --set datadog.apiKey=YOUR_DATADOG_KEY
```

## Configuration

```bash
# View all configuration options
helm show values reductrai/reductrai

# Install with custom values
helm install reductrai reductrai/reductrai -f values.yaml
```

## Example values.yaml

```yaml
license:
  key: "YOUR_LICENSE_KEY"

proxy:
  replicas: 3
  resources:
    requests:
      memory: "512Mi"
      cpu: "500m"
    limits:
      memory: "2Gi"
      cpu: "2000m"

dashboard:
  enabled: true
  ingress:
    enabled: true
    host: reductrai.example.com

storage:
  size: 100Gi
  storageClass: fast-ssd
```

## Upgrade

```bash
helm upgrade reductrai reductrai/reductrai \
  --set proxy.replicas=5
```

## Uninstall

```bash
helm uninstall reductrai
```

## Support

- Documentation: https://docs.reductrai.com/kubernetes
- Support: support@reductrai.com