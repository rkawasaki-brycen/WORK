# クレデンシャル・シークレット管理ポリシー

## 目的

本文書は、チームが取り扱うすべてのクレデンシャル（認証情報）およびシークレット（秘密情報）を安全に管理するための方針と手順を定める。シークレットの漏洩は情報セキュリティインシデントの主要な原因となるため、適切な管理によりリスクを最小化することを目的とする。

## 適用範囲

- APIキー、アクセストークン、OAuthシークレット
- データベース接続文字列、パスワード
- TLS/SSL証明書の秘密鍵
- クラウドサービスのサービスアカウントキー
- Webhookシークレット
- 暗号化キー・署名キー
- チームメンバーのアカウントパスワード

---

## 1. シークレットをGitにコミットしない

### 1.1 基本原則

**シークレットは絶対にGitリポジトリにコミットしてはならない。** これはパブリックリポジトリはもちろん、プライベートリポジトリにおいても同様である。一度コミットされたシークレットはGit履歴に残り、完全な削除は困難となる。

### 1.2 pre-commitフックによる自動検出

すべての開発者は、コミット前にシークレットを自動検出するpre-commitフックを設定しなければならない。

**推奨ツール:** `gitleaks`、`detect-secrets`

```bash
# gitleaks のインストール（macOS）
brew install gitleaks

# pre-commit フックの設定
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
gitleaks protect --staged --redact -v
if [ $? -ne 0 ]; then
  echo "ERROR: シークレットの可能性があるデータが検出されました。コミットを中断します。"
  exit 1
fi
EOF
chmod +x .git/hooks/pre-commit
```

**プロジェクト共通設定（`.gitleaks.toml`）:**

```toml
title = "Gitleaks Configuration"

[allowlist]
  description = "グローバル許可リスト"
  regexes = [
    # テスト用ダミー値
    '''EXAMPLE_.*_KEY''',
    # プレースホルダー
    '''<YOUR_.*_HERE>''',
  ]
```

### 1.3 GitHubシークレットスキャニング

GitHub Advanced Securityのシークレットスキャニングを有効化し、コミット後の第2の防衛線として機能させる。

- リポジトリ設定 → Security → Secret scanning を有効化
- Push protectionを有効化することで、既知パターンのシークレットを含むプッシュを自動的にブロックする
- アラートは即日確認し、対応する（詳細は「6. 誤ってコミットしたシークレットへの対応」を参照）

### 1.4 .gitignore の設定

以下のファイルは必ず`.gitignore`に含める。

```gitignore
# 環境変数ファイル
.env
.env.local
.env.*.local
.env.development.local
.env.test.local
.env.production.local

# シークレットファイル
*.pem
*.key
*_rsa
*_dsa
*_ecdsa
*_ed25519
*.p12
*.pfx

# クラウド認証情報
.aws/credentials
.gcloud/
service-account*.json
*-service-account.json

# その他
secrets/
credentials/
```

---

## 2. CI/CD環境でのシークレット管理

### 2.1 GitHub Secretsの利用

CI/CDパイプラインで使用するシークレットはすべてGitHub Secretsに登録し、コードやワークフローファイルにハードコードしてはならない。

**登録手順:**
1. リポジトリ → Settings → Secrets and variables → Actions
2. 「New repository secret」をクリック
3. 命名規則に従った名前でシークレットを登録する

**利用方法（GitHub Actions）:**

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: アプリケーションのデプロイ
        env:
          API_KEY: ${{ secrets.API_KEY }}
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
        run: |
          ./deploy.sh
