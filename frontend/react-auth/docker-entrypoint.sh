#!/bin/sh

# Substituir as variáveis de ambiente no arquivo /config.js no momento da inicialização
echo "Substituindo variáveis de ambiente no /config.js..."

envsubst < /usr/share/nginx/html/config.js > /usr/share/nginx/html/config.js.temp && mv /usr/share/nginx/html/config.js.temp /usr/share/nginx/html/config.js

# Iniciar o Nginx
echo "Iniciando o Nginx..."
exec "$@"
