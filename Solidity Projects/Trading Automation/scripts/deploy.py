from brownie import accounts, config, Trade, network


def deploy_Trade():
    account = get_account()

    # Deploy Contract
    trade = Trade.deploy({"from": account})

def get_account():
    # if network.show_active() == "development":
    #     return accounts[0]

    # else:
    return accounts.add(config["wallets"]["from_key"])

def main():
    deploy_Trade()