```

### 2.2 シークレットの種類と登録先

| シークレットの種類 | 登録先 | 備考 |
|---|---|---|
| 本番環境APIキー | Repository Secrets | 環境ごとに分離 |
| ステージング環境APIキー | Repository Secrets | 本番と別のシークレットを使用 |
| 組織共通のサービスアカウント | Organization Secrets | 複数リポジトリで共有が必要な場合 |
| デプロイ用SSHキー | Repository Secrets | Deploy Keys と併用 |

### 2.3 環境別のシークレット管理

GitHub Environments機能を使用して、環境ごとにシークレットを分離する。

```
Environments:
├── development  → 開発環境のシークレット
├── staging      → ステージング環境のシークレット
└── production   → 本番環境のシークレット（Required reviewers 設定必須）
```

---

## 3. シークレットの命名規則

一貫した命名規則により、シークレットの目的と管理状態を明確にする。

### 3.1 命名フォーマット

```
{環境プレフィックス}_{サービス名}_{シークレット種別}
```

### 3.2 環境プレフィックス

| プレフィックス | 対象環境 |
|---|---|
| `PROD_` | 本番環境 |
| `STG_` | ステージング環境 |
| `DEV_` | 開発環境 |
| （なし） | 環境非依存（共通） |

### 3.3 命名例

| 用途 | シークレット名 |
|---|---|
| 本番環境のStripe APIキー | `PROD_STRIPE_SECRET_KEY` |
| ステージングのデータベースURL | `STG_DATABASE_URL` |
| GitHub ActionsのSlack通知トークン | `SLACK_WEBHOOK_URL` |
| AWSサービスアカウントのアクセスキーID | `PROD_AWS_ACCESS_KEY_ID` |
| Datadog APIキー | `DATADOG_API_KEY` |

### 3.4 禁止事項

- 汎用的すぎる名前（例: `SECRET`, `KEY`, `TOKEN`）は使用しない
- 実際の値を名前に含めない
- スペース、特殊文字（アンダースコアを除く）は使用しない

---

## 4. シークレットのローテーションポリシー

### 4.1 定期ローテーション

| シークレット種別 | ローテーション周期 | 担当 |
|---|---|---|
| チームアカウントのパスワード | **90日** | 各メンバー |
| APIキー（外部サービス） | **180日** | Tech Lead |
| データベースパスワード | **90日** | インフラ担当 |
| サービスアカウントキー | **180日** | インフラ担当 |
| TLS証明書 | 有効期限の30日前 | インフラ担当 |
| 暗号化キー | **1年** | Tech Lead / Security |

### 4.2 ローテーション手順

1. **新しいシークレットを生成する**（古いシークレットはまだ有効な状態を維持）
2. **GitHub Secretsを更新する**（新しいシークレットで上書き）
3. **デプロイを実行し、新しいシークレットで動作することを確認する**
4. **古いシークレットを無効化・削除する**
5. **ローテーション記録を更新する**（後述のシークレット台帳）

### 4.3 シークレット台帳

シークレットのライフサイクルを以下の台帳で管理する（Notionまたはセキュアな社内ドキュメントで管理）。

| シークレット名 | サービス | 最終ローテーション日 | 次回ローテーション予定日 | 担当者 |
|---|---|---|---|---|
| `PROD_STRIPE_SECRET_KEY` | Stripe | 2026-03-01 | 2026-09-01 | @alice |
| `PROD_DATABASE_URL` | PostgreSQL | 2026-04-15 | 2026-07-15 | @bob |

### 4.4 緊急ローテーション（即時対応）

以下の場合は定期スケジュールに関わらず即時ローテーションを実施する。

- シークレットの漏洩が疑われる場合
- アクセス権のある従業員が退職した場合
- セキュリティインシデントが発生した場合
- サードパーティサービスのセキュリティ侵害が報告された場合

---

## 5. .env.exampleによるテンプレート管理

### 5.1 アプローチ

実際のシークレットが記載された`.env`ファイルはGitにコミットせず、代わりに`.env.example`をコミットすることで、必要な環境変数を文書化する。

### 5.2 .env.exampleの作成ルール

```bash
# .env.example の例

# アプリケーション設定
APP_ENV=development
APP_PORT=3000
APP_SECRET_KEY=your-secret-key-here  # 32文字以上のランダム文字列

# データベース設定
DATABASE_URL=postgresql://user:password@localhost:5432/dbname

# 外部サービス
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxx  # Stripe Dashboard から取得
STRIPE_WEBHOOK_SECRET=whsec_xxxxxxxxxxxx

# 認証
JWT_SECRET=your-jwt-secret-here
OAUTH_CLIENT_ID=your-oauth-client-id
OAUTH_CLIENT_SECRET=your-oauth-client-secret

# 監視・ログ
DATADOG_API_KEY=your-datadog-api-key
SENTRY_DSN=https://xxxx@sentry.io/xxxx
```

**ルール:**
- 実際の値は絶対に記載しない（ダミー値またはプレースホルダーのみ）
- 各変数にコメントで説明と取得方法を記載する
- 省略可能な変数には `# Optional` コメントを付ける
- `.env.example`はコードレビューの対象とする

### 5.3 新規メンバーへのオンボーディング

新規メンバーは以下の手順でローカル環境を設定する。

```bash
cp .env.example .env
# .env を開き、各変数の値を設定する
# 値は Tech Lead または担当者に確認する
```

---

## 6. 誤ってコミットしたシークレットへの対応（緊急手順）

### 6.1 発見から対応までの概要

