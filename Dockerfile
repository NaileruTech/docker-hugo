FROM golang:1.25.1-bookworm

# Set the timezone
ENV TZ=Europe/Oslo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Install utilities via apt (brotli, xz-utils, zstd)
RUN apt-get update && \
    apt-get install -y brotli xz-utils zstd curl && \
    rm -rf /var/lib/apt/lists/*

# Version variables
ARG DART_SASS_VERSION=1.93.2
ARG HUGO_VERSION=0.151.0
ARG NODE_VERSION=22.18.0

# Install Dart Sass
RUN curl -sLJO "https://github.com/sass/dart-sass/releases/download/${DART_SASS_VERSION}/dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz" && \
    tar -C /usr/local -xf "dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz" && \
    ln -s /usr/local/dart-sass/sass /usr/local/bin/sass && \
    rm "dart-sass-${DART_SASS_VERSION}-linux-x64.tar.gz"

# Install Hugo (extended version)
RUN curl -sLJO "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz" && \
    tar -C /usr/local/bin -xf "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz" && \
    rm "hugo_extended_${HUGO_VERSION}_linux-amd64.tar.gz"

# Install Node.js
RUN curl -sLJO "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz" && \
    tar -C /usr/local -xf "node-v${NODE_VERSION}-linux-x64.tar.xz" && \
    ln -s /usr/local/node-v${NODE_VERSION}-linux-x64/bin/* /usr/local/bin/ && \
    rm "node-v${NODE_VERSION}-linux-x64.tar.xz"

# Optional verification (for debugging during image build)
RUN echo "Verifying installations:" && \
    echo "Dart Sass: $(sass --version)" && \
    echo "Go: $(go version)" && \
    echo "Hugo: $(hugo version)" && \
    echo "Node.js: $(node --version)" && \
    echo "brotli: $(brotli --version)" && \
    echo "xz: $(xz --version)" && \
    echo "zstd: $(zstd --version)"
