FROM python:3.10-alpine

# Install ZIG
# RUN apk add libgdiplus --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/
RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
RUN apk update && apk add zig@testing

# Install Python dev
RUN apk add python3-dev

# Workdir
WORKDIR /code
