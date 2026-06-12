# GitHub トレーニング

## 目次

1. [GitHub 基礎おさらい](#1-github-基礎おさらい)
2. [ブランチ戦略の実践](#2-ブランチ戦略の実践)
3. [良い Pull Request の作り方](#3-良い-pull-request-の作り方)
4. [コードレビューのエチケットとフィードバック](#4-コードレビューのエチケットとフィードバック)
5. [GitHub Issues とテンプレートの使い方](#5-github-issues-とテンプレートの使い方)
6. [GitHub Actions — CI 結果の読み方](#6-github-actions--ci-結果の読み方)
7. [セキュリティ機能: Dependabot・シークレットスキャン・CodeQL](#7-セキュリティ機能)
8. [演習](#8-演習)

---

## 1. GitHub 基礎おさらい

### リポジトリ（Repository）

リポジトリはプロジェクトのソースコードと履歴を管理する場所です。

```bash
# リポジトリをクローンする
git clone https://github.com/<org>/<repo>.git

# 現在のリモート設定を確認する
git remote -v
```

### ブランチ（Branch）

ブランチは独立した作業ラインです。`main` ブランチを直接変更せず、必ず作業用ブランチを切ります。

```bash
# ブランチの一覧を確認
git branch -a

# 新しいブランチを作成して移動
git checkout -b feature/user-authentication

# 現在のブランチを確認
git branch --show-current
```

### コミット（Commit）

コミットは変更のスナップショットです。意味のある単位でコミットすることが重要です。

```bash
# 変更をステージング
git add src/auth/login.ts

# コミットメッセージを付けてコミット
git commit -m "feat: ログイン機能にリフレッシュトークンを追加"

# コミット履歴を確認
git log --oneline -10
```

**コミットメッセージの規約（Conventional Commits）**

```
feat:     新機能の追加
fix:      バグ修正
docs:     ドキュメントの変更
style:    フォーマット変更（ロジック変更なし）
refactor: リファクタリング
test:     テストの追加・修正
chore:    ビルドプロセスや補助ツールの変更
```

例:
```
feat: ユーザープロフィール画像のアップロード機能を追加
fix: ログアウト時にセッションが残るバグを修正
docs: API エンドポイントの説明を更新
```

---

## 2. ブランチ戦略の実践

### ブランチの命名規則

```
<type>/<issue-id>-<short-description>

例:
feature/LIN-123-add-user-profile
fix/LIN-456-session-timeout-bug
docs/LIN-789-update-api-docs
chore/LIN-012-upgrade-dependencies
```

- `feature/` — 新機能開発
- `fix/` — バグ修正
- `docs/` — ドキュメント更新
- `chore/` — 雑務・依存関係更新など
- `refactor/` — リファクタリング

### ブランチの運用フロー

```
main
 └── develop（統合ブランチ）
      ├── feature/LIN-123-add-user-profile
      ├── fix/LIN-456-session-bug
      └── docs/LIN-789-readme-update
```

1. `main` から `develop` へのマージは PR + レビュー必須
2. 個人作業ブランチは `develop` から切る
3. 作業完了後は `develop` へ PR を出す
4. リリース時に `develop` → `main` へマージ

### 最新の変更を取り込む

```bash
# develop ブランチの最新を取得
git fetch origin

# 自分のブランチに develop の変更を取り込む（rebase 推奨）
git rebase origin/develop

# コンフリクトが発生した場合
git status                    # コンフリクトしているファイルを確認
# ファイルを編集してコンフリクトを解消
git add <resolved-file>
git rebase --continue
```

---

## 3. 良い Pull Request の作り方

### PR の基本構成

PR を作成する際は、以下の情報を必ず含めます。

**タイトル**
```
[LIN-123] ユーザープロフィール画像のアップロード機能を追加
```

**説明テンプレート例**

```markdown
## 概要
ユーザーがプロフィール画像をアップロードできる機能を追加しました。
対応 Issue: LIN-123

## 変更内容
- `POST /api/users/avatar` エンドポイントを追加
- 画像は S3 にアップロードし、URL を DB に保存
- 対応フォーマット: JPEG, PNG（最大 5MB）

## 動作確認
- [ ] ローカルで正常にアップロードできることを確認
- [ ] 不正ファイル形式のエラーハンドリングを確認
- [ ] 5MB 超過時のエラーを確認

## スクリーンショット（UI 変更がある場合）
（スクリーンショットを貼り付ける）

## 注意事項
- レビュワーは S3 のローカルモック設定が必要です（README 参照）
```

### 小さく分割する

1 つの PR に多くの変更を詰め込まないようにします。

```
悪い例: 1 つの PR に 50 ファイル変更、5 つの機能追加
良い例: 機能ごとに PR を分割し、差分は 300 行以内を目標にする
```

### PR を出す前のチェックリスト

```bash
# テストが全て通るか確認
npm test

# リンターを通す
npm run lint

# ビルドが通るか確認
npm run build

# 差分を最終確認
git diff origin/develop...HEAD
```

---

## 4. コードレビューのエチケットとフィードバック

### レビュワーとしての心得

**フィードバックの種類を明示する**

コメントに prefix を付けることで、重要度と意図を伝えます。

```
[blocking] この変更はセキュリティ上の問題があるため、マージ前に修正が必要です。
           SQL インジェクションのリスクがあります。プレースホルダーを使ってください。

[nit] 変数名が少し曖昧です。`data` より `userProfileData` の方が分かりやすいかもしれません。

[question] この処理が 2 回呼ばれているのは意図的ですか？

[suggestion] ここは Array.reduce() を使うと簡潔に書けるかもしれません（変更不要）。
```

| Prefix | 説明 |
|---|---|
| `[blocking]` | マージ前に必ず修正が必要 |
| `[nit]` | 細かい指摘（対応は任意） |
| `[question]` | 意図の確認・質問 |
| `[suggestion]` | 提案（対応は任意） |

**具体的なフィードバックを心がける**

```
悪い例: 「このコードは読みにくいです」
良い例: 「条件分岐が 4 段ネストしています。早期リターンを使うと読みやすくなります。
         例: if (!user) return null;」
```

**コードではなく実装を指摘する**

```
悪い例: 「あなたのコードは間違っています」
良い例: 「この実装だと、ユーザーが null の場合に TypeError が発生します。
         null チェックを追加することをお勧めします」
```

### 作成者としての心得

- レビューコメントは個人への批判ではなくコードへの指摘として受け取る
- `[blocking]` コメントには必ず返答し、対応したことを伝える
- 対応しない場合は理由を説明する
- 全ての議論が解決したことを確認してから「Approved」をリクエストする

### レビューの応答例

```
> [blocking] このメソッドは Promise を返しますが、await が抜けています。

ご指摘ありがとうございます。await を追加しました。
コミット: abc1234
```

---

## 5. GitHub Issues とテンプレートの使い方

### Issue テンプレートの使い方

リポジトリには以下の Issue テンプレートが用意されています。

**バグ報告テンプレート**

```markdown
## バグの概要
ログイン後にダッシュボードが表示されない

## 再現手順
1. https://app.example.com にアクセス
2. 有効なメールアドレスとパスワードでログイン
3. ダッシュボードページに遷移
4. 白い画面が表示される（コンテンツが表示されない）

## 期待する動作
ダッシュボードのコンテンツが正常に表示される

## 実際の動作
白い画面が表示される。コンソールに "TypeError: Cannot read property 'data' of undefined" エラーあり

## 環境
- OS: macOS 15.0
- ブラウザ: Chrome 125
- アプリバージョン: 2.3.1
```

**機能要望テンプレート**

```markdown
## 機能の概要
CSV エクスポート機能の追加

## 背景・目的
ユーザーがレポートデータを Excel で分析したいというフィードバックが複数あります

## 提案する解決策
レポート画面に「CSV でエクスポート」ボタンを追加する

## 代替案
PDF エクスポートも検討したが、汎用性から CSV を優先したい
```

### Issue のラベル運用

| ラベル | 用途 |
|---|---|
| `bug` | バグ報告 |
| `enhancement` | 機能改善・追加 |
| `documentation` | ドキュメント関連 |
| `good first issue` | 新メンバー向けの取り組みやすい Issue |
| `priority: high` | 優先度高 |
| `blocked` | 他の Issue や外部要因で進行不可 |

---

## 6. GitHub Actions — CI 結果の読み方

### CI パイプラインの概要

PR を作成・更新すると、以下のチェックが自動実行されます。

```
PR 作成
 ├── lint          コードスタイルの確認
 ├── test          ユニットテスト・統合テスト
 ├── build         ビルドの成功確認
 └── security      脆弱性スキャン（CodeQL）
```

### CI 結果の確認方法

PR 画面の下部に表示される「Checks」セクションで確認できます。

```
All checks have passed              ← 全て通過
  ✓ lint (1m 23s)
  ✓ test (3m 45s)
  ✓ build (2m 10s)
  ✓ security / CodeQL (8m 30s)
```

失敗した場合:
```
2 checks failed
  ✗ test (2m 10s)            ← 失敗
  ✓ build (1m 55s)
```

失敗した「test」をクリック → 「Details」リンク → ログを確認します。

### よくある CI 失敗と対処法

| エラー | 原因 | 対処法 |
|---|---|---|
| `ESLint: 3 problems found` | リントエラー | `npm run lint -- --fix` を実行 |
| `Test failed: 2 tests failed` | テスト失敗 | ログを確認して該当テストを修正 |
| `Build error: Module not found` | 依存関係の問題 | `npm install` を実行 |
| `Dependency vulnerability found` | セキュリティ脆弱性 | Dependabot の PR を確認 |

### ワークフローファイルの場所

```
.github/
└── workflows/
    ├── ci.yml          # PR 時の CI チェック
    ├── deploy.yml      # main マージ時のデプロイ
    └── security.yml    # セキュリティスキャン
```

---

## 7. セキュリティ機能

### Dependabot

Dependabot は依存ライブラリの脆弱性を自動検出し、更新 PR を作成します。

**確認場所**: リポジトリ → 「Security」タブ → 「Dependabot alerts」

```
Dependabot が自動作成する PR の例:
タイトル: Bump lodash from 4.17.20 to 4.17.21
内容: セキュリティ脆弱性 CVE-2021-23337 の修正
```

**対応方針**
- `Critical` / `High` の脆弱性は 1 週間以内に対応
- `Medium` / `Low` は次のスプリントで対応
- 自動作成された PR は CI が通過していれば積極的にマージする

### シークレットスキャン（Secret Scanning）

API キー、パスワード、トークンなどの秘匿情報をコードにコミットしないように自動検出します。

**検出例**
```
! Secret scanning alert
  AWS Access Key ID が検出されました: AKIAIOSFODNN7EXAMPLE
  ファイル: src/config/aws.ts (line 12)
```

**誤ってコミットした場合の対処**
1. 該当のシークレット（API キーなど）を即座に無効化・再発行する
2. Git の履歴からシークレットを削除する（`git-filter-repo` を使用）
3. セキュリティチームに報告する

**予防策**
```bash
# .gitignore に必ず追加する
.env
.env.local
.env.*.local
*.key
credentials.json
```

### CodeQL（コード脆弱性解析）

CodeQL は静的解析ツールで、コード内のセキュリティ脆弱性を自動検出します。

**検出できる脆弱性の例**
- SQL インジェクション
- クロスサイトスクリプティング（XSS）
- パストラバーサル
- 認証の不備

**確認場所**: リポジトリ → 「Security」タブ → 「Code scanning alerts」

```
Code scanning alert 例:
  High: SQL query built from user-controlled sources
  ファイル: src/db/userQuery.ts (line 34)
  説明: ユーザー入力が直接 SQL クエリに挿入されています。
        パラメータ化クエリを使用してください。
```

---

## 8. 演習

以下の演習を順番に実施してください。完了後、メンターに確認を依頼してください。

### 演習 1: ブランチの作成とコミット

```bash
# 1. メインリポジトリをクローン（未実施の場合）
git clone https://github.com/<org>/<repo>.git
cd <repo>

# 2. develop ブランチに切り替え
git checkout develop
git pull origin develop

# 3. 自分の作業ブランチを作成
#    形式: training/<your-name>-github-exercise
git checkout -b training/<your-name>-github-exercise

# 4. 練習用ファイルを作成
#    docs/training/exercises/<your-name>.md にファイルを作成し、
#    自己紹介（名前、担当業務、好きな技術）を記載する

# 5. コミット
git add docs/training/exercises/<your-name>.md
git commit -m "docs: <your-name> の自己紹介ファイルを追加"

# 6. リモートにプッシュ
git push origin training/<your-name>-github-exercise
```

### 演習 2: Pull Request の作成

1. GitHub の Web UI を開く
2. 「Compare & pull request」ボタンをクリック
3. ベースブランチを `develop` に設定
4. 以下の PR テンプレートに従って説明を記入する

```markdown
## 概要
GitHub トレーニング演習として自己紹介ファイルを追加しました。

## 変更内容
- docs/training/exercises/<your-name>.md を追加

## 確認事項
- [ ] ファイルが正しいパスに作成されている
- [ ] マークダウンの構文が正しい
```

5. チームメンバー 1 名をレビュワーに指定する

### 演習 3: コードレビューの実施

他のトレーニング受講者が作成した PR を 1 件レビューします。

- `[nit]` や `[suggestion]` のコメントを 1 件以上付ける
- 承認（Approve）またはフィードバックを送る

### 演習 4: CI 結果の確認

自分の PR の「Checks」セクションを確認し、以下を確認します。
- 全てのチェックが通過していること
- もし失敗があれば、ログを読んで原因を特定し修正する

---

**演習完了後**

以下の URL をメンターに Slack で共有してください。
- 作成したブランチの URL
- 作成した PR の URL
- レビューしたコメントのリンク

---

*最終更新: 2026-06-12*
