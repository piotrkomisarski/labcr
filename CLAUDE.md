# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Fullstack application with Kotlin/Spring Boot backend and Angular frontend.

## Tech Stack

**Frontend (`frontend/`):**
- Angular v21 with **Signals** (nie Observables/RxJS)
- Tailwind CSS + DaisyUI
- Standalone components
- **Bun** as package manager (not npm)

**Backend (`backend/`):**
- Kotlin + Spring Boot (latest)
- TBD

## Commands

**Frontend:**
```bash
cd frontend
bun start          # dev server on http://localhost:4200
bun run build      # production build
bun test           # run tests
```

## Claude Code Configuration

Custom status line scripts and MCP server configuration for enhancing the Claude Desktop CLI experience.

## Architecture

**Status Line System:**
- `statusline.sh` - Main bash script for Unix/WSL, displays: directory, model name, context usage (visual progress bar), and git status with file/line change counts
- `.claude/statusline.ps1` - PowerShell equivalent for native Windows (simpler format, no git integration)
- `.claude/settings.local.json` - Configures Claude to use `wsl ./statusline.sh` for status line

**MCP Configuration:**
- `.mcp.json` - Configures Exa AI MCP server providing web search, code context, crawling, company research, LinkedIn search, and deep research capabilities

## Key Files

| File | Purpose |
|------|---------|
| `statusline.sh` | Bash status line with context bar + git info (runs via WSL) |
| `.claude/statusline.ps1` | PowerShell status line (Windows native fallback) |
| `.claude/settings.local.json` | Local Claude settings |
| `.mcp.json` | MCP server configuration |

## Status Line JSON Input

The status line scripts receive JSON via stdin with this structure:
```json
{
  "model": { "display_name": "..." },
  "workspace": { "current_dir": "..." },
  "context_window": {
    "context_window_size": 200000,
    "current_usage": {
      "input_tokens": 0,
      "cache_creation_input_tokens": 0,
      "cache_read_input_tokens": 0
    }
  }
}
```

## Platform Notes

- Primary platform: Windows with WSL
- The bash script requires `jq` to be installed in WSL
- Context percentage calculated against 200k token window
