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
2. `tools/list` → 利用可能ツール一覧 (70ツール)
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

## Available MCP Tools (70)

表の引数の欄は必須の引数を並べる。`?` を付けたものは任意で、その他の任意の引数は `tools/list` の inputSchema を見る。

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
| `show_canvas_app` | MCP Apps 対応ホスト内で仮説キャンバスを read-only UI 表示（非対応ホストでは `get_canvas` と同じテキストを返す） | `canvas_id` |

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

#### Optional Args（create / update 共通）

| Arg | 説明 |
|-----|------|
| `hypothesis_canvas_id` | 紐付ける仮説キャンバスID。update では `null` で解除 |
| `sticky_note_id` | 紐付ける付箋ID。`hypothesis_canvas_id` の付箋であること。update では `null` で解除 |
| `verification_phase` | `problem-fit` \| `solution-fit` \| `channel-fit` \| `pmf` |
| `validation_mode` | `prove`（当てにいく） \| `explore`（出会う） |

#### ⚠️ 検証キャンバスの `sections` フォーマット（必読）

UIは **Why/How/What ウィザード** 形式。`sections` にフラットなデータを入れても表示されない。
必ず以下のネスト構造を使うこと：

```json
{
  "why": {
    "purpose": "この検証の目的",
    "hypothesisStatement": "検証対象の仮説テキスト",
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

`why.targetHypothesis` と `why.stickyNoteId` は紐付けの欄で、サーバーが `hypothesis_canvas_id` / `sticky_note_id` の値で書く（直接書かない）。
仮説の本文は `why.hypothesisStatement` に書く。`targetHypothesis` に本文を書いた場合は `hypothesisStatement` が空なら移される。

- **whatセクション** は検証実施後に埋める（作成時は空でOK）
- `successMetrics[].type` は `"quantitative"` か `"qualitative"`
- `how.method` は6種の enum 値のみ

### Learnings
| Tool | Description | Required Args |
|------|-------------|---------------|
| `add_learning` | ラーニング追加 | `project_id`, `title`, `content?` |
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
| `create_interview` | インタビュー作成（実施日 `date` は YYYY-MM-DD で省略時は UTC の今日、`duration_minutes` は 1〜1440 分） | `project_id`, `title`, `date?`, `duration_minutes?` |

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
- アイテム status: `idea` | `planned` | `in_progress` | `done` | `dropped`
- アイテム priority (MoSCoW): `must` | `should` | `could` | `wont`
- アイテム effort: `small` | `medium` | `large`
- リンク: `hypothesis_id`, `learning_id` で仮説・ラーニングと紐付け可能

### Journey Maps
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_journey_maps` | ジャーニーマップ一覧（`create_journey_map` で保存した `stages` の中身も返す） | `project_id` |
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

### Decision Requests (判断依頼)
これからオーナーに決めてもらう問い。事後に記録する意思決定ログとは別物で、回答されても `decision_logs` には自動で入らない。回答はオーナーが Web か Slack で行い、MCP からは回答できない。

| Tool | Description | Required Args |
|------|-------------|---------------|
| `create_decision_request` | 判断依頼を起票（同じ `source_ref` の open があれば既存を返す） | `project_id`, `title` |
| `list_decision_requests` | 判断依頼一覧（`status`、`format: "json"` 可） | `project_id` |
| `get_decision_request` | 判断依頼詳細（`format: "json"` 可） | `project_id`, `request_id` |
| `acknowledge_decision_request` | 回答を受けて何をしたかを添えて受領済みにする。期限切れの default がある open も受領でき、default が回答として確定する | `project_id`, `request_id`, `note` |
| `cancel_decision_request` | open の判断依頼を取り消す | `project_id`, `request_id` |
| `post_slack_notification` | project の Slack 投稿先に 1 回きりの通知を送る。回答は求めない。`kind` は `alert`（人が動く必要がある異常。owner をメンション）/ `milestone`（節目。メンションしない）。投稿先が未設定ならエラーにせず送らなかったと返す | `project_id`, `kind`, `title`, `body?`, `url?` |

