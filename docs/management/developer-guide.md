# WORK Repository Skeleton v1.0 — 開発者向け利用ガイド

**作成日**: 2026-06-12  
**対象**: 開発者（全員）  
**機密区分**: Internal

---

## このガイドについて

日々の開発で迷ったときのクイックリファレンスです。詳細は各 `docs/` ドキュメントを参照してください。

---

## 毎日の開発フロー

```bash
# ── 朝の準備 ──────────────────────────────────────────
git checkout main
git pull origin main

# Linear で今日取り組む Issue を "In Progress" に変更

# ── 開発 ──────────────────────────────────────────────
# ブランチ作成（Linear の Issue ID を含める）
git checkout -b feature/WORK-123-add-user-authentication

# 実装...

# コミット（Conventional Commits 形式）
git add src/auth/jwt.ts tests/auth/jwt.test.ts   # 具体的にファイルを指定
git commit -m "feat(auth): add JWT token refresh mechanism"

# ── PR 作成前チェック ──────────────────────────────────
npm run lint        # Lint チェック
npm run type-check  # 型チェック
npm test            # テスト実行

# シークレットが含まれていないか確認
git diff HEAD~1 | grep -iE "(password|secret|token|api.key)" || echo "OK"

# ── PR 作成 ───────────────────────────────────────────
gh pr create \
  --title "feat(auth): add JWT token refresh" \
  --body "Closes WORK-123\n\n## 変更内容\n..."

# Linear Issue の URL を PR の概要に記載
# Claude Code を使った場合は AI-assisted ラベルを付与

# ── 夕方 ──────────────────────────────────────────────
# 自分の PR のレビュー状況確認
gh pr list --author "@me"

# 自分がレビュアーになっている PR を確認
gh pr list --reviewer "@me"
```

---

## ブランチ命名規則

| 種別 | 形式 | 例 |
|------|------|----|
| 機能追加 | `feature/LINEAR-ID-短い説明` | `feature/WORK-123-user-auth` |
| バグ修正 | `fix/LINEAR-ID-短い説明` | `fix/WORK-456-login-redirect` |
| 緊急修正 | `hotfix/LINEAR-ID-短い説明` | `hotfix/WORK-789-xss-patch` |
| リリース | `release/v1.2.0` | `release/v2.0.0` |
| 実験的 | `experiment/短い説明` | `experiment/new-cache-strategy` |

---

## Conventional Commits チートシート

```
<type>(<scope>): <summary>

type（必須）:
  feat     新機能
  fix      バグ修正
  docs     ドキュメントのみの変更
  style    コードの意味に影響しない変更（フォーマット等）
  refactor リファクタリング（機能変更なし）
  test     テストの追加・修正
  chore    ビルドプロセスや補助ツールの変更
  ci       CI設定の変更
  security セキュリティ修正（脆弱性対応）
  perf     パフォーマンス改善

scope（任意）: 変更対象のモジュール・コンポーネント名

例:
  feat(auth): add OAuth2 Google login
  fix(api): handle null response from external service
  docs(readme): update setup instructions
  security(deps): upgrade lodash to 4.17.21
  test(user): add edge cases for email validation
```

---

## よく使う GitHub CLI コマンド

```bash
# PR 操作
gh pr create                    # PR 作成（インタラクティブ）
gh pr list                      # PR 一覧
gh pr list --reviewer "@me"     # 自分がレビュアーのPR
gh pr view <number>             # PR 詳細
gh pr checkout <number>         # PR のブランチをローカルにチェックアウト
gh pr review <number> --approve # PR を承認

# Issue 操作
gh issue create                 # Issue 作成
gh issue list                   # Issue 一覧
gh issue view <number>          # Issue 詳細
gh issue close <number>         # Issue クローズ

# CI/CD 操作
gh run list                     # 最近の GitHub Actions 実行一覧
gh run view <run-id>            # 実行詳細
gh run watch                    # 実行をリアルタイムで監視

# リリース操作
gh release list                 # リリース一覧
gh release view v1.2.0          # リリース詳細
```

---

## Claude Code 活用パターン

### 許可される使い方

```bash
# コードの説明を求める
claude "この関数が何をしているか説明して"

# テストの生成
claude "src/auth/jwt.ts の単体テストを生成して"

# バグ調査
claude "このエラーメッセージの原因を調べて: [エラー内容]"

# リファクタリング提案
claude "この関数をよりシンプルにする方法を提案して"

# コードレビュー補助
claude "このPRの変更を確認してセキュリティ上の問題がないか見て"

# ドキュメント生成
claude "この API エンドポイントの JSDoc を生成して"
```

