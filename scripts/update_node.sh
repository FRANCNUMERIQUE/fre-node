#!/bin/bash

LOG_FILE="/home/aliasvava/fre-node/update/update.log"
NODE_DIR="/home/aliasvava/fre-node"
VENV="$NODE_DIR/venv/bin/python3"
BACKUP_DIR="$NODE_DIR/.backup"

echo "=================================================" | tee -a $LOG_FILE
echo "[UPDATE] Démarrage du script de mise à jour..." | tee -a $LOG_FILE
date | tee -a $LOG_FILE
echo "=================================================" | tee -a $LOG_FILE

cd "$NODE_DIR"

# 1) Vérification de l’accès Git
echo "[CHECK] Vérification accès Git..." | tee -a $LOG_FILE
if ! git fetch origin 2>>$LOG_FILE; then
    echo "[ERROR] Impossible de contacter GitHub. Abandon." | tee -a $LOG_FILE
    exit 1
fi

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" == "$REMOTE" ]; then
    echo "[INFO] Dépôt déjà à jour. Aucune action." | tee -a $LOG_FILE
    exit 0
fi

echo "[UPDATE] Nouvelle version détectée : préparation mise à jour." | tee -a $LOG_FILE

# 2) Création d'une sauvegarde
echo "[BACKUP] Création d'une sauvegarde..." | tee -a $LOG_FILE
rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

if ! cp -r "$NODE_DIR"/* "$BACKUP_DIR/" 2>>$LOG_FILE; then
    echo "[ERROR] Sauvegarde échouée. Abandon de la mise à jour." | tee -a $LOG_FILE
    exit 1
fi

# 3) Application du pull sécurisé
echo "[GIT] Pull sécurisé..." | tee -a $LOG_FILE
if ! git pull --rebase 2>>$LOG_FILE; then
    echo "[ERROR] Échec du git pull. Restauration de la sauvegarde." | tee -a $LOG_FILE
    cp -r "$BACKUP_DIR"/* "$NODE_DIR"/
    exit 1
fi

# 4) Mise à jour des dépendances
echo "[PIP] Mise à jour des dépendances..." | tee -a $LOG_FILE

source "$NODE_DIR/venv/bin/activate"
if ! pip install -r requirements.txt 2>>$LOG_FILE; then
    echo "[ERROR] Installation dépendances échouée. Restauration..." | tee -a $LOG_FILE
    cp -r "$BACKUP_DIR"/* "$NODE_DIR"/
    exit 1
fi

# 5) Vérification du démarrage du node AVANT restart du service
echo "[TEST] Test de démarrage en mode sécurisé..." | tee -a $LOG_FILE

timeout 5 $VENV "$NODE_DIR/main.py" --check-only > /tmp/test_output.txt 2>&1

if [ $? -ne 0 ]; then
    echo "[ERROR] Le node plante avec la nouvelle version !" | tee -a $LOG_FILE
    echo "[ERROR] Restauration de l’ancienne version..." | tee -a $LOG_FILE
    cp -r "$BACKUP_DIR"/* "$NODE_DIR"/
    exit 1
fi

echo "[SUCCESS] Le test est concluant. Application de la mise à jour définitive." | tee -a $LOG_FILE

# 6) Redémarrage du service
echo "[SYSTEMD] Redémarrage du node..." | tee -a $LOG_FILE
sudo systemctl restart fre-node

echo "[DONE] Mise à jour réussie !" | tee -a $LOG_FILE
