class Validator:
    def validate(self, tx):
        return True

    def validate_all(self, txs):
        return [tx for tx in txs if self.validate(tx)]

