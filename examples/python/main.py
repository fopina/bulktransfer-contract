#!/usr/bin/env python3

import argparse
from pathlib import Path
from web3 import Web3
from web3.middleware import geth_poa_middleware

import abi

# Avalanche Fuji (Testnet)
PROVIDER_URL = 'https://api.avax-test.network/ext/bc/C/rpc'
# latest from DEPLOYMENTS.md
BULK_TRANSFER_ADDRESS = '0xf5c47cd4747322bd9065dd07ea6dd499256aa793'

# test ERC20 and ERC721 contracts
TEST_TOKEN_ADDRESS = '0x2cDBD48204929c6AD7b77CEd8d3E61364764E1D9'
TEST_NFT_ADDRESS = '0x6Dd6802E2189a8D94f6cc1A5180f6c893e0bE13b'


def balances(accounts, contract):
    print('Balances:')
    for a in accounts:
        _a = a.address
        _b = contract.functions.balanceOf(_a).call({"from": _a})
        print(f'{_a}: {_b}')


def main(argv=None):
    p = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p.add_argument('wallets', type=Path, help='File containing test wallet private keys (1 per line)')
    args = p.parse_args()

    web3 = Web3(Web3.HTTPProvider(PROVIDER_URL))
    web3.middleware_onion.inject(geth_poa_middleware, layer=0)

    accounts = [
        web3.eth.account.from_key(x)
        for x in args.wallets.read_text().splitlines()
    ]
    
    print('Accounts loaded:', [a.address for a in accounts])

    bulkContract = web3.eth.contract(
        address=web3.to_checksum_address(BULK_TRANSFER_ADDRESS),
        abi=abi.BULK_TRANSFER,
    )
    tokenContract = web3.eth.contract(
        address=web3.to_checksum_address(TEST_TOKEN_ADDRESS),
        abi=abi.PARTIAL_ERC20,
    )
    nftContract = web3.eth.contract(
        address=web3.to_checksum_address(TEST_NFT_ADDRESS),
        abi=abi.PARTIAL_ERC721
    )

    # ERC20
    balances(accounts, tokenContract)
    print(tokenContract.functions.approve(bulkContract.address, 2**256-1).transact({"from": accounts[0].address}))
    bulkContract.functions.bulkTransfer20(
        tokenContract.address,
        [
            (accounts[1].address, 10),
            (accounts[2].address, 10),
            (accounts[3].address, 10),
        ]
    ).call({"from": accounts[0].address})


if __name__ == '__main__':
    main()
