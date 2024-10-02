#!/bin/sh

# Substituir as variáveis de ambiente no arquivo /config.js no momento da inicialização
echo "Substituindo variáveis de ambiente no /config.js..."

cat <<EOF > /usr/share/nginx/html/config.js
window._env_ = {
  REACT_APP_API_URL: "$REACT_APP_API_URL"
};
EOF

# Iniciar o Nginx
echo "Iniciando o Nginx..."
exec "$@"
