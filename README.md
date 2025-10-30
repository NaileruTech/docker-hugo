# Docker Hugo Build Image

A lightweight Docker image based on `golang:1.25.1-bookworm` optimized for building Hugo static websites. It pre-installs essential tools like Hugo (extended), Dart Sass, Node.js, and compression utilities (brotli, gzip, zstd) to significantly reduce build times in CI/CD pipelines (e.g., GitLab CI).

This image avoids downloading and extracting dependencies on every run, making it ideal for fast, reproducible Hugo builds.

## Features

- **Base Image**: `golang:1.25.1-bookworm` (includes Go for Hugo compatibility).
- **Pre-installed Tools**:
  - Hugo: v0.151.0 (extended edition for Sass/SCSS support).
  - Dart Sass: v1.93.2.
  - Node.js: v22.18.0 (with npm for theme dependencies).
  - Utilities: brotli, xz-utils, zstd, curl.
- **Timezone**: Set to `Europe/Oslo` (configurable via `ENV TZ`).
- **Optimizations**:
  - Binaries installed in `/usr/local/bin` for easy access.
  - Minimal footprint; no unnecessary packages.
  - Supports Git submodules and deep clones via environment variables.
- **Size**: ~800MB (compressed; focuses on runtime essentials).

## Quick Start

### Building the Image Locally

1. Clone this repository:
   ```
   git clone https://github.com/NaileruTech/docker-hugo.git
   cd docker-hugo
   ```

2. Build the image:
   ```
   docker build -t nailerutech/docker-hugo .
   ```

3. (Optional) Push to Docker Hub or another registry:
   ```
   docker push nailerutech/docker-hugo
   ```

### Running a Hugo Build

Mount your Hugo project directory and build the site:

```bash
docker run --rm -v $(pwd):/src -w /src nailerutech/docker-hugo:latest hugo --gc --minify
```

- This outputs the built site to `./public/`.
- For development server: `docker run --rm -v $(pwd):/src -w /src -p 1313:1313 nailerutech/docker-hugo:latest hugo server -D`.

### Installing Dependencies (if needed)

If your Hugo theme uses npm:
```bash
docker run --rm -v $(pwd):/src -w /src nailerutech/docker-hugo:latest npm ci
```

## Integration with GitLab CI

This image is designed to speed up GitLab CI jobs. Update your `.gitlab-ci.yml`:

```yaml
variables:
  DART_SASS_VERSION: 1.93.2
  HUGO_VERSION: 0.151.0
  NODE_VERSION: 22.18.0
  GIT_DEPTH: 0
  GIT_STRATEGY: clone
  GIT_SUBMODULE_STRATEGY: recursive
  TZ: Europe/Oslo

stages:
  - deploy

image: ghcr.io/nailerutech/docker-hugo:main

pages:
  stage: deploy
  script:
    # Configure Git
    - git config core.quotepath false

    # Install Node.js dependencies (if package-lock.json exists)
    - if [[ -f package-lock.json || -f npm-shrinkwrap.json ]]; then npm ci --prefer-offline; fi

    # Build site
    - hugo --gc --minify

    # Compress assets (optional, for better performance)
    - find public/ -type f -regextype posix-extended -regex '.+\.(css|html|js|json|mjs|svg|txt|xml)$' -print0 > files.txt
    - xargs --null --max-procs=0 --max-args=1 brotli --quality=10 --force --keep < files.txt
    - xargs --null --max-procs=0 --max-args=1 gzip -9 --force --keep < files.txt
  artifacts:
    paths:
      - public
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
      changes:
        - content/**/*.{md,toml,yaml,yml,json}
        - config.*
        - static/**/*
        - themes/**/*
        - data/**/*
```

- **Time Savings**: Eliminates ~2-5 minutes of installation time per job (downloads, extractions).
- Host the image in your GitLab Container Registry for private builds.

## Customization

- **Update Versions**: Edit `ARG` values in `Dockerfile` (e.g., `ARG HUGO_VERSION=0.XXX.X`) and rebuild.
- **Multi-Stage Build**: For an even smaller runtime image, extend this with a multi-stage setup (see [Docker docs](https://docs.docker.com/build/building/multi-stage/)).
- **Environment Variables**:
  - `TZ`: Override timezone (default: `Europe/Oslo`).

## Contents

- `Dockerfile`: Main build script.
- `README.md`: This file.

## License

This project is licensed under the MIT License.

## Contributing

Contributions welcome! Fork the repo, make changes, and submit a PR. For issues, open a ticket.
