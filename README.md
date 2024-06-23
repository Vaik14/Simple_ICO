Simple_ICO
Simple_ICO is a project that includes a token with specific tokenomics and a burn mechanism which allows the burning of 5% of the allocated burn amount every 3 months. Additionally, it includes an ICO contract through which the token can be sold in three phases at different prices.

Documentation
Token Contract
The token contract has the following features:

Tokenomics: Allocation for sale, burn, and reserve.
Burn Mechanism: Burns 5% of the allocated burn amount every 3 months.
Minting: Allows minting for sale, burn, and reserve allocations.
Transfer: Standard ERC20 transfer functions.
Sale Contract
The sale contract facilitates the token sale through three phases with different prices:

Phase One: Initial phase with the lowest price.
Phase Two: Second phase with a moderate price increase.
Phase Three: Final phase with the highest price.
Usage
Build
To build the project, run:

shell
Copy code
$ forge build


Test
To test the project, run:

shell
Copy code
$ forge test
Format
To format the code, run:

shell
Copy code
$ forge fmt
Gas Snapshots
To take gas snapshots, run:

shell
Copy code
$ forge snapshot
Anvil
To start a local Ethereum node with Anvil, run:

shell
Copy code
$ anvil
Deploy
To deploy the contract, run:

shell
Copy code
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
Cast
To interact with the contract using cast, run:

shell
Copy code
$ cast <subcommand>
Help
For help with the tools, run:

shell
Copy code
$ forge --help
$ anvil --help
$ cast --help
