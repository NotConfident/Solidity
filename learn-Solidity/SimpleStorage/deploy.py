import json
from tokenize import maybe
from solcx import compile_standard, install_solc
from web3 import Web3
import os
from dotenv import load_dotenv

# Look for and load .env file
load_dotenv()
install_solc("0.6.0")

with open("./SimpleStorage.sol", "r") as file:
    simple_storage_file = file.read()

# Compile Solidity Code
compliled_sol = compile_standard(
    {
        "language": "Solidity",
        "sources": {"SimpleStorage.sol": {"content": simple_storage_file}},
        "settings": {
            "outputSelection": {
                "*": {"*": ["abi", "metadata", "evm.bytecode", "evm.sourceMap"]}
            }
        },
    },
    solc_version="0.6.0",
)

# Create json file containing output from compilation
with open("compiled_code.json", "w") as file:
    json.dump(compliled_sol, file)

# Get bytecode
bytecode = compliled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["evm"][
    "bytecode"
]["object"]

# Get ABI
abi = compliled_sol["contracts"]["SimpleStorage.sol"]["SimpleStorage"]["abi"]


# Connect to Ganache / Alchemy
w3 = Web3(
    Web3.HTTPProvider(
        f"https://eth-rinkeby.alchemyapi.io/v2/{os.getenv('ALCHEMY_API')}"
    )
)
chain_id = 4
address = "0x7432bbdd46899B0Cb213E8ec7fA84D06ff817290"
private_key = os.getenv("PRIVATE_KEY")

# ======== Creating Contract ========

# Create contract
SimpleStorage = w3.eth.contract(abi=abi, bytecode=bytecode)

# Build Tx
nonce = w3.eth.getTransactionCount(address)
transaction = SimpleStorage.constructor().buildTransaction(
    {"gasPrice": w3.eth.gas_price, "chainId": chain_id, "from": address, "nonce": nonce}
)

# Sign Tx
signed_tx = w3.eth.account.sign_transaction(transaction, private_key=private_key)

# Broadcast signed tx
tx_hash = w3.eth.send_raw_transaction(signed_tx.rawTransaction)

# Wait for transaction to confirm
tx_receipt = w3.eth.wait_for_transaction_receipt(tx_hash)


# ======== Contract Interaction ========

# Interact with Contract
simple_storage = w3.eth.contract(address=tx_receipt.contractAddress, abi=abi)

# Call = A Stimulate to get a reuturn value
# Transact = Make on chain changes
# Build Tx
store_transaction = simple_storage.functions.store(15).buildTransaction(
    {
        "gasPrice": w3.eth.gas_price,
        "chainId": chain_id,
        "from": address,
        "nonce": nonce + 1,
    }
)

# Sign Tx
signed_store_txn = w3.eth.account.sign_transaction(
    store_transaction, private_key=private_key
)

# Broadcast signed tx
send_stored_tx = w3.eth.send_raw_transaction(signed_store_txn.rawTransaction)

# Wait for transaction to confirm
send_stored_tx_receipt = w3.eth.wait_for_transaction_receipt(send_stored_tx)
