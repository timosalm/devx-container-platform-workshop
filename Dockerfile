FROM ghcr.io/vmware-tanzu-labs/educates-jdk17-environment:2.6.8

USER root

RUN echo $' \n\
[tanzu-cli] \n\
name=Tanzu CLI \n\
baseurl=https://storage.googleapis.com/tanzu-cli-os-packages/rpm/tanzu-cli \n\
enabled=1 \n\
gpgcheck=1 \n\
repo_gpgcheck=1 \n\
gpgkey=https://packages.vmware.com/tools/keys/VMWARE-PACKAGING-GPG-RSA-KEY.pub ' >> /etc/yum.repos.d/tanzu-cli.repo

RUN sudo yum install -y tanzu-cli
RUN yes | tanzu plugin install --group vmware-tap/default:v1.6.2

RUN yum install moreutils wget -y

# TBS
RUN curl -L -o /usr/local/bin/kp https://github.com/buildpacks-community/kpack-cli/releases/download/v0.12.0/kp-linux-amd64-0.12.0 && \
  chmod 755 /usr/local/bin/kp

# Knative
RUN curl -L -o /usr/local/bin/kn https://github.com/knative/client/releases/download/knative-v1.11.0/kn-linux-amd64 && \
  chmod 755 /usr/local/bin/kn

# Install krew
RUN \
( \
  set -x; cd "$(mktemp -d)" && \
  OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
  KREW="krew-${OS}_${ARCH}" && \
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
  tar zxvf "${KREW}.tar.gz" && \
  ./"${KREW}" install krew \
)
RUN echo "export PATH=\"${KREW_ROOT:-$HOME/.krew}/bin:$PATH\"" >> ${HOME}/.bashrc
ENV PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
ENV KUBECTL_VERSION=1.25
RUN kubectl krew install tree
RUN kubectl krew install eksporter
RUN chmod 775 -R $HOME/.krew
RUN yum install ruby -y

RUN curl -L -o /usr/local/bin/hey https://hey-release.s3.us-east-2.amazonaws.com/hey_linux_amd64 && \
    chmod 755 /usr/local/bin/hey

USER 1001

RUN fix-permissions /home/eduk8s
