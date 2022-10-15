-include .env

all: clean remove install update build

# Clean the repo
clean :; @forge clean && export FOUNDRY_PROFILE=modules && forge clean

# Remove modules
remove :;
	rm -rf .gitmodules && \
	rm -rf .git/modules/* && \
	rm -rf lib && touch .gitmodules && \
	git add . && \
	git commit -m "chore: modules"

# Install dependencies
install:;
	forge install foundry-rs/forge-std && \
	forge install openzeppelin/openzeppelin-contracts

# Update dependencies
update :; forge update

# Build the project
build: build-dex build-modules

build-dex :; forge build

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
		--block-time ${blockTime} \
		--host 0.0.0.0

# Deploy contracts
deploy: deploy-dex deploy-modules

# Deploy DEX contracts
# This is the private key of account from the mnemonic from the "make anvil" command
deploy-dex :; @forge script script/scalable-dex/DeployStarkEx.s.sol:DeployStarkExScript \
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