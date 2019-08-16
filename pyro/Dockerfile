# Docker image based on torch, adds pyro
# NOTE that the base image has curl, python3, conda, and git already

# Start from the Dockerhub pytorch repo
ARG pytorch_repo=pytorch/pytorch
ARG pytorch_version=latest
FROM ${pytorch_repo}:${pytorch_version}

LABEL maintainer="Ted Brookings <tbrookin@broadinstitute.org>"

# Install pyro
RUN rm -r "$HOME/.cache/pip" \
    && pip --no-cache-dir install pyro-ppl \
    && conda clean -ya
    
# Define default command.
CMD ["bash"]
