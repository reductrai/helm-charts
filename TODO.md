# ReductrAI Helm Chart - TODO

**Status:** ✅ COMPLETE
**Priority:** Medium (Docker deployment is primary focus)
**Completion Date:** October 20, 2025

## Current Status

✅ **All Critical Templates Complete:**
- Chart.yaml - Properly configured
- values.yaml - Complete with all configuration options
- _helpers.tpl - Template helper functions
- deployment-proxy.yaml - Proxy deployment template
- service-proxy.yaml - ClusterIP service for proxy
- service-dashboard.yaml - ClusterIP service for dashboard
- service-ai-query.yaml - ClusterIP service for AI query
- deployment-dashboard.yaml - Dashboard deployment
- deployment-ai-query.yaml - AI Query deployment
- pvc.yaml - PersistentVolumeClaim for data storage
- ingress.yaml - Ingress for dashboard access
- hpa-proxy.yaml - HorizontalPodAutoscaler for proxy
- hpa-dashboard.yaml - HorizontalPodAutoscaler for dashboard

✅ **All Required Service Templates:**
- [x] `service-proxy.yaml` - ClusterIP service for proxy
- [x] `service-dashboard.yaml` - ClusterIP service for dashboard
- [x] `service-ai-query.yaml` - ClusterIP service for AI query

✅ **All Required Deployment Templates:**
- [x] `deployment-dashboard.yaml` - Dashboard deployment
- [x] `deployment-ai-query.yaml` - AI Query deployment

✅ **Storage Templates:**
- [x] `pvc.yaml` - PersistentVolumeClaim for data storage

✅ **Autoscaling Templates:**
- [x] `hpa-proxy.yaml` - HorizontalPodAutoscaler for proxy
- [x] `hpa-dashboard.yaml` - HorizontalPodAutoscaler for dashboard

✅ **Network Templates:**
- [x] `ingress.yaml` - Ingress for dashboard access

❌ **Optional Templates (Not Implemented):**
- [ ] `configmap.yaml` - Not needed, license key uses env var
- [ ] `serviceaccount.yaml` - Not needed for basic deployment
- [ ] `role.yaml` - Not needed for basic deployment
- [ ] `rolebinding.yaml` - Not needed for basic deployment
- [ ] `servicemonitor.yaml` - Not needed for basic deployment

## Template Examples

### service-proxy.yaml
```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "reductrai.fullname" . }}-proxy
  labels:
    {{- include "reductrai.labels" . | nindent 4 }}
    app.kubernetes.io/component: proxy
spec:
  type: {{ .Values.proxy.service.type }}
  ports:
    - port: {{ .Values.proxy.service.port }}
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app.kubernetes.io/name: {{ include "reductrai.name" . }}-proxy
    app.kubernetes.io/instance: {{ .Release.Name }}
```

### deployment-dashboard.yaml
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "reductrai.fullname" . }}-dashboard
  labels:
    {{- include "reductrai.labels" . | nindent 4 }}
    app.kubernetes.io/component: dashboard
