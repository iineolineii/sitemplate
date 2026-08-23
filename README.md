# Prerequisites
## Required:
- Nginx
- GNU gettext `envsubst` utility
- Bash

## Recommended, but can be changed from a template:
- TLS certificate (`fullchain.pem` and `privkey.pem` under `/etc/letsencrypt/live/<DOMAIN>/`)
- Nginx daemon configured to include configuration files from `/etc/nginx/sites-enabled`
- Capability to open TCP port 443 on all interfaces

## Optional, used primarily for installation:
- sudo
- curl

# Installation
1. Download the script to `/usr/local/bin/`:
```
sudo curl -#fL https://raw.githubusercontent.com/iineolineii/sitemplate/refs/heads/main/sitemplate.sh --output /usr/local/bin/sitemplate
```
2. Make it executable:
```
sudo chmod +x /usr/local/bin/sitemplate
```
3. Download the Nginx configuration file template to `/etc/nginx/snippets/`:
```
sudo curl -#fL https://raw.githubusercontent.com/iineolineii/sitemplate/refs/heads/main/server.conf --output /etc/nginx/snippets/server.conf.template
```
4. Download the TLS termination proxy headers snippet to `/etc/nginx/snippets/`:
```
sudo curl -#fL https://raw.githubusercontent.com/iineolineii/sitemplate/refs/heads/main/proxy-headers-https.conf --output /etc/nginx/snippets/proxy-headers-https.conf
```

# Usage
1. Generate the Nginx configuration file for your website, for example:
```
sudo sitemplate git git.mysite.org 127.0.0.1:8000
```
2. Ensure it's enabled:
```
ls -l /etc/nginx/sites-enabled/git.conf
```
3. Test the configuration file:
```
sudo nginx -t
```
4. Reload the Nginx daemon:
```
sudo nginx -s reload
```
