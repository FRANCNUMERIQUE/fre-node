#!/bin/bash

REPO_DIR="/home/aliasvava/fre-node"
VENV_DIR="$REPO_DIR/venv"
SERVICE_NAME="fre-node"
LOG_FILE="/var/log/fre-node-update.log"

echo "[UPDATE] $(date) - Démarrage de la mise à jour" | sudo tee -a $LOG_FILE

cd $REPO_DIR

echo "[UPDATE] Fetch Git..." | sudo tee -a $LOG_FILE
git fetch origin >> $LOG_FILE 2>&1

LOCAL=$(git rev-parse @)
REMOTE=$(git rev-parse @{u})
BASE=$(git merge-base @ @{u})

if [ $LOCAL = $REMOTE ]; then
    echo "[UPDATE] Aucun update disponible." | sudo tee -a $LOG_FILE
    exit 0
elif [ $LOCAL = $BASE ]; then
    echo "[UPDATE] Nouvelle version détectée." | sudo tee -a $LOG_FILE
    git pull --rebase >> $LOG_FILE 2>&1

    source $VENV_DIR/bin/activate
    pip install -r requirements.txt >> $LOG_FILE 2>&1

    echo "[UPDATE] Redémarrage du service..." | sudo tee -a $LOG_FILE
    sudo systemctl restart $SERVICE_NAME
    echo "[UPDATE] OK ✔" | sudo tee -a $LOG_FILE
else
    echo "[UPDATE] Conflit détecté ! ANNULATION" | sudo tee -a $LOG_FILE
    exit 1
fi
