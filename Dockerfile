# Mistake #1: Using a single stage (no build separation)
# This makes the image larger than necessary
# and enlarge the attack surface, as the final image includes the build tools
# and source code, which are not needed for the final image
FROM golang:1.21-alpine3.20
WORKDIR /app

# Mistake #2: Using ENV instead of ARG and Hardcoded sensitive information
# This is a security risk, as ENV variables are stored in the image
# and can be accessed by anyone with access to the image
# Fortunately, Docker can detect hardcoded sensitive information
# and will warn you about it.
ENV DBPASSWORD=acompletelyinsecurepassword
ENV DBNAME=postgres
ENV DBUSER=postgres

# Mistake #3: Not cleaning up unnecessary files
# Copies everything, including .git, .env, and dev files
COPY . .

# There is a good dicsussion about CGO_ENABLED=0
# https://www.reddit.com/r/golang/comments/pi97sp/what_is_the_consequence_of_using_cgo_enabled0/
RUN go mod tidy && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o server .

# Mistake #4: Running the server as root or not specifying a user
# This is a security risk, as the server has full access to the system
# and can be used to escalate privileges
# In this example the default user for golang:1.21-alpine3.20 is root, which is a bad practice and should be avoided
# You can check by running the following command:
# docker run -it --rm golang:1.21-alpine3.20 whoami
# USER root

# Mistake #5: Exposing unnecessary ports
# Exposes SSH and an additional port, which are not needed for the server
# and can be used to attack the system
EXPOSE 22 8080
CMD ["./server"]