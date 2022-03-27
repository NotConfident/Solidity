import pytest
from web3 import Web3, HTTPProvider
from web3.middleware import geth_poa_middleware
from brownie import accounts, config, Trade, network
from dotenv import load_dotenv
import os, os.path, sys, json, requests, time

load_dotenv()

avalanche = f"https://api.avax.network/ext/bc/C/rpc"
web3 = Web3(Web3.HTTPProvider(avalanche))
weiToEther = 1000000000000000000

def get_account():
    return accounts.add(config["wallets"]["from_key"])

def deployContract():
    account = get_account()
    return Trade.deploy({"from": account.address})

def returnABI(_token):
    abi = f'https://api.snowtrace.io/api?module=contract&action=getabi&address={_token}&apikey={os.getenv("ETHERSCAN_TOKEN")}'
    abi = requests.get(url = abi)
    abi = abi.json()
    return abi['result']

""" 
    Unit Test - Test if approve is valid

    Steps: 
    Deploy Contract
    Approve Token
    Retrieve ABI
    Call Tokens's allowance function and assert 
"""
def test_Approve():
    trade = deployContract()
    token0 = os.getenv('PATH0')

    trade.approve(token0)
    contract = web3.eth.contract(address = web3.toChecksumAddress(token0), abi=returnABI(token0))

    assert(contract.functions.allowance(f'{trade.owner()}', f'{trade.router()}').call() == 79228162514264337593543950335)


""" 
    Integration Test - Test both Approve and Swap

    Steps: 
    Deploy Contract
    Fund Contract
    Approve Contract
    Swap 
"""
def test_Swap():
    web3 = Web3(Web3.HTTPProvider('http://127.0.01:7545'))
    # web3.middleware_onion.inject(geth_poa_middleware, layer=0)

    trade = deployContract()
    token0 = os.getenv('PATH0')
    token1 = os.getenv('PATH1')
    userAddress = f"{os.getenv('USER_ADDRESS')}"
    path = [f"{token0}", f"{token1}"]

    abi = returnABI(token0)
    contract = web3.eth.contract(address = web3.toChecksumAddress(token0), abi=abi)
    token0Balance = contract.functions.balanceOf(userAddress).call()

    web3.eth.default_account = web3.eth.account.from_key(os.getenv('HOT_WALLET'))
    
    # Fund from Wallet to Contract
    txn = {
            'from': userAddress,
            'value': web3.toWei(0, 'ether'),
            'nonce': web3.eth.get_transaction_count(userAddress)
    }

    tx = contract.functions.transfer(trade.address, token0Balance)
    build_tx = tx.buildTransaction(txn)
    signed_tx = web3.eth.account.sign_transaction(build_tx, os.getenv('HOT_WALLET'))
    tx_hash = web3.eth.send_raw_transaction(signed_tx.rawTransaction)

    approve = trade.approve(token0)
    assert(str(approve.status) == "Status.Confirmed")

    swapTokens = trade.swapExactTokensForTokens(token0Balance, (token0Balance * 0.995), path, trade.address, 1679899143)
    assert(str(swapTokens.status) == "Status.Confirmed")

    # Optional
    abi = returnABI(token1)
    contract = web3.eth.contract(address = web3.toChecksumAddress(token1), abi=abi)
    token1Balance = contract.functions.balanceOf(trade.address).call({'from': userAddress})
    assert(token1Balance >= (token0Balance * 0.995))