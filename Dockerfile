FROM rustlang/rust:nightly-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y git pkg-config libssl-dev libssl3 && rm -rf /var/lib/apt/lists/*
RUN git clone --branch feature/tcp-for-remote --single-branch https://github.com/cryptonaut01/openclaw-gmail-proxy.git /app/gmail-proxy
WORKDIR /app/gmail-proxy
COPY Cargo.toml ./Cargo.toml
RUN cargo build --release


FROM debian:trixie-slim
WORKDIR /app
RUN apt-get update && apt-get install -y ca-certificates libssl-dev libssl3 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/gmail-proxy/target/release/gmail-proxy /app/gmail-proxy
COPY config.toml /etc/gmail-proxy/config.toml
COPY secrets.toml /etc/gmail-proxy/secrets.toml
RUN chmod 600 /etc/gmail-proxy/secrets.toml
RUN chown 999:999 /etc/gmail-proxy/secrets.toml
VOLUME ["/etc/gmail-proxy", "/var/lib/gmail-proxy"]
ENTRYPOINT ["/bin/bash","/entrypoint.sh"]
