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

RUN echo "DOCKER_TAG=$DOCKER_TAG GIT_BRANCH=$GIT_BRANCH no tag" &&\
 chmod 777 build.sh &&\
 ./build.sh
