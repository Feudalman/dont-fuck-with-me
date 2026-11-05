# dont-fuck-with-me

English | [中文](README.zh.md)

The things I keep having to say a second time when working with AI.

Every repetition is wasted breath; a skill is written once and applies every time. This repo holds exactly one kind of thing: **rules that do not depend on any specific project and should hold in any conversation.**

## What gets in

1. **Swap the project, swap the AI, talk for five minutes — it still holds.** If it doesn't, it doesn't belong here
2. **It fixes something I have already repeated**, not "industry best practice"
3. **It can be judged true or false.** A good rule lets me point at one concrete output and say "this violates it"; "be professional, be good" cannot
4. **The cost is named.** Every rule gives something up (speed, word count, number of options). If you cannot name what it gives up, it has no binding force. That column lives in `docs/backlog.md`, not in SKILL.md — written into a skill, a model reads it as "compensation is allowed"
5. **No motive lectures.** One sentence of reasoning; the rest is "how to do it" and "what counts as missing"

## Usage

Each skill is a directory under `skills/<name>/`, entered through its `SKILL.md`. "Using" a skill means installing it into an AI agent's skills directory, where the agent picks it up in the next session.

### Option 1: skills CLI (recommended)

```bash
# one skill into the current project (applies to that project's sessions only)
npx --yes skills add <owner>/dont-fuck-with-me -s terse

# all of them
npx --yes skills add <owner>/dont-fuck-with-me --all

# install globally (applies everywhere; behavioural rules like terse belong here)
npx --yes skills add <owner>/dont-fuck-with-me --all -g
```

Local paths work too — clone, then point at the directory:

```bash
git clone <repo-url> && npx --yes skills add ./dont-fuck-with-me -s terse
```

### Option 2: plain git + symlink (no node needed)

An agent's skills directory is `./.agents/skills/` per project and `~/.agents/skills/` globally. Link a skill directory into it:

```bash
mkdir -p ~/.agents/skills
ln -s "$PWD/skills/terse" ~/.agents/skills/terse
```

### Checking and updating

```bash
npx --yes skills ls         # list installed skills
npx --yes skills update -y  # update after new commits land here
```

Changes take effect in the next session. `terse` activates on complex, multi-part, or highly technical questions; it stays out of simple Q&A and of requests that explicitly want to roam. The other skills trigger on the literal phrases in their descriptions.

## Skills

| Skill | What it governs | State |
| --- | --- | --- |
| `table-or-list` | Pick the right carrier before pouring content in: a table only when the attributes are uniform and fit, a list otherwise — never compress or drop information | ✅ |
| `batch-then-focus` | For multi-item deliveries, give a scan-complete list first, then one item per round: the reader always knows how many there are and which one they are on | ✅ |
| `re-explain` | When told "I don't follow", move only the layer that makes the other blockers disappear; three or more layers means rewrite, not patch | ✅ |
| `lean-docs` | In any document one fact has one home, and edits go to that home; nothing unusable stays, and every paragraph reads complete once | ✅ |
| `ask-before-extra` | Do only the actions the instruction named; ask before anything else — how far to change, whether to commit, whether to push, all have edges | ✅ |
| `terse` | On complex questions, stay on the question asked, lead with the answer, do not sprawl, drop jargon and ornaments | ✅ |

> Rules not in this table are still queued in `docs/backlog.md`.

## Layout

```
AGENTS.md              working agreement for agents in this repo (read before editing)
skills/<name>/         SKILL.md plus references/ examples/ as needed
templates/SKILL.md      skeleton for a new skill
scripts/new-skill.sh    scaffold: creates the directory, frontmatter, README and backlog rows
scripts/check.sh        merge gate, the only local acceptance command
docs/backlog.md        queue of pending rules, the sole entry point
```

## Development

```bash
./scripts/new-skill.sh answer-first     # create
./scripts/check.sh                      # acceptance, always before committing
```

Write the rule into `docs/backlog.md` first, then turn it into a skill. `check` verifies that the backlog, the README table, and `skills/` all agree.
