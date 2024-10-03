#!/bin/sh
set -e

# Debugging echo
echo "Entrypoint script is running..."

# Criar o arquivo config.js com as variáveis de ambiente
echo "Criando o arquivo /usr/share/nginx/html/config.js..."
cat <<EOL > /usr/share/nginx/html/config.js
window._env_ = {
  REACT_APP_API_URL: '${REACT_APP_API_URL}'
};
EOL
echo "Arquivo config.js criado com sucesso!"

# Continuar com o processo de inicialização do nginx
exec "$@"
