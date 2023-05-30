PARTIAL_ERC20 = [
    {
        'inputs': [
            {'internalType': 'address', 'name': 'spender', 'type': 'address'},
            {'internalType': 'uint256', 'name': 'amount', 'type': 'uint256'},
        ],
        'name': 'approve',
        'outputs': [{'internalType': 'bool', 'name': '', 'type': 'bool'}],
        'stateMutability': 'nonpayable',
        'type': 'function',
    },
    {
        'inputs': [{'internalType': 'address', 'name': 'account', 'type': 'address'}],
        'name': 'balanceOf',
        'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}],
        'stateMutability': 'view',
        'type': 'function',
    },
    {
        'inputs': [
            {'internalType': 'address', 'name': 'recipient', 'type': 'address'},
            {'internalType': 'uint256', 'name': 'amount', 'type': 'uint256'},
        ],
        'name': 'transfer',
        'outputs': [{'internalType': 'bool', 'name': '', 'type': 'bool'}],
        'stateMutability': 'nonpayable',
        'type': 'function',
    },
    {
        'inputs': [
            {'internalType': 'address', 'name': 'sender', 'type': 'address'},
            {'internalType': 'address', 'name': 'recipient', 'type': 'address'},
            {'internalType': 'uint256', 'name': 'amount', 'type': 'uint256'},
        ],
        'name': 'transferFrom',
        'outputs': [{'internalType': 'bool', 'name': '', 'type': 'bool'}],
        'stateMutability': 'nonpayable',
        'type': 'function',
    },
]

PARTIAL_ERC721 = [
    {
        'inputs': [
            {'internalType': 'address', 'name': 'to', 'type': 'address'},
            {'internalType': 'uint256', 'name': 'tokenId', 'type': 'uint256'},
        ],
        'name': 'approve',
        'outputs': [],
        'stateMutability': 'nonpayable',
        'type': 'function',
    },
    {
        'inputs': [{'internalType': 'address', 'name': 'owner', 'type': 'address'}],
        'name': 'balanceOf',
        'outputs': [{'internalType': 'uint256', 'name': '', 'type': 'uint256'}],
        'stateMutability': 'view',
        'type': 'function',
    },
    {
        'inputs': [{'internalType': 'uint256', 'name': 'tokenId', 'type': 'uint256'}],
        'name': 'getApproved',
        'outputs': [{'internalType': 'address', 'name': '', 'type': 'address'}],
        'stateMutability': 'view',
        'type': 'function',
    },
    {
        'inputs': [
            {'internalType': 'address', 'name': 'owner', 'type': 'address'},
            {'internalType': 'address', 'name': 'operator', 'type': 'address'},
        ],
        'name': 'isApprovedForAll',
        'outputs': [{'internalType': 'bool', 'name': '', 'type': 'bool'}],
        'stateMutability': 'view',
        'type': 'function',
    },
    {
        'inputs': [
            {'internalType': 'address', 'name': 'from', 'type': 'address'},
            {'internalType': 'address', 'name': 'to', 'type': 'address'},
            {'internalType': 'uint256', 'name': 'tokenId', 'type': 'uint256'},
        ],
        'name': 'safeTransferFrom',
        'outputs': [],
        'stateMutability': 'nonpayable',
        'type': 'function',
    },
    {
        'inputs': [
            {'internalType': 'address', 'name': 'operator', 'type': 'address'},
            {'internalType': 'bool', 'name': 'approved', 'type': 'bool'},
        ],
        'name': 'setApprovalForAll',
        'outputs': [],
        'stateMutability': 'nonpayable',
        'type': 'function',
    },
    {
        'inputs': [
            {'internalType': 'address', 'name': 'from', 'type': 'address'},
            {'internalType': 'address', 'name': 'to', 'type': 'address'},
            {'internalType': 'uint256', 'name': 'tokenId', 'type': 'uint256'},
        ],
        'name': 'transferFrom',
        'outputs': [],
        'stateMutability': 'nonpayable',
        'type': 'function',
    },
]

BULK_TRANSFER = [
    {
        "inputs":[
            {"internalType":"address","name":"token","type":"address"},
            {
                "components":[
                    {"internalType":"address","name":"to","type":"address"},
                    {"internalType":"uint256","name":"amountOrTokenId","type":"uint256"}
                ],
                "internalType":"struct BulkTransfer.Call[]","name":"calls","type":"tuple[]"
            },
        ],
        "name":"bulkTransfer20",
        "outputs":[],
        "stateMutability":"nonpayable",
        "type":"function"
    },
    {
        "inputs":[
            {"internalType":"address","name":"token","type":"address"},
            {
                "components":[
                    {"internalType":"address","name":"to","type":"address"},
                    {"internalType":"uint256","name":"amountOrTokenId","type":"uint256"}
                ],
                "internalType":"struct BulkTransfer.Call[]",
                "name":"calls",
                "type":"tuple[]",
            }
        ],
        "name":"bulkTransfer721",
        "outputs":[],
        "stateMutability":"nonpayable",
        "type":"function"
    },
    {
        "inputs":[
            {
                "internalType":"address",
                "name":"token",
                "type":"address"
            },
            {
                "internalType":"address",
                "name":"to",
                "type":"address"
            },
            {
                "internalType":"uint256[]",
                "name":"tokenIds",
                "type":"uint256[]"
            }
        ],
        "name":"bulkTransfer721Lite",
        "outputs":[],
        "stateMutability":"nonpayable",
        "type":"function"
    }
]
