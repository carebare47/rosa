#!/usr/bin/env bash
# Copyright (c) 2024. Jet Propulsion Laboratory. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script launches the ROSA demo in Docker

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Set default headless mode
HEADLESS=${HEADLESS:-false}
DEVELOPMENT=${DEVELOPMENT:-false}


# Build and run the Docker container
CONTAINER_NAME="rosa-turtlesim-demo"
echo "Building the $CONTAINER_NAME Docker image..."
docker build --no-cache --build-arg DEVELOPMENT=$DEVELOPMENT -t $CONTAINER_NAME -f Dockerfile . || { echo "Error: Docker build failed"; exit 1; }
xhost +

docker run --name $CONTAINER_NAME -it --security-opt seccomp=unconfined \
              --network=host --ipc=host --pid=host --privileged \
              --gpus all -e NVIDIA_DRIVER_CAPABILITIES=all -e NVIDIA_VISIBLE_DEVICES=all \
              -e DISPLAY -e QT_X11_NO_MITSHM=1 -e LOCAL_USER_ID=$(id -u) \
              -e XDG_RUNTIME_DIR=/run/user/$(id -u) -e ROS_MASTER_URI=http://localhost:11311\
              -v /tmp/.X11-unix:/tmp/.X11-unix:rw -v /dev/input:/dev/input:rw -v /dev:/dev \
              -e HEADLESS=$HEADLESS \
              -e DEVELOPMENT=$DEVELOPMENT \
              -v "$PWD/src":/app/src \
              -v "$PWD/tests":/app/tests \
              -v /run/udev/data:/run/udev/data:rw $CONTAINER_NAME