### 禁止事項（必ず守る）

```
❌ 顧客の個人情報・機密データをプロンプトに含める
❌ 本番の認証情報（APIキー、パスワード）を送信する
❌ Confidential / Restricted 情報を送信する
❌ AIが生成したコードをレビューなしにマージする
❌ 外部公開APIキーを含むコードをAIに渡す
```

### AI支援作業の記録

Claude Code を使った場合は PR の概要に記録します：

```markdown
## AI支援

- Claude Code を使用してテストを生成
- 生成されたコードは全てレビュー・修正済み
```

---

## 開発者のセキュリティチェックリスト（日次）

```
□ ソースコードにシークレット・認証情報を含めていない
□ .env ファイルを git に追加していない（.gitignore で除外済み）
□ 依存関係を追加した場合、ライセンスと脆弱性を確認した
□ ユーザー入力は適切にバリデーション・サニタイズしている
□ SQL クエリにはパラメータバインドを使用している
□ エラーメッセージに内部情報を含めていない
```

---

## コードレビュー観点チートシート

### 自分の PR を出す前に確認

```
□ CI が全て通っている
□ テストを追加・更新した
□ 変更の説明が PR テンプレートに記載されている
□ セキュリティチェックリストを確認した
□ self-review をした（自分でもう一度見直した）
```

### 他者の PR をレビューするときに確認

```
機能・ロジック
□ 変更が Issue/要件を満たしているか
□ エッジケースが考慮されているか
□ エラーハンドリングが適切か

セキュリティ
□ 入力バリデーションがあるか
□ シークレットが含まれていないか
□ 認可チェックが適切か
□ SQL インジェクション・XSS のリスクがないか

コード品質
□ 関数・変数名が明確か
□ 重複コードがないか
□ テストカバレッジが十分か

パフォーマンス
□ N+1 クエリ問題がないか
□ 大量データへの対応ができているか
```

### レビューコメントの書き方

```
# 良い例（建設的・具体的）
> この部分は `Promise.all()` を使うと並列実行できてパフォーマンスが改善します：
> ```js
> const results = await Promise.all([fetchA(), fetchB()])
> ```

# 避けるべき例（曖昧・否定的）
> これは良くないと思います

# コメントの種類を明示する
> [nit] 変数名をもう少し具体的にすると読みやすいです（必須ではありません）
> [must] セキュリティ上の問題があります：入力バリデーションが必要です
> [question] ここでキャッシュを使う理由はありますか？
```

---

## CI 失敗時の対処法

| エラー種別 | 確認場所 | 典型的な原因と対処 |
|-----------|----------|-------------------|
| `lint` 失敗 | Actions ログ → lint job | `npm run lint` をローカルで実行。`npm run lint:fix` で自動修正 |
| `test` 失敗 | Actions ログ → test job | `npm test` をローカルで実行。失敗テストを特定して修正 |
| `build` 失敗 | Actions ログ → build job | `npm run build` をローカルで実行。型エラーや import 問題を確認 |
| `security-scan` 失敗 | Security タブ | CodeQL の指摘を確認 → 修正 or 偽陽性なら `// nosec` コメントでサプレス（理由を記載） |
| `dependency-scan` 失敗 | Actions ログ | 脆弱な依存関係を `npm audit` で確認 → `npm audit fix` または手動バージョン指定 |

---

## 困ったときの相談先

| 困りごと | 相談先 | 手段 |
|----------|--------|------|
| セキュリティ懸念・インシデント | セキュリティ責任者 | Teams DM（緊急時は電話） |
| プロセス・ルール確認 | PM | Teams チャンネル |
| 技術的な設計相談 | Tech Lead | Teams チャンネル または 1:1 |
| CI/CD・インフラ問題 | DevOps エンジニア | Teams チャンネル |
| ツール不具合（GitHub/Linear） | PM | Teams チャンネル |
| Claude Code の使い方 | [docs/training/claude-code-training.md](../training/claude-code-training.md) | まず自己解決 |

---

## 関連ドキュメント

| ドキュメント | 内容 |
|-------------|------|
| [development-lifecycle.md](../development-lifecycle.md) | 開発ライフサイクル全体図 |
| [github-operations.md](../github-operations.md) | GitHub ルール詳細 |
| [isms/information-classification.md](../isms/information-classification.md) | 情報の取り扱いルール |
| [ai-governance/claude-code-policy.md](../ai-governance/claude-code-policy.md) | Claude Code 利用ポリシー |
| [training/secure-coding-training.md](../training/secure-coding-training.md) | セキュアコーディング詳細 |
