# Day 1 ガイド — 初日で戦力になるための完全手順書

最終更新: 2026-06-12

---

## はじめに

このガイドはチームに加わった初日、1日で開発環境の構築・プロセスの理解・最初のコントリビューションまでを完了するための手順書です。

ステップを順番どおりに進めてください。詰まったらすぐに担当メンターに声をかけてください。「困ったときは」セクションに連絡先をまとめています。

**このガイドを読む前に:** メンターから本ドキュメントのリンクと招待メール（GitHub / Linear / Teams）が送付されているはずです。届いていない場合はメンターに確認してください。

---

## 事前準備チェックリスト

入社初日の朝（着席前）に以下が手元にあることを確認してください。

- [ ] 会社支給のPC（初期セットアップ済み）
- [ ] 会社メールアドレス（`@example.com`）が使える状態
- [ ] GitHub への招待メール（未承諾の場合は承諾してから着席）
- [ ] Linear への招待メール
- [ ] Microsoft Teams へのアクセス（SSO 経由）
- [ ] パスワードマネージャーのアカウント（1Password Business など — IT担当から払い出し）
- [ ] MFA 用スマートフォン（会社端末 or 申請済み私用端末）

---

## 午前：環境セットアップ (9:00-12:00)

### Step 1: アカウント設定 (9:00-9:30)

#### GitHub

- [ ] 招待メールの「Join organization」リンクをクリックして GitHub Organization に参加する
  - 招待が届いていない場合: メンターに `GitHub username` を伝えて再送してもらう
- [ ] GitHub アカウントで MFA を有効化する
  1. <https://github.com/settings/security> を開く
  2. 「Two-factor authentication」→「Enable two-factor authentication」
  3. 認証アプリ（Google Authenticator / Microsoft Authenticator）でQRコードをスキャン
  4. リカバリーコードをパスワードマネージャーに保存する
- [ ] 自分の GitHub プロフィールに会社メールアドレスを追加・確認する
  - <https://github.com/settings/emails>

#### Linear

- [ ] 招待メールの「Join workspace」リンクをクリックして Linear Workspace に参加する
- [ ] プロフィール写真・表示名・タイムゾーン（Asia/Tokyo）を設定する
  - Linear 左下のアバター → 「Profile」
- [ ] 自分が所属するチームに追加されていることを確認する（メンターに確認）

#### Microsoft Teams

- [ ] SSO でサインインできることを確認する（<https://teams.microsoft.com>）
- [ ] 以下のチャンネルに参加する
  - `#general` — 全社アナウンス
  - `#dev` — 開発チーム全体
  - `#dev-random` — 雑談・TIL
  - `#alerts` — システムアラート（閲覧のみ）
- [ ] チームメンバーと1対1のチャットが送れることを確認する（メンターに「テストです」と送ってみる）

---

### Step 2: 開発環境セットアップ (9:30-11:00)

#### Git の設定

```bash
# コミットに使う名前とメールを設定（会社メールを使うこと）
git config --global user.name "姓 名"
git config --global user.email "yourname@example.com"

# デフォルトブランチ名を main に統一
git config --global init.defaultBranch main

# コミットエディタを設定（VSCode の場合）
git config --global core.editor "code --wait"

# 改行コードの自動変換を無効化（macOS / Linux）
git config --global core.autocrlf input

# 設定確認
git config --global --list
```

> **GPG 署名（任意）:** コミット署名を求めるプロジェクトでは GPG キーの設定が必要です。メンターに確認してください。

#### リポジトリのクローン

```bash
# 作業ディレクトリを作成
mkdir -p ~/src && cd ~/src

# SSH クローン（推奨）
git clone git@github.com:<ORG>/<REPO>.git

# HTTPS の場合
git clone https://github.com/<ORG>/<REPO>.git

cd <REPO>
```

