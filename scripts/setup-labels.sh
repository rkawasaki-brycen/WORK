#!/usr/bin/env bash
#
# setup-labels.sh — リポジトリに運用ラベルを一括作成する
#
# Issue テンプレートの frontmatter および dependency-scan.yml の
# gh issue create が前提とするラベル。リポジトリ作成直後に一度実行する。
#
# 使い方:
#   gh auth login 済みの環境で
#   ./scripts/setup-labels.sh [owner/repo]
#   (引数省略時はカレントディレクトリのリポジトリが対象)

set -euo pipefail

REPO_FLAG=()
if [ $# -ge 1 ]; then
  REPO_FLAG=(--repo "$1")
fi

create_label() {
  local name="$1" color="$2" description="$3"
  if gh label create "$name" --color "$color" --description "$description" "${REPO_FLAG[@]}" 2>/dev/null; then
    echo "created: $name"
  else
    echo "skipped (already exists): $name"
  fi
}

# Issue テンプレート用 (type / priority)
create_label "type:feature"       "1D76DB" "新機能の要求"
create_label "type:bug"           "D73A4A" "バグ報告"
create_label "type:investigation" "FBCA04" "調査・技術検証"
create_label "type:improvement"   "A2EEEF" "既存機能の改善"
create_label "type:docs"          "0075CA" "ドキュメント追加・修正"
create_label "type:security"      "B60205" "セキュリティ上の問題"
create_label "priority:critical"  "B60205" "即時対応が必要"

# dependency-scan.yml の自動 Issue 起票用
create_label "security"           "D93F0B" "セキュリティ関連"
create_label "dependencies"       "0366D6" "依存パッケージ関連"

# PR 運用ラベル (docs/github-operations.md「ラベル運用」参照)
create_label "feature"            "1D76DB" "新機能追加"
create_label "bug"                "D73A4A" "バグ修正"
create_label "hotfix"             "B60205" "緊急修正"
create_label "documentation"      "0075CA" "ドキュメント変更"
create_label "breaking-change"    "E99695" "後方互換性を壊す変更"
create_label "needs-review"       "0E8A16" "レビュー待ち"
create_label "wip"                "EDEDED" "作業中 (Draft PR と併用)"
create_label "urgent"             "B60205" "緊急対応 (レビュー SLA 4 時間)"

echo ""
echo "ラベルのセットアップが完了しました。"
