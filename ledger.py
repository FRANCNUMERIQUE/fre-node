import json
import os

class Ledger:
    def __init__(self):
        self.path = "data/ledger/"
        os.makedirs(self.path, exist_ok=True)

    def write_block(self, block):
        with open(f"{self.path}/block_{block.index:06}.json", "w") as f:
            json.dump(block.to_dict(), f)
