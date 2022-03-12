from brownie import accounts, config, Escrow, network


def deploy_Escrow():
    account = get_account()

    # Deploy Contract
    escrow = Escrow.deploy({"from": account}, publish_source=True)

def get_account():
    if network.show_active() == "development":
        return accounts[0]

    else:
        return accounts.add(config["wallets"]["from_key"])

def main():
    deploy_Escrow()
