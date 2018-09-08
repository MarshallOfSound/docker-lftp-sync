FROM ubuntu:18.04

RUN apt update && apt install -y \
    lftp \
    cron \
 && apt upgrade -y && rm -rf /var/lib/apt/lists/*

ADD crontab /etc/cron.d/hello-cron
ADD scripts /var/scripts

RUN chmod 0644 /etc/cron.d/hello-cron

RUN touch /var/log/cron.log
RUN touch /var/log/lftp.log

RUN mkdir -p /media

CMD cron && tail -f /var/log/cron.log
