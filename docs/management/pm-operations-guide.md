# WORK Repository Skeleton v1.0 — プロジェクト管理者向け運用ガイド

**作成日**: 2026-06-12  
**対象**: プロジェクトマネージャー・Tech Lead  
**機密区分**: Internal

---

## はじめに

このガイドは、WORK Repository Skeleton を使って開発チームを運営するプロジェクト管理者（PM）向けの実践的な運用手順書です。日常的な運用手順から、プロジェクト立ち上げ、インシデント対応まで網羅しています。

---

## プロジェクト立ち上げ手順

### 1. GitHub Repository 設定

```bash
# 1-1. このテンプレートから新しいリポジトリを作成
#      GitHub UI: Use this template → Create a new repository

# 1-2. ブランチ保護の設定（GitHub UI で設定）
# Settings → Branches → Add rule → "main"
# ✅ Require a pull request before merging
# ✅ Require approvals: 1（セキュリティ関連は2）
# ✅ Require status checks to pass before merging
#    → lint, test, build を指定
# ✅ Require branches to be up to date before merging
# ✅ Include administrators
```

| 設定項目 | 推奨値 |
|----------|--------|
| Required reviewers | 1（通常）/ 2（セキュリティ・重要機能） |
| Required status checks | ci/lint, ci/test, ci/build |
| Dismiss stale reviews | ✅ 有効 |
| Restrict pushes | ✅ 有効（main は PR のみ） |

### 2. チームメンバーアクセス設定

| ロール | GitHub 権限 | Linear 権限 |
|--------|-------------|-------------|
| Developer | Write | Member |
| Tech Lead | Maintain | Admin |
| PM | Maintain | Admin |
| セキュリティ責任者 | Write + CODEOWNERS | Member |
| 外部委託 | Read または Write（限定） | Guest |

### 3. Linear プロジェクト設定

```
1. Team作成: Settings → Teams → Create team
   - Team名: プロジェクト名
   - Identifier: 3-4文字の略称（例: WORK）

2. 初期Cycleの設定
   - 開始日・終了日（2週間スプリント推奨）
   - Story Point スケール設定

3. Projectの作成
   - Phase別に Milestone Project を作成
   - Sprint Project は Cycle と連動

4. GitHub Integration 有効化
   - Settings → Integrations → GitHub
   - リポジトリと連携
```

### 4. CLAUDE.md のプロジェクト固有カスタマイズ

プロジェクト固有の情報を `CLAUDE.md` に追記してください：

```markdown
## プロジェクト固有情報

### 技術スタック
- 言語: Node.js 20.x / TypeScript 5.x
- フレームワーク: 
- データベース: 
- インフラ: 

### 重要なコマンド
- 開発サーバー起動: `npm run dev`
- テスト実行: `npm test`
- ビルド: `npm run build`

### 注意事項
（プロジェクト固有の注意点をここに記載）
```

> ⚠️ 機密情報・認証情報を CLAUDE.md に含めないこと

---

## 日常運用

### Daily チェック（15分）

```
□ Linear で "Blocked" 状態の Issue を確認 → 解消できるか判断
□ GitHub で "Review Required" なPRを確認 → 24時間以内にレビュー依頼
□ CI 失敗がある場合 → 担当者に確認・支援
□ Dependabot アラート → セキュリティ重要度確認
```

### Weekly チェック（スプリントレビュー＋プランニング）

#### スプリントレビュー（30分）
```
□ 完了した Issue の動作確認
□ 未完了 Issue の持ち越し判断
□ バグ・品質問題の振り返り
□ KPI 指標の確認（リードタイム、デプロイ頻度）
```

#### スプリントプランニング（60分）
```
□ バックログの優先順位確認
□ 各Issue の Story Point 見積もり
□ スプリントへの割り当て（チームキャパシティを考慮）
□ リスク確認（ブロッカーとなりそうな依存関係）
□ Linear でスプリントを開始
```

### Monthly チェック（2時間）

```
□ セキュリティスキャン結果のレビュー（GitHub Security タブ）
□ 依存関係の更新状況確認（Dependabot PR の処理）
□ Risk Register の更新・確認
□ KPI トレンド分析（前月比）
□ ドキュメントの陳腐化チェック
□ チームメンバーのアクセス権限レビュー
```

### Quarterly チェック（半日）

```
□ 内部監査実施（docs/audit/ のチェックリスト使用）
□ リスク評価の全体レビュー
□ QMS プロセスの有効性評価
□ ISMS 管理策の有効性評価
□ トレーニング完了率確認・未完了者フォロー
□ 次四半期の改善計画立案
□ 経営層への報告資料作成
```

---

## リリース管理

### リリース実施手順

