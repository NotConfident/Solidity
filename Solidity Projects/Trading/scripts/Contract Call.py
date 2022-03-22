from web3 import Web3, HTTPProvider
import os, sys, json
from dotenv import load_dotenv

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
load_dotenv()

local = f"http://127.0.0.1:7545"
web3 = Web3(Web3.HTTPProvider(local))

abi = [{"inputs": [], "stateMutability": "nonpayable", "type": "constructor", "name": "constructor"}, {"inputs": [], "name": "owner", "outputs": [{"internalType": "address", "name": "", "type": "address"}], "stateMutability": "view", "type": "function"}, {"inputs": [{"internalType": "uint256", "name": "amountIn", "type": "uint256"}, {"internalType": "uint256", "name": "amountOutMin", "type": "uint256"}, {"internalType": "address[]", "name": "path", "type": "address[]"}, {"internalType": "address", "name": "to", "type": "address"}, {"internalType": "uint256", "name": "deadline", "type": "uint256"}], "name": "swapExactTokensForTokens", "outputs": [{"internalType": "uint256[]", "name": "amounts", "type": "uint256[]"}], "stateMutability": "nonpayable", "type": "function"}]

# Private Key
spare_PrivateKey = os.getenv('HOT_WALLET')

tradeContract = web3.eth.contract(address = web3.toChecksumAddress('0xcEd56d1530a023321115c1aDB8Af606CB1b3729A'), abi=abi)
print(web3.eth.get_balance("0xA04C70cab4129a79936C651107cEE1149fB3B6be"))
# gas_estimate = linkContract.functions.approve(web3.toChecksumAddress('0xa63b4daae5daf69cd7299870588b8cc0085e8eb8'), 115792089237316195423570985008687907853269984665640564039457584007913129639935).estimateGas()

# txn = {
#     'from': '0xA04C70cab4129a79936C651107cEE1149fB3B6be',
#     'value': web3.toWei(0, 'ether'),
#     'gas': 500000,
#     'gasPrice': web3.toWei(2, 'gwei'),
#     'nonce': web3.eth.getTransactionCount('0xA04C70cab4129a79936C651107cEE1149fB3B6be')
# }

# deposit = tradeContract.functions.deposit(web3.toChecksumAddress('0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735'), 1000000000000000000)

# # Build the transaction with the contract data
# # buildTransaction = getApprove.buildTransaction(txn)
# buildTransaction = deposit.buildTransaction(txn)

# # Sign the transaction
# signed_tx = web3.eth.account.sign_transaction(buildTransaction, spare_PrivateKey)

# # Send transaction
# tx_hash = web3.eth.sendRawTransaction(signed_tx.rawTransaction)

# # Get transaction hash
# print(web3.toHex(tx_hash))