# login DockerHub
printf "Logging into Dockerhub"

echo "$REGISTRY_PASS" | docker login --username "$REGISTRY_USER" --password-stdin

# build the docker image and push to DockerHub repository
printf "Building docker image for ${DEPLOY_ENV}\n\n"

if [ $DEPLOY_ENV = "green" ]
then
  # Production deploy
  git checkout beta
fi

docker build --force-rm --tag "${IMAGE_NAME}:${DEPLOY_ENV}" .
docker push "${IMAGE_NAME}:${DEPLOY_ENV}"
