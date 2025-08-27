FROM debian:bookworm-slim AS builder

ARG app_version

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl unzip ca-certificates; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN set -eux; \
    curl -fL \
      "https://github.com/bitwarden/clients/releases/download/cli-v${app_version}/bw-linux-${app_version}.zip" \
      -o bw.zip; \
    unzip bw.zip; \
    install -m 0755 -o root -g root bw /usr/local/bin/bw

FROM debian:bookworm-slim

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends ca-certificates; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/bw /usr/local/bin/bw

RUN set -eux; \
    chown root:root /usr/local/bin/bw; \
    chmod 0755 /usr/local/bin/bw

ENTRYPOINT ["bw"]
CMD ["--version"]

