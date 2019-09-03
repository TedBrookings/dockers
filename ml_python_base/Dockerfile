ARG UBUNTU_TAG=19.04
ARG PYTHON_VERSION=3.7.4
ARG NVIDIA_DRIVER_VERSION

FROM ubuntu:$UBUNTU_TAG

ARG CONDA_INSTALLER=/root/miniconda_install.bin
ARG CONDA_INSTALL_PATH=/miniconda
ARG NVIDIA_DRIVER_VERSION

LABEL maintainer="Ted Brookings <tbrookin@broadinstitute.org>"
ENV HOME=/root
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=$CONDA_INSTALL_PATH/bin:$PATH


# install basic system utils,
#         google-cloud-sdk (gsutil),
#         and latest NVIDIA driver
# NOTE: ignore apt-utils warnings: we don't want interactive install anyway!
RUN sed -i 's/^#force_color_prompt=yes$/force_color_prompt=yes/' ~/.bashrc \
    && apt-get update && apt-get install --no-install-recommends -y \
        apt-transport-https ca-certificates gnupg-agent \
        software-properties-common curl wget nano \
    && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
        > /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
        | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
    && add-apt-repository -y ppa:graphics-drivers/ppa \
    && apt-get update \
    && if [ -n "$NVIDIA_DRIVER_VERSION" ]; then \
            echo "nvidia-driver-$NVIDIA_DRIVER_VERSION"; \
        else \
            apt-cache search ^nvidia-driver- | grep "NVIDIA driver" \
            | cut -d' ' -f1 | tail -n1; \
        fi \
        | xargs apt-get install --no-install-recommends -y \
            cmake google-cloud-sdk nvidia-cuda-toolkit \
    && apt-get autoremove && apt-get clean
