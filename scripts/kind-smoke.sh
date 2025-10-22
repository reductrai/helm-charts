#!/usr/bin/env bash
# Smoke test the ReductrAI Helm chart against a local kind cluster.
# Requirements: kind, kubectl, helm, curl, jq

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="${SCRIPT_DIR%/scripts}/charts/reductrai"
CLUSTER_NAME="${KIND_CLUSTER_NAME:-reductrai-smoke}"
LICENSE_KEY="${REDUCTRAI_LICENSE_KEY:-RF-DEMO-2025}"

for bin in kind kubectl helm curl jq; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    echo "❌ Required command '$bin' not found" >&2
    exit 1
  fi
done

log() {
  printf "\e[1;34m%s\e[0m\n" "$*"
}

cleanup() {
  set +e
  log "🧹 Cleaning up Helm release (if present)"
  helm uninstall reductrai >/dev/null 2>&1 || true
  log "🧹 Deleting kind cluster $CLUSTER_NAME"
  kind delete cluster --name "$CLUSTER_NAME" >/dev/null 2>&1 || true
}
trap cleanup EXIT

port_forward() {
  local svc=$1 local_port=$2 remote_port=$3
  kubectl port-forward "svc/${svc}" "${local_port}:${remote_port}" >/tmp/"${svc}"-pf.log 2>&1 &
  echo $!
}

wait_for_url() {
  local name=$1 url=$2 timeout=${3:-90}
  local start elapsed
  start=$(date +%s)
  until curl -fsS "$url" >/dev/null 2>&1; do
    sleep 3
    elapsed=$(( $(date +%s) - start ))
    if (( elapsed > timeout )); then
      echo "❌ ${name} did not respond at ${url} within ${timeout}s"
      return 1
    fi
  done
  echo "✅ ${name} reachable at ${url}"
}

wait_for_rollout() {
  local deploy=$1
  kubectl rollout status "deploy/${deploy}" --timeout=120s
}

log "🚀 Creating kind cluster ${CLUSTER_NAME}"
kind create cluster --name "$CLUSTER_NAME" >/dev/null

log "📦 Installing chart with all components"
helm install reductrai "$CHART_DIR" \
  --set license.key="$LICENSE_KEY" \
  --set dashboard.enabled=true \
  --set aiQuery.enabled=true \
  --set ollama.enabled=true \
  --wait

wait_for_rollout reductrai-proxy
wait_for_rollout reductrai-dashboard
wait_for_rollout reductrai-ai-query
wait_for_rollout reductrai-ollama

PF_PROXY=$(port_forward reductrai-proxy 8080 8080)
PF_DASH=$(port_forward reductrai-dashboard 5173 80)
PF_AI=$(port_forward reductrai-ai-query 8081 8081)
PF_OLLAMA=$(port_forward reductrai-ollama 11434 11434)
sleep 5

wait_for_url "Proxy" "http://localhost:8080/health"
wait_for_url "Dashboard" "http://localhost:5173" 60
wait_for_url "AI Query" "http://localhost:8081/health"
wait_for_url "Ollama" "http://localhost:11434/api/tags"

kill "$PF_PROXY" "$PF_DASH" "$PF_AI" "$PF_OLLAMA" >/dev/null 2>&1 || true

log "🔄 Upgrading chart with dashboard disabled"
helm upgrade reductrai "$CHART_DIR" \
  --set license.key="$LICENSE_KEY" \
  --set dashboard.enabled=false \
  --set aiQuery.enabled=true \
  --set ollama.enabled=true \
  --wait

wait_for_rollout reductrai-proxy
wait_for_rollout reductrai-ai-query
wait_for_rollout reductrai-ollama
if kubectl get deploy reductrai-dashboard >/dev/null 2>&1; then
  echo "❌ Dashboard deployment still exists when disabled"
  exit 1
else
  echo "✅ Dashboard correctly removed when disabled"
fi

log "🔄 Upgrading chart with AI stack disabled"
helm upgrade reductrai "$CHART_DIR" \
  --set license.key="$LICENSE_KEY" \
  --set dashboard.enabled=false \
  --set aiQuery.enabled=false \
  --set ollama.enabled=false \
  --wait

wait_for_rollout reductrai-proxy
for deploy in reductrai-ai-query reductrai-ollama; do
  if kubectl get deploy "$deploy" >/dev/null 2>&1; then
    echo "❌ Deployment $deploy still exists when disabled"
    exit 1
  fi
done
echo "✅ AI Query and Ollama correctly removed when disabled"

echo "🎉 Helm smoke test completed successfully"
