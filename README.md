# Foundry Template [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gha]: https://github.com/threesigmaxyz/threesigma-starkex-contracts/actions
[gha-badge]: https://github.com/threesigmaxyz/threesigma-starkex-contracts/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

A Foundry-based development fork of StarkEx core.

# Getting Started

## Requirements

In order to run the tests and deployment scripts you must install the following:

- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) - A distributed version control system
- [Foundry](https://book.getfoundry.sh/getting-started/installation) - A toolkit for Ethereum application development.

Additionaly, you should have [make](https://man7.org/linux/man-pages/man1/make.1.html) installed.

## Installation

```sh
git clone https://github.com/threesigmaxyz/threesigma-starkex-contracts
cd threesigma-starkex-contracts
make all
```

## Testing
To run all tests execute the following commad:
```
make test
```

Alternatively, you can run specific tests as detailed in this [guide](https://book.getfoundry.sh/forge/tests).

## Deployment

The deployment scripts perform the following actions:

- Deploys a proxy contract;
- Deploys all StarkEx core contracts + peripherals;
- Proxy setup + implementation init;

### Setup
Prior to deployment you must configure the following variables in the `.env` file:

- `ANVIL_MNEMONIC`: The mnemonic for Anvil wallet initialization.
- `DEPLOYER_PRIVATE_KEY`: The private key for the deployer wallet (should be funded by Anvil).

### Run Anvil
To start a local blockchain, with a determined private key, run:

```sh
make anvil blockTime=10
```

The `blockTime` parameter sets the mining interval, which means that a new block will be generated in a given period of time selected (in seconds).

### Deploy Contracts
Afterwards, you can deploy all contracts via:

```sh
make deploy
```

## Local Deployment

By default, Foundry ships with a local Ethereum node [Anvil](https://github.com/foundry-rs/foundry/tree/master/anvil) (akin to Ganache and Hardhat Network). This allows us to quickly deploy to our local network for testing.

To start a local blockchain, with a determined private key, run:

```bash
make anvil
```

Afterwards, you can deploy to it via:

```bash
make deploy blockTime=10
```

The `blockTime` parameter sets the mining interval, which means that a new block will be generated in a given period of time selected (in seconds).

## Security

This repository includes a Slither configuration, a popular static analysis tool from [Trail of Bits](https://www.trailofbits.com/). To use Slither, you'll first need to [install Python](https://www.python.org/downloads/) and [install Slither](https://github.com/crytic/slither#how-to-install).

Then, you can run:

```sh
make slither
```

And analyse the output of the tool.

# License

[MIT](./LICENSE.md) © Three Sigma
