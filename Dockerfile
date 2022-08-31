FROM ghcr.io/foundry-rs/foundry:latest

WORKDIR /app

COPY src src
COPY lib lib
COPY script script

RUN forge build

ENTRYPOINT ["anvil", "-m", "test test test test test test test test test test test junk", "--block-time", "10"]
