# KaizenLab API Reference

## Authentication
All API calls require Bearer token authentication:
```
Authorization: Bearer <API_KEY>
```
API キーは Settings 画面で発行。

## MCP Endpoint

`POST https://kaizen-lab.buildgeeks.dev/api/mcp` — JSON-RPC 2.0 over HTTP

### Protocol Flow
1. `initialize` → サーバー情報取得
2. `tools/list` → 利用可能ツール一覧 (56ツール)
3. `tools/call` → ツール実行

### Example
```bash
curl -X POST https://kaizen-lab.buildgeeks.dev/api/mcp \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"list_projects","arguments":{}}}'
```

### MCP Client 設定例（Claude Desktop / Cursor 等）
```json
{
  "mcpServers": {
    "kaizen-lab": {
      "url": "https://kaizen-lab.buildgeeks.dev/api/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_TOKEN"
      }
    }
  }
}
```

---

## Available MCP Tools (56)

### Projects
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_projects` | プロジェクト一覧 | — |
| `create_project` | プロジェクト作成 | `name` |
| `delete_project` | プロジェクト削除 | `project_id` |
| `export_project` | エクスポート（csv/json/markdown） | `project_id`, `format`, `target` |
| `get_dashboard` | ダッシュボード（統計情報） | `project_id` |
| `get_changelog` | 変更履歴 | `project_id` |

### Hypothesis Canvas
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_canvases` | 仮説キャンバス一覧 | `project_id` |
| `get_canvas` | 仮説キャンバス詳細 | `canvas_id` |
| `create_canvas` | 仮説キャンバス作成 | `project_id`, `name` |
| `update_canvas` | 仮説キャンバス更新（名前・フェーズ）。phase: `ideation`, `problem-validation`, `solution-validation`, `mvp-building`, `growth` | `canvas_id` |
| `delete_canvas` | 仮説キャンバス削除（関連付箋も削除） | `canvas_id` |
| `get_pmf_score` | PMFスコア取得 | `project_id` |
| `analyze_competitors` | 仮説キャンバスを元にAI競合分析を実行しDBに保存 | `canvas_id` |

`create_canvas` の `fields` オプション:
```json
{
  "purpose": "", "vision": "", "valueProposition": "",
  "obviousProblem": "", "latentProblem": "", "means": "",
  "advantage": "", "metrics": "", "revenueModel": "",
  "marketSize": "", "situation": "", "trend": "",
  "alternatives": "", "channel": ""
}
```

