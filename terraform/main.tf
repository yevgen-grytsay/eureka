provider "flux" {
  kubernetes = {
    config_path    = "~/.kube/config"
    config_context = "microk8s"
  }

  git = {
    url = "https://github.com/${var.github_org}/${var.github_repository}"
    http = {
      username = var.github_org
      password = var.github_token
    }
  }
}

resource "flux_bootstrap_git" "this" {
  path = "clusters"
}
