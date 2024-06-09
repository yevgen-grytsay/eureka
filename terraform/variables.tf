variable "github_org" {
  type     = string
  nullable = false
}

variable "github_repository" {
  type     = string
  nullable = false
}

variable "github_token" {
  sensitive = true
  type      = string
  nullable  = false
}
