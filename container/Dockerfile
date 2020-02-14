FROM golang:1.13.5-alpine3.10 as builder

RUN apk add -U ca-certificates curl git gcc musl-dev openssh-keygen

WORKDIR /go/src
ADD . /go/src/
ENV GO111MODULE=on
RUN go mod download
RUN CGO_ENABLED=0 GO111MODULE=on go build -o /binary cmd/server/main.go


FROM debian:7.11-slim
COPY --from=builder /binary /binary

EXPOSE 9000
ENV PORT 9000
CMD ["./binary"]
