FROM ubuntu:22.04

ARG TERRAFORM_VERSION
ARG TERRASCAN_VERSION
ARG ACCURICS_VERSION

ENV PATH="/opt/bin:${PATH}"

WORKDIR /opt/bin

COPY accurics_linux_*.md5 /opt/bin/
COPY terrascan_*_Linux_x86_64.tar.gz.md5 /opt/bin/

# Accurics uses git to determine information about the repo being scanned
RUN apt-get update \
    && apt-get install -y git \
    gpg \
    wget \
    zip \
    && apt-get clean \
    && apt-get autoremove --yes

RUN gpg --quick-generate-key --batch --passphrase "" human@example.com \
    && wget -q https://keybase.io/hashicorp/pgp_keys.asc \
    && gpg --import pgp_keys.asc \
    && gpg --batch --yes --sign-key 34365D9472D7468F

RUN wget https://github.com/accurics/terrascan/releases/download/v${TERRASCAN_VERSION}/terrascan_${TERRASCAN_VERSION}_Linux_x86_64.tar.gz \
    && tar xf terrascan*.tar.gz \
    && md5sum -c terrascan_${TERRASCAN_VERSION}_Linux_x86_64.tar.gz.md5 \
    && rm -f terrascan*.tar.gz \
    && chmod 755 ./terrascan

RUN wget https://downloads.accurics.com/cli/${ACCURICS_VERSION}/accurics_linux \
    && md5sum -c accurics_linux_${ACCURICS_VERSION}.md5 \
    && mv ./accurics_linux ./accurics \
    && chmod 755 ./accurics

# The recommended way to ensure we're not installing poisoned binaries from Hashicorp
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig \
    && gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && shasum --ignore-missing -a 256 -c terraform_${TERRAFORM_VERSION}_SHA256SUMS \
    && unzip terraform*.zip \
    && rm -f terraform*.zip \
    && chmod 755 ./terraform

# Usually this container is used to run CI and have the accurics tools available and not run the tool directly.
CMD ["/bin/bash"]
