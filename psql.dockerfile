FROM python:3.9-buster

WORKDIR app

COPY . .

RUN apt update \
 && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
 && echo "deb http://apt.postgresql.org/pub/repos/apt buster-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && apt update \
 && apt install -y postgresql-client \
 && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["make"]
