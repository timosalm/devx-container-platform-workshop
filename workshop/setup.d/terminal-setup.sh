#!/bin/bash
set -x
set +e

kubectl annotate namespace ${SESSION_NAMESPACE} secretgen.carvel.dev/excluded-from-wildcard-matching-
kubectl label namespaces ${SESSION_NAMESPACE} apps.tanzu.vmware.com/tap-ns=""

cat <<EOL >> samples/workload.yaml
  params:
  - name: registry
    value:
      server: $REGISTRY_HOST
      repository: workloads
EOL