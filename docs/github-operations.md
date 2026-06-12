# GitHub 運用ルール

小規模開発チーム向けの GitHub 運用規約。本ドキュメントに従い、品質・安全性・効率性を維持する。

---

## 1. Branch Strategy

### ブランチ構成

| ブランチ名 | 役割 | 備考 |
|---|---|---|
| `main` | 本番環境に常にデプロイ可能な状態を維持する保護ブランチ | 直接 push 禁止 |
| `develop` | 複数フィーチャーを統合するインテグレーションブランチ | チーム人数 10 名超の場合に導入を推奨 |
| `feature/*` | 新機能開発用ブランチ | `main` または `develop` から派生 |
| `fix/*` | バグ修正用ブランチ | `main` または `develop` から派生 |
| `hotfix/*` | 本番環境の緊急修正用ブランチ | `main` から派生し、修正後に `main` へマージ |
| `release/*` | リリース準備用ブランチ | バージョン確定・最終テスト・Changelog 更新を行う |

### ブランチ命名規則

```
<type>/<ticket-id>-<short-description>
```

- **type**: ブランチ種別 (`feature`, `fix`, `hotfix`, `release`)
- **ticket-id**: Linear / Jira などのチケット番号（例: `LINEAR-123`）
- **short-description**: 英小文字・ハイフン区切りの簡潔な説明

#### 命名例

```
feature/LINEAR-123-add-user-authentication
feature/LINEAR-456-redesign-dashboard-layout
fix/LINEAR-789-fix-login-redirect-bug
fix/LINEAR-101-correct-tax-calculation
hotfix/LINEAR-202-patch-sql-injection-vulnerability
release/v1.4.0
```

### 運用フロー

```
main
 └─ hotfix/LINEAR-202-*  →  main (緊急修正)
 └─ release/v1.4.0       →  main (リリース時)

develop (任意)
 ├─ feature/LINEAR-123-*  →  develop
 ├─ feature/LINEAR-456-*  →  develop
 └─ fix/LINEAR-789-*      →  develop
        develop            →  main (リリース時)
```

---

## 2. Commit Rules

### Conventional Commits 形式

