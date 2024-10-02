#!/bin/sh

# Substituir variáveis de ambiente no arquivo de configuração do Nginx
envsubst '\$REACT_APP_API_URL' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf

# Iniciar o Nginx
nginx -g 'daemon off;'
