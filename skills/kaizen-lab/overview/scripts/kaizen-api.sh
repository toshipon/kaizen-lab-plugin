#!/bin/bash
# KaizenLab API helper script
# Usage: kaizen-api.sh <method> <path> [json-body]
# Env: KAIZEN_API_KEY, KAIZEN_BASE_URL (defaults provided)

BASE_URL="${KAIZEN_BASE_URL:-https://kaizen-lab.buildgeeks.dev}"
API_KEY="${KAIZEN_API_KEY:?KAIZEN_API_KEY is required. Generate a token in Settings > Access Tokens}"

METHOD="${1:-GET}"
PATH_="${2:-/api/projects}"
BODY="${3:-}"

if [ -n "$BODY" ]; then
  curl -s -X "$METHOD" "${BASE_URL}${PATH_}" \
    -H "Authorization: Bearer ${API_KEY}" \
    -H "Content-Type: application/json" \
    -d "$BODY"
else
  curl -s -X "$METHOD" "${BASE_URL}${PATH_}" \
    -H "Authorization: Bearer ${API_KEY}"
fi
