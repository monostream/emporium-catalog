FROM golang:1.22-alpine3.19 AS builder

RUN apk add git

WORKDIR /src
RUN git clone https://github.com/v1k45/pastepass.git

WORKDIR /src/pastepass
RUN go mod download
RUN CGO_ENABLED=0 go build -o /out/pastepass main.go


FROM alpine:3.19

ENV USER=pastepass
ENV UID=1000
ENV GID=1000
ENV APP_DIR=/app
ENV DATA_DIR=/data

RUN apk add --no-cache tini ca-certificates \
    && addgroup -g $GID -S $USER \
    && adduser -u $UID -S -G $USER $USER

WORKDIR $APP_DIR
COPY --from=builder --chown=$UID:$GID /out/pastepass .

RUN mkdir -p $DATA_DIR && chown $UID:$GID $DATA_DIR

USER $USER
EXPOSE 8008

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["./pastepass", "-db-path", "/data/pastepass.db"]