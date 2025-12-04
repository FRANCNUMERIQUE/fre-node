import json
import os

class Ledger:
    def __init__(self):
        os.makedirs("data/ledger", exist_ok=True)

    def write_block(self, block):
        index = block["index"]
        with open(f"data/ledger/block_{index:06}.json", "w") as f:
            json.dump(block, f)