> SSH キーを GitHub に登録していない場合: <https://github.com/settings/keys> から「New SSH key」で追加してください。`cat ~/.ssh/id_ed25519.pub` の出力を貼り付けます。キーがなければ `ssh-keygen -t ed25519 -C "yourname@example.com"` で生成してください。

#### 必須ツールのインストール

以下のツールをインストールします。バージョンはプロジェクトの `.tool-versions` または `package.json` の `engines` フィールドを確認してください。

```bash
# Homebrew（未インストールの場合）
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# mise（言語バージョン管理、asdf 互換）
brew install mise
echo 'eval "$(mise activate zsh)"' >> ~/.zshrc
source ~/.zshrc

# プロジェクトで指定されたランタイムをインストール（例）
# mise install   # .tool-versions があれば自動インストール

# --- Node.js（フロントエンド / スクリプト）---
# mise use --global node@<VERSION>

# --- Python（バックエンド / スクリプト）---
# mise use --global python@<VERSION>

# --- その他プロジェクト固有ツール ---
# README.md または CLAUDE.md の「開発環境セットアップ」セクションを参照
```

- [ ] プロジェクトの `README.md` または `CLAUDE.md` を開き、追加の依存関係セクションを確認した
- [ ] `npm install` / `pip install -r requirements.txt` など、依存関係のインストールが完了した
- [ ] `npm run dev` / `python main.py` などでローカル起動できることを確認した

#### Claude Code CLI のインストールと設定

```bash
# Claude Code CLI をインストール
npm install -g @anthropic-ai/claude-code

# バージョン確認
claude --version

# 初回認証（ブラウザが開くので Anthropic アカウントでサインイン）
claude login
```

- [ ] `claude --version` でバージョンが表示された
- [ ] `claude login` が完了した

**個人設定（`~/.claude/settings.json`）の確認:**

```bash
# 設定ファイルを開く（なければ新規作成）
code ~/.claude/settings.json
```

推奨設定例:

```json
{
  "model": "claude-sonnet-4-5",
  "theme": "dark"
}
```

**プロジェクトの `CLAUDE.md` を確認する:**

```bash
cat ~/src/<REPO>/CLAUDE.md
```

`CLAUDE.md` にはこのリポジトリ固有のコーディング規約・コマンド・注意事項が記載されています。Claude Code はセッション開始時にこのファイルを自動で読み込みます。必ず一読してください。

- [ ] `CLAUDE.md` を読んだ

---

### Step 3: ツール確認 (11:00-12:00)

実際に手を動かしてフローが正常に動くことを確認します。

#### テストコミットとドラフト PR の作成

```bash
cd ~/src/<REPO>

# feature ブランチを作成
git checkout -b feature/onboarding-test-<あなたのGitHub username>

# 動作確認用のファイルを作成（本番コードに触れないこと）
echo "# Onboarding test by <name>" > /tmp/onboarding-test.txt
# ※ リポジトリ内に scratch/ ディレクトリがあればそこに作成してください

# ステージング & コミット
git add .
git commit -m "chore: onboarding environment check by <name>"

# リモートへプッシュ
git push -u origin feature/onboarding-test-<あなたのGitHub username>
```

```bash
# GitHub CLI でドラフト PR を作成
gh pr create \
  --title "chore: onboarding test [WIP]" \
  --body "This is an onboarding test PR. Please ignore or close." \
  --draft
```

> GitHub CLI が未インストールの場合: `brew install gh && gh auth login`

- [ ] テストブランチが GitHub 上に表示されている
- [ ] ドラフト PR が作成できた
- [ ] PR を自分でクローズした（テスト完了後）

#### Linear でスターターイシューをアサイン

- [ ] Linear を開き、自分のチームのバックログを確認する
- [ ] 「Good first issue」または「Starter」ラベルの付いたイシューを1件選ぶ
- [ ] そのイシューを自分にアサインし、ステータスを「In Progress」に変更する
- [ ] メンターにどのイシューを選んだか共有する

