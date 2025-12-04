#!/bin/bash
cd /home/pi/fre-node

git fetch origin

LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    git pull
    source venv/bin/activate
    pip install -r requirements.txt
    sudo systemctl restart fre-node
fi
