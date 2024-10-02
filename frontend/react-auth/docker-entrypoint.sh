#!/bin/sh

# Exibir variáveis de ambiente
echo "Valor de REACT_APP_API_URL: $REACT_APP_API_URL"

# Verificar o diretório onde o config.js será criado
ls -ld /usr/share/nginx/html

# Substituir as variáveis de ambiente no arquivo /config.js no momento da inicialização
echo "Substituindo variáveis de ambiente no /config.js..."

cat <<EOF > /usr/share/nginx/html/config.js
window._env_ = {
  REACT_APP_API_URL: "$REACT_APP_API_URL"
};
EOF

# Verificar se o arquivo foi criado
echo "Verificando se o config.js foi criado..."
ls /usr/share/nginx/html/config.js

# Iniciar o Nginx
echo "Iniciando o Nginx..."
exec "$@"
