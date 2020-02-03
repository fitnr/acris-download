FROM python:3.8
ENV APP_PATH /app
RUN mkdir -p $APP_PATH
WORKDIR $APP_PATH
COPY . .
RUN pip install -r requirements.txt
RUN apt update && apt install -y lsb-release
RUN wget -O mysql-apt.deb -c https://dev.mysql.com/get/mysql-apt-config_0.8.14-1_all.deb && DEBIAN_FRONTEND=noninteractive dpkg -i mysql-apt.deb && apt update
RUN apt install -y mysql-client
