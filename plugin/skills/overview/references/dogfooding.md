# Dogfooding Protocol

When using KaizenLab and encountering bugs or improvement ideas, report them to the dogfooding project.

## Dogfooding Project
- **Project ID**: `3e425e9e-6fab-44d7-9f03-f65685365409`
- **Project Name**: KaizenLab ドッグフーディング

## MCP 経由のレポート（推奨）

### バグ報告
```bash
curl -X POST https://kaizen-lab.buildgeeks.dev/api/mcp \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $KAIZEN_API_KEY" \
  -d '{
    "jsonrpc": "2.0", "id": 1,
    "method": "tools/call",
    "params": {
      "name": "add_learning",
      "arguments": {
        "project_id": "3e425e9e-6fab-44d7-9f03-f65685365409",
        "title": "Bug: [短い説明]",
        "content": "[詳細な再現手順と期待される動作]",
        "category": "bug",
        "tags": ["bug", "dogfooding", "[affected-feature]"]
      }
    }
  }'
```

### 改善提案
```bash
curl -X POST https://kaizen-lab.buildgeeks.dev/api/mcp \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $KAIZEN_API_KEY" \
  -d '{
    "jsonrpc": "2.0", "id": 1,
    "method": "tools/call",
    "params": {
      "name": "add_learning",
      "arguments": {
        "project_id": "3e425e9e-6fab-44d7-9f03-f65685365409",
        "title": "Improvement: [短い説明]",
        "content": "[改善の詳細と期待される効果]",
        "category": "improvement",
        "tags": ["improvement", "dogfooding", "[affected-feature]"]
      }
    }
  }'
```

## REST API 経由のレポート

### バグ報告
```bash
bash scripts/kaizen-api.sh POST /api/project/3e425e9e-6fab-44d7-9f03-f65685365409/learnings \
  '{"title":"Bug: [短い説明]","content":"[詳細]","category":"bug","source":"dogfooding","tags":["bug","dogfooding"]}'
```

### 改善提案
```bash
bash scripts/kaizen-api.sh POST /api/project/3e425e9e-6fab-44d7-9f03-f65685365409/learnings \
  '{"title":"Improvement: [短い説明]","content":"[詳細]","category":"improvement","source":"dogfooding","tags":["improvement","dogfooding"]}'
```

## Severity Guidelines
- **Bug**: 機能が動かない、エラーが出る、データが消える
- **Improvement**: UXの改善、パフォーマンス、新機能アイデア
- Tags に影響範囲を含める: `canvas`, `persona`, `interview`, `learning`, `verification`, `roadmap`, `api`, `mobile`, `dark-mode`, `mcp`

## ドッグフーディングサイクル（MCP版）

1. **MCP で状態確認**: `list_projects` → `get_canvas` → `get_verification_status`
2. **本番サイトを触る**: <https://kaizen-lab.buildgeeks.dev> を実際に操作
3. **問題発見 → MCP で即レポート**: `add_learning` でバグ/改善を記録
4. **修正実装 → PR → マージ**: コードで修正
5. **MCP で修正確認**: 再度状態確認して改善を検証
