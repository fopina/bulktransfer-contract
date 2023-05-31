# Python Example

This python examples uses the official [web3.py](https://github.com/ethereum/web3.py) (because every other smart contract library uses this one underneath).

It shows how to use all the 3 functions in this contract:
* bulkTransfer721Lite
* bulkTransfer721
* bulkTransfer20

And also allows for some real-world gas testing (instead of `forge test/snapshot`).

## Usage

* Install requirements
    ```
    pip install -r requirements.txt
    ```

* Create a file `conf.local` with 4 accounts
    * First one needs:
        * Balance of an ERC20 token (`TEST_TOKEN_ADDRESS`)
        * 6 tokens of an ERC721 token (`TEST_NFT_ADDRESS` and `TEST_TOKEN_IDS`)
    * Others only need AVAX for the transaction fees

* Run it
    ```
    $ ./main.py conf.local
    Accounts loaded: ['0x76e..', '0xd99..', '0xcc..', '0x9ED..']
    Balances:
    0x76e..: 1999500000.0
    0xd99..: 0.0
    0xccB..: 0.0
    0x9ED..: 0.0

    Approval for token (0.000683075)
    Approval for NFT (0.00066925)
    bulkTransfer20 3x (0.002933825)
    bulkTransfer721 3x (0.0035493)
    Restore NFT 10 from 0xd99.. (0.0011558)
    Resto.. NFT 11 from 0xcc.. (0.0011558)
    Restore NFT 12 from 0x9ED.. (0.0011558)
    bulkTransfer721 6x (0.004617)
    Restore NFT 10 from 0xd99.. (0.0015833)
    Resto.. NFT 11 from 0xcc.. (0.0011558)
    Restore NFT 12 from 0x9ED.. (0.0011558)
    Restore NFT 13 from 0xd99.. (0.0011558)
    Resto.. NFT 14 from 0xcc.. (0.0011558)
    Restore NFT 15 from 0x9ED.. (0.0011558)
    bulkTransfer721Lite 3x (0.002425775)
    Restore NFT 13 from 0xd99.. (0.0011558)
    Restore NFT 14 from 0xd99.. (0.0011558)
    Restore NFT 15 from 0xd99.. (0.0011558)
    bulkTransfer721Lite 6x (0.003453275)

    Balances:
    0x76e..: 1999499997.0
    0xd99..: 1.0
    0xccB..: 1.0
    0x9ED..: 1.0
    ```

* Reset - send all balance and NFTs back to first account
    ```
    $ ./main.py conf.local
    ```
