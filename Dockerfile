FROM ghcr.io/linuxserver/baseimage-alpine:3.20-version-6315bc7d

RUN apk add -U --upgrade --no-cache lftp

ADD crontab /etc/cron.d/hello-cron
ADD scripts /var/scripts

RUN chmod 0644 /etc/cron.d/hello-cron

RUN touch /var/log/cron.log
RUN touch /var/log/lftp.log

RUN mkdir /root/.ssh && echo 'ariel.whatbox.ca,72.21.17.8 ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABCJTdYFtRKJCLkydzAFZDfQroHWlWTES21HEY1jBBlQrKWcxZgPE+7eW4d550QuLVaBhQnj/wCjaUDcyaptPoHqgDdzZGa85crQCU+SJNbKAxdpzFNhFXKdGSDPPokQ8slXFyGzvK+ztToctc6CDVSYV95uRk/lPRn0BU81Lr85oyxWw==' > /root/.ssh/known_hosts

RUN mkdir -p /media

CMD printenv | sed 's/^\(.*\)$/export \1/g' | sed 's/=\(.*\)/="\1"/' > /env.sh && crontab /etc/cron.d/hello-cron && tail -f /var/log/cron.log
