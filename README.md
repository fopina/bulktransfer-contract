# BulkTransfer

<a href="">![tests](https://github.com/fopina/bulktransfer-contract/actions/workflows/test.yml/badge.svg)</a>
<a href="">![license](https://img.shields.io/github/license/fopina/bulktransfer-contract)</a>

[BulkTransfer](./src/BulkTransfer.sol) main use case is for an EOA to save some gas by batching multiple `transferFrom` calls.

## Usage

ABI is available in [Snowtrace](https://snowtrace.io/address/0xee5b5376d71d4af51bdc64ca353f51485fa8d6d5#code).

Check the [examples](examples).

## Deployments

Check [DEPLOYMENTS.md](DEPLOYMENTS.md)

## Security

**This contract is unaudited.**

## Development

This repo uses [Foundry]([https://github.com/gakonst/foundry](https://github.com/foundry-rs/foundry)) for development and testing
and git submodules for dependency management.

Clone the repo and run `forge test` to run tests.
Forge will automatically install any missing dependencies.
