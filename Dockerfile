# Correction #1: Use multi-stage builds to reduce the image size
# and reduce the attack surface
FROM golang:1.21-alpine AS build
WORKDIR /app

# Correction #2: Use .dockerignore to exclude unnecessary files
# The copy command here is okay to do because when using multi-stage builds
# the final image will only contain the binary file and not the source code
COPY . .
RUN go mod tidy && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o server .

# Correction #3: Use smaller base image as the final image
# You can use Alpine, Scratch, Ubuntu, or any other small base image depending on your needs
# You can also use Distroless images for more security
# Using Scratch or Distroless images will not have a shell, package manager, or any other programs in typical Linux distributions.
# So if a hacker gains access to the container, they won't be able to do much
# However, those images are not recommended for development because they are harder to debug
# since you can't exec into the container and run commands.
# They also requires more technical knowledge to use.
# So to balance between security and ease of use, I'll use Alpine here
# https://medium.com/google-cloud/alpine-distroless-or-scratch-caac35250e0b
FROM alpine:3.21.3 AS final

# Correction #4: Use ARG instead of ENV to pass build-time variables
# This is because ARG is only available during the build stage
# and the values are not stored in the final image
ARG DBPASSWORD
ARG DBNAME
ARG DBUSER

# Correction #5: Use non-root user
# However, you need to make sure that the user has the necessary permissions to run the application
USER nobody:nogroup

WORKDIR /app
# The COPY command here is to copy the binary file from the build stage
# to the final image
COPY --from=build --chown=nobody:nogroup /app/server .

# Correction #6: Only expose the necessary port
EXPOSE 8080

CMD ["/app/server"]