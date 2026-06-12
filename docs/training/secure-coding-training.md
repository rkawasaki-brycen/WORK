# セキュアコーディングトレーニング

**対象:** 開発者、Tech Lead
**所要時間:** 約90分
**更新日:** 2026-06-12

---

## はじめに

セキュアコーディングは「セキュリティ担当者が後から確認する仕事」ではなく、**コードを書く段階から組み込む設計思想**です。このトレーニングでは、日常の開発で直面する代表的な脆弱性と、その具体的な防止策を学びます。

---

## 1. OWASP Top 10 概要

[OWASP（Open Web Application Security Project）](https://owasp.org/Top10/)は、Web アプリケーションにおける最も重大なセキュリティリスクを毎年まとめています。2021年版の Top 10 を以下に示します。

| 順位 | リスク | 説明 |
|------|--------|------|
| A01 | アクセス制御の不備 | 認可されていない操作が許可されてしまう |
| A02 | 暗号化の失敗 | 機密データが平文または弱い暗号化で保護されている |
| A03 | インジェクション | 信頼できないデータがコマンド・クエリに挿入される（SQL インジェクション等） |
| A04 | セキュアでない設計 | セキュリティを考慮しない設計・アーキテクチャ |
| A05 | セキュリティの設定ミス | デフォルト設定の使用、不要な機能の有効化、エラー情報の漏洩等 |
| A06 | 脆弱で古くなったコンポーネント | パッチ未適用のライブラリ・フレームワーク・OS の使用 |
| A07 | 識別と認証の失敗 | 認証・セッション管理の不備 |
| A08 | ソフトウェアとデータの整合性の失敗 | CI/CD パイプラインやソフトウェアアップデートの検証不足 |
| A09 | セキュリティログとモニタリングの失敗 | 不正アクセスを検知・調査できないログの欠如 |
| A10 | SSRF（サーバーサイドリクエストフォージェリ） | サーバーが攻撃者の指定した外部リソースにリクエストを送信してしまう |

以降のセクションでは、開発者が日常的に遭遇するリスクを具体的に解説します。

---

## 2. 入力バリデーションのベストプラクティス

### 2.1 基本原則: すべての入力を信頼しない

ユーザー入力・外部 API レスポンス・データベースからのデータも含め、**外部から来るデータはすべて不正な値が含まれる可能性がある**と仮定して処理してください。

### 2.2 バリデーションの実装パターン

**TypeScript / Node.js の例（Zod を使用）:**

```typescript
import { z } from 'zod';

// スキーマ定義
const CreateUserSchema = z.object({
  email: z.string().email().max(255),
  password: z.string().min(12).max(100),
  name: z.string().min(1).max(100).regex(/^[a-zA-Z\s぀-ゟ゠-ヿ一-鿿]+$/),
  age: z.number().int().min(0).max(150).optional(),
});

// コントローラでの利用
async function createUser(req: Request, res: Response) {
  const result = CreateUserSchema.safeParse(req.body);
  if (!result.success) {
    return res.status(400).json({ errors: result.error.flatten() });
  }
  const { email, password, name, age } = result.data; // 安全なデータのみ使用
  // ...
}
```

### 2.3 バリデーションチェックリスト

- [ ] 型チェック（文字列・数値・日付など）
- [ ] 長さ・範囲のチェック（文字列の最大長、数値の最小値・最大値）
- [ ] フォーマットチェック（メールアドレス、URL、電話番号など）
- [ ] 許可リスト方式（特定の値のみ受け入れ）
- [ ] ファイルアップロードの場合: MIME タイプ・拡張子・サイズの検証

---

## 3. 認証と認可のパターン

### 3.1 認証（Authentication）と認可（Authorization）の違い

| 概念 | 意味 | 例 |
|------|------|----|
| 認証（Authentication） | あなたは誰か | ログイン処理 |
| 認可（Authorization） | あなたは何ができるか | 管理者のみが特定操作を実行できる |

**最も多い脆弱性**: 認証を確認しても認可を確認していない（「ログインしているか」は確認するが「この操作を実行する権限があるか」を確認しない）。

### 3.2 認証の実装注意点

```typescript
// 悪い例: パスワードを平文で保存
const user = await db.users.create({ email, password }); // 禁止

// 良い例: bcrypt でハッシュ化して保存
import bcrypt from 'bcrypt';
const SALT_ROUNDS = 12;
const hashedPassword = await bcrypt.hash(password, SALT_ROUNDS);
const user = await db.users.create({ email, password: hashedPassword });

// ログイン時の照合
const isValid = await bcrypt.compare(inputPassword, user.hashedPassword);
```

```typescript
// JWT の検証を必ず行う
import jwt from 'jsonwebtoken';

function authMiddleware(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!);
    req.user = decoded;
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid token' });
  }
}
```

### 3.3 認可の実装注意点

```typescript
// 悪い例: URL のパラメータのみでリソースを返す（IDOR: 安直な直接参照）
app.get('/api/orders/:orderId', async (req, res) => {
  const order = await db.orders.findById(req.params.orderId);
  return res.json(order); // 他のユーザーの注文も返せてしまう
});

// 良い例: ログインユーザーのリソースであるか確認する
app.get('/api/orders/:orderId', authMiddleware, async (req, res) => {
  const order = await db.orders.findOne({
    id: req.params.orderId,
    userId: req.user.id, // 自分の注文のみ
  });
  if (!order) return res.status(404).json({ error: 'Not found' });
  return res.json(order);
});
```

---

## 4. SQL インジェクション防止

### 4.1 SQL インジェクションとは

ユーザー入力を SQL クエリに直接埋め込むことで、意図しない SQL が実行される脆弱性です。

### 4.2 脆弱なコードの例

```python
# 悪い例: ユーザー入力を直接 SQL に埋め込む
username = request.form['username']
query = f"SELECT * FROM users WHERE username = '{username}'"
cursor.execute(query)

# 攻撃: username に「' OR '1'='1」を入力すると全ユーザーが返される
# 攻撃: username に「'; DROP TABLE users; --」を入力するとテーブルが削除される
```

### 4.3 防止策: プリペアドステートメント（パラメータ化クエリ）を使う

```python
# 良い例: プリペアドステートメントを使用（Python + psycopg2）
username = request.form['username']
query = "SELECT * FROM users WHERE username = %s"
cursor.execute(query, (username,))  # パラメータとして渡す
```

```typescript
// 良い例: ORM を使用（Prisma）
const user = await prisma.user.findUnique({
  where: { username: req.body.username }, // 自動的にエスケープ
});
```

```typescript
// 良い例: クエリビルダーを使用（Knex.js）
const user = await knex('users').where({ username: req.body.username }).first();
// 生の SQL を書く場合はバインドパラメータを必ず使う
const user = await knex.raw('SELECT * FROM users WHERE username = ?', [username]);
```

### 4.4 コードレビューチェックポイント

- [ ] ユーザー入力が SQL に直接連結されていないか
- [ ] すべての SQL パラメータがバインドパラメータ（`?` や `:param`）になっているか
- [ ] ORM やクエリビルダーを使用しているか（生の SQL は最小限に）

---

## 5. XSS（クロスサイトスクリプティング）防止

### 5.1 XSS とは

悪意のあるスクリプトが Web ページに挿入され、他のユーザーのブラウザ上で実行される脆弱性です。セッションの乗っ取り・フィッシング・マルウェア配布に悪用されます。

### 5.2 脆弱なコードの例

```javascript
// 悪い例（フロントエンド）: ユーザー入力を innerHTML に直接代入
document.getElementById('output').innerHTML = userInput; // 禁止

// 攻撃: userInput に「<script>steal(document.cookie)</script>」が入ると攻撃成立
```

### 5.3 防止策

**フロントエンド:**

```javascript
// 良い例: textContent を使うか、エスケープ処理を行う
document.getElementById('output').textContent = userInput; // テキストとして扱う

// React/Vue/Angular などのフレームワークは標準でエスケープする
// ただし dangerouslySetInnerHTML（React）などの明示的な HTML 挿入は慎重に使うこと
```

**バックエンド（テンプレートエンジン）:**

```python
# 悪い例（Jinja2）: |safe フィルタでエスケープを無効化する
# {{ user_input | safe }}  # 禁止

# 良い例: デフォルトのエスケープ（何もしない）
{{ user_input }}  # 自動エスケープ
```

**Content Security Policy（CSP）ヘッダーの設定:**

```typescript
// Express.js での設定例（helmet.js を使用）
import helmet from 'helmet';
app.use(helmet.contentSecurityPolicy({
  directives: {
    defaultSrc: ["'self'"],
    scriptSrc: ["'self'"],
    styleSrc: ["'self'", "'unsafe-inline'"], // できれば unsafe-inline も排除
    imgSrc: ["'self'", "data:", "https:"],
  },
}));
```

---

## 6. シークレット管理（コード内）

### 6.1 ハードコードは絶対に禁止

```typescript
// 禁止: コードにシークレットを直接書く
const stripe = new Stripe('sk_live_xxxxxxxxxxxxxxxxxxxx');
const dbUrl = 'postgresql://admin:password@prod.example.com/db';

// 良い例: 環境変数から読み込む
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!);
const dbUrl = process.env.DATABASE_URL!;
```

### 6.2 環境変数の検証

起動時に必要な環境変数が設定されているかを検証することで、設定漏れを早期に発見できます。

```typescript
// 起動時チェック（Zod を使用）
import { z } from 'zod';

const EnvSchema = z.object({
  NODE_ENV: z.enum(['development', 'staging', 'production']),
  DATABASE_URL: z.string().url(),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  JWT_SECRET: z.string().min(32),
});

const env = EnvSchema.parse(process.env);
export default env;
```

### 6.3 pre-commit フックで自動検出

```bash
# gitleaks をインストール（macOS）
brew install gitleaks

# pre-commit フックを設定
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/sh
gitleaks protect --staged --redact -v
if [ $? -ne 0 ]; then
  echo "ERROR: シークレットの可能性があるデータが検出されました。"
  exit 1
fi
EOF
chmod +x .git/hooks/pre-commit
```

---

## 7. 依存ライブラリのセキュリティ管理

### 7.1 脆弱なライブラリのリスク

使用しているライブラリに脆弱性が発見された場合、自分のコードに問題がなくても攻撃対象になります（OWASP A06）。

### 7.2 脆弱性スキャンの実行

```bash
# npm audit（Node.js）
npm audit
npm audit fix  # 自動修正（後方互換性のある範囲）
npm audit fix --force  # 強制修正（破壊的変更を含む場合あり）

# Python の場合（pip-audit）
pip install pip-audit
pip-audit

# Snyk（CI/CD 統合向け）
npx snyk test
```

### 7.3 GitHub Dependabot の活用

リポジトリ設定で Dependabot を有効化することで、脆弱性が発見されたライブラリへのアップデート PR が自動的に作成されます。

設定場所: `リポジトリ → Settings → Security → Dependabot`

### 7.4 ライブラリ更新のルール

- **Patch バージョン**（1.0.0 → 1.0.1）: セキュリティ修正が含まれる可能性が高い。積極的に適用する
- **Minor バージョン**（1.0.0 → 1.1.0）: 後方互換性がある新機能。テストを確認して適用する
- **Major バージョン**（1.0.0 → 2.0.0）: 破壊的変更を含む。移行コストとリスクを評価して対応する

Critical / High の脆弱性は**検出後1週間以内**に対応することを原則とします。

---

## 8. セキュリティテストの実施方法

### 8.1 ローカルでのセキュリティスキャン

```bash
# Snyk によるコードと依存関係のスキャン
npx snyk test           # 依存関係の脆弱性チェック
npx snyk code test      # ソースコードの静的解析

# gitleaks によるシークレットスキャン（コミット前）
gitleaks detect --source .

# semgrep による静的解析（セキュリティルールの適用）
# インストール: pip install semgrep
semgrep --config=p/owasp-top-ten .
semgrep --config=p/javascript .
```

### 8.2 CI/CD でのセキュリティチェック

CI パイプラインには以下のセキュリティチェックが組み込まれています。

```yaml
# GitHub Actions の例
name: Security Checks
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run gitleaks（シークレットスキャン）
        uses: gitleaks/gitleaks-action@v2

      - name: Run npm audit（依存関係チェック）
        run: npm audit --audit-level=high

      - name: Run CodeQL（コード品質・セキュリティ解析）
        uses: github/codeql-action/analyze@v3
```

CI でセキュリティチェックが失敗した場合は、マージ前に必ず対応してください。

### 8.3 セキュリティ問題の報告

スキャンで発見した脆弱性や、コードレビュー中に気づいたセキュリティ問題は、通常のバグチケットではなく **Restricted** 情報として扱います。

- 修正前の脆弱性情報は公開 GitHub Issue に記載しない
- `#security-alerts` チャンネルまたは Security 担当者に直接報告する
- Linear のチケットには概要のみ記載し、詳細は非公開ドキュメントに記録する

---

## 9. コードレビューのセキュリティチェックリスト

PR レビュー時に以下の観点を確認してください。

### 入力・出力

- [ ] すべてのユーザー入力がバリデーションされているか
- [ ] SQL クエリにパラメータバインディングが使用されているか
- [ ] HTML 出力にエスケープ処理が施されているか
- [ ] ファイルアップロード処理が適切に制限されているか（MIME タイプ・サイズ・格納先）

### 認証・認可

- [ ] 認証が必要なエンドポイントに認証ミドルウェアが適用されているか
- [ ] 認可チェックがリソースへのアクセスごとに行われているか（IDOR 対策）
- [ ] パスワードが bcrypt 等で適切にハッシュ化されているか
- [ ] JWT の検証に署名検証が含まれているか

### シークレット・データ保護

- [ ] シークレットがコードにハードコードされていないか
- [ ] ログに個人情報・機密情報が出力されていないか
- [ ] エラーレスポンスに内部情報（スタックトレース等）が含まれていないか
- [ ] 機密データが適切に暗号化されているか

### 依存関係

- [ ] 新しく追加されたライブラリに既知の脆弱性がないか（`npm audit` 確認済みか）
- [ ] ライセンスが問題ないか

---

## 10. セキュアコーディング: よくある間違いと正しい書き方

### 10.1 安全でないランダム値

```python
# 悪い例: 推測可能なランダム値
import random
token = str(random.random())  # 予測可能

# 良い例: 暗号学的に安全な乱数
import secrets
token = secrets.token_hex(32)  # 64文字の暗号学的に安全なトークン
```

```typescript
// TypeScript / Node.js
import { randomBytes } from 'crypto';
const token = randomBytes(32).toString('hex');
```

### 10.2 適切なセッション管理

```typescript
// セッションの設定（Express.js + express-session）
app.use(session({
  secret: process.env.SESSION_SECRET!,
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,  // JavaScript からのアクセスを禁止（XSS 対策）
    secure: process.env.NODE_ENV === 'production', // HTTPS のみ
    sameSite: 'strict', // CSRF 対策
    maxAge: 24 * 60 * 60 * 1000, // 24時間
  },
}));
```

### 10.3 CSRF 対策

```typescript
// Express.js での CSRF 対策（csurf ライブラリまたはカスタム実装）
import csrf from 'csurf';
const csrfProtection = csrf({ cookie: true });

app.post('/api/transfer', csrfProtection, (req, res) => {
  // CSRF トークンが自動検証される
});
```

---

## 関連ドキュメント

- [ISMS セキュリティ意識向上トレーニング](./isms-training.md)
- [クレデンシャル・シークレット管理ポリシー](../isms/credential-management.md)
- [脆弱性管理プロセス](../isms/vulnerability-management.md)
- [インシデント管理プロセス](../isms/incident-management.md)
- [OWASP Top 10](https://owasp.org/Top10/)

---

## バージョン履歴

| バージョン | 日付 | 変更内容 | 担当 |
|-----------|------|---------|------|
| 1.0.0 | 2026-06-12 | 初版作成 | - |
