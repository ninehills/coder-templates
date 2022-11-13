---
name: Develop in Docker with Vars
description: Run workspaces on a Docker host with variables.
tags: [local, docker]
---

# docker

To get started, run `coder templates init`. When prompted, select this template.
Follow the on-screen instructions to proceed.

## code-server

`code-server` is installed via the `startup_script` argument in the `coder_agent`
resource block. The `coder_app` resource is defined to access `code-server` through
the dashboard UI over `localhost:13337`.

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

### Todo

- [ ] If clone repo from remote, set coder-server default folder as `/home/coder/<repo>`.
- [ ] Use custom code-server images to replace default images.
- [ ] Set VSCode Settings Sync. <https://coder.com/docs/code-server/latest/FAQ#how-can-i-reuse-my-vs-code-configuration>
