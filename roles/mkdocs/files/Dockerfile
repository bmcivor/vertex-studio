FROM squidfunk/mkdocs-material:latest AS builder

WORKDIR /docs
COPY . .
RUN mkdocs build

FROM nginx:alpine

COPY --from=builder /docs/site /usr/share/nginx/html

EXPOSE 80
