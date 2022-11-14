terraform {
  required_providers {
    coder = {
      source  = "coder/coder"
      version = "0.6.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.22"
    }
  }
}

data "coder_provisioner" "me" {
}

provider "docker" {
}

data "coder_workspace" "me" {
}

variable "dockerd_enabled" {
  description = <<-EOF
  Start dockerd. (optional)

  Need dind supported.
  EOF

  default = "false"
}

variable "dotfiles_uri" {
  description = <<-EOF
  Dotfiles repo URI (optional)

  see https://dotfiles.github.io
  example: git@github.com:ninehills/dotfiles.git
  EOF

  default = ""
}

variable "image" {
  description = <<-EOF
  Container images from coder-com

  EOF
  default = "ninehills/coder-base:latest"
  validation {
    condition = contains([
      "ninehills/coder-golang:latest",
      "ninehills/coder-base:latest",
      "codercom/enterprise-node:ubuntu",
      "codercom/enterprise-java:ubuntu",
      "marktmilligan/clion-rust:latest"
    ], var.image)
    error_message = "Invalid image!"   
  }  
}

variable "repo" {
  description = <<-EOF
  Code repository to clone, example: git@github.com:ninehills/p2pfile.git 

  EOF
  default = ""
}

variable "work_dir" {
  description = <<-EOF
  Work dir will be /home/coder/<work_dir>.

  EOF
  default = ""
}

variable "http_proxy" {
  description = <<-EOF
  HTTP(S) Proxy, default is host.docker.internal:7890.

  EOF
  default = "http://host.docker.internal:7890"
}


resource "coder_agent" "main" {
  arch           = data.coder_provisioner.me.arch
  os             = "linux"
  startup_script = <<EOF
    #!/bin/bash
    set -eu

    # set proxy
    if [[ "${var.http_proxy}" != "" ]];then
      echo "Set http(s) proxy to ${var.http_proxy}"
      export https_proxy="${var.http_proxy}" http_proxy="${var.http_proxy}"
    fi

    # clone repo
    if [[ "${var.repo}" != "" ]];then
      echo "Clone repo ${var.repo} ..."
      mkdir -p ~/.ssh
      ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts
      git clone ${var.repo} ${var.work_dir} || echo "ignore clone failed"
    fi

    # install code-server if not in image.
    if ! which code-server ; then
      echo "Install code-server..."
      curl -fsSL https://code-server.dev/install.sh | sh
    fi

    code-server --auth none --port 13337 &

    # use coder CLI to clone and install dotfiles
    if [[ "${var.dotfiles_uri}" != "" ]];then
      echo "Install dotfiles..."
      coder dotfiles -y ${var.dotfiles_uri}
    fi

    # start dockerd
    if [[ "${var.dockerd_enabled}" == "true" ]];then
      echo "Start dockerd..."
      sudo dockerd &
    fi
    EOF

  # These environment variables allow you to make Git commits right away after creating a
  # workspace. Note that they take precedence over configuration defined in ~/.gitconfig!
  # You can remove this block if you'd prefer to configure Git manually or using
  # dotfiles. (see docs/dotfiles.md)
  env = {
    GIT_AUTHOR_NAME     = "${data.coder_workspace.me.owner}"
    GIT_COMMITTER_NAME  = "${data.coder_workspace.me.owner}"
    GIT_AUTHOR_EMAIL    = "${data.coder_workspace.me.owner_email}"
    GIT_COMMITTER_EMAIL = "${data.coder_workspace.me.owner_email}"
  }
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "code-server"
  url          = "http://localhost:13337/?folder=/home/coder/${var.work_dir}"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://localhost:13337/healthz"
    interval  = 5
    threshold = 6
  }
}

resource "docker_volume" "coder_volume" {
  name = "coder-${data.coder_workspace.me.id}-${lower(data.coder_workspace.me.name)}"
  # https://coder.com/docs/coder-oss/latest/templates/resource-persistence#-bulletproofing
  # Every container has owner volume, so dont need to set ignore_changes = all

  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace.me.owner
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace.me.owner_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  # This field becomes outdated if the workspace is renamed but can
  # be useful for debugging or cleaning out dangling volumes.
  labels {
    label = "coder.workspace_name_at_creation"
    value = data.coder_workspace.me.name
  }
}

resource "docker_container" "workspace" {
  count = data.coder_workspace.me.start_count
  image = "${var.image}"
  # Use sysbox-run as runtime to support dind.
  runtime = "sysbox-runc"
  # Uses lower() to avoid Docker restriction on container names.
  name = "coder-${data.coder_workspace.me.owner}-${lower(data.coder_workspace.me.name)}"
  # Hostname makes the shell more user friendly: coder@my-workspace:~$
  hostname = lower(data.coder_workspace.me.name)
  # Use the docker gateway if the access URL is 127.0.0.1
  entrypoint = ["sh", "-c", replace(coder_agent.main.init_script, "/localhost|127\\.0\\.0\\.1/", "host.docker.internal")]
  env        = ["CODER_AGENT_TOKEN=${coder_agent.main.token}"]
  host {
    host = "host.docker.internal"
    ip   = "host-gateway"
  }
  volumes {
    container_path = "/home/coder"
    volume_name    = docker_volume.coder_volume.name
    read_only      = false
  }
  # Add labels in Docker to keep track of orphan resources.
  labels {
    label = "coder.owner"
    value = data.coder_workspace.me.owner
  }
  labels {
    label = "coder.owner_id"
    value = data.coder_workspace.me.owner_id
  }
  labels {
    label = "coder.workspace_id"
    value = data.coder_workspace.me.id
  }
  labels {
    label = "coder.workspace_name"
    value = data.coder_workspace.me.name
  }
}
