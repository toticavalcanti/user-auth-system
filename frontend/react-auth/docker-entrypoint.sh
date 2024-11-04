#!/bin/sh
set -e

# Debugging echo
echo "Entrypoint script is running..."

# Verificar se a variável de ambiente foi passada corretamente
echo "Valor de REACT_APP_API_URL: '${REACT_APP_API_URL}'"

# Criar o arquivo config.js com as variáveis de ambiente diretamente no entrypoint
echo "Criando o arquivo /usr/share/nginx/html/config.js..."
cat <<EOL > /usr/share/nginx/html/config.js
window._env_ = {
  REACT_APP_API_URL: '${REACT_APP_API_URL}'
};
EOL

# Verificar se o arquivo foi criado corretamente
if [ -f /usr/share/nginx/html/config.js ]; then
    echo "Arquivo config.js criado com sucesso!"
else
    echo "Falha ao criar o arquivo config.js!"
    exit 1
fi

# Iniciar o Nginx
exec "$@"