```mermaid
flowchart TD
    A([シークレットのコミットを発見]) --> B[即時: 該当シークレットを無効化]
    B --> C[Tech Lead・Security Leadに報告]
    C --> D[Git履歴からシークレットを削除]
    D --> E[新しいシークレットを発行・設定]
    E --> F[影響範囲の調査・評価]
    F --> G{不正アクセスの証拠あり?}
    G -->|Yes| H[インシデント管理プロセスへ移行]
    G -->|No| I[事後報告書の作成]
    I --> J[再発防止策の実施]
    J --> K([完了])
```

### 6.2 ステップ1: 即時対応（発見後15分以内）

**最優先事項: シークレットを無効化する**

コミット日時や公開範囲にかかわらず、発見したら直ちに該当シークレットを無効化する。これは、Git履歴の書き換えよりも先に行う。

- APIキー: サービスのダッシュボードでキーを失効させる
- パスワード: 即時変更する
- 証明書: 失効申請を行う

### 6.3 ステップ2: 報告

```
報告チャンネル: #security-alerts (Slack)
報告内容:
- 何がコミットされたか（シークレットの種別）
- いつ、どのコミットでコミットされたか
- リポジトリがパブリックか否か
- 既に無効化済みか
```

### 6.4 ステップ3: Git履歴からの削除

```bash
# git filter-repo を使用した削除（推奨）
pip install git-filter-repo

# 特定ファイルを履歴から完全削除する場合
git filter-repo --path .env --invert-paths

# 特定の文字列を履歴から削除する場合
git filter-repo --replace-text <(echo "実際のシークレット値==>REMOVED")

# 強制プッシュ（Tech Lead の承認後に実施）
git push origin --force --all
git push origin --force --tags
```

**注意:** 強制プッシュ後、すべてのコントリビューターはローカルリポジトリを再クローンする必要がある。

### 6.5 ステップ4: 影響範囲の調査

- GitHubのアクセスログを確認する
- クラウドサービスのアクセスログを確認する
- 不審なAPIコール、リソースアクセスがないか確認する
- 調査結果をインシデントレポートに記録する

---

## 7. チームアカウントのパスワードポリシー

### 7.1 パスワード要件

| 要件 | 基準 |
|---|---|
| 最小文字数 | 12文字以上 |
| 複雑性 | 大文字・小文字・数字・記号を各1文字以上含む |
| 禁止事項 | 辞書に存在する単語、個人情報（名前・誕生日等）、過去5回分のパスワードの再利用 |
| パスワードマネージャー | **必須**（1Password、Bitwarden等） |

### 7.2 パスワードマネージャーの利用

全メンバーはパスワードマネージャーを使用し、各サービスごとに異なるランダムパスワードを設定しなければならない。

- チーム共有アカウントのパスワードは、パスワードマネージャーの「共有ボルト」機能で管理する
- 個人アカウントのパスワードをSlackやメールで共有してはならない

### 7.3 アカウント管理

- 退職者のアカウントは退職日当日に無効化する
- 長期休暇（2週間以上）のメンバーのアカウントは一時停止を検討する
- 共有アカウントは原則として使用せず、個人アカウントを使用する

---

## 8. 多要素認証（MFA）要件

### 8.1 MFA必須サービス

以下のサービスへのアクセスには、MFAの設定を必須とする。

| サービス | MFA方式 | 備考 |
|---|---|---|
| GitHub | TOTP（認証アプリ）またはハードウェアキー | 組織ポリシーで強制 |
| AWSマネジメントコンソール | TOTP またはハードウェアキー | IAMポリシーで強制 |
| Google Workspace | TOTP またはGoogle Prompt | 管理コンソールで強制 |
| クラウドインフラ管理画面 | TOTP 以上 | |
| パスワードマネージャー | TOTP + マスターパスワード | |
| VPN | TOTP またはクライアント証明書 | |

### 8.2 MFA方式の優先順位

1. **ハードウェアセキュリティキー（YubiKey等）** - 最も安全（推奨）
2. **認証アプリ（Google Authenticator、Authy等）** - 標準
3. **SMS** - フィッシング耐性が低いため、利用可能な場合は上位方式を優先する

### 8.3 バックアップコードの管理

MFA設定時に生成されるバックアップコードは以下のルールで管理する。

- パスワードマネージャーに保存する（平文テキストファイルでの保存は禁止）
- バックアップコードはパスワードマネージャー以外の場所（Slackやメール等）に送信しない

---

## 関連ドキュメント

- [インシデント管理プロセス](./incident-management.md)
- [脆弱性管理プロセス](./vulnerability-management.md)
- [ログ管理ポリシー](./log-management.md)

---

*最終更新: 2026-06-12*
*文書番号: ISMS-CRED-001*

## バージョン履歴

| バージョン | 日付 | 変更内容 | 担当 |
|---|---|---|---|
| 1.0.0 | 2026-06-12 | 初版作成 | - |
