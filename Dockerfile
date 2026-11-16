FROM golang:1.27.4-alpine3.24@sha256:70bd7ddea8b6cbe5d6943cde279d6b67feb10cc924fb9100d1d8757c1575b280 AS build

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY main.go cli.go schema.go ./
COPY docs/cli-core.md ./docs/cli-core.md
RUN CGO_ENABLED=0 go build -trimpath -ldflags="-s -w" -o /out/linkding .

FROM scratch

LABEL org.opencontainers.image.source="https://github.com/zewelor/linkding"

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /out/linkding /usr/local/bin/linkding

USER 65532:65532

ENTRYPOINT ["/usr/local/bin/linkding"]
CMD ["mcp"]
