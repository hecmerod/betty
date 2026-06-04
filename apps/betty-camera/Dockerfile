FROM rust:1.93-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends clang libclang-dev libv4l-dev pkg-config \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/src/betty-camera

COPY Cargo.toml ./
COPY src ./src
RUN cargo fetch
RUN cargo install cargo-watch

COPY . .

EXPOSE 8001

CMD ["sh", "-c", "cargo watch -i target -w src -w Cargo.toml -x 'run --release'"]
