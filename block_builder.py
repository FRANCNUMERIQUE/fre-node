class BlockBuilder:
    def __init__(self, ledger):
        self.ledger = ledger
        self.index = 0

    def build_block(self, txs):
        block = {
            "index": self.index + 1,
            "txs": txs,
        }
        return block

    def finalize_block(self, block):
        self.index = block["index"]
        self.ledger.write_block(block)
