#!/bin/bash
set -x
set +e

kubectl create secret generic regcred --from-file=.dockerconfigjson=$REGISTRY_AUTH_FILE --type=kubernetes.io/dockerconfigjson

kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "regcred"}]}'

# JVM image
docker pull docker.io/paketobuildpacks/builder:base
docker pull docker.io/paketobuildpacks/run:base-cnb