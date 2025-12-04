#!/bin/bash

sudo apt update && sudo apt install -y python3 python3-pip python3-venv git

cd /home/pi
git clone https://github.com/FRANCNUMERIQUE/fre-node.git
cd fre-node

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

sudo cp system/fre-node.service /etc/systemd/system/
sudo systemctl enable fre-node
sudo systemctl start fre-node
