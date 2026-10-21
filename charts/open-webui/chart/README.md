# Open WebUI

Open WebUI is a self-hosted chat interface for large language models. Talk to local models through Ollama or to any OpenAI-compatible service, all from one polished, private web app.

## Features

- Chat with local models (Ollama) and OpenAI-compatible APIs side by side
- Document and web search (RAG), image upload and voice input
- Prompt library, model presets, tools and functions
- Multi-user with roles, groups and shared chats
- Single sign-on through Emporium: administrators and users are mapped from their Emporium role

## Perfect for

Teams and households who want a private ChatGPT-style assistant on their own models and data.

## Good to know

- Sign-in uses the Emporium (Logto) role: `emporium-admin` becomes an Open WebUI administrator, `emporium-user` a regular user. A user whose token has no roles at all gets an account in the `pending` state (no access until an administrator approves it); a user with other roles only is rejected. Both role names are inputs. Roles are re-evaluated at every sign-in, but Open WebUI keeps the role of an existing account when the token carries no roles: to revoke access completely, also delete or demote the account under Admin Panel > Users.
- Emporium users without an email address still work: Open WebUI generates an internal address for them.
- The local administrator (email and generated password in the app's Secret) is for break-glass use; the login form stays available for it. Open WebUI's own sign-up is off.
- Ollama: set the Ollama URL input (for example the in-cluster address of the Emporium Ollama app) or add connections later under Admin Settings > Connections. Models are never downloaded by this chart. Open WebUI stores connection settings in its database at the first start and then prefers them over the environment: changing the Ollama URL input later (or adding one after installing without) does not take effect. Change it under Admin Settings > Connections instead (the input only seeds the first start).
- `/api`, `/openai` and `/ollama` skip the Emporium login so tools and editor plugins can call them with an Open WebUI API key.
- Open WebUI is released under the Open WebUI License (BSD-3-Clause with a branding clause): keep the "Open WebUI" name and logo unless you have fewer than 50 users or a permission from the vendor.
- The image bundles machine-learning libraries for local document embeddings; give it at least 1 GiB of memory.
