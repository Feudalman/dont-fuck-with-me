#!/usr/bin/env bash
# 合并闸门。校验 frontmatter、正文骨架、占位符、可达性、README/backlog 同步。
# 用法：./scripts/check.sh
set -uo pipefail

cd "$(cd "$(dirname "$0")/.." && pwd)"

fail=0
ok() { printf '  ok    %s\n' "$*"; }
bad() { printf '  FAIL  %s\n' "$*"; fail=$((fail + 1)); }
section() { printf '\n%s\n' "$*"; }

skill_dirs() { ls -d skills/*/ 2>/dev/null || true; }
skill_count=$(skill_dirs | grep -c . || true)

# ------------------------------------------------------------------ 结构
section "结构"
missing=0
for dir in $(skill_dirs); do
  name=$(basename "$dir")
  [ -f "$dir/SKILL.md" ] || { bad "$name: 缺 SKILL.md"; missing=1; }
done
[ -f templates/SKILL.md ] || bad "缺 templates/SKILL.md"
[ -f docs/backlog.md ] || bad "缺 docs/backlog.md"
ok "skill 数量：$skill_count"

# --------------------------------------------------------------- frontmatter
section "frontmatter"
for dir in $(skill_dirs); do
  name=$(basename "$dir")
  file="$dir/SKILL.md"
  [ -f "$file" ] || continue

  [ "$(head -1 "$file")" = "---" ] || { bad "$name: 首行不是 ---"; continue; }

  fm_name=$(awk 'NR>1 && /^---$/{exit} NR>1 && /^name:/{sub(/^name:[ ]*/,""); print; exit}' "$file")
  fm_desc=$(awk 'NR>1 && /^---$/{exit} NR>1 && /^description:/{sub(/^description:[ ]*/,""); print; exit}' "$file")
  fm_lines=$(awk 'NR>1 && /^---$/{print NR-2; exit}' "$file")

  [ "$fm_name" = "$name" ] || bad "$name: frontmatter name '$fm_name' 与目录名不一致"
  [ -n "$fm_desc" ] || { bad "$name: 缺 description"; continue; }

  printf '%s' "$fm_desc" | grep -q '^Use when'   || bad "$name: description 未以 'Use when' 开头"
  printf '%s' "$fm_desc" | grep -q 'Triggered by' || bad "$name: description 缺 'Triggered by' 原话钩子"
  printf '%s' "$fm_desc" | grep -q 'Not for'      || bad "$name: description 缺 'Not for' 相邻职责边界"
  [ "${fm_lines:-0}" -eq 2 ] || bad "$name: frontmatter 只应有 name 与 description 两个字段（当前 ${fm_lines:-0} 行内容）"

  ok "$name frontmatter"
done

# ------------------------------------------------------------------ 正文骨架
section "正文骨架"
for dir in $(skill_dirs); do
  name=$(basename "$dir")
  file="$dir/SKILL.md"
  [ -f "$file" ] || continue
  body=$(awk '/^---$/{c++; next} c>=2{print}' "$file")

  for h in "规矩" "怎么做" "什么算没做到" "代价"; do
    printf '%s\n' "$body" | grep -qx "## $h" || bad "$name: 缺 '## $h'"
  done
  printf '%s\n' "$body" | grep -q '^# ' || bad "$name: 缺一级标题"
  printf '%s\n' "$body" | grep -qE '^## (背景|动机|原理|说明)' && bad "$name: 正文出现解释性章节"

  lines=$(printf '%s\n' "$body" | wc -l | tr -d ' ')
  [ "$lines" -le 80 ] || bad "$name: 正文 $lines 行，超过 80 行上限（把细节移进 references/）"

  # 占位符与未填项
  ph=$(grep -nE 'TODO|TBD|<neighbor>|<skill-name>|SKILL_NAME|示例文本' "$file" || true)
  [ -z "$ph" ] || { printf '%s\n' "$ph" | sed 's/^/        /'; bad "$name: 正文残留占位符"; }

  ok "$name 骨架（$lines 行）"
done

# ------------------------------------------------------------- 跨仓库/项目泄漏
section "泄漏"
leak='arui-skills|aruing|Feudalman|/Users/|^C:\\\\'
hits=$(grep -nE "$leak" skills/*/SKILL.md 2>/dev/null || true)
if [ -n "$hits" ]; then
  printf '%s\n' "$hits" | sed 's/^/        /'
  bad "SKILL.md 含项目/仓库成分（正文只写判断，示例放 examples/）"
else
  ok "SKILL.md 无项目与仓库成分"
fi

# ----------------------------------------------------------- references 双向
section "references"
for dir in $(skill_dirs); do
  name=$(basename "$dir")
  skill="$dir/SKILL.md"
  [ -f "$skill" ] || continue

  for rel in $(grep -ohE 'references/[A-Za-z0-9._-]+\.md' "$skill" 2>/dev/null | sort -u); do
    [ -f "$dir/$rel" ] || bad "$name: 正文引用 $rel 但文件不存在"
  done

  if [ -d "$dir/references" ]; then
    for file in "$dir/references"/*.md; do
      [ -e "$file" ] || continue
      base="references/$(basename "$file")"
      grep -qF "$base" "$skill" || bad "$name: $base 在正文中无指针"
    done
  fi

  if grep -q 'examples/' "$skill" 2>/dev/null; then
    [ -n "$(ls "$dir/examples" 2>/dev/null)" ] || bad "$name: 引用了 examples/ 但目录为空"
  fi
done
ok "references / examples 可达性已检查"

# --------------------------------------------------------- README 与 backlog
section "README"
if [ ! -f README.md ]; then
  bad "缺 README.md"
else
  for dir in $(skill_dirs); do
    name=$(basename "$dir")
    grep -q "^| \`$name\` |" README.md || bad "README 表缺 $name"
  done
  for name in $(grep -E '^\| `[^`]+` \|.*✅' README.md | sed 's/^| `\([^`]*\)`.*/\1/'); do
    [ -d "skills/$name" ] || bad "README 标 ✅ 但 skills/$name 不存在"
  done
  ok "README 表与 skills/ 一致"
fi

section "backlog"
if [ ! -f docs/backlog.md ]; then
  bad "缺 docs/backlog.md"
else
  # backlog 里每个 ✅ 行必须点到一个真实 skill
  for name in $(grep -E '✅' docs/backlog.md | grep -oE '`[a-z0-9-]+`' | tr -d '`' | sort -u); do
    [ -d "skills/$name" ] || bad "backlog 标 ✅ 但 skills/$name 不存在"
  done
  # TODO 只允许出现在 backlog 的待办区，skill 已存在则不该还挂着 TODO 状态
  for name in $(grep -E '^\| .*✍️ `[a-z0-9-]+`' docs/backlog.md | grep -oE '`[a-z0-9-]+`' | tr -d '`' | sort -u); do
    [ -d "skills/$name" ] || bad "backlog 标 ✍️ 但 skills/$name 不存在"
  done
  # skills/ 里每个 skill 都必须在 backlog 出现过，否则是没走流程冒出来的
  for dir in $(skill_dirs); do
    name=$(basename "$dir")
    grep -q "\`$name\`" docs/backlog.md || bad "$name 未在 docs/backlog.md 登记"
  done
  ok "backlog 与 skills/ 双向一致"
fi

printf '\n'
if [ "$fail" -eq 0 ]; then
  echo "check passed（$skill_count 个 skill）"
  exit 0
fi
echo "check failed: $fail 项"
exit 1
