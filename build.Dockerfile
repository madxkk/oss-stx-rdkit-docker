FROM bitnami/minideb:buster
LABEL maintainer="madxkk@xaked.com"

WORKDIR /w
COPY . .

ENV DOCKER_TAG latest
ENV GIT_REPO https://github.com/rdkit/rdkit.git
ENV GIT_BRANCH Release_2019_09
ENV BASE madxkk

RUN echo $DOCKER_TAG
