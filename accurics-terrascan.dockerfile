FROM ubuntu:20.04

ENV PATH="/opt/bin:${PATH}"

WORKDIR /opt/bin

RUN apt-get update \
    && apt-get install -y wget \
    && wget -q https://github.com/accurics/terrascan/releases/download/v1.13.1/terrascan_1.13.1_Linux_x86_64.tar.gz \
    && tar xf terrascan*.tar.gz \
    && rm -f terrascan*.tar.gz \
    && chown root:root terrascan \
    && chmod 755 terrascan \
    && wget -q https://downloads.accurics.com/cli/1.0.33/accurics_linux \
    && mv ./accurics_linux ./accurics \
    && chmod 755 ./accurics \
    && apt-get clean \
    && apt-get autoremove --yes

# Usually this container is used to run CI and have the accurics tools available and not run the tool directly.
CMD ["/bin/bash"]
