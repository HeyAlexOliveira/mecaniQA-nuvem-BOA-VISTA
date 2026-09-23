FROM mysql:8.0

LABEL maintainer="MecaniQA Tech - Equipe BOA VISTA"

# so roda na primeira vez, com o volume vazio
COPY init.sql /docker-entrypoint-initdb.d/init.sql

EXPOSE 3306
