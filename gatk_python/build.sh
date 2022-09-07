#!/bin/bash
set -eu -o pipefail
# create docker image with most recently build gatk python environment
# this script needs python3 to be installed, version 3.5 or greater
# you also need to specify these three values
REPO=${REPO:-us.gcr.io/broad-dsde-methods/tbrookin}
GATK_PATH=${GATK_PATH:-"$HOME/code/gatk"}
IMAGE=${IMAGE:-gatk-python}

# the rest is managed by the script
GATK_PATH=$(cd "$GATK_PATH/" && pwd)
YML=$GATK_PATH/build/gatkcondaenv.yml
# assign tag based on hash of YML
TAG=$(shasum -U -a1 < $YML | awk '{print $1}')
DOCKER_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOCKER_FILE=$DOCKER_DIR/Dockerfile
LOCAL_TARGET=$IMAGE:$TAG
REMOTE_TARGET=$REPO/$IMAGE:$TAG
# path to nearest parent folder of Dockerfile and gatk
BUILD_CONTEXT=$(python3 -c "import os; print(os.path.commonpath([\"$GATK_PATH\", \"$DOCKER_DIR\"]))")


REMOTE_TARGET="$REPO/$IMAGE:$TAG"

if ! DOCKER_CLI_EXPERIMENTAL=enabled docker manifest inspect $REMOTE_TARGET &> /dev/null; then
  # need to  build the image
  
  # create custom .dockerignore so that we can get all the context we need
  # but not copy tons of irrelevant crap
  trap "rm -f "$BUILD_CONTEXT"/.dockerignore" EXIT
  cp "$DOCKER_DIR"/.dockerignore "$BUILD_CONTEXT"/.dockerignore

  # spit out some text showing what we've found and how the docker image
  # will be built
  1>&2 echo "BUILD_CONTEXT=$BUILD_CONTEXT"
  1>&2 echo "Context of .dockerignore:"
  1>&2 cat "$BUILD_CONTEXT"/.dockerignore
  
  # time to actually build the image
  1>&2 docker build \
    --progress plain \
    -f "$DOCKER_FILE" \
    --tag $LOCAL_TARGET \
    $BUILD_CONTEXT

  # apply remote docker tag
  1>&2 docker tag $LOCAL_TARGET $REMOTE_TARGET
  # push to remote repo
  1>&2 docker push $REMOTE_TARGET
fi

echo "$REMOTE_TARGET"
