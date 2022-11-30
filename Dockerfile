FROM ghcr.io/foundry-rs/foundry:nightly-15c022681740307380a8179ec9594c50a5483e7c

WORKDIR /app

COPY . .

RUN forge build
ENV FOUNDRY_PROFILE=modules
RUN forge build

# TODO remove hardcoded mnemonic
ENTRYPOINT ["anvil", "-m", "test test test test test test test test test test test junk", "--base-fee", "0", "--block-time", "10", "--host", "0.0.0.0"]
