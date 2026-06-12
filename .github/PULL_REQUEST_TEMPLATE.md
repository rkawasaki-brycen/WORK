## PR タイプ

該当するものにチェックを入れてください:

- [ ] Feature — 新機能の追加
- [ ] Bug Fix — バグ修正
- [ ] Improvement — 既存機能の改善・最適化
- [ ] Docs — ドキュメントの追加・更新
- [ ] Security — セキュリティ対応
- [ ] Refactor — リファクタリング（機能変更なし）
- [ ] CI/CD — ビルド・デプロイパイプラインの変更

---

## Summary（概要）

<!-- このPRで何を・なぜ変更したかを簡潔に説明してください -->

---

## Related Issue

<!-- 関連するIssue・チケットをリンクしてください -->

- Linear: <!-- e.g. ENG-123 → https://linear.app/your-org/issue/ENG-123 -->
- GitHub Issue: <!-- e.g. Closes #42 / Fixes #42 / Resolves #42 -->

---

## Changes（変更内容）

<!-- 主要な変更点を箇条書きで記述してください -->

-
-
-

---

## Testing（テスト）

### 自動テスト

- [ ] Unit Test を追加・更新した
- [ ] Integration Test を追加・更新した
- [ ] 既存のテストがすべて pass している (`npm test` / `pytest` 等)

### Manual Test（手動確認）

- [ ] ローカル環境で動作確認済み
- [ ] Staging 環境で動作確認済み（該当する場合）

<!-- 手動テストの手順・確認内容を記述してください -->

```
1.
2.
3.
```

---

## Security Checklist（セキュリティ確認）

- [ ] シークレット・認証情報・APIキーをコードに含めていない
- [ ] 依存パッケージの脆弱性チェックを実施した（`npm audit` / `pip-audit` 等）
- [ ] 外部入力に対して適切な Input Validation / Sanitization を実施している
- [ ] 認証・認可の変更がある場合、影響範囲を確認した
- [ ] ログ出力に個人情報・機密情報が含まれていない

---

## Quality Checklist（品質確認）

- [ ] Lint / Formatter が pass している
- [ ] Type Check が pass している（TypeScript / mypy 等）
- [ ] コードの可読性・保守性を考慮した実装になっている
- [ ] 不要なデバッグコード・コメントアウトを削除した
- [ ] Code Review の準備ができている（セルフレビュー済み）

---

## Breaking Changes（破壊的変更）

- [ ] この PR に Breaking Change は含まれない
- [ ] Breaking Change が含まれる（下記に詳細を記述）

<!-- Breaking Change がある場合、影響範囲と移行手順を記述してください -->

---

## Screenshots / Demo（該当する場合）

<!-- UI変更・ビジュアル確認が必要な場合はスクリーンショットや動画を貼り付けてください -->

| Before | After |
|--------|-------|
| <!-- 変更前 --> | <!-- 変更後 --> |

---

## Reviewer Notes（レビュアーへの補足）

<!-- レビュアーに特に確認してほしい点・背景情報・判断の根拠などを記述してください -->

---

## Post-Merge Tasks（マージ後の作業）

<!-- マージ後に必要な作業があれば記述してください -->

- [ ] 環境変数・設定の更新（Staging / Production）
- [ ] データマイグレーションの実行
- [ ] 関連ドキュメントの更新
- [ ] チームへの周知・リリースノートの作成
- [ ] 特になし
