#!/bin/bash

# ------------------------------
# CONFIG NODE
# ------------------------------

LOG_FILE="/home/aliasvava/fre-node/update/update.log"
NODE_DIR="/home/aliasvava/fre-node"
WEBHOOK_URL="https://discord.com/api/webhooks/1446582993002037350/H_tC0C0XEejMcT0OGvDCmNRgtAUPe_R5MYU_Kz-LaBvVqZAv-IpfPEIghkaRdNXi2LEa"  # <-- Mets ton URL ici

send_discord() {
    MESSAGE="$1"
    curl -H "Content-Type: application/json" \
        -X POST \
        -d "{\"content\": \"$MESSAGE\"}" \
        $WEBHOOK_URL > /dev/null 2>&1
}

VENV="$NODE_DIR/venv/bin/python3"
BACKUP_DIR="$NODE_DIR/.backup"

echo "=================================================" | tee -a $LOG_FILE
echo "[UPDATE] Démarrage du script de mise à jour..." | tee -a $LOG_FILE
date | tee -a $LOG_FILE
echo "=================================================" | tee -a $LOG_FILE

cd "$NODE_DIR"

# 1) Vérification de l’accès GitHub
echo "[CHECK] Vérification accès Git..." | tee -a $LOG_FILE
if ! git fetch origin 2>>$LOG_FILE; then
    echo "[ERROR] GitHub inaccessible." | tee -a $LOG_FILE
    send_discord "❌ FRE-NODE : Impossible de contacter GitHub. Mise à jour annulée."
    exit 1
fi

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" == "$REMOTE" ]; then
    echo "[INFO] Dépôt déjà à jour." | tee -a $LOG_FILE
    send_discord "ℹ️ FRE-NODE : Aucune mise à jour disponible."
    exit 0
fi

echo "[UPDATE] Nouvelle version détectée." | tee -a $LOG_FILE
send_discord "🔄 FRE-NODE : Mise à jour détectée. Application..."

# 2) Création d'une sauvegarde
echo "[BACKUP] Création d'une sauvegarde..." | tee -a $LOG_FILE
rm -rf "$BACKUP_DIR"
mkdir -p "$BACKUP_DIR"

if ! cp -r "$NODE_DIR"/* "$BACKUP_DIR/" 2>>$LOG_FILE; then
    echo "[ERROR] Sauvegarde échouée." | tee -a $LOG_FILE
    send_discord "❌ FRE-NODE : Sauvegarde échouée. Mise à jour annulée."
    exit 1
fi

# 3) Pull Git sécurisé
echo "[GIT] Pull sécurisé..." | tee -a $LOG_FILE
if ! git pull --rebase 2>>$LOG_FILE; then
    echo "[ERROR] Git pull échoué." | tee -a $LOG_FILE
    send_discord "❌ FRE-NODE : Échec du GIT PULL – rollback appliqué."
    cp -r "$BACKUP_DIR"/* "$NODE_DIR"/
    exit 1
fi

# 4) Mise à jour des dépendances
echo "[PIP] Mise à jour dépendances..." | tee -a $LOG_FILE
source "$NODE_DIR/venv/bin/activate"

if ! pip install -r requirements.txt 2>>$LOG_FILE; then
    echo "[ERROR] Pip install échoué." | tee -a $LOG_FILE
    send_discord "❌ FRE-NODE : Dépendances invalides – rollback appliqué."
    cp -r "$BACKUP_DIR"/* "$NODE_DIR"/
    exit 1
fi

# 5) Test de démarrage (sécurisé)
echo "[TEST] Test de démarrage..." | tee -a $LOG_FILE
timeout 5 $VENV "$NODE_DIR/main.py" --check-only > /tmp/test_output.txt 2>&1

if [ $? -ne 0 ]; then
    echo "[ERROR] Test de démarrage échoué." | tee -a $LOG_FILE
    send_discord "❌ FRE-NODE : Nouvelle version invalide – rollback effectué."
    cp -r "$BACKUP_DIR"/* "$NODE_DIR"/
    exit 1
fi

echo "[SUCCESS] Test concluant." | tee -a $LOG_FILE

# 6) Redémarrage du service
echo "[SYSTEMD] Redémarrage..." | tee -a $LOG_FILE
sudo systemctl restart fre-node

echo "[DONE] Mise à jour réussie !" | tee -a $LOG_FILE
send_discord "✅ FRE-NODE : Mise à jour appliquée avec succès ✔️"
