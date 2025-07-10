# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
FROM composer:2.7

# Install dependencies to build Git from source
RUN apk add --no-cache \
    curl \
    make \
    perl \
    openssl \
    tar \
    bash \
    gcc \
    libc-dev \
    musl-dev \
    zlib-dev \
    expat-dev \
    pcre2-dev \
    libcurl \
    wget \
    mysql-client

# Install Git ≥ 2.50.1 from source
ENV GIT_VERSION=2.50.1
RUN wget https://github.com/git/git/archive/refs/tags/v${GIT_VERSION}.tar.gz && \
    tar -zxf v${GIT_VERSION}.tar.gz && \
    cd git-${GIT_VERSION} && \
    make prefix=/usr install && \
    cd .. && rm -rf git-${GIT_VERSION} v${GIT_VERSION}.tar.gz && \
    git --version

# Clone repo and clean up lock files
RUN git clone https://github.com/aquasecurity/trivy-ci-test.git && \
    cd trivy-ci-test && \
    rm -f Cargo.lock Pipfile.lock
