#!/bin/sh
set -e

# Substituir as variáveis de ambiente no arquivo /config.js no momento da inicialização
echo "Substituindo variáveis de ambiente no /config.js..."
echo "Valor de REACT_APP_API_URL: $REACT_APP_API_URL"

cat <<EOF > /usr/share/nginx/html/config.js
window._env_ = {
  REACT_APP_API_URL: "$REACT_APP_API_URL"
};
EOF

# Verificar se o arquivo foi criado corretamente
if [ -f /usr/share/nginx/html/config.js ]; then
    echo "Arquivo config.js criado com sucesso."
else
    echo "Falha ao criar o arquivo config.js."
fi

# Por fim, chamar o script de entrada original do Nginx
exec /docker-entrypoint.sh "$@"
