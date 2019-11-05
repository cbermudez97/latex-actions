FROM paperist/alpine-texlive-ja:latest
LABEL maintainer "mainek00n <dev.pylori1229@gmail.com>"

RUN apk --no-cache add curl python3

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]