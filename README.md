# FundMe Project

## Overview

The **FundMe** project is a decentralized funding contract built on the Ethereum blockchain. It allows users to fund the contract with ETH and enables the owner to withdraw the funds. The project utilizes Chainlink's price feeds to ensure that the funding amounts meet a minimum threshold in USD.

## Features

- Users can fund the contract with ETH.
- The contract checks the current ETH/USD price using Chainlink oracles.
- Only the contract owner can withdraw the funds.
- Supports multiple funders and keeps track of their contributions.

## Technologies Used

- Solidity
- Ethereum
- Chainlink
- Forge (for testing and deployment)

## Installation

To get started with the FundMe project, follow these steps:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/cgrade/fundme.git
   cd fundme
   ```

2. **Install dependencies:**
   Make sure you have [Foundry](https://book.getfoundry.sh/) installed. If not, you can install it using:

   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

3. **Install required libraries:**
   ```bash
   forge install
   ```

## Usage

### Deployment

To deploy the FundMe contract, run the following command:

```bash
forge script script/DeployFundMe.s.sol --broadcast
```

This will deploy the FundMe contract to the active network specified in the `HelperConfig` script.

### Testing

To run the tests for the FundMe contract, use the following command:

```bash
forge test
```

This will execute all the tests defined in the `test/FundMeTest.t.sol` file.

## Contract Structure

- **`script/DeployFundMe.s.sol`**: Script for deploying the FundMe contract.
- **`src/FundMe.sol`**: Main contract that handles funding and withdrawals.
- **`script/HelperConfig.s.sol`**: Provides network-specific configurations for deployment.
- **`test/FundMeTest.t.sol`**: Contains tests for the FundMe contract.
- **`test/mocks/MockV3Aggregator.t.sol`**: Mock contract for testing price feeds.

## Contributing

Contributions are welcome! If you have suggestions for improvements or new features, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Chainlink](https://chain.link/) for providing reliable price feeds.
- [Foundry](https://book.getfoundry.sh/) for the development and testing framework.
