---
name: overview
description: Use KaizenLab hypothesis validation platform via MCP. Create projects, hypothesis canvases, personas, AI interviews, verifications, and learnings for PMF validation. Manage team collaboration with role-based access control, member invitations, and project comments. Use when validating business hypotheses, running lean startup cycles, or doing customer development. Also use when the user wants to brainstorm, validate, or test a business idea systematically.
---

# KaizenLab Overview

KaizenLab は **仮説検証型のプロダクト開発** を支援するプラットフォーム。
「正しいものを正しくつくる」ために、**つくる前に学ぶ** ことを重視する。

不確実性の高いプロダクト開発では、いきなりつくり始めるのではなく、
まず「何が分かっていないのか」を明らかにし、最もリスクの高い仮説から順に検証していく。
KaizenLab はこの **仮説→検証→学び→次の仮説** のサイクルを構造化し、チームの学びを蓄積する。

> このスキルは KaizenLab 全体の使い方を俯瞰するガイド。
> 個別の操作はコマンドスキル `/kaizen-lab:canvas`, `/kaizen-lab:verify`, `/kaizen-lab:learn`, `/kaizen-lab:roadmap` を使う。

---

## 思想: 仮説検証ループ

プロダクト開発の本質は「正解を当てる」ことではなく、「学びを積み重ねて正解に近づく」こと。

```
仮説を立てる → 検証する → 学びを得る → 次の仮説に活かす
    ↑                                        ↓
    ←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←←
```

### 3つの原則

1. **不確実性の高いものから検証する**
   - 全部つくってからダメだったでは遅い。最もリスクが高い（＝分からない）部分から潰す
   - 「顧客は本当にこの課題を持っているか？」が「ボタンの色は何色か？」より先

2. **つくらずに学ぶ**
   - コードを書く前にできる検証がある。インタビュー、プロトタイプ、競合分析
   - 「つくる」は検証手段の一つでしかない

3. **学びを資産にする**
   - 検証の結果（成功も失敗も）を記録し、チームの判断基準にする
   - 同じ失敗を繰り返さない。学びが次の仮説の精度を上げる

---

## 機能と利用順序

KaizenLab の各機能は、仮説検証サイクルのフェーズに対応している。

### Phase 1: 仮説を立てる

#### 🎯 仮説キャンバス（Hypothesis Canvas）

**事業やプロダクトレベルの仮説** を構造化して記述するキャンバス。
Lean Canvas をベースに、目的・課題・提供価値・優位性などを1枚にまとめる。

- 1キャンバス = 1つの事業/プロダクト仮説（機能単位ではない）
- 14フィールド: purpose, vision, valueProposition, obviousProblem, latentProblem, means, advantage, metrics, revenueModel, marketSize, situation, trend, alternatives, channel
- 20分で1枚描けるくらいが適切な粒度

操作は `/kaizen-lab:canvas` を参照。
**ツール**: `list_canvases`, `get_canvas`, `create_canvas`, `update_canvas`, `delete_canvas`, `add_sticky_note`, `update_sticky_note`, `delete_sticky_note`

#### 👤 ペルソナ（Persona）

仮説キャンバスで想定した **ターゲット顧客** を具体化する。
抽象的な「ユーザー」ではなく、年齢・職業・目標・不満・行動パターンまで描くことで、
仮説の解像度を上げる。

##### 🧠 心理的状態次元（State Dimensions） — HumanLM-inspired

ペルソナの **内面的な状態** をモデル化する機能。
Stanford の HumanLM 論文に基づき、表面的な属性だけでなく心理的次元を定義することで、
AI 擬似インタビューの応答リアリズムが大幅に向上する。

- **stances**: トピック別の立場（例: `{ "価格": "コスト意識が非常に高い", "新技術": "慎重だが興味あり" }`）
- **emotionalTendencies**: 感情的傾向（例: `["変化に不安を感じやすい", "共感力が高い"]`）
- **communicationStyle**: コミュニケーション特性（例: `"率直だが慎重、データを重視する"`）
- **decisionPattern**: 意思決定パターン（例: `"口コミ重視、比較検討を徹底する慎重派"`）
- **values**: 核となる価値観（例: `["家族第一", "効率重視", "品質にはお金をかける"]`）

AI 擬似インタビューでは、質問に対してまず State Dimensions から **内部状態（latent state）を推論** し、
その状態に基づいて応答を生成する。これにより「この人ならこう答えるだろう」という
心理的整合性のある応答が得られる。

**ツール**: `list_personas`, `create_persona`

### Phase 2: 検証する

#### 🔍 検証キャンバス（Verification Canvas）

