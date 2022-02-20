from brownie import SimpleStorage, accounts


def test_Deploy():
    expected_value = 0
    account = accounts[0]

    # Deploy Contract
    simple_storage = SimpleStorage.deploy({"from": account})
    starting_value = simple_storage.retrieve()

    assert starting_value == expected_value


def test_UpdateStorage():
    expected_value = 15
    account = accounts[0]

    # Deploy Contract
    simple_storage = SimpleStorage.deploy({"from": account})
    simple_storage.store(expected_value, {"from": account})

    assert simple_storage.retrieve() == expected_value
