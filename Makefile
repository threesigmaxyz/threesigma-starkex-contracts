-include .env

all: clean remove install update build

# Clean the repo
clean :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

# Install dependencies
install :; yarn install && forge install foundry-rs/forge-std

# Update dependencies
update :; forge update

# Build the project
build :; forge build

# Run tests
test :; forge test

# Take chain snapshot
snapshot :; forge snapshot

# Run slither static analysis
slither :; slither ./src 

format :; yarn prettier

# Run Solhint linter
lint :; yarn lint

# Deploy a local blockchain
anvil :; anvil -m 'test test test test test test test test test test test junk' --block-time ${blockTime}

# This is the private key of account from the mnemonic from the "make anvil" command
deploy :; @forge script script/Deployment.s.sol:DeploymentScript --rpc-url http://localhost:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast
