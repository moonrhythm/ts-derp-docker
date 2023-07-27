FROM golang

RUN go install tailscale.com/cmd/derper@main

ENTRYPOINT ["/go/bin/derper"]
