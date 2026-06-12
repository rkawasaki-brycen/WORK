# アーキテクチャ決定記録 (ADR)

## ADRとは

ADR（Architecture Decision Record）とは、ソフトウェア開発における重要なアーキテクチャ上の決定を文書化するための軽量な手法です。各ADRは、ある時点でチームが下した技術的な意思決定を、その背景・根拠・影響とともに記録します。

### なぜADRが重要か

- **意思決定の透明性**: 誰が、いつ、なぜその決定をしたかを明確にする
- **知識の継承**: チームメンバーが入れ替わっても、過去の意思決定の文脈が失われない
- **変更の追跡**: 決定が覆された場合、その理由と新しい決定を記録できる
- **オンボーディングの促進**: 新メンバーがアーキテクチャの全体像と経緯を把握しやすくなる
- **議論の効率化**: 過去に検討した選択肢を再検討する無駄を省ける

---

## いつADRを書くか

以下のような意思決定を行う際にADRを作成してください。

**必ず書く場面**
- 主要な技術スタックの選定（プログラミング言語、フレームワーク、データベース等）
- インフラ・アーキテクチャパターンの採用（マイクロサービス、イベント駆動等）
- 外部サービス・ライブラリの採用・廃止
- セキュリティ・認証方式の決定
- データモデルの重要な変更

**書くことを推奨する場面**
- チームの開発規約・コーディング標準の制定
- CI/CD パイプラインの設計変更
- 大規模なリファクタリング方針の決定
- パフォーマンス改善のための重要なトレードオフの選択

**書かなくてよい場面**
- 日常的な実装の詳細（関数名、変数名等）
- 一時的な対応（hotfixなど）
- 既存ADRで既にカバーされた範囲内の決定

---

## ADRのライフサイクル

```
Proposed → Accepted → Deprecated
                    → Superseded
```

| ステータス | 説明 |
|------------|------|
| **Proposed** | 提案中。チームでの議論・レビューを待っている状態 |
| **Accepted** | 承認済み。チームの合意を得て採用された決定 |
| **Deprecated** | 非推奨。決定は過去のものとなったが、置き換えのADRはない |
| **Superseded** | 置き換え済み。新しいADRにより置き換えられた状態。新ADRへのリンクを含む |

---

## 番号付け規則

ADRファイルは以下の命名規則に従ってください。

```
NNNN-short-title.md
```

- `NNNN`: ゼロパディングした4桁の連番（例: `0001`, `0042`）
- `short-title`: 決定内容を表す短い英語の説明（ハイフン区切り、小文字）

**例:**
```
0001-record-architecture-decisions.md
0002-use-postgresql.md
0003-adopt-event-driven-architecture.md
0015-migrate-to-kubernetes.md
```

---

## コードからのADRリンク方法

### コードコメントでの参照

重要なアーキテクチャ上の判断が含まれるコードには、対応するADRへの参照コメントを残してください。

```python
# ADR-0003: イベント駆動アーキテクチャの採用に基づく実装
# See: docs/adr/0003-adopt-event-driven-architecture.md
class OrderEventPublisher:
    ...
```

```typescript
// ADR-0007: JWT認証方式の採用
// See: docs/adr/0007-use-jwt-authentication.md
const verifyToken = (token: string): Claims => {
    ...
}
```

### PRディスクリプションでの参照

アーキテクチャ決定に関連するPull Requestでは、ディスクリプションに以下の形式でリンクを記載してください。

```markdown
## 関連ADR
- docs/adr/0005-use-redis-for-caching.md (Accepted)
```

---

## ADRのレビュープロセス

1. **作成**: 意思決定を行う担当者がADRを `Proposed` ステータスで作成する
2. **Draft PR**: ADRを含むPull Requestを作成し、チームに共有する
3. **議論**: PRのレビューコメント、またはチームミーティングで内容を議論する
4. **修正**: フィードバックを反映してADRを更新する
5. **承認**: チームの合意が得られたらステータスを `Accepted` に変更してマージする
6. **周知**: 重要なADRはチャンネルやドキュメントで広くアナウンスする

### レビューの観点

- コンテキストの記述は十分か（背景・制約が明確か）
- 却下した選択肢が適切に比較されているか
- 影響範囲とリスクが正直に評価されているか
- 関連するADRや外部参考文献が適切にリンクされているか

---

## ADR 一覧

| 番号 | タイトル | ステータス | 決定日 |
|------|----------|------------|--------|
| [ADR-0001](0001-record-architecture-decisions.md) | アーキテクチャ決定記録の採用 | Accepted | 2026-06-12 |

---

## 参考資料

- [Documenting Architecture Decisions - Michael Nygard](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [ADR GitHub Organization](https://adr.github.io/)
- [MADR - Markdown Architectural Decision Records](https://adr.github.io/madr/)