### Verification Canvas
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_verification_canvases` / `list_verifications` | 検証キャンバス一覧 | `project_id` |
| `get_verification_canvas` | 検証キャンバス詳細 | `canvas_id` |
| `create_verification_canvas` | 検証キャンバス作成 | `project_id`, `name` |
| `update_verification_canvas` | 検証キャンバス更新 | `canvas_id` |
| `get_verification_status` | 検証ステータス取得 | `project_id` |

ステータス: `not-started` | `in-progress` | `validated` | `invalidated`

#### ⚠️ 検証キャンバスの `sections` フォーマット（必読）

UIは **Why/How/What ウィザード** 形式。`sections` にフラットなデータを入れても表示されない。
必ず以下のネスト構造を使うこと：

```json
{
  "why": {
    "purpose": "この検証の目的",
    "targetHypothesis": "検証対象の仮説テキスト",
    "stickyNoteId": null,
    "successMetrics": [
      { "id": "sm1", "type": "quantitative", "description": "指標名", "target": "目標値" },
      { "id": "sm2", "type": "qualitative", "description": "定性的な成功基準" }
    ],
    "expectations": "期待される結果の予測"
  },
  "how": {
    "method": "interview|survey|prototype|ab-test|analytics|other",
    "mvpDefinition": "検証手順の詳細（複数行OK）",
    "environment": {
      "tools": "使用ツール",
      "targetUsers": "対象ユーザー",
      "location": "実施場所"
    },
    "schedule": [
      { "id": "s1", "label": "タスク名", "startDate": "YYYY-MM-DD", "endDate": "YYYY-MM-DD" }
    ]
  },
  "what": {
    "quantitativeResults": [
      { "id": "r1", "metricName": "指標名", "expected": "期待値", "actual": "実績値" }
    ],
    "qualitativeResults": "定性的な結果（テキスト）",
    "learnings": [
      { "id": "l1", "content": "学んだこと", "tags": ["tag1"] }
    ],
    "nextAction": { "type": "pivot|persevere|stop|", "description": "次のアクション" }
  }
}
```

- **whatセクション** は検証実施後に埋める（作成時は空でOK）
- `successMetrics[].type` は `"quantitative"` か `"qualitative"`
- `how.method` は6種の enum 値のみ

##### ⚠️ `sections` は全置換（マージではない）

`update_verification_canvas` に `sections` を渡すと **トップレベルが丸ごと置き換わる**。
`{ "what": {...} }` だけを渡すと **既存の `why` と `how` は黙って消える**。

部分更新をしたい場合は必ず `get_verification_canvas` で現在値を読み、マージした完全なオブジェクトを渡すこと。

また、**未知のキーはエラーにならず黙って破棄される**。キー名を1文字間違えるだけで内容が失われ、警告も出ない。推測せず上記のスキーマ表に従うこと。

型が混在している点にも注意:

| キー | 型 |
|------|-----|
| `what.qualitativeResults` | **文字列** |
| `what.quantitativeResults` | **配列** |
| `what.nextAction` | **オブジェクト** `{ type, description }` |
| `what.learnings` | **配列** |

### Learnings
| Tool | Description | Required Args |
|------|-------------|---------------|
| `add_learning` | ラーニング追加 | `project_id`, `title`, `content` |
| `get_learning` | ラーニング詳細 | `learning_id` |
| `update_learning` | ラーニング更新 | `learning_id` |
| `delete_learning` | ラーニング削除 | `learning_id` |
| `search_learnings` | ラーニング検索 | `project_id` |
| `list_learnings` | 学習一覧（ページネーション対応） | `project_id` |
| `analyze_learnings` | 蓄積された学びからパターン・矛盾・次アクションをAI分析 | `project_id` |

オプション: `tags` (text[]), `impact_level` (`low`|`medium`|`high`|`critical`)

### Personas & Interviews
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_personas` | ペルソナ一覧 | `project_id` |
| `create_persona` | ペルソナ作成 | `project_id`, `name` |
| `get_interview_records` | インタビュー記録取得 | `project_id` |
| `create_interview` | インタビュー作成 | `project_id`, `title` |

ペルソナ注意: フィールドは `occupation`（`role` ではない）。`goals`/`frustrations`/`behaviors` は text[]。
インタビュー注意: `title` は **必須**。`key_insights`/`quotes`/`tags` は `text[]`。

### Roadmap
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_roadmap` | フェーズ・アイテム一覧 | `project_id` |
| `create_roadmap_phase` | フェーズ作成 | `project_id`, `name` |
| `create_roadmap_item` | アイテム作成 | `project_id`, `phase_id`, `title` |
| `update_roadmap_item` | アイテム更新 | `project_id`, `item_id` |

- フェーズ status: `planning` | `in_progress` | `done`
- アイテム status: `idea` | `planned` | `in_progress` | `done` | `cancelled`
- アイテム priority (MoSCoW): `must` | `should` | `could` | `wont`
- アイテム effort: `small` | `medium` | `large`
- リンク: `hypothesis_id`, `learning_id` で仮説・ラーニングと紐付け可能

### Journey Maps
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_journey_maps` | ジャーニーマップ一覧 | `project_id` |
| `create_journey_map` | ジャーニーマップ作成 | `project_id`, `title` |

