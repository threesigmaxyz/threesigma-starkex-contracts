FROM ghcr.io/foundry-rs/foundry:latest

WORKDIR /app

COPY . .

RUN forge build
ENV FOUNDRY_PROFILE=modules
RUN forge build

# TODO remove hardcoded mnemonic
ENTRYPOINT ["anvil", "-m", "test test test test test test test test test test test junk", "--base-fee", "0", "--block-time", "10", "--host", "0.0.0.0"]
