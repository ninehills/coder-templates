FROM ninehills/coder-base:latest

# Run everything as root
USER root

# Install go
RUN curl -L "https://dl.google.com/go/go1.19.3.linux-amd64.tar.gz" | tar -C /usr/local -xzvf -

# Setup go env vars
ENV GOROOT /usr/local/go
ENV PATH $PATH:$GOROOT/bin

ENV GOPATH /home/coder/go
ENV GOBIN $GOPATH/bin
ENV PATH $PATH:$GOBIN

# Set back to coder user
USER coder

# Install VS Code Plugin
RUN code-server --install-extension "golang.go"
