FROM alpine:latest as build

RUN apk add --no-cache \
    curl \
    git \
    openssh-client \
    rsync

ENV VERSION 0.65.3
RUN mkdir -p /usr/local/src \
    && cd /usr/local/src \
    && curl -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_linux-64bit.tar.gz | tar -xz \
    && mv hugo /usr/local/bin/hugo \
    && curl -L https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz | tar -xz \
    && mv minify /usr/local/bin/ \
    && addgroup -Sg 1000 hugo \
    && adduser -SG hugo -u 1000 -h /src hugo

ADD . /src

WORKDIR /src

RUN hugo

FROM ubuntu:18.04

COPY --from=build /src/public /src/public

RUN apt-get update && apt-get install -y python3

WORKDIR /src/public

ENTRYPOINT python3 -m http.server 3000