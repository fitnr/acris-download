FROM mysql:8.0

RUN apt update \
 && apt update \
 && apt install -y \
    curl \
    make \
 && rm -rf /var/lib/apt/lists/*

WORKDIR app

COPY Makefile .
COPY mysql .

ENV MYSQL_DATABASE acris

ENTRYPOINT ["make"]
CMD ["mysql"]