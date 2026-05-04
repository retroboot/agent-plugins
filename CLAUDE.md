# Hivrr Claude Plugin

Skills and commands for implementation, brainstorming, planning, and code review workflows in Claude Code.

## Plugins

### `hivrr`
Full development toolkit — implementation, brainstorming, planning, and code review.

**Skills:** `audit`, `audit-accessibility`, `audit-performance`, `audit-security`, `audit-tech-debt`, `brainstorm`, `core`, `debug`, `merge-pr`, `planning`, `review-pr`, `wave`, `work-issue`, `work-pr`

**Commands:** `audit`, `brainstorm`, `debug`, `merge-pr`, `planning`, `review-pr`, `work-issue`, `work-pr`, `write-plan`

---

### `manager`
Manager utility skills for automated work allocation — scoring, grouping, and failure diagnosis.

**Skills:** `score-issues`, `group-issues`, `diagnose-failure`

**Commands:** `score-issues`, `group-issues`, `diagnose-failure`

---

### `data-platform`
Full data platform skills — covers the complete stack from ingestion and pipelines to ML, LLMs, dashboards, and database administration.

**Skills:** `senior-data-scientist`, `senior-data-engineer`, `senior-data-analyst`, `senior-ai-engineer`, `snowflake`, `postgres`, `postgres-query`

---

## Running Multiple Instances

When running multiple instances of the plugin, set the `CONTAINER_NETWORK` environment variable in your `.env` file to reference the Docker network created by Docker Compose. The network name follows the pattern `{directory_name}_default`, where `directory_name` is the folder containing the compose file — not the project name. For example, if your compose file is located in `/path/to/agent-plugin/docker-compose.yml`, add the following to your `.env` file:

```
CONTAINER_NETWORK=agent-plugin_default
```

If you define a custom network name in your `docker-compose.yml`, use that name instead of the `{directory_name}_default` pattern. If the specified network does not exist, Docker will fail to connect and containers will be unable to communicate.
