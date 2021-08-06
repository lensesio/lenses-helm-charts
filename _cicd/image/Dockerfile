FROM alpine:latest AS downloader
ARG HELM_REPO_URL
ARG BUILD_INFO

RUN apk --no-cache add --update ca-certificates openssl wget && update-ca-certificates

WORKDIR /www

# Download all charts (tgz files) and index.yaml
RUN wget -m https://lenses.jfrog.io/artifactory/helm-charts/
# Replace the absolute url in index.yaml
RUN sed "s|https://lenses.jfrog.io/artifactory/api/helm/helm-charts|${HELM_REPO_URL}|" -i lenses.jfrog.io/artifactory/helm-charts/index.yaml
RUN sed "s|https://lenses.jfrog.io/lenses-helm-charts|${HELM_REPO_URL}|" -i lenses.jfrog.io/artifactory/helm-charts/index.yaml
RUN mv lenses.jfrog.io/artifactory/helm-charts/* .
RUN rm -rf lenses.jfrog.io/ index.html
RUN echo "${BUILD_INFO}" > build.info

FROM caddy:2-alpine

COPY Caddyfile /etc/caddy/Caddyfile
COPY index.html /usr/share/caddy/
COPY --from=downloader /www /usr/share/caddy/