### Decision Logs (意思決定ログ)
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_decisions` | 意思決定ログ一覧 | `project_id` |
| `get_decision` | 意思決定ログ詳細 | `decision_id` |
| `create_decision` | 意思決定ログ作成 | `project_id`, `title`, `decision_type`, `rationale` |
| `update_decision` | 意思決定ログ更新 | `decision_id` |
| `delete_decision` | 意思決定ログ削除 | `decision_id` |

意思決定タイプ (`decision_type`):
- `pivot`: ピボット（方向転換）
- `persevere`: 継続
- `kill`: 中止
- `pause`: 保留

代替案 (`alternatives_considered`) フォーマット:
```json
[
  { "option": "案A", "reason_rejected": "コストが高い" },
  { "option": "案B", "reason_rejected": "時間がかかる" }
]
```

### Team Collaboration - Members
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_members` | プロジェクトメンバー一覧 | `project_id` |
| `invite_member` | メンバーを招待（user_idとrole指定） | `project_id`, `user_id`, `role` |
| `update_member_role` | メンバーの権限を更新（オーナーのみ） | `project_id`, `member_id`, `role` |
| `remove_member` | メンバーを削除 | `project_id`, `member_id` |

ロール: `owner` | `editor` | `viewer`
ステータス: `pending` | `accepted`

**権限ルール**:
- 招待: オーナーまたはエディター
- 権限変更: オーナーのみ
- 削除: オーナー（他メンバー）または自分自身（脱退）
- オーナーは削除不可

### Team Collaboration - Comments
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_comments` | コメント一覧 | `project_id` |
| `create_comment` | コメント作成 | `project_id`, `content` |
| `update_comment` | コメント更新（自分のみ） | `project_id`, `comment_id`, `content` |
| `get_comment` | コメント詳細（全文表示） | `project_id`, `comment_id` |
| `delete_comment` | コメント削除 | `project_id`, `comment_id` |

オプション: `field_key`（フィールド紐付け）, `thread_id`（スレッド）, `parent_id`（返信）
最大文字数: 10000

**権限ルール**:
- 作成: オーナーまたはエディター
- 更新: コメント作成者のみ
- 削除: コメント作成者またはオーナー

### Team Collaboration - Invitations
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_invitations` | 自分宛の保留中招待一覧 | — |
| `accept_invitation` | 招待を承諾 | `invitation_id` |
| `reject_invitation` | 招待を拒否 | `invitation_id` |

### 付箋（Sticky Notes）

| ツール名 | 説明 | 必須パラメータ | オプション |
|----------|------|---------------|-----------|
| `add_sticky_note` | 仮説キャンバスの付箋を追加 | `canvas_id`, `field_id`, `text` | `color`, `supplementary_note` |
| `update_sticky_note` | 付箋の内容を更新 | `note_id` | `text`, `color`, `supplementary_note` |
| `delete_sticky_note` | 付箋を削除 | `note_id` | — |

### 検証キャンバス（追加操作）

| ツール名 | 説明 | 必須パラメータ |
|----------|------|---------------|
| `delete_verification_canvas` | 検証キャンバスを削除 | `canvas_id` |

---

## DB Column Gotchas

| テーブル | 注意点 |
|----------|--------|
| `personas` | `occupation`（NOT `role`）、goals/frustrations/behaviors は `text[]` |
| `learnings` | `content`（NOT `description`）、tags は `text[]` |
| `interview_records` | key_insights/quotes/tags は `text[]` |
| `hypothesis_canvases` | `fields` カラム削除済み。API/MCPは `fields` パラメータを受け付けるが内部で `sticky_notes` に変換 |
| `projects` | `owner_id`（NOT `user_id`） |
| `validation_canvases` | `name`（NOT `title`）、`sections` は `{why, how, what}` ネスト構造必須（フラットNG） |
| `hypothesis_canvases` | `fields` カラムは削除済み（PR #365）。`sticky_notes` テーブルが唯一のデータソース |
| `roadmap_items` | priority は MoSCoW、status は idea/planned/in_progress/done/cut |
| `project_members` | `status` は `pending`/`accepted`。`role` は `owner`/`editor`/`viewer`。UNIQUE(project_id, user_id) |
| `project_comments` | `content` は必須（最大10000文字）。`field_key`/`thread_id`/`parent_id` は nullable |
