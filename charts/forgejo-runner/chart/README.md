# Forgejo Runner

**WARNING:** this is [alpha release quality](https://en.wikipedia.org/wiki/Software_release_life_cycle#Alpha) code and should not be considered secure enough to deploy in production.

A daemon that connects to a Forgejo instance and runs jobs for continous integration. The [installation and usage instructions](https://forgejo.org/docs/next/admin/actions/) are part of the Forgejo documentation.

# Hacking

The Forgejo runner depends on [a fork of ACT](https://code.forgejo.org/forgejo/act) and is a dependency of the [setup-forgejo action](https://code.forgejo.org/actions/setup-forgejo). See [the full dependency graph](https://code.forgejo.org/actions/cascading-pr/#forgejo-dependencies) for a global view.