spec:
  replicas: {{ .Values.dashboard.replicas }}
  selector:
    matchLabels:
      app.kubernetes.io/name: {{ include "reductrai.name" . }}-dashboard
      app.kubernetes.io/instance: {{ .Release.Name }}
  template:
    metadata:
      labels:
        app.kubernetes.io/name: {{ include "reductrai.name" . }}-dashboard
        app.kubernetes.io/instance: {{ .Release.Name }}
        app.kubernetes.io/component: dashboard
    spec:
      containers:
        - name: dashboard
          image: "{{ .Values.dashboard.image.repository }}:{{ .Values.dashboard.image.tag }}"
          imagePullPolicy: {{ .Values.dashboard.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
```

### pvc.yaml
```yaml
{{- if .Values.storage.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: {{ include "reductrai.fullname" . }}-data
  labels:
    {{- include "reductrai.labels" . | nindent 4 }}
spec:
  accessModes:
    - {{ .Values.storage.accessMode }}
  {{- if .Values.storage.storageClass }}
  storageClassName: {{ .Values.storage.storageClass }}
  {{- end }}
  resources:
    requests:
      storage: {{ .Values.storage.size }}
{{- end }}
```

## Testing Plan

Once templates are complete:

1. **Lint the Chart**
   ```bash
   helm lint charts/reductrai
   ```

2. **Template Rendering Test**
   ```bash
   helm template reductrai charts/reductrai \
     --set license.key=RF-DEMO-2025 \
     --set backends.datadog.enabled=true \
     --set backends.datadog.apiKey=test-key \
     > rendered.yaml

   # Verify all resources are generated
   grep "kind:" rendered.yaml
   ```

3. **Dry-Run Install**
   ```bash
   helm install reductrai charts/reductrai \
     --dry-run --debug \
     --set license.key=RF-DEMO-2025
   ```

4. **Actual Install (requires Kubernetes cluster)**
   ```bash
   # Create namespace
   kubectl create namespace reductrai

   # Install chart
   helm install reductrai charts/reductrai \
     --namespace reductrai \
     --set license.key=RF-DEMO-2025 \
     --set backends.datadog.enabled=true \
     --set backends.datadog.apiKey=$DATADOG_API_KEY

   # Verify deployment
   kubectl get all -n reductrai
   kubectl get pvc -n reductrai
   kubectl logs -n reductrai deployment/reductrai-proxy
   ```

5. **Upgrade Test**
   ```bash
   # Modify values
   helm upgrade reductrai charts/reductrai \
     --namespace reductrai \
     --set proxy.replicas=5
   ```

6. **Rollback Test**
   ```bash
   helm rollback reductrai -n reductrai
   ```

## values.yaml Validation

Current values.yaml is well-structured and includes:

✅ Proxy configuration (image, replicas, resources, autoscaling)
✅ Dashboard configuration
✅ AI Query configuration
✅ Storage configuration
✅ Backend integrations (Datadog, New Relic, Prometheus, OTLP)
✅ Security contexts
✅ Node selectors, tolerations, affinity

## Documentation Needed

After templates are complete, add to the chart:

- [ ] `charts/reductrai/README.md` - Installation and configuration guide
- [ ] `charts/reductrai/EXAMPLES.md` - Common deployment scenarios
- [ ] `charts/reductrai/UPGRADING.md` - Upgrade procedures
- [ ] `charts/reductrai/CHANGELOG.md` - Version history

## Integration with Docker Images

✅ **Already Correct:**
- values.yaml references published Docker Hub images:
  - `reductrai/proxy:latest`
  - `reductrai/dashboard:latest`
  - `reductrai/ai-query:latest`
- No changes needed once templates are complete

## Priority Order

1. **Critical (for basic functionality):**
   - service-proxy.yaml
   - service-dashboard.yaml
   - service-ai-query.yaml
   - deployment-dashboard.yaml
   - deployment-ai-query.yaml
   - pvc.yaml

2. **Important (for production):**
   - hpa-proxy.yaml
   - ingress.yaml
   - configmap.yaml (optional - license can be env var)

3. **Nice to have:**
   - serviceaccount.yaml
   - role.yaml
   - rolebinding.yaml
   - servicemonitor.yaml

## Estimated Timeline

- **Phase 1 (Critical templates):** 1.5-2 hours (no secrets needed!)
- **Phase 2 (Testing and validation):** 1 hour
- **Phase 3 (Documentation):** 1 hour
- **Phase 4 (Production templates):** 1-2 hours

**Total:** 3.5-5 hours for complete, production-ready Helm chart

**Note:** ReductrAI is an intelligent proxy - it doesn't need backend API keys as secrets! Apps send requests with their own API keys through the proxy. Only the ReductrAI license key is needed (can be env var).

## Notes

- values.yaml is already comprehensive and production-ready
- Chart.yaml properly configured with keywords and metadata
- _helpers.tpl follows Helm best practices
- deployment-proxy.yaml is a good template to follow for other deployments
- All Docker images are already correctly referenced

## When to Complete

**Recommendation:** After Docker deployment is fully validated and in use, complete Helm chart for Kubernetes customers. Docker deployment (via docker-compose or all-in-one image) should be the primary focus initially.
