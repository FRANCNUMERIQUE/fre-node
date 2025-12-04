from fre_node.validator import Validator
from fre_node.consensus import Consensus
from fre_node.network import NodeNetwork
from fre_node.ledger import Ledger
from fre_node.block_builder import BlockBuilder
from fre_node.anchor_client import AnchorClient
from fre_node.config import *

import time

print(f"[FRE-NODE] Démarrage du nœud {NODE_ID} - version {VERSION}")

ledger = Ledger()
validator = Validator()
network = NodeNetwork()
builder = BlockBuilder(ledger)
anchor = AnchorClient()
consensus = Consensus(network, ledger, anchor)

while True:
    txs = network.collect_transactions()
    valid_txs = validator.validate_all(txs)
    block = builder.build_block(valid_txs)

    if consensus.reach(block):
        builder.finalize_block(block)
        anchor.push_block(block)

    time.sleep(2)
