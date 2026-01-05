#!/usr/bin/env bash

# Set in ENV:
# - REG_USER
# - REG_TOKEN
# - LABEL
# - IMAGE_ID
# - IMAGE_NAME

build() {
  docker build path-traversal --file path-traversal/Containerfile --tag "$IMAGE_NAME" --label "$LABEL"
}

login() {
  echo "$REG_TOKEN" | docker login ghcr.io -u "$REG_USER" --password-stdin
}

push() {
  VERSION=latest
  echo IMAGE_ID="$IMAGE_ID"
  docker tag "$IMAGE_NAME" "$IMAGE_ID:latest"
  docker push "$IMAGE_ID:latest"
}

"$@"
