FROM alpine:edge
MAINTAINER Josh Dvir <josh@dvir.us>

ENV INTERVAL_IN_HOURS=12

RUN apk add --update --no-cache \
    curl \
    less \
    python \
    py-pip \
    && pip install --upgrade pip awscli

ADD https://bin.equinox.io/c/ekMN3bCZFUn/forego-stable-linux-amd64.tgz /forego.tgz
RUN cd /usr/local/bin && tar xfz /forego.tgz && chmod +x /usr/local/bin/forego && rm /forego.tgz

WORKDIR /opt

RUN echo $'#!/bin/bash\n\
\n\
while true; do\n\
  aws dynamodb create-backup --table-name $TABLE_NAME/ --backup-name $BACKUP_NAME \n\
  sleep $(( 60*60*INTERVAL_IN_HOURS ))\n\
done' > backup_dynamodb.sh && chmod +x backup_dynamodb.sh

RUN echo 'dynamodb: ./backup_dynamodb.sh' >> Procfile

CMD [ "forego", "start" ]

