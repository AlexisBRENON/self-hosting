FROM alpine:3.19

RUN apk add --no-cache netcat-openbsd docker-cli docker-cli-compose

COPY trigger-service.sh /trigger-service.sh
RUN chmod +x /trigger-service.sh

ENTRYPOINT ["/trigger-service.sh"]
