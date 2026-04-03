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

## Links

- 🌐 [kaizen-lab.buildgeeks.dev](https://kaizen-lab.buildgeeks.dev)
- 📦 [npmjs.com/package/kaizen-lab-mcp](https://npmjs.com/package/kaizen-lab-mcp)
- 🔧 [smithery.ai/servers/toshipon/kaizen-lab](https://smithery.ai/servers/toshipon/kaizen-lab)
