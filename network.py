class NodeNetwork:
    def __init__(self):
        self.buffer = []

    def collect_transactions(self):
        return self.buffer

    def validators(self):
        return ["node1", "node2", "node3"]

    def collect_signatures(self, block):
        return ["signature1", "signature2"]