---

## 午後：プロセス理解 (13:00-17:00)

### Step 4: 必須ドキュメント読了 (13:00-14:30)

以下のドキュメントを順番に読んでください。疑問点はメモしておき、Step 6 の自己紹介後にメンターにまとめて質問してください。

- [ ] [`docs/development-lifecycle.md`](../development-lifecycle.md)
  - ブランチ戦略・PR プロセス・レビュー方針・リリースフロー
- [ ] [`docs/github-operations.md`](../github-operations.md)
  - GitHub の運用ルール・ブランチ命名規則・コミットメッセージ規約
- [ ] [`docs/isms/information-classification.md`](../isms/information-classification.md)
  - 情報の機密レベル分類・取り扱いルール（ISMS 要件）
- [ ] [`docs/ai-governance/claude-code-policy.md`](../ai-governance/claude-code-policy.md)
  - AI ツール利用ポリシー・禁止事項・承認フロー
- [ ] [`docs/isms/credential-management.md`](../isms/credential-management.md)
  - 認証情報の管理方法・シークレットの扱い（特に重要）
- [ ] [`docs/linear-operations.md`](../linear-operations.md)
  - Linear のワークフロー・イシュー管理・スプリント運用

---

### Step 5: セキュリティ設定確認 (14:30-15:00)

#### パスワードマネージャー

- [ ] パスワードマネージャー（1Password 等）に会社メール・GitHub・Linear のログイン情報が保存されている
- [ ] マスターパスワードが十分に強力（20文字以上を推奨）

#### MFA の確認

- [ ] GitHub: MFA が有効 → <https://github.com/settings/security> で確認
- [ ] Teams / Microsoft アカウント: MFA が有効
- [ ] Linear: SSO 経由でログインしているため Microsoft MFA が適用されている
- [ ] パスワードマネージャー: マスターパスワード + MFA が設定されている

#### コードへの認証情報混入防止

- [ ] `.gitignore` に `.env` が含まれていることを確認した
- [ ] `git-secrets` または `gitleaks` をインストールした（プロジェクトの CLAUDE.md を参照）
- [ ] **誓約:** コードやコミットに API キー・パスワード・トークン等の認証情報を含めない

> **万が一コミットした場合:** 直ちにメンターとセキュリティ担当に報告してください。履歴からの削除・トークンの無効化が必要です。隠蔽しないことが最重要です。

---

### Step 6: チームへの自己紹介 (15:00-15:30)

#### Teams チャンネルへの自己紹介投稿

`#dev` チャンネルに以下のテンプレートで自己紹介を投稿してください。

```
こんにちは！本日からチームに加わりました、[氏名] です。

担当: [担当領域・チーム名]
バックグラウンド: [経験・得意技術を簡潔に]
今日から: [担当予定のプロジェクト・イシュー]
よろしくお願いします！
```

- [ ] `#dev` チャンネルに自己紹介を投稿した
- [ ] メンターが自己紹介に返信してくれたことを確認した

#### Linear プロフィールの設定

- [ ] フルネームが正しく設定されている
- [ ] タイムゾーンが `Asia/Tokyo` になっている
- [ ] 表示アバターが設定されている（任意）

---

### Step 7: 初仕事開始 (15:30-17:00)

Step 3 でアサインしたスターターイシューの実装を開始します。

#### ブランチの作成

ブランチ命名規則: `feature/<linear-issue-id>-<短い説明>` （例: `feature/DEV-42-add-login-button`）

```bash
git checkout main
git pull origin main
git checkout -b feature/<LINEAR-ISSUE-ID>-<短い説明>
```

#### Claude Code を使った開発

```bash
# リポジトリ内で Claude Code を起動
cd ~/src/<REPO>
claude
```

初めて使う場合は以下を試してみてください。

```
> このリポジトリの構造を教えてください
> <イシューの説明> を実装するにはどこを変更すればいいですか？
```

