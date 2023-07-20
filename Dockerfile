FROM alpine:latest

RUN apk add --no-cache bash git openssh coreutils
RUN adduser -D watcher

USER watcher
WORKDIR /home/watcher/
COPY --chown=watcher watcher.sh .
RUN chmod +x watcher.sh

CMD ["bash", "watcher.sh"]