# Whatbot Playbook Site

Static demo site for the Whatbot v1.7 playbooks (English + Thai), specialist playbooks, and pitch collateral.

## Deploy on VPS

```bash
chmod +x deploy.sh
./deploy.sh deploy
```

Site listens on **port 6200** by default.

## Nginx Proxy Manager

1. Add Proxy Host → your domain
2. Scheme: `http`
3. Forward to `127.0.0.1:6200`
4. Enable SSL (Let's Encrypt)

## Commands

| Command | Description |
|---------|-------------|
| `./deploy.sh deploy` | Build and start (default) |
| `./deploy.sh rebuild` | Clean rebuild |
| `./deploy.sh logs` | Tail logs |
| `./deploy.sh stop` | Stop container |

Override port: `PLAYBOOK_PORT=8080 ./deploy.sh deploy`

## New GitHub repo

This folder is self-contained. Initialize a new repo from here:

```bash
cd whatbot-playbook-site
git init
git add .
git commit -m "Initial Whatbot playbook demo site"
git remote add origin git@github.com:YOUR_ORG/whatbot-playbook-site.git
git push -u origin main
```
