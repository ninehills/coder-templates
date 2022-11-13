# coder-templates

Coder templates for my self.

Docs:

- https://coder.com/docs/coder-oss/latest/templates
- https://registry.terraform.io/providers/coder/coder/latest/docs
- https://github.com/coder/coder/tree/main/examples/templates
    - Template examples in Coder CLI with `coder templates init`.
- https://github.com/coder/coder/blob/main/examples/templates/community-templates.md
    - Community templates.

Docker images:

- codercom enterprise images: https://github.com/coder/enterprise-images
    - Base Dockerfile: https://github.com/coder/enterprise-images/blob/main/images/base/Dockerfile.ubuntu


## Templates

- `docker`: `https://github.com/coder/coder/tree/main/examples/templates/docker`
- `docker-vars`: Docker templates with vars support.

## Images

- `ninehills/coder-base:latest`: Base image.
- `ninehills/golang:latest`: Golang image
- Other language, please refer to <https://github.com/coder/enterprise-images/tree/main/images>


> Tips: build image with proxy  
>  
> `$ docker build --build-arg http_proxy=http://172.20.0.1:7890 --build-arg https_proxy=http://172.20.0.1:7890 -t ninehills/coder-base:latest .`