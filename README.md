# BulkTransfer

<a href="">![tests](https://github.com/fopina/bulktransfer-contract/actions/workflows/test.yml/badge.svg)</a>
<a href="">![license](https://img.shields.io/github/license/fopina/bulktransfer-contract)</a>

[BulkTransfer](./src/BulkTransfer.sol) main use case is for an EOA to save some gas by batching multiple `transferFrom` calls.

## Usage

Multicall3 has two main use cases:

- Aggregate results from multiple contract reads into a single JSON-RPC request.
- Execute multiple state-changing calls in a single transaction.

Because it can be used for both use cases, no methods in this contract are `view`, and all can mutate state and are `payable`.

## Deployments and ABI

Multicall3 is deployed on over 70 chains at `0xcA11bde05977b3631167028862bE2a173976CA11`[^2].
A sortable, searchable list of all chains it's deployed on can be found at https://multicall3.com/deployments.
To request a Multicall3 deployment to a new chain, please [open an issue](https://github.com/mds1/multicall/issues/new?assignees=mds1&labels=Deployment+Request&projects=&template=deployment_request.yml).
You can speed up the new deploy by sending funds to cover the deploy cost to the deployer account: `0x05f32B3cC3888453ff71B01135B34FF8e41263F2`

The ABI can be found on https://multicall3.com/abi, where it can be downloaded or copied to the clipboard in various formats, including:

- Solidity interface.
- JSON ABI, prettified.
- JSON ABI, minified.
- ethers.js human readable ABI.
- viem human readable ABI.

Alternatively, you can:

- Download the ABI from the [releases](https://github.com/mds1/multicall/releases) page.
- Copy the ABI from [Etherscan](https://etherscan.io/address/0xcA11bde05977b3631167028862bE2a173976CA11#code).
- Install [Foundry](https://github.com/gakonst/foundry/) and run `cast interface 0xcA11bde05977b3631167028862bE2a173976CA11`.

## Security

**This contract is unaudited.**

For on-chain transactions:

- Ensure it never holds your funds after a transaction ends. If it does hold funds, anyone can steal them.
- Never approve Multicall3 to spend your tokens. If you do, anyone can steal your tokens.
- Be sure you understand CALL vs. DELEGATECALL behavior depending on your use case. See the [Batch Contract Writes](#batch-contract-writes) section for more details.

For off-chain reads the worst case scenario is you get back incorrect data, but this should not occur for properly formatted calls.

## Development

This repo uses [Foundry](https://github.com/gakonst/foundry) for development and testing
and git submodules for dependency management.

Clone the repo and run `forge test` to run tests.
Forge will automatically install any missing dependencies.

The repo for https://multicall3.com can be found [here](https://github.com/mds1/multicall3-frontend).

## Gas Golfing Tricks and Optimizations

Below is a list of some of the optimizations used by Multicall3's `aggregate3` and `aggregate3Value` methods[^3]:

- In `for` loops, array length is cached to avoid reading the length on each loop iteration.
- In `for` loops, the counter is incremented within an `unchecked` block.
- In `for` loops, the counter is incremented with the prefix increment (`++i`) instead of a postfix increment (`i++`).
- All revert strings fit within a single 32 byte slot.
- Function parameters use `calldata` instead of `memory`.
- Instead of requiring `call.allowFailure || result.success`, we use assembly's `or()` instruction to [avoid](https://twitter.com/transmissions11/status/1501645922266091524) a `JUMPI` and `iszero()` since it's cheaper to evaluate both conditions.
- Methods are given a `payable` modifier which removes a check that `msg.value == 0` when calling a method.
- Calldata and memory pointers are used to cache values so they are not read multiple times within a loop.
- No block data (e.g. block number, hash, or timestamp) is returned by default, and is instead left up to the caller.
- The value accumulator in `aggregate3Value` is within an `unchecked` block.

Read more about Solidity gas optimization tips:

- [Generic writeup about common gas optimizations, etc.](https://gist.github.com/hrkrshnn/ee8fabd532058307229d65dcd5836ddc) by [Harikrishnan Mulackal](https://twitter.com/_hrkrshnn)
- [Yul (and Some Solidity) Optimizations and Tricks](https://hackmd.io/@gn56kcRBQc6mOi7LCgbv1g/rJez8O8st) by [ControlCplusControlV](https://twitter.com/controlcthenv)

[^1]: [`Multicall`](./src/Multicall.sol) is the original contract, and [`Multicall2`](./src/Multicall2.sol) added support for handling failed calls in a multicall. [`Multicall3`](./src/Multicall3.sol) is recommended over these because it's backwards-compatible with both, cheaper to use, adds new methods, and is deployed on more chains. You can read more about the original contracts and their deployments in the [makerdao/multicall](https://github.com/makerdao/multicall) repo.
[^2]: There are a few unofficial deployments at other addresses for chains that compute addresses differently, which can also be found at
[^3]: Some of these tricks are outdated with newer Solidity versions and via-ir. Be sure to benchmark your code before assuming the changes are guaranteed to reduce gas usage.
