import time
from fre_node.validator import Validator
from fre_node.network import Network
from fre_node.consensus import Consensus
from fre_node.ledger import Ledger
from fre_node.block_builder import BlockBuilder
from fre_node.anchor_client import AnchorClient
from fre_node.config import NODE_NAME

import requests

DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1446582993002037350/H_tC0C0XEejMcT0OGvDCmNRgtAUPe_R5MYU_Kz-LaBvVqZAv-IpfPEIghkaRdNXi2LEa"

def send_discord(message):
    try:
        requests.post(
            DISCORD_WEBHOOK,
            json={"content": message},
            timeout=2
        )
    except:
        pass  # on ignore les erreurs réseau


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
            with open("last_block.txt", "a") as f:
                f.write(str(block["id"]) + "\n")

            
            # 🔥 Notification Discord
            send_discord(f"📦 Nouveau bloc validé par {self.name} — ID: {block['id']}")

            # Émettre le bloc sur le réseau
            self.network.broadcast_block(block)

            # Essayer d’ancrer un bloc (simulé)
            self.anchor_client.send_anchor(block)

            time.sleep(2)


if __name__ == "__main__":
    node = Node()
    node.start()