すべてのコミットメッセージは [Conventional Commits](https://www.conventionalcommits.org/) に従う。

```
<type>(<scope>): <subject>

[optional body]

[optional footer(s)]
```

- **type**: コミットの種別（必須）
- **scope**: 変更対象のコンポーネント・モジュール名（任意）
- **subject**: 変更内容の要約。英語・命令形・現在形で記述。末尾にピリオド不要

### type 一覧

| type | 用途 |
|---|---|
| `feat` | 新機能の追加 |
| `fix` | バグ修正 |
| `docs` | ドキュメントのみの変更 |
| `style` | コードの動作に影響しない変更（フォーマット、空白等） |
| `refactor` | バグ修正・機能追加を伴わないコードの改善 |
| `test` | テストの追加・修正 |
| `chore` | ビルドプロセスや補助ツールの変更 |
| `ci` | CI/CD 設定・スクリプトの変更 |
| `security` | セキュリティ上の修正・強化 |

### コミットメッセージ例

```
feat(auth): add OAuth2 login with Google

fix(cart): correct total price calculation when coupon applied

docs(api): update endpoint descriptions in README

refactor(user): extract profile update logic into service layer

test(payment): add unit tests for credit card validation

ci(github-actions): add automated deploy workflow for staging

security(auth): enforce HTTPS-only session cookies
```

### Breaking Change の記法

後方互換性のない変更は `BREAKING CHANGE:` フッターを付与するか、type/scope の後に `!` を付ける。

```
feat(api)!: remove deprecated v1 endpoints

BREAKING CHANGE: /api/v1/* エンドポイントを削除。/api/v2/* へ移行すること。
```

### コミットメッセージテンプレート

プロジェクトルートに `.gitmessage` を配置して `git config commit.template .gitmessage` で設定する。

```
# <type>(<scope>): <subject>
#
# type: feat | fix | docs | style | refactor | test | chore | ci | security
# scope: 変更対象のコンポーネント名（任意）
# subject: 変更内容を英語・命令形で簡潔に記述
#
# --- body (任意) ---
# なぜこの変更が必要か、何を変更したかを記述
#
# --- footer (任意) ---
# BREAKING CHANGE: <説明>
# Closes: LINEAR-XXX
```

---

## 3. Pull Request Rules

### PR サイズガイドライン

| 規模 | 変更行数の目安 | 方針 |
|---|---|---|
| Small | ~100 行 | 推奨。レビューが容易 |
| Medium | 100〜400 行 | 許容範囲。目的を明確に |
| Large | 400 行超 | 原則として分割を検討する |

400 行を超える PR を作成する場合は、分割不可能な理由を PR 説明に記載する。

### PR タイトル形式

Conventional Commits に準拠した形式で記述する。

```
<type>(<scope>): <subject>  [LINEAR-XXX]
```

#### タイトル例

```
feat(auth): add two-factor authentication support [LINEAR-123]
fix(order): prevent duplicate order submission [LINEAR-456]
docs(setup): update local development guide [LINEAR-789]
```

### PR 説明の必須項目

PR 説明には以下のセクションを含める。テンプレートとして `.github/PULL_REQUEST_TEMPLATE.md` に定義する。

```markdown
## 概要
<!-- この PR で何を行ったか・なぜ行ったかを記述 -->

## 変更内容
<!-- 変更した箇所の箇条書きリスト -->
- 

## テスト方法
<!-- レビュアーが動作確認する手順 -->
1. 
2. 

## スクリーンショット（UI 変更がある場合）
<!-- Before / After の画像を貼り付ける -->

## チェックリスト
- [ ] セルフレビュー実施済み
- [ ] テスト追加・更新済み（または不要と判断した理由を記載）
- [ ] ドキュメント更新済み（または不要）
- [ ] Breaking Change なし（ある場合は概要に記載）

## 関連チケット
Closes LINEAR-XXX
```

### ラベル運用

| ラベル | 用途 |
|---|---|
| `feature` | 新機能追加 |
| `bug` | バグ修正 |
| `hotfix` | 緊急修正 |
| `documentation` | ドキュメント変更 |
| `security` | セキュリティ関連 |
| `breaking-change` | 後方互換性を壊す変更 |
| `needs-review` | レビュー待ち |
| `wip` | 作業中（Draft PR と併用） |
| `urgent` | 緊急対応（レビュー SLA 4 時間） |

### 自動アサインルール

`.github/CODEOWNERS` を設定し、変更ファイルのパスに応じてレビュアーを自動アサインする。

```
# 全体のデフォルトオーナー
*                   @team-lead

# フロントエンド
/frontend/          @frontend-team

# バックエンド API
/backend/api/       @backend-team

# インフラ・CI 設定
/.github/           @devops-team
/infra/             @devops-team

# セキュリティ関連
/auth/              @security-reviewer @team-lead
```

### Draft PR の使いどころ

- 実装方針についてフィードバックをもらいたい場合
- 作業途中で他メンバーに共有したい場合
- CI が通るか事前確認したい場合

Draft PR は `wip` ラベルを付与し、レビュー可能になったら **"Ready for review"** に変更してから `needs-review` ラベルを付与する。

---

## 4. Review Rules

### レビュアー人数

| コードの種別 | 最低レビュアー数 |
|---|---|
| 通常の変更 | 1 名 |
| セキュリティ・認証・個人情報に関わる変更 | 2 名（うち 1 名はセキュリティオーナー） |
| インフラ・本番環境に影響する変更 | 2 名（うち 1 名は devops-team） |

### レビュー SLA

| 優先度 | 期限 |
|---|---|
| 通常 (`needs-review`) | 24 時間以内 |
| 緊急 (`urgent`) | 4 時間以内 |

レビュー依頼を受けた場合、対応不可能な理由がある場合は即座にコメントで伝え、代替レビュアーを指名する。

### レビューエチケット

**コメントの書き方**

コメントは実装者への批判でなく、コードに対する建設的な指摘を行う。以下のプレフィックスを活用する。

| プレフィックス | 意味 |
|---|---|
| `[must]` | マージ前に必ず対応が必要（バグ・セキュリティリスク等） |
| `[should]` | 対応を強く推奨するが、理由があればスキップ可 |
| `[nit]` | 軽微な指摘（スタイル・命名等）。対応は任意 |
| `[question]` | 確認・質問。対応不要の場合もある |
| `[praise]` | 良い実装への称賛 |

**コメント例**

```
[must] SQL クエリにユーザー入力を直接連結しています。プレースホルダーを使用してください。

[should] この処理は service layer に切り出すと責務が明確になります。

[nit] 変数名 `d` より `dueDate` の方が意図が伝わりやすいです。

[question] ここでエラーを握りつぶしている意図はありますか？

[praise] エラーハンドリングが丁寧に実装されています。
```

### LGTM の基準

以下をすべて確認してから Approve する。

- [ ] 機能要件を満たしている
- [ ] テストが追加・更新されており、CI が green
- [ ] セキュリティ上の問題がない
- [ ] コードの可読性・保守性が適切
- [ ] Breaking Change がある場合、ドキュメントに記載されている
- [ ] パフォーマンス上の問題がない

### レビューで確認すべき観点

#### セキュリティ
- SQL インジェクション、XSS、CSRF 等の脆弱性
- 認証・認可の抜け漏れ
- 機密情報（API キー、パスワード）のハードコーディング
- 入力値バリデーションの欠如

#### ロジック
- 要件通りの実装になっているか
- エッジケース・境界値の処理
- エラーハンドリングの適切さ
- 競合状態（race condition）の可能性

#### テスト
- 主要なユースケースがカバーされているか
- 異常系・境界値のテストが存在するか
- テスト自体が正しく機能しているか

#### ドキュメント
- 複雑なロジックにコメントが付いているか
- 公開 API・関数に説明が付いているか
- README や仕様書の更新が必要か

---

## 5. Branch Protection Rules (GitHub Settings)

`main` ブランチに対して GitHub リポジトリの **Settings > Branches > Branch protection rules** から以下を設定する。

### main ブランチの保護設定

```
Branch name pattern: main

[✓] Require a pull request before merging
    [✓] Require approvals
        Required number of approvals before merging: 1
    [✓] Dismiss stale pull request approvals when new commits are pushed
    [✓] Require review from Code Owners

[✓] Require status checks to pass before merging
    [✓] Require branches to be up to date before merging
    Status checks that are required:
      - ci/build
      - ci/test
      - ci/lint

[✓] Require conversation resolution before merging

[✓] Require signed commits  ※ チーム合意の上で有効化を検討

[✓] Require linear history  ※ Squash merge 運用の場合に有効化

[ ] Include administrators  ※ 緊急時の hotfix 対応を考慮して無効も可

[✓] Restrict who can push to matching branches
    （team-lead のみ許可する場合に設定）

[✓] Do not allow bypassing the above settings
```

### develop ブランチの保護設定（使用する場合）

```
Branch name pattern: develop

[✓] Require a pull request before merging
    [✓] Require approvals
        Required number of approvals before merging: 1

[✓] Require status checks to pass before merging
    Status checks that are required:
      - ci/build
      - ci/test

[✓] Require conversation resolution before merging
```

---

## 6. Release Rules

### Semantic Versioning

`MAJOR.MINOR.PATCH` の形式でバージョンを管理する。

| 種別 | いつ上げるか | 例 |
|---|---|---|
| `MAJOR` | 後方互換性を壊す変更 | `1.0.0` → `2.0.0` |
| `MINOR` | 後方互換性を保ちながら機能追加 | `1.0.0` → `1.1.0` |
| `PATCH` | 後方互換性を保ちながらバグ修正 | `1.0.0` → `1.0.1` |

### リリースブランチの作成

```bash
# develop または main からリリースブランチを作成
git checkout -b release/v1.4.0 develop

# バージョン番号の更新（package.json 等）
npm version 1.4.0 --no-git-tag-version

# Changelog の更新（後述）
# 最終テスト・バグ修正をこのブランチで実施
```

### Changelog 生成

`CHANGELOG.md` は [Keep a Changelog](https://keepachangelog.com/) 形式に準拠する。Conventional Commits に基づき自動生成ツール（`conventional-changelog-cli` 等）を活用する。

```bash
npx conventional-changelog-cli -p conventionalcommits -i CHANGELOG.md -s
```

`CHANGELOG.md` のエントリ例：

```markdown
## [1.4.0] - 2026-06-12

### Added
- ユーザープロフィール画像のアップロード機能を追加 (LINEAR-123)
- Google OAuth2 ログインに対応 (LINEAR-456)

### Fixed
- カート合計金額がクーポン適用時に誤算される問題を修正 (LINEAR-789)

### Security
- セッション Cookie を HTTPS 専用に変更 (LINEAR-101)

### Breaking Changes
- `/api/v1/*` エンドポイントを削除。`/api/v2/*` へ移行すること。
```

### リリースマージとタグ付与

```bash
# リリースブランチを main にマージ
git checkout main
git merge --no-ff release/v1.4.0

# タグを付与（v プレフィックス必須）
git tag -a v1.4.0 -m "Release v1.4.0"
git push origin main --tags

# develop にも反映（develop ブランチを使用している場合）
git checkout develop
git merge --no-ff release/v1.4.0
git push origin develop

# リリースブランチを削除
git branch -d release/v1.4.0
git push origin --delete release/v1.4.0
```

### GitHub Release の作成

```bash
# gh CLI を使用して GitHub Release を作成
gh release create v1.4.0 \
  --title "v1.4.0" \
  --notes-file CHANGELOG_latest.md \
  --latest
```

または GitHub UI の **Releases > Draft a new release** から以下を設定する。

- **Tag version**: `v1.4.0`（既存タグを選択）
- **Release title**: `v1.4.0`
- **Description**: CHANGELOG の該当バージョンの内容を貼り付け
- **Set as the latest release**: チェック

### タグ形式

```
v<MAJOR>.<MINOR>.<PATCH>

例:
v1.0.0
v1.4.0
v2.0.0-rc.1   （リリース候補版）
v2.0.0-beta.1  （ベータ版）
```

---

## 7. Merge Strategy

### feature / fix ブランチ: Squash merge

フィーチャーブランチおよびバグ修正ブランチは **Squash and merge** を使用する。

**理由:**
- `main` / `develop` のコミット履歴を1 PR = 1 commit に保ち、履歴を読みやすくする
- 開発中の WIP コミットを本線に混入させない

**手順（GitHub UI）:**
1. PR のマージボタンのドロップダウンから **"Squash and merge"** を選択
2. コミットメッセージを Conventional Commits 形式に整える
3. 末尾に PR 番号を付与する（例: `feat(auth): add OAuth2 login (#42)`）

**GitHub リポジトリ設定:**
Settings > General > Pull Requests にて **"Allow squash merging"** のみを有効化し、他のマージ方法を無効化することを推奨する。

```
[✓] Allow squash merging
    Default commit message: Pull request title and description

[ ] Allow merge commits

[ ] Allow rebase merging
```

### release / hotfix ブランチ: Merge commit

リリースブランチおよびホットフィックスブランチは **Create a merge commit** を使用する。

**理由:**
- マージポイントを明示的に履歴に残し、リリース境界を追跡しやすくする
- タグとの対応関係を明確にする

**手順:**
```bash
# CLI での merge commit
git checkout main
git merge --no-ff release/v1.4.0 -m "chore(release): merge release/v1.4.0 into main"
```

### 方針まとめ

| ブランチ種別 | マージ先 | マージ方法 |
|---|---|---|
| `feature/*` | `develop` または `main` | Squash merge |
| `fix/*` | `develop` または `main` | Squash merge |
| `release/*` | `main`（および `develop`） | Merge commit |
| `hotfix/*` | `main`（および `develop`） | Merge commit |
