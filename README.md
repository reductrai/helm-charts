# ReductrAI Helm Charts

Official Helm charts for deploying ReductrAI on Kubernetes.

**Universal AI SRE Proxy** — Works with 20+ monitoring tools out of the box. Reduce monitoring costs by 90% while maintaining full observability.

## Prerequisites

- Kubernetes 1.21+
- Helm 3.8+
- Valid ReductrAI license key

## Quick Start

**Works with ANY monitoring tool** — Datadog, Prometheus, New Relic, OpenTelemetry, Dynatrace, and 20+ others.

```bash
# Add ReductrAI Helm repository
helm repo add reductrai https://charts.reductrai.com
helm repo update

# Install with Datadog
helm install reductrai reductrai/reductrai \
  --set license.key=YOUR_LICENSE_KEY \
  --set backends.datadog.enabled=true \
  --set backends.datadog.apiKey=YOUR_DATADOG_KEY

# Or with Prometheus
helm install reductrai reductrai/reductrai \
  --set license.key=YOUR_LICENSE_KEY \
  --set backends.prometheus.enabled=true \
  --set backends.prometheus.endpoint=http://prometheus:9090

# Or with New Relic
helm install reductrai reductrai/reductrai \
  --set license.key=YOUR_LICENSE_KEY \
  --set backends.newrelic.enabled=true \
  --set backends.newrelic.apiKey=YOUR_NEWRELIC_KEY

# Or with OpenTelemetry
helm install reductrai reductrai/reductrai \
  --set license.key=YOUR_LICENSE_KEY \
  --set backends.otlp.enabled=true \
  --set backends.otlp.endpoint=http://otel-collector:4318
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
  autoscaling:
    enabled: true
    minReplicas: 3
    maxReplicas: 10

aiQuery:
  enabled: true  # Enable for natural language queries
  replicas: 1

ollama:
  enabled: true  # LLM runtime for AI queries

storage:
  size: 100Gi
  storageClass: fast-ssd

backends:
  datadog:
    enabled: true
    apiKey: "YOUR_KEY"
  # Or use any other monitoring tool
  # prometheus, newrelic, otlp, etc.
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