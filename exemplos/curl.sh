#!/usr/bin/env bash
# Testes rápidos do MCP do Donnar.
# Uso:
#   bash exemplos/curl.sh
#   DONNAR_TOKEN=dmcp_... bash exemplos/curl.sh
set -euo pipefail

MCP_URL="${MCP_URL:-https://mcp.donnar.app/start}"
TOKEN="${DONNAR_TOKEN:-}"

echo "== initialize =="
curl -s "$MCP_URL" \
  -H 'content-type: application/json' \
  -H 'accept: application/json, text/event-stream' \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2025-06-18",
      "capabilities": {},
      "clientInfo": { "name": "donnar-exemplo", "version": "1.0.0" }
    }
  }'
echo
echo

echo "== tools/list =="
curl -s "$MCP_URL" \
  -H 'content-type: application/json' \
  -d '{"jsonrpc":"2.0","id":2,"method":"tools/list"}'
echo
echo

if [[ -z "$TOKEN" ]]; then
  echo "DONNAR_TOKEN não definido: pulando tools/call."
  echo "Gere uma chave em https://dash.donnar.app/ia ou use OAuth no seu cliente."
  exit 0
fi

echo "== tools/call: donnar_contexto =="
curl -s "$MCP_URL" \
  -H 'content-type: application/json' \
  -H "authorization: Bearer $TOKEN" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": { "name": "donnar_contexto", "arguments": {} }
  }'
echo
