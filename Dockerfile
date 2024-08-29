FROM golang:1.14 AS builder

WORKDIR /app

COPY go.mod ./
COPY go.sum ./

ENV GOPROXY "https://mirrors.tencent.com/go/"

RUN go mod download

COPY . .

ARG LOCAL_UI_MODULE="false"

RUN if [ "${LOCAL_UI_MODULE}" = "true" ]; then \
      make replace_ui_module_with_local_path; \
    fi; \
    make linux_build;


FROM alpine:latest
# 解决go 时区和https请求证书错误问题
RUN  apk update \
  && apk add ca-certificates \
  && update-ca-certificates \
  && apk add tzdata

WORKDIR /app

COPY --from=builder /app/bin/ems ./

EXPOSE 10280

CMD ["./ems"]
