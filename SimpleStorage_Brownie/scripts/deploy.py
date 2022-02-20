from brownie import accounts, config, SimpleStorage


def deploy_simple_storage():
    account = accounts[0]
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


def main():
    deploy_simple_storage()
