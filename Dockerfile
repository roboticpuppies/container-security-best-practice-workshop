# Correction #1: Use multi-stage builds to reduce the image size
# and reduce the attack surface
FROM golang:1.21-alpine AS build
WORKDIR /app

# Correction #2: Use .dockerignore to exclude unnecessary files
# The copy command here is okay to do because when using multi-stage builds
# the final image will only contain the binary file and not the source code
COPY . .
RUN go mod tidy && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o server .

FROM alpine:3.21.3 AS final

# Correction #3: Use ARG instead of ENV to pass build-time variables
# This is because ARG is only available during the build stage
# and the values are not stored in the final image
ARG DBPASSWORD
ARG DBNAME
ARG DBUSER

# Correction #4: Use non-root user
USER nobody:nogroup

WORKDIR /app
# The COPY command here is to copy the binary file from the build stage
# to the final image
COPY --from=build /app/server .

# Correction #5: Only expose the necessary port
EXPOSE 8080
CMD ["/app/server"]