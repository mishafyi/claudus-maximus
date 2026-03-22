# claudus-maximus

Personal Claude Code plugin marketplace.

## Usage

```bash
/plugin marketplace add mishafyi/claudus-maximus
```

## Adding plugins

Add plugin entries to `.claude-plugin/marketplace.json` under the `plugins` array.

Each plugin can be sourced from:
- A local subdirectory: `"source": "./plugins/my-plugin"`
- A GitHub repo: `"source": {"source": "github", "repo": "owner/repo"}`
- A git URL: `"source": {"source": "url", "url": "https://...repo.git"}`
- A git subdirectory: `"source": {"source": "git-subdir", "url": "...", "path": "path/to/plugin"}`

### Plugin entry example

```json
{
  "name": "my-plugin",
  "description": "What this plugin does",
  "source": "./plugins/my-plugin",
  "version": "1.0.0"
}
```

Each local plugin needs its own `.claude-plugin/plugin.json` manifest inside its directory.
