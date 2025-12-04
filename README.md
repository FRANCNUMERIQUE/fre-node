# FRE-Node – FRE Layer 2 Validator

FRE-Node est un nœud validateur pour le Layer 2 FRE fonctionnant sur TON.

Fonctionnalités :
- Validation des transactions L2
- Construction de blocs L2
- Consensus mPoS (2/3 signatures)
- Envoi du hash des blocs à l’Anchor L1 (smart-contract TACT)
- Ledger local
- Auto-update via Git
- Synchronisation automatique

Installation :

```bash
curl -s https://raw.githubusercontent.com/ton_repo/fre-node/main/scripts/install.sh | bash
