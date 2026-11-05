# dont-fuck-with-me

日常和 AI 一起干活时，我反复要说第二遍的那些话。

每说一次出口是浪费时间；写成 skill 是一次投入、每次生效。这个仓库只装这一类东西：**不依赖具体项目、在任何一次对话里都该成立的规矩**。

## 和别的仓库的区别

| | `dont-fuck-with-me`（本仓库） | `arui-skills` |
| --- | --- | --- |
| 服务对象 | 我，和我每天的任何一次任务 | 一个项目的研发流程 |
| 触发场景 | 任何时候 | 会话/提交/PR/发布等流程节点 |
| 内容形态 | 行为约束与默认动作 | 可执行的流程步骤 |
| 依赖 | 无 | 项目 profile、git 分支模型、forge |

一个东西只能进一边。写进来之前先问：**换一个项目、换一个 AI、只聊五分钟，这条还成立吗？** 不成立就属于 `arui-skills`。

## 一条 skill 的准入门槛

1. **它治的是我重复说过的话**，不是“业界最佳实践”
2. **能判真假**。合格的规矩能被人指着一次具体输出说"这里违反了"；"要专业、要好"不行
3. **代价明确**。每条规矩都意味着放弃某个东西（速度、字数、选项数）。说不出放弃什么，说明它其实没有约束力。这一栏记在 `docs/backlog.md` 的第四列，不写进 SKILL.md——写进去会被模型读成「允许补偿」
4. **不解释动机**。道理写一句，剩下全是"怎么做"和"什么算做到"

## 使用

每个 skill 是 `skills/<name>/` 下的一个目录，入口是其中的 `SKILL.md`。"使用"就是把它装进 AI agent 的 skills 目录，agent 下一轮会话自动加载。

### 方式一：skills CLI（推荐）

```bash
# 装单个 skill 到当前项目（只对这个项目的会话生效）
npx --yes skills add <owner>/dont-fuck-with-me -s terse

# 装全部
npx --yes skills add <owner>/dont-fuck-with-me --all

# 装到全局（所有项目生效；terse 这类行为规矩适合全局）
npx --yes skills add <owner>/dont-fuck-with-me --all -g
```

也接受本地路径，克隆后直接指向目录：

```bash
git clone <repo-url> && npx --yes skills add ./dont-fuck-with-me -s terse
```

### 方式二：纯 git + symlink（不需要 node）

agent 的 skills 目录：项目级 `./.agents/skills/`，全局 `~/.agents/skills/`。把 skill 目录链进去即可：

```bash
mkdir -p ~/.agents/skills
ln -s "$PWD/skills/terse" ~/.agents/skills/terse
```

### 验证与更新

```bash
npx --yes skills ls         # 查看已装的 skill
npx --yes skills update -y  # 仓库有新提交后更新
```

装完在下一轮会话生效。`terse` 在复杂、多问或专业性强的问题上自动生效，简单问答和明确要发散的场合不管；别的 skill 用描述里的原话触发。

## Skills

| Skill | 治什么 | 状态 |
| --- | --- | --- |
| `table-or-list` | 先选对载体再装内容：属性同类且说得完才用表格，装不下就换列表，不压缩不丢信息 | ✅ |
| `batch-then-focus` | 多条交付先给全貌清单，细节一轮一件：读者随时知道一共几件、自己在第几件 | ✅ |
| `re-explain` | 被说看不懂时先动能让其余卡点自己消失的那一层；要同时动三层以上就重写，不缝补 | ✅ |
| `lean-docs` | 留下的文档一个事实只有一个出处，改就改原处；用不上的内容一处也不留，每段读一遍就懂 | ✅ |
| `ask-before-extra` | 只做指令点名的动作，没点名的先问再做：改到哪、提不提交、推不推送都有边界 | ✅ |
| `terse` | 复杂问题专注作答：被问什么答什么、先给结论、不发散、不用黑话与记号 | ✅ |

> 表里没出现的规矩还在 `docs/backlog.md` 排队。

## 仓库结构

```
AGENTS.md              本仓库的 agent 工作约定（改仓库前先读）
skills/<name>/         SKILL.md + 按需 references/ examples/
templates/SKILL.md     新 skill 的骨架
scripts/new-skill.sh   脚手架：建目录、生成 frontmatter、登记 README 与 backlog
scripts/check.sh       合并闸门，本地唯一验收命令
docs/backlog.md        待沉淀清单，规矩的唯一入口
```

## 开发

```bash
./scripts/new-skill.sh answer-first     # 新建
./scripts/check.sh                      # 验收，提交前必跑
```

新增或修改的规矩先写进 `docs/backlog.md`，再落 skill。check 会校验 backlog、README 表、`skills/` 三者互相对得上。
