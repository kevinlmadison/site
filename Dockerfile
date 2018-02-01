FROM alpine:edge
MAINTAINER Kevin Madison <coolklm121@gmail.com>
LABEL caddy_version = "0.10.6" architecture="amd64"

# Caddy
RUN adduser -S caddy

ARG plugins=tls.dns.namecheap

RUN apk add --no-cache --virtual .build-caddy openssh-client tar curl \
  && curl --silent --show-error --fail --location \
  --header "Accept: application/tar+gzip, application/x-zip, application/octet-stream" -p \
  "https://caddyserver.com/download/linux/amd64?plugins=${plugins}" \
  | tar --no-same-owner -C /usr/bin -xz caddy \
  && chmod 0755 /usr/bin/caddy \
  && apk del --purge .build-caddy

RUN /usr/bin/caddy --plugins

# Gutenberg

COPY public/ /www/public
COPY Caddyfile /etc/Caddyfile

WORKDIR /www/public

#USER caddy
ENTRYPOINT ["/usr/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout"]
