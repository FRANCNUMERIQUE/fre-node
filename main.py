import time
from fre_node.validator import Validator
from fre_node.network import Network
from fre_node.consensus import Consensus
from fre_node.ledger import Ledger
from fre_node.block_builder import BlockBuilder
from fre_node.anchor_client import AnchorClient
from fre_node.config import NODE_NAME


class Node:
    """Nœud FRE Layer 2"""

    def __init__(self):
        self.name = NODE_NAME
        self.network = Network(self.name)
        self.ledger = Ledger()
        self.validator = Validator(self.ledger)
        self.consensus = Consensus(self.validator, self.network)
        self.block_builder = BlockBuilder(self.ledger)
        self.anchor_client = AnchorClient()

    def start(self):
        print(f"[FRE-NODE] Démarrage du nœud : {self.name}")

        while True:
            # Construire un bloc simulé
            block = self.block_builder.build_block()

            # Ajouter le bloc au ledger
            self.ledger.add_block(block)

            # Émettre le bloc sur le réseau
            self.network.broadcast_block(block)

            # Essayer d’ancrer un bloc (simulé)
            self.anchor_client.send_anchor(block)

            time.sleep(2)


if __name__ == "__main__":
    node = Node()
    node.start()
