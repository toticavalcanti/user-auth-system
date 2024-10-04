#!/bin/sh

# Cria ou atualiza o arquivo de configuração
cat <<EOF > /usr/share/nginx/html/config.js
window._env_ = {
  REACT_APP_API_URL: '${REACT_APP_API_URL:-http://api-service}'
};
EOF

# Executa o comando original passado para o script
exec "$@"