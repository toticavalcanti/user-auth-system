#!/bin/sh
set -e

# Primeiro, verifica se o primeiro argumento é "nginx" ou "nginx-debug"
# Se for, inicia o Nginx
if [ "${1#-}" != "$1" ]; then
	set -- nginx "$@"
fi

# Em seguida, verifica novamente se o argumento é nginx ou nginx-debug
if [ "$1" = 'nginx' ] || [ "$1" = 'nginx-debug' ]; then
	# Se houver scripts no diretório /docker-entrypoint.d/, executa-os
	for f in /docker-entrypoint.d/*; do
		# Só executa se o arquivo for legível
		if [ -r "$f" ]; then
			case "$f" in
				*.sh)
					echo "$0: Executando $f";
					. "$f"
					;;
				*)
					echo "$0: Ignorando $f";
					;;
			esac
		fi
	done
fi

# Por fim, chama o comando Nginx passado no CMD
exec "$@"
