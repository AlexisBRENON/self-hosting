#!/bin/sh

PORT=9090
SERVICES="$(find /stacks/ -type d -mindepth 1 -maxdepth 1 | grep -v -e traefik -e .git | xargs -I ARG basename ARG)"
echo "Available services:"
echo "${SERVICES}"

start_service() {
	SERVICE="$1"
	if [ "$SERVICE" = "trigger-status" ]; then
		# echo "Returning trigger status..."
		true
	elif [ "$(echo "$SERVICES" | grep "^$SERVICE$" | wc -l)" -eq 1 ]; then
		docker compose -f /stacks/$SERVICE/docker-compose.yml up -d
	else
		echo "Service non reconnu: $SERVICE" >&2
	fi
}

on_get() {
	while IFS=$'\r\n' read -r line; do
		# echo "Line: $line" >&2
		if [ "$(echo "$line" | cut -d':' -f1)" = 'X-Forwarded-Uri' ]; then
			service="$(echo "$line" | cut -d' ' -f2 | cut -d'/' -f2)"
			start_service "$service" &
		fi
	done
}

mkdir -p /tmp
cd /tmp
echo "🔁 Serveur de déclenchement en écoute sur le port $PORT..."

while true; do
	echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n$(docker ps)" |
		nc -l -p $PORT -q 0 -v |
		on_get
done
