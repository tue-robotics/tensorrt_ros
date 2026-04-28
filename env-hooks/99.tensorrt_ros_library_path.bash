#! /usr/bin/env bash

# Detect if running on Darwin platform
if [ "$(uname -s)" = "Darwin" ]
then
  export DYLD_LIBRARY_PATH="/opt/tensorrt_ros/lib${DYLD_LIBRARY_PATH:+:${DYLD_LIBRARY_PATH}}"
else
  export LD_LIBRARY_PATH="/opt/tensorrt_ros/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
fi
