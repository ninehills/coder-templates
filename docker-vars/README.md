---
name: Develop in Docker with Vars
description: Run workspaces on a Docker host with variables.
tags: [local, docker]
---

# docker-vars

To get started, run `coder templates create docker-var`. 

## DIND（Docker in Docker）

Docs: <https://coder.com/docs/coder-oss/latest/templates/docker-in-docker>

### Sysbox runtime 

1. Install sysbox runc to replace docker runc: <https://github.com/nestybox/sysbox/blob/master/docs/user-guide/install.md>
2. Then we can run dockerd in container.

### Privileged sidecar container 

While less secure, you can attach a privileged container to your templates. This may come in handy if your nodes cannot run Sysbox.

## Additional variables

- `dotfiles_url`: Prompt user and clone/install a dotfiles repository (for personalization settings)
- `image`: Prompt user for container image to use
- `repo`: Prompt user for repo to clone
- `extension`: Prompt user for which VS Code extension to install from the Open VSX marketplace

## Supported Parameters

You can create a file containing parameters and pass the argument
`--parameter-file` to `coder templates create`.
See `params.sample.yaml` for more information.

This template has the following predefined parameters:

- `docker_host`: Path to (or address of) the Docker socket.
  > You can determine the correct value for this by running
  > `docker context ls`.
- `docker_arch`: Architecture of the host running Docker.
  This can be `amd64`, `arm64`, or `armv7`.

## Docker support.

### Todo

- [x] If clone repo from remote, set coder-server default folder as `/home/coder/<repo>`.
- [x] Use custom code-server images to replace default images.
- [ ] VSCode settings sync.
