FROM ubuntu:18.04

ARG UNAME=jenkins
ARG GNAME=jenkins
ARG UID=1000
ARG GID=1000

ENV GO_VERSION 1.11.1

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install make build-essential git jq vim curl wget \
    && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ bionic main" | tee /etc/apt/sources.list.d/azure-cli.list \
    && wget https://packages.microsoft.com/keys/microsoft.asc \
    && apt-key add microsoft.asc \
    && apt-get update \
    && apt-get -y install apt-transport-https azure-cli \
    && wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && groupadd --gid ${GID} ${GNAME} \
    && useradd --create-home --uid ${UID} --gid ${GID} --shell /bin/bash ${UNAME}

ENV PATH "${PATH}:/usr/local/go/bin"
