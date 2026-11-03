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

1. **它治的是我重复说过的话**，不是"业界最佳实践"。写不出来"我上次在哪被气到"就不写
2. **能判真假**。合格的规矩能被人指着一次具体输出说"这里违反了"；"要专业、要好"不行
3. **代价明确**。每条规矩都意味着放弃某个东西（速度、字数、选项数），说不出放弃什么，说明它其实没有约束力
4. **不解释动机**。道理写一句，剩下全是"怎么做"和"什么算做到"

## 安装

```bash
# 全部装到当前项目
npx --yes skills add <owner>/dont-fuck-with-me --all

# 或只装某几个
npx --yes skills add <owner>/dont-fuck-with-me -s answer-first,no-guessing

# 装到全局（所有项目都生效）
npx --yes skills add <owner>/dont-fuck-with-me --all -g
```

## Skills

| Skill | 治什么 | 状态 |
| --- | --- | --- |

> 空表是刻意的。条目一个个进来，先进 `docs/backlog.md` 排队，达标了再落成 skill。

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
