FROM golang:1.21-alpine AS build
WORKDIR /app
COPY . .
RUN go mod tidy
RUN go build -o server .

FROM alpine:3.21.3 AS final
ARG DBPASSWORD
ARG DBNAME
ARG DBUSER
USER nobody:nogroup
WORKDIR /app
COPY --from=build /app/server .
EXPOSE 8080
CMD ["/app/server"]