FROM alpine:latest

RUN apk add --no-cache git

WORKDIR /home/app

COPY commit-push.sh .
RUN chmod +x commit-push.sh

CMD ["sh", "commit-push.sh"]