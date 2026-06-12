# CLAUDE.md — チーム開発標準テンプレート

このファイルはClaude Codeがプロジェクトを理解するための設定ドキュメントです。
本リポジトリは会社標準の開発テンプレートとして使用されます。

---

## Project Overview

このリポジトリはチーム開発の標準テンプレートです。新規プロジェクトはこのテンプレートをベースに構築してください。
一貫したコード品質・セキュリティ基準・ワークフローをチーム全体で維持することを目的としています。

---

## Key Directories

```
/
├── src/              # アプリケーションのソースコード
├── tests/            # テストコード（unitおよびintegration）
├── docs/             # プロジェクトドキュメント
├── scripts/          # CI/CDおよびユーティリティスクリプト
├── .github/          # GitHub Actions workflow定義
├── .env.example      # 環境変数のテンプレート（シークレットは含めない）
└── CLAUDE.md         # このファイル（Claude Code設定）
```

---

## Development Workflow

### ブランチ戦略

- `main` ブランチは常にデプロイ可能な状態を維持する
- 作業は必ず `main` から新しいブランチを作成して開始する
- ブランチ命名規則: `feature/<task-id>-<short-description>`, `fix/<task-id>-<short-description>`

```bash
git checkout main
git pull origin main
git checkout -b feature/123-add-login
```

### Pull Request

- 作業完了後はPRを作成し、レビューを依頼する
- PRには変更内容・テスト方法・スクリーンショット（UI変更の場合）を記載する
- マージには最低1名のapprovalが必要
- CIがすべてパスしていることを確認してからmergeする
- `main` への直接pushは禁止

---

## Code Quality Standards

### Lintおよびフォーマット

コミット前に必ずlintを実行すること。

```bash
# lintチェック
npm run lint        # または: make lint

# 自動フォーマット
npm run format      # または: make format
```

### テスト

- 新機能には必ずunit testを追加する
- バグ修正には再現するテストを追加してから修正する
- テストカバレッジは80%以上を維持する

```bash
# テスト実行
npm test            # または: make test

# カバレッジレポート
npm run test:coverage
```

### コミット前チェックリスト

- [ ] `lint` がエラーなしでパスする
- [ ] すべてのテストがパスする
- [ ] 新機能にはテストが追加されている
- [ ] セキュリティチェックを実行した

---

## Security Rules

1. **シークレットをコミットしない**: APIキー・パスワード・トークン・証明書は絶対にコードに含めない
2. **`.env.example` を使用する**: 環境変数のキー一覧は `.env.example` に記載し、値は空にする。実際の値は `.env` に記述し、`.gitignore` に含める
3. **依存関係の脆弱性チェック**: 定期的に脆弱性スキャンを実行する

```bash
# セキュリティスキャン
npm audit           # または: make security-scan

# シークレットのスキャン（git-secretsまたはgitleaks使用）
gitleaks detect --source .
```

4. **`.env` ファイルは `.gitignore` に必ず含める**

```
# .gitignore に含めること
.env
.env.local
.env.*.local
*.pem
*.key
```

---

## AI Usage Guidelines (Claude Code)

### 基本方針

- Claude Codeはコーディング支援ツールとして積極的に活用してよい
- 生成されたコードは必ず人間がレビューし、内容を理解した上でコミットすること
- セキュリティに関わるコード（認証・暗号化・権限管理）は特に慎重にレビューすること

### 推奨される使い方

- コードの説明・ドキュメント生成
- テストコードの作成支援
- リファクタリングの提案
- バグの原因調査

### 注意事項

- 機密情報（APIキー・顧客データ・内部仕様）をプロンプトに含めない
- AIが生成したコードをそのまま本番環境に適用しない（レビュー必須）
- 会社のAI利用ポリシーに従う（詳細は社内ドキュメントを参照）

---

## Important Files

| ファイル | 説明 |
|---|---|
| `CLAUDE.md` | Claude Code設定・プロジェクト概要（このファイル） |
| `README.md` | プロジェクトの概要・セットアップ手順 |
| `.env.example` | 必要な環境変数の一覧（値なし） |
| `.gitignore` | Gitの追跡対象外ファイル設定 |
| `.github/workflows/` | CI/CD pipeline定義 |
| `package.json` / `Makefile` | タスクランナー・依存関係管理 |

---

## Commands

### セットアップ

```bash
# 依存関係インストール
npm install

# 環境変数のセットアップ
cp .env.example .env
# .env を編集して必要な値を設定する
```

### 開発

```bash
# 開発サーバー起動
npm run dev

# ビルド
npm run build

# テスト実行
npm test

# lint実行
npm run lint

# フォーマット
npm run format
```

### CI/CD相当のフルチェック（PR前に実行推奨）

```bash
npm run lint && npm test && npm audit
# または
make ci
```

### Git操作

```bash
# 新しいブランチ作成
git checkout -b feature/<task-id>-<description>

# PRの作成（GitHub CLI使用）
gh pr create --title "feat: ..." --body "..."

# PRのレビュー状況確認
gh pr status
```

---

## Notes for Claude Code

- このリポジトリはチーム共有のため、変更は慎重に行うこと
- `.env` ファイルや `*.key` ファイルは読み込まない
- セキュリティスキャンで検出された問題は必ず報告すること
- コード変更後はlintとテストを実行してから完了とすること
