FROM bitnami/minideb:buster
LABEL maintainer="madxkk@xaked.com"

WORKDIR /w
COPY . .

ENV DOCKER_TAG v1.0.0
ENV GIT_REPO https://github.com/rdkit/rdkit.git
ENV GIT_BRANCH Release_2019_09
ENV BASE madxkk
ENV DOCKER_USER $DOCKER_USER
ENV DOCKER_PASSWORD $DOCKER_PASSWORD

RUN apt-get update &&\
  apt-get install -y apt-transport-https\
  ca-certificates\
  curl\
  gnupg2\
  software-properties-common &&\
  curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - &&\
  add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable" &&\
  apt-get update &&\
  apt-get install -y docker-ce\
  bash\
  docker-ce-cli &&\
  apt-get clean -y &&\
  echo "DOCKER_TAG=$DOCKER_TAG GIT_BRANCH=$GIT_BRANCH no tag" &&\
  chmod 777 build.sh &&\
  /bin/bash /w/build.sh
