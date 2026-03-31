FROM rustlang/rust:nightly-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y git pkg-config libssl-dev libssl3 && rm -rf /var/lib/apt/lists/*
RUN git clone --feature/branch tcp-for-remote --single-branch https://github.com/cryptonaut01/openclaw-gmail-proxy.git .
RUN cargo build --release


FROM debian:trixie-slim
WORKDIR /app
RUN apt-get update && apt-get install -y libssl-dev libssl3 && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/gmail-proxy /app/gmail-proxy
COPY config.toml /etc/gmail-proxy/config.toml
COPY entrypoint.sh /entrypoint.sh
VOLUME ["/etc/gmail-proxy", "/var/lib/gmail-proxy"]
ENTRYPOINT ["/bin/bash","/entrypoint.sh"]