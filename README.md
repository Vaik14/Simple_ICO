## Sample_ICO
Sample_ICO is a project that includes a token with specific tokenomics and a burn mechanism which allows the burning of 5% of the allocated burn amount every 3 months. Additionally, it includes an ICO contract through which the token can be sold in three phases at different prices.

## Documentation

# Token Contract
The token contract has the following features:

# Tokenomics: Allocation for sale, burn, and reserve.

# Burn Mechanism: Burns 5% of the allocated burn amount every 3 months.
# Minting: Allows minting for sale, burn, and reserve allocations.

# Transfer: Standard ERC20 transfer functions.

# Sale Contract
The sale contract facilitates the token sale through three phases with different prices:
- **Phase One:** Initial phase with the lowest price.
- **Phase Two:** Second phase with a moderate price increase.
- **Phase Three:** Final phase with the highest price.



## Requirements For Initial Setup

Ensure the following prerequisites are installed:

- **Git:** Install the MetaMask browser extension.
- **Foundry:** You'll know you did it right if you can run forge --version and you see a response like forge 0.2.0 


## Getting Started

Follow these steps to set up Tokenmaster locally:

### 1. Clone/Download the Repository

Clone the repository or download the source files.


# Usage

# Build
To build the project, run:

```shell
$ forge build
```

# Test
To test the project, run:

```shell
$ forge test
```

# Format
To format the code, run:

```shell
$ forge fmt
```

#Gas Snapshots
To take gas snapshots, run:

```shell
$ forge snapshot
```

# Anvil
To start a local Ethereum node with Anvil, run:

```shell
$ anvil
```

# Deploy
To deploy the contract, run:

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

# Cast
To interact with the contract using cast, run:

```shell
$ cast <subcommand>
```

# Help
For help with the tools, run:

```shell
$ forge --help
$ anvil --help
$ cast --help
```
