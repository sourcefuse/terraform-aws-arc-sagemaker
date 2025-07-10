# Base stage: Setup and build
FROM composer:2.7 as builder

# Add non-root user and group
RUN addgroup -S nonroot && adduser -S nonroot -G nonroot

# Clone repo and remove sensitive lock files
RUN git clone --depth 1 https://github.com/aquasecurity/trivy-ci-test.git \
    && cd trivy-ci-test \
    && rm -f Cargo.lock Pipfile.lock

# Install MySQL client
RUN apk add --no-cache mysql-client

# Runtime stage: secure final image
FROM composer:2.7

# Copy non-root user from builder
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Copy files from builder (optional based on your need)
COPY --from=builder /trivy-ci-test /trivy-ci-test

# Use non-root user
USER nonroot

WORKDIR /trivy-ci-test

ENTRYPOINT ["sh"]
