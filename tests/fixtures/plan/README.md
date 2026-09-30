# 作者端工具链共享 fixture 语料

本目录的 `.plan` 语料由 `build-plan-authoring-tooling` 的四层测试共用：
tree-sitter corpus/golden、Emacs ERT、LSP transcript/integration 与 JVM/native
smoke。语义与 IR 仍以 Clojure 分析管线（`plan.analyze/analyze`）为唯一权威。

| 文件 | 用途 | 期望分析结果 |
| --- | --- | --- |
| `valid.plan` | 合法计划：summary/leaf/milestone、plain scalar 日期与显示名称、`@id` 引用、字符串、多行、注释 | valid，无诊断 |
| `reserved.plan` | reserved form：圆括号表达式与裸数字 | `syntax/reserved`（layout-blocked） |
| `incomplete.plan` | 编辑中残缺：`:items` 与 `:after` 未闭合 | `syntax/parse`（局部，layout-blocked） |
| `i18n.plan` | 中文/emoji 名称与多行文本（ID 保持 ASCII kebab-case） | valid，无诊断 |
| `semantic.plan` | 依赖环 + 缺失引用，语法/结构合法 | 语义错误，非 layout-blocked（仍可格式化） |
| `people-calendar.plan` | inline calendar/people、leave/overtime、单人与多人 `:to` | valid，输出 people/assignees/allocations |
| `people-calendar-errors.plan` | 重复/缺失 person 和可用性冲突 | 多项人员日历语义错误，不生成 IR |
| `person-name-references.plan` | 可选 person ID、名字引用、ID/名字混合 assignment | valid，派生稳定 ID 并归一为 `personId` |
| `person-name-reference-errors.plan` | 未知与重名 person 名字引用 | 返回 `person/name-unknown` / `person/name-ambiguous`，不生成 IR |
| `name-first-identities.plan` | task/milestone 省略 ID，assignment 使用项目 Person `@key` | valid；formatter 一次物化工作项 ID 并保留稳定引用，二次运行幂等 |
| `people-calendar-warnings.plan` | 工作日 overtime、leave 分配、超载和多任务跨 overtime | valid，输出完整 IR 与容量 warning |
| `progressive-task-decomposition.plan` | 已排期 task 原位拆分并保留日期、deadline、after、to | valid，summary rollup 为 partial，保留字段 inactive，约束未决 |
| `legacy-name-references.plan` | 旧工作项与 Person 名称引用 | 仅供 `migrate references` 回归，普通分析拒绝 |
| `namespace-isolation.plan` | 工作项 ID 与 Person key 同形 | `:after` 与 `:to` 在独立 namespace 解析到各自实体 |
| `sibling-ordering.plan` | BRD/PRD 同级 placement 与批量依赖更新 | valid，显式位置变更保持稳定源码顺序 |
| `milestone-workflow.plan` | milestone 完成命令与 edit-set golden 输入 | valid，完成 milestone 后 summary `completionRollup` 为 done |
| `milestone-states.plan` | done/overdue/active/not-started/unscheduled 视觉语料 | valid，对应 `apps/gantt/fixtures/ir/milestone-states.json` |

大型计划性能基线（500 work item）复用 `apps/gantt/fixtures/large.plan`，
真实多团队计划复用 `examples/infra-migration.plan`，不在本目录重复。

含空格路径用例：测试在临时目录内以带空格的文件名复制上述语料驱动 LSP，
不在仓库提交带空格的文件名。
