FROM eclipse-temurin:17-jdk-alpine

LABEL maintainer="MecaniQA Tech - Equipe BOA VISTA"

WORKDIR /app

COPY Main.java .

RUN javac Main.java

EXPOSE 8080

CMD ["java", "Main"]
