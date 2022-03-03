from brownie import accounts, config, SimpleStorage, network


def deploy_simple_storage():
    account = get_account()

    # brownie accounts new [name] - create new account with prefined key
    # brownie accounts list - view list of pre-defined account
    # brownie accounts delete [name] - delete account
    # account = accounts.load("learn-solidity")

    # Get account from .env using .yml
    # account = accounts.add(config["wallets"]["from_key"])

    # Deploy Contract
    simple_storage = SimpleStorage.deploy({"from": account})

    # Call contract function
    stored_value = simple_storage.retrieve()
    print(stored_value)

    # Making state / on chain change
    transaction = simple_storage.store(15, {"from": account})
    transaction.wait(1)

    # Call contract function
    updated_stored_value = simple_storage.retrieve()
    print(updated_stored_value)


def get_account():
    if network.show_active() == "development":
        return accounts[0]

    else:
        return accounts.add(config["wallets"]["from_key"])


def main():
    deploy_simple_storage()
