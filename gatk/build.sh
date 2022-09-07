#!/bin/bash
set -eu -o pipefail
# create docker image with most recently build gatk
# this script needs python3 to be installed, version 3.5 or greater
# you also need to specify these five values
REPO=${REPO:-us.gcr.io/broad-dsde-methods/tbrookin}
GATK_PATH=${GATK_PATH:-"$HOME/code/gatk"}
IMAGE=${IMAGE:-gatk}
TAG=${1:-$(git -C $GATK_PATH rev-parse --short HEAD)}
GATK_SV_PATH=${GATK_SV_PATH:="$HOME/code/gatk-sv"}

# the rest is managed by the script
GATK_PATH=$(cd "$GATK_PATH/" && pwd)
DOCKER_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
DOCKER_FILE=$DOCKER_DIR/Dockerfile
LOCAL_TARGET=$IMAGE:$TAG
REMOTE_TARGET=$REPO/$IMAGE:$TAG
# path to nearest parent folder of Dockerfile and gatk
BUILD_CONTEXT=$(python3 -c "import os; print(os.path.commonpath([\"$GATK_PATH\", \"$DOCKER_DIR\"]))")

# ensure that latest GATK changes are built and localJar is present
CWD=$(pwd)
cd $GATK_PATH && ./gradlew localJar
cd "$CWD"

# get most recently built GATK jar
function get_latest_jar() {
  unset -v LATEST_JAR
  set +u
  for JAR in "$GATK_PATH/build/libs"/*.jar; do
    [[ $JAR -nt $LATEST_JAR ]] && LATEST_JAR=$JAR
  done
  set -u
  realpath --relative-to="$GATK_PATH" "$LATEST_JAR"
}
LATEST_JAR=$(get_latest_jar)

# make sure that the python environment is built
GATK_PYTHON_IMAGE=$($DOCKER_DIR/../gatk_python/build.sh)

# get the base image by getting the current version of sv-base-mini
BASE_IMAGE=$(grep -o -m1 '[^"]*sv-base-mini:[^"]*' $GATK_SV_PATH/inputs/values/dockers.json)

# create custom .dockerignore so that we can get all the context we need
# but not copy tons of irrelevant crap
trap "rm -f "$BUILD_CONTEXT"/.dockerignore" EXIT
cp "$DOCKER_DIR"/.dockerignore "$BUILD_CONTEXT"/.dockerignore
echo "!/gatk/$LATEST_JAR" >> "$BUILD_CONTEXT"/.dockerignore

# spit out some text showing what we've found and how the docker image
# will be built
echo "BUILD_CONTEXT=$BUILD_CONTEXT"
echo "LATEST_JAR=$LATEST_JAR"
echo "GATK_PYTHON_IMAGE=$GATK_PYTHON_IMAGE"
echo "Context of .dockerignore:"
cat "$BUILD_CONTEXT"/.dockerignore

# time to actually build the image
docker build \
  --progress plain \
  -f "$DOCKER_FILE" \
  --tag $LOCAL_TARGET \
  --build-arg LATEST_JAR="$LATEST_JAR" \
  --build-arg BASE_IMAGE=$BASE_IMAGE \
  --build-arg GATK_PYTHON_IMAGE=$GATK_PYTHON_IMAGE \
  $BUILD_CONTEXT

# apply remote docker tag
docker tag $LOCAL_TARGET $REMOTE_TARGET
# push to remote repo
docker push $REMOTE_TARGET

echo "Pushed $REMOTE_TARGET"
