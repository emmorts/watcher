FROM alpine:latest

RUN apk add --no-cache git openssh coreutils
RUN adduser -D watcher

USER watcher
WORKDIR /home/watcher/
COPY --chown=watcher commit-push.sh .
RUN chmod +x commit-push.sh

CMD ["sh", "commit-push.sh"]