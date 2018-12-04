#!/bin/bash
set -euo pipefail

repo=$1

# TRAVIS_BRANCH is set to the target branch for PRs so we don't want to overwrite
# anything that hasn't been merged yet.


echo "Shipping new image to repo: ${repo}"

cd $TRAVIS_BUILD_DIR

docker login -u $DOCKER_USER -p $DOCKER_PASS

branch=$(echo $TRAVIS_BRANCH | sed -e 's/\//-/g') # docker tags cannot have slashes
sha=`git rev-parse HEAD`
tag="$branch-${sha:0:10}"

echo "Building: docker build -t ${repo}:${tag} ."
docker build -t $repo:$tag .

if [[ "$TRAVIS_PULL_REQUEST" != "false" ]]; then
  echo "Not shipping image for pull request"
  exit
fi

echo "Pushing: docker push ${repo}:${tag}"
docker push $repo:$tag

if [[ "$TRAVIS_BRANCH" == "master" ]]; then
  echo "Tagging: docker tag ${repo}:${tag} ${repo}:latest"
  docker tag $repo:$tag $repo:latest
  echo "Pushing: docker push ${repo}:latest"
  docker push $repo:latest
fi