仮説キャンバスから導かれた **具体的な検証計画** を管理する。
仮説キャンバスが「何を信じているか」なら、検証キャンバスは「どうやって確かめるか」。

- 仮説キャンバスと `hypothesis_canvas_id` で紐付け
- ステータス遷移: `not-started` → `in-progress` → `validated` / `invalidated`
- セクションで検証項目を構造化（Why/How/What 形式、`references/api.md` 参照）
- **1つの仮説キャンバスに対して、複数の検証キャンバスを作れる**
  （例: 課題の検証、解決策の検証、チャネルの検証）

操作は `/kaizen-lab:verify` を参照。
**ツール**: `list_verification_canvases` (`list_verifications` alias), `get_verification_canvas`, `create_verification_canvas`, `update_verification_canvas`, `delete_verification_canvas`, `get_verification_status`

#### 🎙️ インタビュー（Interview）／ AI 擬似インタビュー

ペルソナに基づく **顧客インタビュー** の記録。
AI 擬似インタビュー機能もあり、仮説の初期検証に使える。

- ペルソナと紐付け可能（`persona_id`）
- ペルソナの State Dimensions を踏まえて AI が「その人ならこう答える」応答を生成
- key_insights, quotes, tags で構造化
- 定性的な学びの源泉。実インタビュー前の仮説の絞り込みに有効

**ツール**: `get_interview_records`, `create_interview`

### Phase 3: 学びを得る

#### 💡 ラーニング（Learning）

検証の結果得られた **学び** を記録する。仮説検証サイクルの最も重要なアウトプット。
成功（仮説が正しかった）も失敗（間違っていた）も等しく価値がある。

- `source_type` で検証キャンバスやインタビューと紐付け
- `impact_level`: low / medium / high / critical
- tags で検索・分類可能
- バグや技術的発見もラーニングとして記録する

操作は `/kaizen-lab:learn` を参照。
**ツール**: `add_learning`, `get_learning`, `update_learning`, `delete_learning`, `search_learnings`, `analyze_learnings`

> `analyze_learnings`: 蓄積された学びからパターン・矛盾・次のアクションを AI 分析。`analyze_all=true` で全件分析可能。

#### 📊 PMF スコア（PMF Score）

プロジェクト全体の **仮説検証の進捗** を数値化。
どれだけ検証が進んでいるか、学びが蓄積されているかを俯瞰する。

**ツール**: `get_pmf_score`

### Phase 4: 次のアクションを決める

#### 🗺️ ロードマップ（Roadmap）

検証結果と学びに基づいて、**次に何をつくるか** を計画する。
仮説やラーニングとリンクすることで、「なぜこれをつくるのか」の根拠が明確になる。

- フェーズ（Phase）: 時間軸での区切り。status: `planning` → `in_progress` → `done`
- アイテム（Item）: 具体的なタスク/機能
  - priority (MoSCoW): `must` / `should` / `could` / `wont`
  - status: `idea` → `planned` → `in_progress` → `done` / `cancelled`
  - effort: `small` / `medium` / `large`
  - `hypothesis_id`, `learning_id` で仮説・学びと紐付け

操作は `/kaizen-lab:roadmap` を参照。
**ツール**: `list_roadmap`, `create_roadmap_phase`, `create_roadmap_item`, `update_roadmap_item`

#### 🗺️ ジャーニーマップ（Journey Map）

顧客体験の流れを **ステージごとに可視化** する。
ペルソナがプロダクトとどう出会い、どう使い、どこで離脱するかを描く。

**ツール**: `list_journey_maps`, `create_journey_map`

#### 📝 意思決定ログ（Decision Log）

検証結果に基づく **意思決定** を記録する。
ピボット（方向転換）・継続・中止・保留の判断とその理由を残し、
チームの合意形成と意思決定のトレーサビリティを確保する。

- 意思決定タイプ: `pivot`（ピボット）/ `persevere`（継続）/ `kill`（中止）/ `pause`（保留）
- 検討した代替案と採用しなかった理由を記録
- 仮説キャンバスやラーニングと紐付け可能

**ツール**: `list_decisions`, `get_decision`, `create_decision`, `update_decision`, `delete_decision`

### Phase 5: チームで共有する

#### 👥 メンバー管理（Members）

プロジェクトへのアクセスをロールベースで管理する。
オーナー > エディター > ビューワーの階層で、各メンバーの権限を制御。

- ロール: `owner`（プロジェクト作成者）/ `editor`（編集可能）/ `viewer`（閲覧のみ）
- ステータス: `pending`（招待中）→ `accepted`（承諾済み）
- オーナーとエディターがメンバーを招待可能
- オーナーのみメンバーの権限変更・削除が可能（自分自身の脱退は誰でも可）

