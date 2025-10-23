#!/bin/bash

# Usage: ./build.sh <version> <latest_flag>
# Example: ./build.sh 4.105.1 true

# Exit on any error
set -e

VERSION=$1
LATEST_FLAG=$2
IMAGE_NAME="knight1988/code-server"

if [ -z "$VERSION" ]; then
    echo "Error: Version is required."
    echo "Usage: $0 <version> <latest_flag>"
    exit 1
fi

# Build Docker image with version tag
echo "Building Docker image $IMAGE_NAME:$VERSION..."
docker build -t $IMAGE_NAME:$VERSION --build-arg CODE_VERSION=$VERSION .

# If latest flag is true, tag it as latest
if [ "$LATEST_FLAG" == "true" ]; then
    echo "Tagging image as latest..."
    docker tag $IMAGE_NAME:$VERSION $IMAGE_NAME:latest
fi

# Push version tag
echo "Pushing $IMAGE_NAME:$VERSION to Docker Hub..."
docker push $IMAGE_NAME:$VERSION

# Push latest tag if applicable
if [ "$LATEST_FLAG" == "true" ]; then
    echo "Pushing $IMAGE_NAME:latest to Docker Hub..."
    docker push $IMAGE_NAME:latest
fi

echo "Done."

