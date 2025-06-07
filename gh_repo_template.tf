terraform {
  required_providers {
    github = {
      source  = "opentofu/github"
      version = "6.6.0"
    }
  }
}

provider "github" {
  token = var.gh_token
}

locals {
  gh_owner           = "K-Saikrishnan"
  repo_visibility    = "public"
  template_repo_name = "template"

  repo_name   = "python-projects"
  repo_desc   = ""
  repo_topics = ["python", "uv"]
}

resource "github_repository" "repo" {
  name        = local.repo_name
  description = local.repo_desc
  visibility  = local.repo_visibility
  topics      = local.repo_topics

  has_discussions = false
  has_issues      = true
  has_projects    = false
  has_wiki        = false

  allow_merge_commit = false
  allow_rebase_merge = false
  allow_squash_merge = true

  allow_auto_merge       = true
  allow_update_branch    = true
  delete_branch_on_merge = true

  template {
    owner                = local.gh_owner
    repository           = local.template_repo_name
    include_all_branches = false
  }
}


resource "github_branch" "dev" {
  depends_on = [github_repository.repo]

  repository = local.repo_name
  branch     = "dev"
}

resource "github_actions_secret" "docker_hub_user" {
  depends_on = [github_repository.repo]

  for_each = {
    DOCKER_HUB_USER = var.docker_hub_user
    DOCKER_HUB_PAT  = var.docker_hub_pat
  }

  repository      = local.repo_name
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_repository_ruleset" "branch_ruleset" {
  depends_on = [github_repository.repo]

  name        = "main"
  repository  = local.repo_name
  target      = "branch"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~DEFAULT_BRANCH"]
      exclude = []
    }
  }

  dynamic "bypass_actors" {
    for_each = [
      # Repository Admin
      { actor_id = 5, actor_type = "RepositoryRole", bypass_mode = "always" },
      # Renovate
      # { actor_id = 2740, actor_type = "Integration", bypass_mode = "exempt" },
    ]

    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  rules {
    creation                = true
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true
    required_signatures     = true

    pull_request {
      dismiss_stale_reviews_on_push = true
      # require_code_owner_review         = true
      require_last_push_approval        = false
      required_approving_review_count   = 1
      required_review_thread_resolution = true
    }

    required_status_checks {
      do_not_enforce_on_create             = false
      strict_required_status_checks_policy = true

      required_check {
        context        = "SonarCloud Code Analysis"
        integration_id = 12526
      }

      # GiHub Actions
      dynamic "required_check" {
        for_each = ["lint", "build", "test"]
        content {
          context        = required_check.value
          integration_id = 15368
        }
      }
    }
  }
}

resource "github_repository_ruleset" "tag_ruleset" {
  depends_on = [github_repository.repo]

  name        = "tags"
  repository  = local.repo_name
  target      = "tag"
  enforcement = "active"

  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
  }

  dynamic "bypass_actors" {
    for_each = [
      # Repository Admin
      { actor_id = 5, actor_type = "RepositoryRole", bypass_mode = "always" },
    ]

    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = bypass_actors.value.bypass_mode
    }
  }

  rules {
    creation                = true
    deletion                = true
    non_fast_forward        = true
    required_linear_history = true
    required_signatures     = true
    update                  = false

    required_status_checks {
      do_not_enforce_on_create             = false
      strict_required_status_checks_policy = true

      required_check {
        context        = "SonarCloud Code Analysis"
        integration_id = 12526
      }

      # GiHub Actions
      dynamic "required_check" {
        for_each = ["lint", "build", "test"]
        content {
          context        = required_check.value
          integration_id = 15368
        }
      }
    }
  }
}

resource "github_issue_label" "issue_labels" {
  for_each = {
    # bug  = "d73a4a"
    deps = "ededed"
    # docs = "0075ca"
  }

  repository = local.repo_name
  name       = each.key
  color      = each.value
}

# https://github.com/integrations/terraform-provider-github/issues/2089

# resource "github_issue_labels" "issue_labels" {
#   for_each = {
#     bug  = "d73a4a"
#     deps = "e4e669"
#     docs = "0075ca"
#   }

#   repository = local.repo_name

#   label {
#     name  = each.key
#     color = each.value
#   }
# }