```bash
# Step 1: リリースブランチ作成（main から）
git checkout main && git pull
git checkout -b release/v1.2.0

# Step 2: バージョン番号更新
npm version minor  # または major/patch

# Step 3: CHANGELOG 更新
# CHANGELOG.md に変更内容を記載

# Step 4: PR作成（release → main）
gh pr create --title "release: v1.2.0" --label "release"

# Step 5: Go/No-Go 判定ミーティング（15分）
```

#### Go/No-Go チェックリスト

| チェック項目 | 担当 | 結果 |
|-------------|------|------|
| 全テスト通過 | 自動 | CI で確認 |
| セキュリティスキャン合格 | 自動 | CI で確認 |
| リリースノート作成済み | PM | 手動確認 |
| ロールバック手順確認済み | Tech Lead | 手動確認 |
| ステージング環境での動作確認 | QA | 手動確認 |
| 監視アラート設定確認 | DevOps | 手動確認 |

```bash
# Step 6: main にマージ（PR承認後）
# Step 7: GitHub Release 作成
gh release create v1.2.0 --title "v1.2.0" --notes-file CHANGELOG_v1.2.0.md

# Step 8: リリース後30分モニタリング
# エラーレート、レスポンスタイム、主要機能の動作確認
```

---

## インシデント対応時の PM の役割

### インシデント発生時（最初の30分）

```
1. インシデント報告を受領
2. 深刻度の判定（P1/P2/P3/P4）
3. インシデントコマンダーの任命（自分または Tech Lead）
4. GitHub Issue 作成（Security テンプレート使用）
5. Teams の #incident チャンネルに状況共有
6. 必要に応じて経営層エスカレーション
```

#### 深刻度基準

| レベル | 基準 | 対応開始目標 | エスカレーション |
|--------|------|-------------|----------------|
| P1 Critical | 本番サービス全停止 or セキュリティ侵害 | 15分以内 | 即座に経営層へ |
| P2 High | 主要機能停止 or 多数ユーザー影響 | 1時間以内 | 2時間で未解決なら経営層 |
| P3 Medium | 一部機能低下 or 少数ユーザー影響 | 4時間以内 | 翌営業日報告 |
| P4 Low | 軽微な問題 | 次スプリント | 週次報告に含める |

---

## メトリクスダッシュボード

### GitHub Insights で確認できる指標

- **Pulse**: 週次のコミット・PR・Issue の活動量
- **Contributors**: メンバーごとのコントリビューション
- **Code frequency**: コード変更量のトレンド
- **Dependency graph**: 依存関係の可視化

### Linear で確認できる指標

- **Cycle Burndown**: スプリントの進捗
- **Lead Time**: Issue作成〜完了までの時間
- **Cycle Time**: 着手〜完了までの時間
- **Throughput**: スプリントごとの完了Issue数

### 月次レポートテンプレート

```markdown
## 月次開発レポート [YYYY-MM]

### KPI サマリー
- デプロイ数: X回
- 本番障害件数: X件
- 平均リードタイム: X日
- セキュリティ脆弱性対応率: X%

### 完了した主要機能
1. 
2. 

### 課題・リスク
1. 

### 来月の計画
1. 
```

---

## 新メンバー加入時の PM チェックリスト

```
事前準備（加入1週間前）
□ GitHub organization に招待
□ Linear workspace に招待
□ Teams チャンネルに追加
□ 適切な権限グループに追加（CODEOWNERS 更新は不要なら省略）
□ オンボーディングバディの割り当て

加入当日
□ day-one-guide.md を共有
□ バディと1:1 ミーティングをセット
□ 最初の Issue を Linear でアサイン（簡単なものを選ぶ）
□ チームへの紹介アナウンス（Teams）

加入1週間後
□ 環境構築できているか確認
□ 最初のPRがマージできたか確認
□ 困っていることがないか1:1で確認

加入1ヶ月後
□ 全研修完了確認（docs/training/README.md チェックリスト）
□ セキュリティ宣誓書の提出確認
□ パフォーマンス・フィードバック面談
```

---

## よくある問題と解決策

**Q: CI が毎回失敗して PR がマージできない**  
A: 失敗している job 名を確認 → `.github/workflows/` の該当ファイルを確認 → ローカルで `npm run lint && npm test` を実行して再現確認。解消できなければ DevOps に相談。

**Q: Dependabot PR が大量に溜まっている**  
A: セキュリティ更新（`security` ラベル）を優先して処理。マイナー・パッチ更新は週次でまとめて処理する運用で対応。

**Q: レビュー待ちのPRが24時間を超えている**  
A: CODEOWNERS で指定されているレビュアーに Teams で直接依頼。それでも進まない場合はPMが代替レビュアーを調整。

**Q: Linear と GitHub の Issue がずれてきた**  
A: GitHub Issue はテンプレート提出のエントリーポイントとして使い、実際の作業管理は Linear で行う運用を徹底。Linear の GitHub Integration 設定を再確認。
