#!/usr/bin/env bash
# Conecta o Donnar ao Claude Code.
# Documentação: https://docs.anthropic.com/en/docs/claude-code/mcp
set -euo pipefail

claude mcp add --transport http donnar https://mcp.donnar.app/start
claude mcp list

cat <<'EOF'

Próximos passos:
  1. Abra o Claude Code e rode /mcp.
  2. Escolha "donnar" e conclua o login no navegador.
  3. Peça: "Mostre o contexto da conexão do Donnar."

Se preferir configuração por projeto, use o .mcp.json da raiz deste repositório.
EOF
