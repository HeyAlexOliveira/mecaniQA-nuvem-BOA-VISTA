FROM redis:7-alpine

LABEL maintainer="MecaniQA Tech - Equipe BOA VISTA"

COPY redis.conf /usr/local/etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "/usr/local/etc/redis/redis.conf"]
