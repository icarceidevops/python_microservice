#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl enable --now docker.service
#read secrets from aws
#OPEN_AI_KEY=$(aws secretsmanager get-secret-value --secret-id "secret-name" --query 'SecretString' --output text)

# Pass environment variables to file
cat << 'EOF' > /etc/environment
${join("\n", environment_lines)}
EOF

# loading environment variables
set -a
source /etc/environment
set +a

sudo docker run --name gigi_kent --restart always -e OPENAI_API_KEY=$OPENAI_API_KEY -p 80:80 -p 8080:8080 -d icarcei/sun_microsevice:latest
sudo yum install nginx -y
sudo mkdir /etc/nginx/ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/sslkey.key -out /etc/nginx/sslcert.crt -subj "/C=RO/ST=Bucuresti/L=Bucuresti/O=CompaniaTa/OU=DepartamentulIT/CN=example.com"
cat << 'EOF' > /etc/nginx/nginx.conf
# Conținutul fișierului nginx.conf
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log notice;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;

events {
    worker_connections 1024;
}

http{
    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile            on;
    tcp_nopush          on;
    keepalive_timeout   65;
    types_hash_max_size 4096;

    include             /etc/nginx/mime.types;
    default_type        application/octet-stream;

    server {
        listen 443 ssl;
        server_name your_server_name;

        ssl_certificate /etc/nginx/sslcert.crt;
        ssl_certificate_key /etc/nginx/sslkey.key;

        rewrite ^/doc$ /doc/ permanent;
        rewrite ^/app$ /app/ permanent;

        location /doc/ {
            proxy_pass http://localhost:80/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }

        location /app/ {
            proxy_pass http://localhost:8080/;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }
}
EOF
sudo systemctl enable --now nginx.service
echo "${github_actions_public_key}" >> /home/ec2-user/.ssh/authorized_keys

