from brownie import accounts, config, GLDToken, network


def deploy_simple_storage():
    account = get_account()

    # brownie accounts new [name] - create new account with prefined key
    # brownie accounts list - view list of pre-defined account
    # brownie accounts delete [name] - delete account
    # account = accounts.load("learn-solidity")

    # Get account from .env using .yml
    # account = accounts.add(config["wallets"]["from_key"])

    # Deploy Contract
    token = GLDToken.deploy(1000000, {"from": account})

def get_account():
    if network.show_active() == "development":
        return accounts[0]

    else:
        return accounts.add(config["wallets"]["from_key"])


def main():
    deploy_simple_storage()