**ツール**: `list_members`, `invite_member`, `update_member_role`, `remove_member`

#### 💬 コメント（Comments）

プロジェクトやキャンバスのフィールドに対してコメントを残す。
チーム内のディスカッションやフィードバックを構造化して記録。

- `field_key` でキャンバスの特定フィールドに紐付け可能
- `thread_id` でスレッド形式の会話をサポート
- `parent_id` で返信構造をサポート
- オーナーとエディターがコメント作成可能
- 自分のコメントは編集・削除可能、オーナーは全コメント削除可能

**ツール**: `list_comments`, `get_comment`, `create_comment`, `update_comment`, `delete_comment`

#### 📨 招待管理（Invitations）

自分宛の招待を確認・承諾・拒否する。

**ツール**: `list_invitations`, `accept_invitation`, `reject_invitation`

### プロジェクト管理・分析

#### 📁 プロジェクト（Project）

全ての活動の入れ物。仮説キャンバス、検証、ペルソナ、ラーニング等はすべてプロジェクトに属する。

**ツール**: `list_projects`, `create_project`, `delete_project`, `export_project`, `get_dashboard`, `get_changelog`

#### 🤖 AI 分析（AI Analysis）

仮説キャンバスや学びに対して AI 分析を実行し、結果を DB に保存する。

- `analyze_competitors`: 仮説キャンバスを元に AI 競合分析を実行（`canvas_id` 指定、`project_id` は自動解決可能）
- `analyze_learnings`: 蓄積された学びのパターン・矛盾・次のアクションを AI 分析（`analyze_all=true` で全件対象）

**ツール**: `analyze_competitors`, `analyze_learnings`

---

## 機能の関連図

```
Project
  ├── Hypothesis Canvas ──→ 「何を信じているか」
  │     ├── Verification Canvas ──→ 「どう確かめるか」
  │     │     └── Learning ──→ 「何が分かったか」
  │     └── (複数の検証を紐付け可能)
  │
  ├── Persona ──→ 「誰のための仮説か」（State Dimensions で内面をモデル化）
  │     └── Interview ──→ 「実際に聞いてみた結果」（AI 擬似インタビュー可）
  │           └── Learning
  │
  ├── Roadmap ──→ 「学びに基づいて何をつくるか」
  │     └── Item ←── hypothesis_id / learning_id で根拠リンク
  │
  ├── Journey Map ──→ 「顧客体験の全体像」
  │
  ├── Members ──→ 「誰がチームにいるか」（RBAC: owner > editor > viewer）
  │     └── Invitations ──→ 「招待の承諾待ち」
  │
  ├── Comments ──→ 「チームのディスカッション」
  │     └── field_key / thread_id で構造化
  │
  └── Learning ──→ 全ての学びの蓄積（検証・インタビュー・バグ・発見）
```

---

## キャンバス粒度ガイド

**原則: 1キャンバス = 1つの事業/プロダクトレベルの仮説**

Lean Canvas の考え方に準拠: キャンバスは事業全体のスナップショットであり、20分で1枚描くもの。

| 内容 | 管理先 |
|------|--------|
| 事業/プロダクトの仮説 | **仮説キャンバス** |
| 仮説の検証計画・結果 | **検証キャンバス** |
| バグ・技術的発見 | **ラーニング** |
| 機能改善アイデア | **ラーニング** or **ロードマップアイテム** |
| 大きな機能計画 | **ロードマップアイテム** |

---

## セットアップ

MCP クライアント（Claude Code / Claude Desktop / Cursor 等）から接続：
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

- エンドポイント: `POST https://kaizen-lab.buildgeeks.dev/api/mcp`
- JSON-RPC 2.0 / Bearer token 認証 / ステートレス

## API Reference

完全な MCP ツールドキュメント（引数つき）は [references/api.md](references/api.md) を参照。

## DB Column Gotchas

- personas: `occupation`（NOT `role`）、goals/frustrations/behaviors は `text[]`、`state_dimensions` は JSONB（HumanLM-inspired）
- learnings: `content`（NOT `description`）、tags は `text[]`
- interview_records: `title`（必須）、key_insights/quotes/tags は `text[]`
- hypothesis_canvases: `phase` は enum: `ideation`/`problem-validation`/`solution-validation`/`mvp-building`/`growth`
- projects: `owner_id`（NOT `user_id`）
- validation_canvases: `name`（NOT `title`）、`sections` は `{why, how, what}` ネスト構造必須（フラット NG）
- project_members: `status` は `pending`/`accepted`、`role` は `owner`/`editor`/`viewer`、UNIQUE(project_id, user_id)
- project_comments: `content`（必須）、`field_key`/`thread_id`/`parent_id` は nullable、最大 10000 文字