- [ ] feature ブランチを作成した
- [ ] イシューの内容を理解し、着手した
- [ ] 終業前にメンターに進捗を報告した（Teams DM で OK）

---

## 完了チェックリスト

終業前に以下がすべて完了していることを確認してください。

### アカウント

- [ ] GitHub Organization に参加、MFA 有効
- [ ] Linear Workspace に参加、プロフィール設定済み
- [ ] Microsoft Teams にサインイン、必要チャンネル参加済み
- [ ] パスワードマネージャーにすべての認証情報を保存済み
- [ ] 全アカウントで MFA 設定済み

### 開発環境

- [ ] Git の `user.name` / `user.email` を会社情報で設定済み
- [ ] リポジトリをクローン済み
- [ ] 必須ツール（Node.js / Python 等）インストール済み
- [ ] プロジェクトの依存関係インストール済み
- [ ] ローカルでアプリが起動することを確認済み
- [ ] Claude Code CLI インストール済み・認証済み
- [ ] `CLAUDE.md` を読んだ

### フロー確認

- [ ] テストブランチでコミット・プッシュできた
- [ ] ドラフト PR を作成・クローズできた
- [ ] Linear でスターターイシューをアサイン済み

### ドキュメント

- [ ] `docs/development-lifecycle.md` 読了
- [ ] `docs/github-operations.md` 読了
- [ ] `docs/isms/information-classification.md` 読了
- [ ] `docs/ai-governance/claude-code-policy.md` 読了
- [ ] `docs/isms/credential-management.md` 読了
- [ ] `docs/linear-operations.md` 読了

### セキュリティ

- [ ] 全アカウント MFA 設定確認済み
- [ ] コードへの認証情報混入防止策を理解した
- [ ] `git-secrets` / `gitleaks` 設定済み

### チーム

- [ ] Teams `#dev` チャンネルに自己紹介投稿済み
- [ ] Linear プロフィール設定済み
- [ ] メンターに初日完了報告済み

### 初仕事

- [ ] スターターイシューの feature ブランチを作成した
- [ ] 実装に着手した
- [ ] 終業前に進捗をメンターに共有した

---

## 困ったときは

| 困りごと | 誰に聞くか | 連絡先 |
|---|---|---|
| 開発環境・ツールの問題 | メンター | Teams DM |
| GitHub / Linear のアクセス権限 | メンター → IT担当 | Teams `#it-support` |
| コードレビュー・実装の相談 | メンター / チームリード | Teams DM または `#dev` |
| セキュリティインシデント（認証情報の漏洩等） | セキュリティ担当 + メンター | 即時 Teams DM、詳細は [`docs/isms/incident-management.md`](../isms/incident-management.md) |
| ISMS・コンプライアンスの疑問 | コンプライアンス担当 | Teams `#compliance` |
| AI ツール利用の疑問 | チームリード | Teams `#dev` |
| 体調不良・緊急時 | 上長 | 電話 or Teams DM |

### よく使うリンク

- GitHub Organization: `https://github.com/<ORG>`
- Linear Workspace: `https://linear.app/<WORKSPACE>`
- Teams: <https://teams.microsoft.com>
- 社内ポータル（Notion / Confluence 等）: ※ メンターに確認

### 参考ドキュメント一覧

- [開発ライフサイクル](../development-lifecycle.md)
- [GitHub 運用ガイド](../github-operations.md)
- [Linear 運用ガイド](../linear-operations.md)
- [情報分類ポリシー](../isms/information-classification.md)
- [認証情報管理](../isms/credential-management.md)
- [インシデント管理](../isms/incident-management.md)
- [Claude Code 利用ポリシー](../ai-governance/claude-code-policy.md)

---

> このドキュメントに誤り・古い情報を発見した場合は、遠慮なく PR を送ってください。初日のフレッシュな目線からの改善提案は特に歓迎します。
