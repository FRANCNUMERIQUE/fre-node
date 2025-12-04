class Consensus:
    def __init__(self, network, ledger, anchor):
        self.network = network
        self.ledger = ledger
        self.anchor = anchor

    def reach(self, block):
        signatures = self.network.collect_signatures(block)
        return len(signatures) >= 2  # consensus simplifié
