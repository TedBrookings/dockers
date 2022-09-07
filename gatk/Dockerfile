# NOTE: this Dockerfile is designed to be built with the accompanying build.sh script

# path to latest .jar file, relative to gatk folder
ARG LATEST_JAR
ARG GATK_PYTHON_IMAGE
ARG GATK_LOC=/opt/gatk
ARG CONDA_LOC=/opt/conda
ARG BASE_IMAGE=ubuntu:latest

from $GATK_PYTHON_IMAGE as gatk_python_image

from $BASE_IMAGE
ARG GATK_LOC
ARG LATEST_JAR
ARG GATK_PYTHON_IMAGE

# Copy /venv from the previous stage:
COPY --from=gatk_python_image /venv /venv
COPY gatk/gatk $GATK_LOC/
COPY gatk/$LATEST_JAR $GATK_LOC/$LATEST_JAR

ENV PATH="/venv/bin:$GATK_LOC:$PATH"
ENV GATK_LOCAL_JAR=$GATK_LOC/$LATEST_JAR

RUN sed -i 's/^#force_color_prompt=yes$/force_color_prompt=yes/' ~/.bashrc \
    && apt-get update --fix-missing \
    && DEBIAN_FRONTEND=noninteractive apt-get install --no-upgrade --no-install-recommends -y \
      gcc openjdk-8-jdk \
    && apt-get autoremove && apt-get clean

SHELL ["/bin/bash", "-c"]
