FROM crystallang/crystal

WORKDIR /usr/src/api

COPY . .

RUN shards install

RUN apt update -y && apt upgrade -y

RUN apt install postgresql-14 -y

EXPOSE 3000


