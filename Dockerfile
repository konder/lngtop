FROM nginx
MAINTAINER zhangnan "nan.zhang@me.com"

RUN apt-get install -y git

COPY . /usr/share/nginx/html

WORKDIR /src




