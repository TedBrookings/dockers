# NOTE: this Dockerfile is designed to be built with the accompanying build.sh script

ARG GATK_LOC=/opt/gatk
ARG CONDA_LOC=/opt/conda

FROM ubuntu:latest as build_conda
ENV HOME=/root
ARG CONDA_LOC
ARG GATK_LOC

RUN apt-get update --fix-missing \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-upgrade --no-install-recommends -y \
      curl wget apt-transport-https ca-certificates gnupg-agent software-properties-common

COPY gatk/build/gatkcondaenv.yml $GATK_LOC/
COPY gatk/build/gatkPythonPackageArchive.zip $GATK_LOC/

ENV PATH="$CONDA_LOC/envs/gatk/bin:$CONDA_LOC/bin:$PATH"

RUN wget -q https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh \
    && bash miniconda.sh -b -p "$CONDA_LOC" \
    && conda env create -f $GATK_LOC/gatkcondaenv.yml \
    && conda install -n gatk -y --freeze-installed -c conda-forge conda-pack

# Use conda-pack to create a standalone enviornment
# in /venv:
RUN conda-pack -n gatk -o /tmp/env.tar && \
  mkdir /venv && cd /venv && tar xf /tmp/env.tar && \
  rm /tmp/env.tar

# We've put venv in same path it'll be in final image,
# so now fix up paths:
RUN /venv/bin/conda-unpack

FROM ubuntu:latest
COPY --from=build_conda /venv /venv
