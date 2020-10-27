FROM golang:alpine AS s5cmd-builder
ARG OBJSYNC_VERSION="1.0.0"

RUN apk add build-base curl git make unzip
RUN curl -L https://github.com/dominikh/go-tools/releases/download/2020.1.3/staticcheck_linux_amd64.tar.gz | tar xvz -C /opt/ \
  && cp /opt/staticcheck/staticcheck /go/bin/

RUN go get mvdan.cc/unparam
RUN git clone https://github.com/peak/s5cmd.git --branch=v1.0.0
RUN cd s5cmd && make
FROM golang:1.14-alpine
COPY --from=s5cmd-builder /go/s5cmd/s5cmd /go/bin/

RUN apk update && apk add bash
RUN mkdir /root/.aws

COPY ./*.sh /usr/bin/
RUN chmod +x /usr/bin/*.sh
CMD ["/usr/bin/list.sh"]
