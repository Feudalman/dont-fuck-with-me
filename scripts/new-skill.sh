#!/usr/bin/env bash
# 新建一个 skill：建目录、写 frontmatter 骨架、在 README 表和 backlog 里登记。
# 用法：./scripts/new-skill.sh <kebab-case-name>
set -euo pipefail

cd "$(cd "$(dirname "$0")/.." && pwd)"

name="${1:-}"
if [ -z "$name" ]; then
  echo "用法: ./scripts/new-skill.sh <kebab-case-name>" >&2
  exit 1
fi

if ! printf '%s' "$name" | grep -qE '^[a-z][a-z0-9]*(-[a-z0-9]+)*$'; then
  echo "skill 名必须是 kebab-case: $name" >&2
  exit 1
fi

if [ -e "skills/$name" ]; then
  echo "skills/$name 已存在" >&2
  exit 1
fi

mkdir -p "skills/$name"

title=$(printf '%s' "$name" | awk -F- '{for (i = 1; i <= NF; i++) printf "%s%s", toupper(substr($i,1,1)), substr($i,2), (i < NF ? " " : "")}')

sed "s/SKILL_NAME/$name/g; s/SKILL_TITLE/$title/g; s/SKILL_NEIGHBOR/<neighbor>/g" \
  templates/SKILL.md > "skills/$name/SKILL.md"

# README 表：插到表头下一行之后
if ! grep -q "^| \`$name\` |" README.md; then
  awk -v line="| \`$name\` | TODO | ✍️ |" '
    { print }
    /^\| Skill \|/ { seen = 1 }
    seen && /^\| --- \|/ && !done { print line; done = 1 }
  ' README.md > README.md.tmp && mv README.md.tmp README.md
fi

# backlog：插到清单表表头之后
if ! grep -q "^| .*\`$name\`" docs/backlog.md; then
  awk -v line="| TODO | TODO | TODO | ✍️ \`$name\` |" '
    { print }
    /^\| 规矩 \|/ { seen = 1 }
    seen && /^\| --- \|/ && !done { print line; done = 1 }
  ' docs/backlog.md > docs/backlog.md.tmp && mv docs/backlog.md.tmp docs/backlog.md
fi

echo "已创建 skills/$name/SKILL.md"
echo "下一步：填 frontmatter 与正文，然后 ./scripts/check.sh"
