import socket
import json

class NodeNetwork:

    def __init__(self):
        self.nodes = []      # liste des autres nœuds
        self.buffer = []

    def collect_transactions(self):
        return self.buffer

    def broadcast_block(self, block):
        payload = json.dumps(block.to_dict())
        # envoi TCP ou websocket
        pass

    def collect_signatures(self, block):
        # reçoit signatures des pairs
        return []
