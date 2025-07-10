# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

FROM composer:2.7

# It's important to avoid running everything as root unless necessary.
# Consider switching to a non-root user if this image is extended further.

# Clone the Trivy test repo and remove lock files
RUN git clone --depth 1 https://github.com/aquasecurity/trivy-ci-test.git \
    && cd trivy-ci-test \
    && rm -f Cargo.lock Pipfile.lock

# Install MySQL client safely
RUN apk add --no-cache mysql-client
