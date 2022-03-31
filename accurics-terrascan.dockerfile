FROM ubuntu:20.04

ENV PATH="/opt/bin:${PATH}"

WORKDIR /opt/bin

RUN apt-get update

# wget is used to download tools
# git is used by accurics to get repository information
RUN apt-get install -y wget git zip

RUN wget -q https://github.com/accurics/terrascan/releases/download/v1.13.1/terrascan_1.13.1_Linux_x86_64.tar.gz \
    && tar xf terrascan*.tar.gz \
    && rm -f terrascan*.tar.gz \
    && chown root:root terrascan \
    && chmod 755 terrascan

RUN wget -q https://downloads.accurics.com/cli/1.0.34/accurics_linux \
    && mv ./accurics_linux ./accurics \
    && chmod 755 ./accurics

RUN wget -q https://releases.hashicorp.com/terraform/1.1.7/terraform_1.1.7_linux_amd64.zip \
    && unzip ./terraform_1.1.7_linux_amd64.zip \
    && rm -f terraform_1.1.7_linux_amd64.zip \
    && chown root:root terraform \
    && chmod 755 terraform

RUN apt-get clean \
    && apt-get autoremove --yes

# Usually this container is used to run CI and have the accurics tools available and not run the tool directly.
CMD ["/bin/bash"]
