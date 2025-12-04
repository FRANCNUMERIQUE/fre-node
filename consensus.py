class Consensus:
    def __init__(self, network, ledger, anchor):
        self.network = network
        self.ledger = ledger
        self.anchor = anchor

    def reach(self, block):
        signatures = self.network.collect_signatures(block)

        needed = int((2/3) * len(self.network.validators()))

        if len(signatures) >= needed:
            block.signatures = signatures
            return True
        return False
