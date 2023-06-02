FROM alpine:3.14

RUN ARCH=amd64 \
    && PLATFORM=$(uname -s)_$ARCH \
    && apk update && apk add curl \
    && curl -sLO "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$PLATFORM.tar.gz" \
    && tar -xzf eksctl_$PLATFORM.tar.gz -C /tmp && rm eksctl_$PLATFORM.tar.gz \
    && mv /tmp/eksctl /usr/local/bin \
    && curl -sSL https://git.io/install-kubent | sh \
    && curl --silent --location "https://github.com/FairwindsOps/pluto/releases/download/v5.16.1/pluto_5.16.1_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
    && mv /tmp/pluto /usr/local/bin \
    && curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl \
    && apk add aws-cli \
    && curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp \
    && mv /tmp/eksctl /usr/local/bin \
    && apk add jq

COPY . /
RUN chmod +x /*.sh