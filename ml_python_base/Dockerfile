FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu16.04
LABEL maintainer="Ted Brookings <tbrookin@broadinstitute.org>"

ENV HOME=/root

RUN sed -i 's/^#force_color_prompt=yes$/force_color_prompt=yes/' ~/.bashrc \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
        apt-transport-https ca-certificates gnupg-agent \
        linux-headers-generic git g++ cmake \
        software-properties-common curl wget nano \
    && git config --global core.editor "nano" \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
        > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
            google-cloud-sdk \
    && apt-get autoremove && apt-get clean
