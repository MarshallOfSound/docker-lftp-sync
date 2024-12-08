FROM ghcr.io/linuxserver/baseimage-alpine:3.20-version-6315bc7d

RUN apk add -U --upgrade --no-cache \
    lftp \
    apk-cron

ADD crontab /etc/cron.d/hello-cron
ADD scripts /var/scripts

RUN chmod 0644 /etc/cron.d/hello-cron

RUN touch /var/log/cron.log
RUN touch /var/log/lftp.log
RUN mkdir -p /media

CMD printenv | sed 's/^\(.*\)$/export \1/g' | sed 's/=\(.*\)/="\1"/' > /env.sh && cron && tail -f /var/log/cron.log
