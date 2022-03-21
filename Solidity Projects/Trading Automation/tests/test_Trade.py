import pytest
from web3 import Web3, HTTPProvider
from brownie import accounts, config, Trade, network
from dotenv import load_dotenv
import os, sys, json, requests

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
load_dotenv()

avalanche = f"https://api.avax.network/ext/bc/C/rpc"
web3 = Web3(Web3.HTTPProvider(avalanche))

# Deploy
def init():
    account = get_account()
    return Trade.deploy({"from": account})

# Unit Test - Test if approve is valid
# Steps: 
# - Deploy Contract
# - Approve Token
# - Retrieve ABI
# - Call Tokens's allowance function and assert
def test_Approve():
    trade = init()
    _token = "0x22d4002028f537599bE9f666d1c4Fa138522f9c8"
    trade.approve(_token)

    abi = f'https://api.snowtrace.io/api?module=contract&action=getabi&address={_token}&apikey={os.getenv("ETHERSCAN_TOKEN")}'
    abi = requests.get(url = abi)
    abi = abi.json()
    contract = web3.eth.contract(address = web3.toChecksumAddress(_token), abi=abi['result'])

    assert(contract.functions.allowance(f'{trade.owner()}', f'{trade.router()}').call() ==  79228162514264337593543950335)

def get_account():
    return accounts.add(config["wallets"]["from_key"])

