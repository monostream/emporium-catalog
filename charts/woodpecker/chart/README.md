# Woodpecker CI

Woodpecker is a simple, fast CI/CD engine. Pipelines are defined in your repository (`.woodpecker/*.yaml`), every step runs in its own container, and plugins cover pushing images, notifying chats and deploying.

This chart runs the Woodpecker server and one agent with the **Kubernetes backend**: each pipeline step is a pod in the namespace of this app.

## Features

- Pipelines as code, matrix builds, services, secrets and cron triggers
- Works with Forgejo, Gitea, GitLab and GitHub
- Lightweight: one Go server, one agent, PostgreSQL

## Perfect for

Teams that host their code on a Forgejo or Gitea instance (for example the catalog's Forgejo app) and want CI next to it.

## Good to know

- **Login goes through the forge, not through Emporium single sign-on.** Woodpecker has no generic OpenID Connect login. Create an OAuth2 application in the forge (Forgejo/Gitea: Site administration or user settings > Applications) with the redirect URI `https://<host of this app>/authorize`, then enter the forge URL, client ID and client secret in the install form. Pick the app's subdomain first so you know the redirect URI.
- The forge must accept the token request from Woodpecker. A Forgejo behind the Emporium login has to let `/login/oauth/access_token` pass (public access, or a skip path), otherwise the login fails after the forge's authorize page.
- **The Emporium login covers the web interface.** `/api/hook` (webhooks from the forge), `/authorize` (the OAuth2 callback) and `/api/badges/*` skip it. The Woodpecker API and CLI (`/api/*` with a personal token) need the Emporium session; use access "public" if you drive Woodpecker from outside a browser.
- The forge URL is a plain input. Emporium app connections cannot create the OAuth2 application, so the forge is not wired automatically.
- Pipelines run in this app's namespace. The agent has a Role limited to pods, volumes, services and secrets of that namespace and no cluster-wide permissions. Pipeline steps can use any image, so give access to trusted people.
- Administrators are named by their forge username. With "Everyone on the forge may log in" off, other users must be added by an administrator.
- Workflow volumes are ReadWriteOnce by default (Woodpecker itself defaults to ReadWriteMany, which most block storage cannot provide and leaves the pipeline pending). With ReadWriteOnce volumes the agent keeps all steps of one workflow on the same node (pod affinity on the workflow label, Kubernetes 1.31 or newer). Turn on "ReadWriteMany workspace volumes" only with an RWX storage class.
- Pipeline pods and volumes belong to Woodpecker, not to the release. Finished pipelines remove them; a pipeline that is stuck when you uninstall leaves them behind and the namespace stays until you delete them.
