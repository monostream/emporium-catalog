# Changelog

## 0.1.0

- Initial Emporium chart for Woodpecker CI 3.19.0 (server and Kubernetes-backend agent).
- Login through the forge (Forgejo, Gitea, GitLab, GitHub) with an OAuth2 application.
- Workflow volumes are ReadWriteOnce by default (`WorkspaceRWX` input).
- ReadWriteOnce workflows are co-located per workflow; the parallel workflows input no longer overrides the profile.
- PostgreSQL through the `postgres` integration; generated agent secret.
