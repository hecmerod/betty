FROM rust:1.91-slim-bookworm AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y \
    pkg-config \
    libclang-dev \
    clang \
    && rm -rf /var/lib/apt/lists/*

COPY Cargo.toml Cargo.lock ./

RUN mkdir src && echo "fn main() {}" > src/main.rs \
    && cargo build --release \
    && rm -rf src

COPY src ./src
RUN touch src/main.rs && cargo build --release


FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    ca-certificates \
    libv4l-dev \
    && rm -rf /var/lib/apt/lists/*

# Acceso al dispositivo de cámara
RUN usermod -aG video root 2>/dev/null || true

COPY --from=builder /app/target/release/betty-camera ./betty-camera

EXPOSE 8001

CMD ["./betty-camera"]