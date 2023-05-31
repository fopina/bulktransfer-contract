#!/usr/bin/env python3

import argparse
from pathlib import Path
from web3 import Web3
from web3.middleware import geth_poa_middleware

import abi

DECS = 1000000000000000000

# Avalanche Fuji (Testnet)
PROVIDER_URL = 'https://api.avax-test.network/ext/bc/C/rpc'
# latest from DEPLOYMENTS.md
BULK_TRANSFER_ADDRESS = '0xf5c47cd4747322bd9065dd07ea6dd499256aa793'

# test ERC20 and ERC721 contracts
TEST_TOKEN_ADDRESS = '0x2cDBD48204929c6AD7b77CEd8d3E61364764E1D9'
TEST_NFT_ADDRESS = '0x6Dd6802E2189a8D94f6cc1A5180f6c893e0bE13b'
# token IDs to use for NFT bulk transfer - must be 6
TEST_TOKEN_IDS = [10, 11, 12, 13, 14, 15]


def _transact(web3, call, account):
    # web.py .transact() does not work with this AVAX RPC URL `the method eth_sendTransaction is not available`
    # use send_raw_transaction instead
    nonce = web3.eth.get_transaction_count(account.address)
    tx = call.build_transaction({"nonce": nonce, "from": account.address})
    stx = account.sign_transaction(tx)
    tx_hash = web3.eth.send_raw_transaction(stx.rawTransaction)
    return web3.eth.wait_for_transaction_receipt(tx_hash, timeout=120)


def main(argv=None):
    p = argparse.ArgumentParser(formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    p.add_argument('wallets', type=Path, help='File containing test wallet private keys: needs 4, 1 per line - and first should have token and NFTs')
    p.add_argument('--reset', action='store_true', help='Undo every default action')
    args = p.parse_args(argv)

    web3 = Web3(Web3.HTTPProvider(PROVIDER_URL))
    web3.middleware_onion.inject(geth_poa_middleware, layer=0)

    accounts = [
        web3.eth.account.from_key(x)
        for x in args.wallets.read_text().splitlines()
    ]
    
    print('Accounts loaded:', [a.address for a in accounts])

    bulk_contract = web3.eth.contract(
        address=web3.to_checksum_address(BULK_TRANSFER_ADDRESS),
        abi=abi.BULK_TRANSFER,
    )
    token_contract = web3.eth.contract(
        address=web3.to_checksum_address(TEST_TOKEN_ADDRESS),
        abi=abi.PARTIAL_ERC20,
    )
    nft_contract = web3.eth.contract(
        address=web3.to_checksum_address(TEST_NFT_ADDRESS),
        abi=abi.PARTIAL_ERC721
    )

    if args.reset:
        reset(web3, accounts, token_contract)
        reset_nfts(web3, accounts, nft_contract)
        return

    # ERC20
    balances(accounts, token_contract)

    print()
    report_gas(
        'Approval for token',
        _transact(web3, token_contract.functions.approve(bulk_contract.address, 2**256-1), accounts[0]),
    )
    report_gas(
        'Approval for NFT',
        _transact(web3, nft_contract.functions.setApprovalForAll(bulk_contract.address, True), accounts[0]),
    )
    report_gas(
        'bulkTransfer20 3x',
        _transact(
            web3,
            bulk_contract.functions.bulkTransfer20(
                token_contract.address,
                [
                    (accounts[1].address, 1 * DECS),
                    (accounts[2].address, 1 * DECS),
                    (accounts[3].address, 1 * DECS),
                ]
            ),
            accounts[0],
        ),
    )
    report_gas(
        'bulkTransfer721 3x',
        _transact(
            web3,
            bulk_contract.functions.bulkTransfer721(
                nft_contract.address,
                [
                    (accounts[1].address, TEST_TOKEN_IDS[0]),
                    (accounts[2].address, TEST_TOKEN_IDS[1]),
                    (accounts[3].address, TEST_TOKEN_IDS[2]),
                ]
            ),
            accounts[0],
        ),
    )
    reset_nfts(web3, accounts[:4], nft_contract)
    report_gas(
        'bulkTransfer721 6x',
        _transact(
            web3,
            bulk_contract.functions.bulkTransfer721(
                nft_contract.address,
                [
                    (accounts[1].address, TEST_TOKEN_IDS[0]),
                    (accounts[2].address, TEST_TOKEN_IDS[1]),
                    (accounts[3].address, TEST_TOKEN_IDS[2]),
                    (accounts[1].address, TEST_TOKEN_IDS[3]),
                    (accounts[2].address, TEST_TOKEN_IDS[4]),
                    (accounts[3].address, TEST_TOKEN_IDS[5]),
                ]
            ),
            accounts[0],
        ),
    )
    reset_nfts(web3, accounts, nft_contract)
    report_gas(
        'bulkTransfer721Lite 3x',
        _transact(
            web3,
            bulk_contract.functions.bulkTransfer721Lite(
                nft_contract.address,
                accounts[1].address,
                TEST_TOKEN_IDS[3:]
            ),
            accounts[0],
        ),
    )
    reset_nfts(web3, accounts[:4], nft_contract)
    report_gas(
        'bulkTransfer721Lite 6x',
        _transact(
            web3,
            bulk_contract.functions.bulkTransfer721Lite(
                nft_contract.address,
                accounts[1].address,
                TEST_TOKEN_IDS
            ),
            accounts[0],
        ),
    )
    print()

    balances(accounts, token_contract)


def balances(accounts, contract):
    print('Balances:')
    for a in accounts:
        _a = a.address
        _b = contract.functions.balanceOf(_a).call({"from": _a})
        print(f'{_a}: {_b / DECS}')


def report_gas(desc, tx):
    fee = tx['gasUsed'] * tx['effectiveGasPrice'] / DECS
    print(f'{desc} ({fee})')


def reset(web3, accounts, token_contract):
    main, *others = accounts
    for a in others:
        _a = a.address
        _b = token_contract.functions.balanceOf(_a).call({"from": _a})
        if _b > 0:
            report_gas(
                f'Restore {_b / DECS} from {_a}',
                _transact(web3, token_contract.functions.transfer(main.address, _b), a),
            )


def reset_nfts(web3, accounts, nft_contract):
    main = accounts[0]
    a_dict = {
        a.address: a
        for a in accounts
    }

    for token_id in TEST_TOKEN_IDS:
        owner = nft_contract.functions.ownerOf(token_id).call()
        if owner != main.address:
            a = a_dict[owner]
            _a = a.address
            report_gas(
                f'Restore NFT {token_id} from {_a}',
                _transact(web3, nft_contract.functions.transferFrom(_a, main.address, token_id), a),
            )


if __name__ == '__main__':
    main()
