#!/bin/bash
# Copyright (c) 2022, NVIDIA CORPORATION.
#
# Adopted from https://github.com/tmcdonell/travis-scripts/blob/dfaac280ac2082cd6bcaba3217428347899f2975/update-accelerate-buildbot.sh

set -e

# Setup 'gpuci_retry' for upload retries (results in 4 total attempts)
export GPUCI_RETRY_MAX=3
export GPUCI_RETRY_SLEEP=30

# Set label option.
# LABEL_OPTION="--label testing"
LABEL_OPTION="--label main"

# Skip uploads unless BUILD_MODE == "branch"
if [ ${BUILD_MODE} != "branch" ]; then
  echo "Skipping upload"
  return 0
fi

# Skip uploads if there is no upload key
if [ -z "$MY_UPLOAD_KEY" ]; then
  echo "No upload key"
  return 0
fi

################################################################################
# UPLOAD - Conda packages
################################################################################

gpuci_logger "Starting conda uploads"

if [[ "$BUILD_LIBRAFT" == "1" && "$UPLOAD_LIBRAFT" == "1" ]]; then
  LIBRAFT_HEADERS_FILE=$(conda build --no-build-id --croot ${CONDA_BLD_DIR} -c ${CONDA_LOCAL_CHANNEL} conda/recipes/libraft_headers --output)
  test -e ${LIBRAFT_HEADERS_FILE}
  echo "Upload libraft-headers"
  echo ${LIBRAFT_HEADERS_FILE}
  gpuci_retry anaconda -t ${MY_UPLOAD_KEY} upload -u ${CONDA_USERNAME:-rapidsai} ${LABEL_OPTION} --skip-existing ${LIBRAFT_HEADERS_FILE} --no-progress

  LIBRAFT_NN_FILE=$(conda build --no-build-id --croot ${CONDA_BLD_DIR} -c ${CONDA_LOCAL_CHANNEL} conda/recipes/libraft_nn --output)
  test -e ${LIBRAFT_NN_FILE}
  echo "Upload libraft-nn"
  echo ${LIBRAFT_NN_FILE}
  gpuci_retry anaconda -t ${MY_UPLOAD_KEY} upload -u ${CONDA_USERNAME:-rapidsai} ${LABEL_OPTION} --skip-existing ${LIBRAFT_NN_FILE} --no-progress

  LIBRAFT_DISTANCE_FILE=$(conda build --no-build-id --croot ${CONDA_BLD_DIR} -c ${CONDA_LOCAL_CHANNEL} conda/recipes/libraft_distance --output)
  test -e ${LIBRAFT_DISTANCE_FILE}
  echo "Upload libraft-distance"
  echo ${LIBRAFT_DISTANCE_FILE}
  gpuci_retry anaconda -t ${MY_UPLOAD_KEY} upload -u ${CONDA_USERNAME:-rapidsai} ${LABEL_OPTION} --skip-existing ${LIBRAFT_DISTANCE_FILE} --no-progress
fi

if [[ "$BUILD_RAFT" == "1" ]]; then
  PYRAFT_FILES=$(conda build --no-build-id --croot ${CONDA_BLD_DIR} -c ${CONDA_LOCAL_CHANNEL} conda/recipes/pyraft --python=$PYTHON --output)
  echo "Upload pyraft and pylibraft"
  gpuci_retry anaconda -t ${MY_UPLOAD_KEY} upload -u ${CONDA_USERNAME:-rapidsai} ${LABEL_OPTION} --skip-existing --no-progress ${PYRAFT_FILES}
fi
