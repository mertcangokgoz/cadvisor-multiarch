FROM golang:1.22-bookworm AS build
ARG VERSION

RUN apt-get update \
    && apt-get install -y make git bash gcc gnutls-bin \
    && mkdir -p $GOPATH/src/github.com/google \
    && git clone https://github.com/google/cadvisor.git $GOPATH/src/github.com/google/cadvisor --depth=1

WORKDIR $GOPATH/src/github.com/google/cadvisor
RUN git fetch --tags \
    && git checkout $VERSION \
    && make build \
    && echo "Build finished" \
    && cp $GOPATH/src/github.com/google/cadvisor/_output/cadvisor /cadvisor

# ------------------------------------------
FROM alpine:3.18

RUN apk --no-cache add libc6-compat device-mapper findutils ndctl zfs && \
    apk --no-cache add thin-provisioning-tools --repository http://dl-3.alpinelinux.org/alpine/edge/main/ && \
    echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
    rm -rf /var/cache/apk/*

# Grab cadvisor from the staging directory.
COPY --from=build /cadvisor /usr/bin/cadvisor

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --quiet --tries=1 --spider http://localhost:8080/healthz || exit 1

ENTRYPOINT ["/usr/bin/cadvisor", "-logtostderr"]
