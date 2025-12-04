#!/bin/bash

USER_HOME=$(eval echo ~$USER)
REPO_DIR="$USER_HOME/fre-node"

echo "[INSTALL] Mise à jour du système..."
sudo apt update && sudo apt install -y python3 python3-pip python3-venv git

echo "[INSTALL] Clonage du repository FRE Node..."
if [ -d "$REPO_DIR" ]; then
    echo "[INSTALL] Le dossier fre-node existe déjà."
else
    git clone https://github.com/FRANCNUMERIQUE/fre-node.git $REPO_DIR
fi

cd $REPO_DIR

echo "[INSTALL] Création du venv..."
python3 -m venv venv
source venv/bin/activate

echo "[INSTALL] Installation des dépendances..."
pip install -r requirements.txt

echo "[INSTALL] Installation du service FRE Node..."
sudo cp system/fre-node.service /etc/systemd/system/fre-node.service
sudo systemctl daemon-reload
sudo systemctl enable fre-node
sudo systemctl start fre-node

echo "[INSTALL] Installation du système de mise à jour FRE..."
sudo cp scripts/update_node.sh /usr/local/bin/fre-node-update
sudo chmod +x /usr/local/bin/fre-node-update

echo "[INSTALL] Installation du service update..."
sudo cp system/fre-node-update.service /etc/systemd/system/
sudo cp system/fre-node-update.timer /etc/systemd/system/

sudo systemctl daemon-reload
sudo systemctl enable fre-node-update.timer
sudo systemctl start fre-node-update.timer

echo "[INSTALL] Installation terminée avec succès ✔"
