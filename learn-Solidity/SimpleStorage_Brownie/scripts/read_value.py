from brownie import SimpleStorage, accounts, config


def read_contract():
    # Contract Address of first contract deployed
    # print(SimpleStorage[0])

    # -1 = Most recent deployed contract
    simple_storage = SimpleStorage[-1]

    print(simple_storage.retrieve())


def main():
    read_contract()
