# BulkTransfer

<a href="">![tests](https://github.com/fopina/bulktransfer-contract/actions/workflows/test.yml/badge.svg)</a>
<a href="">![license](https://img.shields.io/github/license/fopina/bulktransfer-contract)</a>

[BulkTransfer](./src/BulkTransfer.sol) main use case is for an EOA to save some gas by batching multiple `transferFrom` calls.

It has 3 functions

| function | description | [gas comments](.gas-snapshot) |
| -------- | ----------- | ------------ |
| `bulkTransfer20(address token, Call[] calls)` | Transfers ERC20 `token` to an array of `(target, amount)` tuples. | Comparing `testGasBaseline20` with `testGasTransfer20*`, it's not worth using for less than 4 transfers |
| `bulkTransfer721(address token, Call[] calls)` | Transfer ERC721 `token` to an array of `(target, tokenId)` tuples. | Comparing `testGasBaseline721` with `testGasTransfer721*`, it's already slightly worth for 2 transfers (and it gets better) |
| `bulkTransfer721Lite(address token, address to, uint256[] tokenIds)` | Transfer an array of `tokenIds` of ERC721 `token` to a single address. | Comparing `testGasBaseline721` with `testGasTransfer721Lite*`, it's already quite worth for 2 transfers (and it gets even better) |

> Do not forget either `approve` (ERC20/721) or `setApprovalForAll` (ERC721) need to be used before any of these.

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
