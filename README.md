# KaizenLab — Claude Code Plugin

Use KaizenLab's hypothesis validation platform directly from Claude Code.  
Records learnings, manages canvases, and runs PMF validation cycles — all via slash commands.

## Install

```bash
# Step 1: Add as marketplace source
claude plugin marketplace add toshipon/kaizen-lab-plugin

# Step 2: Install
claude plugin install kaizen-lab@kaizen-lab
```

On first use, your browser opens for Google sign-in. Token is issued automatically (no API key needed).

> **Note**: If you use nvm/volta, Claude Desktop may use an older Node.js.  
> Check with `which npx` and use the full path in `claude_desktop_config.json` if needed.

## Slash Commands

| Command | Description |
|---------|-------------|
| `/kaizen-lab:learn [insight]` | Record a learning from the current session |
| `/kaizen-lab:verify` | Check verification status across hypotheses |
| `/kaizen-lab:canvas` | View or update the hypothesis canvas |

## What it does

The plugin bundles:
- **MCP server** — 56 tools for full KaizenLab access (projects, canvases, personas, interviews, verifications, learnings, roadmap)
- **Slash commands** — quick workflows for the most common actions

## MCP Only (no slash commands)

If you just want the MCP server without slash commands:

```bash
claude mcp add --transport http kaizen-lab https://kaizen-lab.buildgeeks.dev/api/mcp
```

## Install via APM

The skills are also distributed through [APM (Agent Package Manager)](https://github.com/microsoft/apm), so you can pull them into any APM-compatible agent (Claude Code, Copilot, Cursor, Codex...).

Add the skills you want to your project's `apm.yml`:

```yaml
name: your-project
version: 1.0.0
dependencies:
  apm:
    # All three skills
    - toshipon/kaizen-lab-plugin/skills/kaizen-lab/learn
    - toshipon/kaizen-lab-plugin/skills/kaizen-lab/verify
    - toshipon/kaizen-lab-plugin/skills/kaizen-lab/canvas
  mcp:
    - name: kaizen-lab
      registry: false
      transport: http
      url: https://kaizen-lab.buildgeeks.dev/api/mcp
```

Then run:

```bash
apm install
```

Pin a specific version with `#v1.2.0` (or any git ref):

```yaml
- toshipon/kaizen-lab-plugin/skills/kaizen-lab/learn#v1.2.0
```

Or install the whole skill bundle at once:

```yaml
dependencies:
  apm:
    - toshipon/kaizen-lab-plugin#v1.2.0
```

> APM will deploy the skills into your agent's expected location (e.g. `.claude/skills/`). The MCP server is configured automatically from the `mcp` block.

## Links

- 🌐 [kaizen-lab.buildgeeks.dev](https://kaizen-lab.buildgeeks.dev)
- 📦 [npmjs.com/package/kaizen-lab-mcp](https://npmjs.com/package/kaizen-lab-mcp)
- 🔧 [smithery.ai/servers/toshipon/kaizen-lab](https://smithery.ai/servers/toshipon/kaizen-lab)
