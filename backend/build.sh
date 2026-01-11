#!/usr/bin/env bash

set -e

trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT

APP_NAME="labcr-backend"
DOCKER_REPO="piotrkomisarski/labcr-backend"

# Get current version from build.gradle.kts
CURRENT_VERSION=$(grep -oP 'version\s*=\s*"\K[^"]+' build.gradle.kts | head -1)
echo "Current version: $CURRENT_VERSION"

# Remove -SNAPSHOT suffix if present
CURRENT_VERSION=${CURRENT_VERSION%-SNAPSHOT}

# Bump patch version
IFS='.' read -r -a v <<< "$CURRENT_VERSION"
((v[2]++))
NEW_VERSION="${v[0]}.${v[1]}.${v[2]}"
echo "New version: $NEW_VERSION"

# Update version in build.gradle.kts
sed -i "s/version = \".*\"/version = \"$NEW_VERSION\"/" build.gradle.kts

# Build
./gradlew clean bootJar --no-daemon

# Docker build & push
docker build -t ${APP_NAME}:${NEW_VERSION} .
docker tag ${APP_NAME}:${NEW_VERSION} ${DOCKER_REPO}:${NEW_VERSION}
docker tag ${APP_NAME}:${NEW_VERSION} ${DOCKER_REPO}:latest
docker push ${DOCKER_REPO}:${NEW_VERSION}
docker push ${DOCKER_REPO}:latest

# Git commit & push
git config --global user.email "github-actions@github.com"
git config --global user.name "GitHub Actions"
git add build.gradle.kts
git commit -m "Bump version to $NEW_VERSION"
git push

echo "Successfully deployed version $NEW_VERSION"
