-include .env

all: clean remove install build

# Clean the repo
clean :;
	@FOUNDRY_PROFILE=default forge clean && export FOUNDRY_PROFILE=modules && forge clean

# Remove modules
remove :;
	@rm -rf .gitmodules && \
	rm -rf .git/modules/* && \
	rm -rf lib && touch .gitmodules

# Install dependencies
install: install-dex install-modules

install-dex:;
	@export FOUNDRY_PROFILE=default && \
	forge install foundry-rs/forge-std@2a2ce36 --no-commit

install-modules:;
	@export FOUNDRY_PROFILE=modules && \
	forge install foundry-rs/forge-std --no-commit && \
	forge install openzeppelin/openzeppelin-contracts --no-commit

# Build the project
build: build-dex build-modules

build-dex :; export FOUNDRY_PROFILE=default && forge build

build-modules:; export FOUNDRY_PROFILE=modules && forge build

# Run tests
tests: test-dex test-modules

test-dex :; forge test -vvv

test-modules :; export FOUNDRY_PROFILE=modules && forge test -vvv

# Start a local blockchain node
anvil :;
	anvil \
		--mnemonic ${ANVIL_MNEMONIC} \
		--accounts 1 \
		--balance 1000000 \
		--base-fee 0 \
		--block-time ${blockTime} \
		--host 0.0.0.0

# Deploy contracts
deploy: deploy-dex deploy-modules

# Deploy DEX contracts
# This is the private key of account from the mnemonic from the "make anvil" command
deploy-dex :; @export FOUNDRY_PROFILE=default && \
	forge script script/scalable-dex/DeployStarkEx.s.sol:DeployStarkExScript \
	--rpc-url http://localhost:8545 \
	--private-key ${DEPLOYER_PRIVATE_KEY} \
	--broadcast

# Deploy mudule contracts
# This is the private key of account from the mnemonic from the "make anvil" command
deploy-modules :; @export SCALABLE_DEX_ADDRESS=0x5fbdb2315678afecb367f032d93f642f64180aa3 && \
	export FOUNDRY_PROFILE=modules && \
 	forge script script/modules/DeployMintableModule.s.sol:DeployMintableModuleScript \
	--rpc-url http://localhost:8545 \
	--private-key ${DEPLOYER_PRIVATE_KEY} \
	--broadcast

# Take chain snapshot
snapshot :; forge snapshot

# Run slither static analysis
slither :; slither ./src/modules