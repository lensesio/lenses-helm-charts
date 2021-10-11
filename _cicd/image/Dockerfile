FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile

WORKDIR /usr/share/caddy/
COPY ./charts .
COPY index.html .
RUN echo "${BUILD_INFO}" > build.info

EXPOSE 80
CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]