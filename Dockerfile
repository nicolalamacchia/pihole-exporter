ARG OS=linux
ARG ARCH=amd64

FROM golang:1.21.5-alpine3.17 as builder

WORKDIR /go/src/github.com/nicolalamacchia/pihole-exporter
COPY . .

RUN apk --no-cache add git alpine-sdk

RUN GO111MODULE=on go mod vendor
RUN CGO_ENABLED=0 GOOS=$OS GOARCH=$ARCH go build -ldflags '-s -w' -o pihole_exporter ./

FROM busybox:uclibc as busybox

FROM gcr.io/distroless/base-debian12

LABEL name="pihole-exporter"
EXPOSE 9617
WORKDIR /
COPY --from=busybox /bin/sh /bin/sh
COPY --from=busybox /bin/wget /bin/wget
COPY --from=builder /go/src/github.com/nicolalamacchia/pihole-exporter/pihole_exporter /usr/bin/pihole_exporter
ENTRYPOINT ["/usr/bin/pihole_exporter"]