status は `open` → `answered`（オーナーが回答）→ `acknowledged`（ループが受領）と進む。`open` は `cancelled` にもできる。

選択肢 (`options`) フォーマット（6 件まで。0 件なら自由記述だけで答える依頼）:
```json
[
  { "key": "monthly", "label": "月額", "description": "初期費用を抑える" },
  { "key": "yearly", "label": "年額" }
]
```
`default_option_key` を付けるときは 24 時間以上先の `due_at` が必要（ループが期限をすぐ先にして自分の default を確定できないようにするため）。`format: "json"` の出力は `id`、`status`、`answer_option_key`、`answer_option_label`、`answer_comment`、`answer_via`（`web` / `slack` / `default`）、`due_at`、`default_option_key`、`source_ref` を含む。

### Team Collaboration - Members
| Tool | Description | Required Args |
|------|-------------|---------------|
| `list_members` | プロジェクトメンバー一覧（オーナーには未承諾のメール招待の id・メール・ロール・期限も） | `project_id` |
| `invite_member` | メンバーをメールで招待（`email` と `role` を指定。`role` は `editor` \| `viewer`） | `project_id`, `email`, `role` |
| `update_member_role` | メンバーの権限を更新（オーナーのみ） | `project_id`, `member_id`, `role` |
| `remove_member` | メンバーを削除 | `project_id`, `member_id` |
| `revoke_email_invitation` | 未承諾のメール招待を取り消す（オーナーのみ。外したメンバー宛ての招待は remove_member が自動で消す） | `project_id`, `invitation_id` |

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

| ツール名 | 説明 | パラメータ（`?` は任意） |
|----------|------|---------------|
| `add_sticky_note` | 仮説キャンバスの付箋を追加 | `canvas_id`, `field_id`, `text`, `color?`, `supplementary_note?` |
| `update_sticky_note` | 付箋の内容を更新 | `note_id`, `text?`, `color?`, `supplementary_note?` |
| `delete_sticky_note` | 付箋を削除 | `note_id` |

### 検証キャンバス（追加操作）

| ツール名 | 説明 | 必須パラメータ |
|----------|------|---------------|
| `delete_verification_canvas` | 検証キャンバスを削除 | `canvas_id` |

### 実験バックログ（Experiment Backlog）

仮説・検証・学び・意思決定から「次にやる実験」を優先度順に積むバックログ。

| ツール名 | 説明 | 必須パラメータ |
|----------|------|---------------|
| `list_backlog_items` | 実験バックログを優先度順に取得 | `project_id` |
| `create_backlog_item` | バックログアイテムを作成 | `project_id`, `title` |
| `update_backlog_item` | バックログアイテムを更新 | `project_id`, `item_id` |

共通オプション:

- `type`: `experiment` / `feature` / `research` / `interview` / `analysis` / `improvement`
- `status`: `idea` / `prioritized` / `planned` / `running` / `done` / `dropped`
- `source_type`: `hypothesis` / `verification` / `learning` / `decision` / `manual`（`source_id` で紐付け元を指定）
- 紐付け: `hypothesis_canvas_id`, `verification_canvas_id`, `learning_id`
- スコア: `impact`, `confidence`, `effort`, `risk`（いずれも 1〜5）
- その他: `description`, `reason`, `expected_learning`, `success_criteria`, `owner`, `due_date`
- `list_backlog_items` は `status` / `source_type` で絞り込み、`limit` で件数指定が可能

### Analytics

| ツール名 | 説明 | パラメータ（`?` は任意） |
|----------|------|---------------|
| `get_mcp_tool_analytics_summary` | MCP ツール呼び出しの集計・`decisionSignals`・`recommendations` を取得（`days` は 1〜90、default 30） | `days?` |
| `get_activation_analytics_summary` | 自分のプロジェクトの activation 集計（`activation_daily_summary`, `canvas_first_note_timing` 等。`days` は 1〜90、default 30） | `days?` |

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
