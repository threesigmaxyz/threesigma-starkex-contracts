# StarkEx Core [![Github Actions][gha-badge]][gha] [![Foundry][foundry-badge]][foundry] [![License: MIT][license-badge]][license]

[gha]: https://github.com/threesigmaxyz/threesigma-starkex-contracts/actions
[gha-badge]: https://github.com/threesigmaxyz/threesigma-starkex-contracts/actions/workflows/ci.yml/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[license]: https://opensource.org/licenses/MIT
[license-badge]: https://img.shields.io/badge/License-MIT-blue.svg

A Foundry-based development fork of StarkEx core.

# Overview
This repository is split in two components:

- StarkEx core contracts (`scalable-dex`).
- Custom modules for extended functionality (`modules`).

The original StarkEx contracts target version `0.6.12` of the Solidity compiler, while our custom modules target more recent versions (`^0.8.0`). The `foundry.toml` configuration file defines two isolated execution profiles (`default` and `modules`) to avoid version imcompatibilities.

## StarkEx Core
The `scalable-dex` component includes the following modification over the [original implementation](https://github.com/starkware-libs/starkex-contracts/tree/master/scalable-dex) by Starkware:

- Disabled signature verification on user registration.
- Disabled `isContract` vealidation on asset whitelisting.
- Removed `onlyTokenAdmin` modifier on asset whitelisting.

## Modules
The `modules` component consists of custom modules that extend the core functionality of StarkEX. The following table summarizes the current modules:

| Name | Description | Status |
| --- | --- | --- |
| `mintable` | Standard implementation for mintable assets. | FINISHED |
| `bridge` | Trustless Sidechain-to-StarkEx [bridge](https://medium.com/starkware/a-trustless-sidechain-to-starkex-bridge-secured-by-ethereum-61e00f19f7e0). | [IN_PROGESS](https://github.com/threesigmaxyz/threesigma-starkex-contracts/pull/5) |

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

### Run Anvil
By default, Foundry ships with a local Ethereum node [Anvil](https://github.com/foundry-rs/foundry/tree/master/anvil) (akin to Ganache and Hardhat Network). This allows us to quickly deploy to our local network for development/testing. The following environment variables allow can be used to customize the local chain.

| Variable | Description |
| --- | --- |
| `ANVIL_MNEMONIC` | The mnemonic for Anvil wallet initialization. |

To start a local Anvil blockchain, run:

```sh
make anvil blockTime=10
```

The `blockTime` parameter sets the mining interval, which means that a new block will be generated in a given period of time selected (in seconds). This should eventually be moved to an env variable.


### Configuration
Prior to deployment you must set configure the `DEPLOYER_PRIVATE_KEY` variable, in the `.env` file, with the private key for the deployer account. This account should have been previously funded with enough ETH to cover the deployment gas costs.

The following environmet variables can be used to configure the intial StarkEx state:
| Variable | Description |
| --- | --- |
| `STARKEX_SEQUENCE_NUMBER` | State sequence number. |
| `STARKEX_VALIDIUM_VAULT_ROOT` | Merkle root for the Validium balances tree. |
| `STARKEX_ROLLUP_VAULT_ROOT` | Merkle root for the ZK-Rollup balances tree. |
| `STARKEX_ORDER_ROOT` | Merkle root for the orders tree. |
| `STARKEX_VALIDIUM_TREE_HEIGHT` | Height of the Validium balances tree. |
| `STARKEX_ROLLUP_TREE_HEIGHT` | Height of the ZK-Rollup balances tree. |
| `STARKEX_ORDER_TREE_HEIGHT` | Height of the orders tree. |
| `STARKEX_STRICT_VAULT_BALANCE_POLICY` | When disabled, flash loans are enabled. |

Additionally, the data availability committee can be consigured using:
| Variable | Description |
| --- | --- |
| `STARKEX_DA_THRESHOLD` | Threshold of member signatures required. |
| `STARKEX_DA_COMMITTEE` | List of addresses for the committee members. |


### Deploy Contracts
Afterwards, you can deploy all contracts via:

```sh
make deploy
```

Alternatively, you can deploy the core StarkEx contracts in separate using:
```sh
make deploy-dex
```

And the custim moules using:
```sh
make deploy-modules
```

## Security

This repository includes a Slither configuration, a popular static analysis tool from [Trail of Bits](https://www.trailofbits.com/). To use Slither, you'll first need to [install Python](https://www.python.org/downloads/) and [install Slither](https://github.com/crytic/slither#how-to-install).

Then, you can run:

```sh
make slither
```

And analyse the output of the tool.



# About Us
[Three Sigma](https://threesigma.xyz/) is a venture builder firm focused on blockchain engineering, research, and investment. Our mission is to advance the adoption of blockchain technology and contribute towards the healthy development of the Web3 space.

If you are interested in joining our team, please contact us [here](mailto:info@threesigma.xyz).

---

<p align="center">
  <img src="https://threesigma.xyz/_next/image?url=%2F_next%2Fstatic%2Fmedia%2Fthree-sigma-labs-research-capital-white.0f8e8f50.png&w=2048&q=75" width="90%" />
</p>