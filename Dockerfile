FROM alpine:3.11.5

COPY mu-scripts.sh /

ONBUILD COPY . /app/scripts

CMD ["/bin/sh", "/mu-scripts.sh"]
