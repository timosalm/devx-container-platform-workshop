set -x

ytt template -f resources -f values.yaml --ignore-unknown-comments | kapp deploy -n tap-install -a devx-container-platform-workshop -f- --diff-changes --yes