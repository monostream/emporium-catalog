# Langfuse

Langfuse is an open-source LLM engineering platform: trace every call of your AI application, evaluate answers, manage prompts and watch cost, latency and quality in one place.

## Features

- Tracing for LLM apps, agents and RAG pipelines through the Langfuse SDKs (Python, JS/TS), OpenTelemetry and integrations such as LangChain, LlamaIndex and the OpenAI SDK
- Sessions, users, cost and token tracking, dashboards
- Prompt management with versions and labels, playground
- Evaluation: LLM-as-a-judge, manual annotation, datasets and experiments
- Single sign-on through Emporium: every Emporium user can open the same project

## Perfect for

Teams building on LLMs who want to see what their application really does, without sending prompts and answers to a third-party cloud.

## Good to know

- **Components.** Emporium installs the Langfuse web app and worker, a single-node ClickHouse (official image, volume sized in the install form) for traces, and uses Emporium's PostgreSQL (CloudNativePG, certificate verified), Redis (Valkey, persistent) and S3 storage (RustFS) providers. This is a heavy app: plan for about 1.7 GiB of memory in use at idle (web, worker, ClickHouse, PostgreSQL, Redis, S3) and 4.5 GiB of limits for web, worker and ClickHouse.
- **Single sign-on.** "Sign in with Emporium" is Langfuse's generic OpenID Connect login. Langfuse needs an **email address** on the account: Emporium users without an email cannot sign in by SSO (an Emporium administrator sets it). The first SSO login creates the Langfuse account and adds it to the "Emporium" organization with the role chosen at install (default Viewer); organization owners change roles under Organization settings > Members. Langfuse does not read the Emporium `roles` claim, so Emporium administrators are not mapped to Langfuse administrators.
- **Bootstrap administrator.** The first start creates the account from "Administrator email" (default `admin@example.com`), the organization "Emporium" and the project "Default". The password and the initial project API keys are in the app's Secret (`LANGFUSE_INIT_USER_PASSWORD`, `LANGFUSE_INIT_PROJECT_PUBLIC_KEY`, `LANGFUSE_INIT_PROJECT_SECRET_KEY`). A single-sign-on account with the same email is linked to it, so using your real email as the administrator email makes SSO sign you in as owner.
- **New accounts.** Langfuse has one switch for sign-up (`AUTH_DISABLE_SIGNUP`); it also blocks the first single sign-on of a new user. "Block new accounts" therefore leaves only existing accounts able to sign in. The Emporium login in front already limits who reaches the app.
- **SDK access skips the Emporium login.** The public API routes the SDKs and exporters use (`/api/public/ingestion`, `/otel`, `/traces`, `/scores`, `/prompts`, `/datasets`, `/metrics`, `/mcp` and the other key-authenticated ones, listed in `emporium.yaml`) are reachable without an Emporium session and are protected by the project API keys (public + secret key, HTTP basic auth). Create keys under Project settings > API keys. `/api/public/health` and `/api/public/ready` need no key and report status, so they are not in the list and stay behind the Emporium login. The web UI is behind the Emporium login too.
- **Which SDKs.** Langfuse 4 stores traces in a new layout. By default ("Trace storage: Both") the legacy layout is written as well, so Langfuse SDK v2/v3 and the old ingestion endpoint keep working next to SDK v4 and OpenTelemetry (`/api/public/otel`). "New layout only" halves the trace storage but rejects the older SDKs.
- **Media attachments.** Event data goes to S3 through the worker. Uploads of images and other media from SDKs use presigned URLs on the S3 endpoint, which is internal to the cluster; use text and structured data, or point `extraEnv` at an externally reachable S3 endpoint for media.
- **Licence.** The Langfuse core is MIT. Features under the Langfuse Enterprise licence (SCIM, audit logs, project-level roles, data retention, protected prompt labels) stay locked because no licence key is set. Telemetry to Langfuse is off.
- Upstream v4 images are used (`docker.io/langfuse/langfuse` and `langfuse-worker`, 4.67.0); the v3 line is the legacy one.
- **Database connections.** PostgreSQL is reached with TLS and the server certificate is verified against the CloudNativePG CA (`sslaccept=strict`). ClickHouse accepts connections only from the Langfuse web and worker pods (NetworkPolicy; needs a CNI that enforces it).
- **Known upstream limitation.** At start the Langfuse image runs its migrations with the PostgreSQL and ClickHouse credentials as command-line arguments (`prisma db execute --url`, `migrate -database`). They are visible only to processes inside that container, at startup; Emporium cannot change this without patching the image.
- **ClickHouse version.** The ClickHouse image is pinned to the 25.12 alpine line that Langfuse upstream tests against, and is not tracked by the automatic image updater (newer lines drop the alpine variant). Bump it by hand after checking Langfuse's supported ClickHouse version.
- **Slack integration.** `/api/public/slack*` stays behind the Emporium login: installing the Slack app happens in a signed-in browser, so it does not need the bypass.
