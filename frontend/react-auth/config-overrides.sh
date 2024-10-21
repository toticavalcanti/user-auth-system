#!/bin/sh

# Debugging echo
echo "Executando o script config-overrides.sh..."

# Atualiza o arquivo config.js, caso haja necessidade de sobrescrever variáveis
echo "Atualizando o arquivo config.js com variáveis de ambiente..."
cat <<EOF > /usr/share/nginx/html/config.js
window._env_ = {
  REACT_APP_API_URL: '${REACT_APP_API_URL:-http://auth-api-service:3000}',
  ENV: '${ENV:-production}'
};
EOF

# Verificar se o arquivo foi atualizado corretamente
if [ -f /usr/share/nginx/html/config.js ]; then
    echo "Arquivo config.js atualizado com sucesso!"
else
    echo "Falha ao atualizar o arquivo config.js!"
    exit 1
fi
