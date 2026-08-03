---
name: knowledge-video-sfx
description: 为知识讲解、技术教程与口播类视频执行音效 Spotting：读取口播稿、分镜、动画描述或合成源，以及共享 sfx-catalog.yaml；识别有认知作用的语义事件，匹配候选音效，并生成可试听、可校验的项目级 sfx-cues.yaml。用于“给知识视频配音效”“从脚本/分镜生成音效表”“为 HyperFrames 动画匹配 SFX”等任务。
---

# 知识视频音效 Spotting

把音效视为第三条信息通道：它应帮助观众定位关系、感知状态改变、确认结论，而不是为每个动画制造存在感。对于 AI Agent、编程和开发工具内容，优先把它当作 UI Feedback：一声对应一个可见、可解释的状态迁移，不把声音当作娱乐、节拍或“科技感”填充。

## 输入与边界

先定位以下输入；缺少其中一项时，说明影响并按可用信息继续。

- 口播稿或字幕：解释事件的意义和旁白压力。
- 分镜、`video-spec.md`、画面说明或合成源：确定可见动作和场景 ID。
- 最终音频/SRT、场景时间轴或 `data-duration`：确定时间码。优先级依次为最终音频/SRT、已实现时间轴、脚本估时。
- 共享 `sfx-catalog.yaml`：必须作为可用资产的唯一来源。不要从文件名推断音效语义。

默认在项目目录写入 `sfx-cues.yaml`，绝不把场景号、项目标题、时间码或选用结果写回共享 catalog，也不改动原始音频。没有最终时间轴时，使用脚本和画面锚点，保留 `timing.at_s: null`；不要编造秒数。

需要事件类别、触发时机和排除规则时，读取 [references/event-taxonomy.md](references/event-taxonomy.md)。写入字段前，读取 [references/sfx-cues-format.md](references/sfx-cues-format.md)，并以 [assets/sfx-cues.template.yaml](assets/sfx-cues.template.yaml) 为起点。

## 开发者 UI Feedback 模式

当画面主体是代码执行、终端、Agent 运行、IDE 或开发工具界面时，在 `project.sound_style` 写 `developer_ui_feedback`。这不是新增一套“更密”的音效方案，而是更严格的准入门槛：没有离散状态迁移或需要立即注意的规则/异常，就保持静音。

每条非 `omitted` cue 都要写 `state_change.before`、`state_change.after` 和 `state_change.feedback_kind`。`event` 仍然只使用共享 catalog 实际声明的 `use_for` 事件；`state_change` 则记录这声 UI 反馈在叙事上确认了什么。四类首选节点、声音特征和可用的 catalog 事件映射见 [references/event-taxonomy.md](references/event-taxonomy.md)。

代码输入、光标闪烁、终端滚动、普通卡片进场、逐项 bullet、镜头硬切和“看起来像系统”的装饰动画默认静音。一次执行从开始到结果若不足约 2 秒，通常只保留结果确认；只有开始与结果都是观众必须分辨的独立状态时才允许两声，并在目标镜头试听它们是否形成提示音序列。

## 先校准密度，再开始 Spotting

不要把“克制”理解成十分钟只放十几条音效，也不要按固定数量给每张卡片配声。先根据已实现画面选择密度档位，并在 `sfx-cues.yaml` 写入 `density_plan`：

| 档位 | 适用画面 | 目标（实际使用 cue / 分钟） |
| --- | --- | --- |
| `sparse` | 以稳定口播、少量大图或实拍为主 | 2.0–3.5 |
| `balanced`（默认） | 有分镜、关系图、流程卡和章节动作的知识视频 | 3.5–5.0 |
| `dense` | 快节奏产品演示、代码/UI 操作或连续状态变化 | 4.5–6.0 |

只统计 `needs_audition` 和 `approved` cue，不统计 `omitted` 或 `blocked`。例如 10 分钟的 `balanced` 视频，首轮应计划约 35–50 条候选；这是一条覆盖检查线，不是要为 50 次动画各响一次。若没有最终时长，先写档位和理由，待 SRT/音频完成后回填数量。

完成第一轮选择后，从头扫描每段连续 20 秒：如果其中有两个以上新的、可见且语义不同的**重要状态迁移**，却没有任何 cue，必须补最强的一个候选，或在 `omissions` / `sfx-spotting.md` 写明为什么这段保持静音。单纯的对象运动、重复进入和装饰动画不算状态迁移，不为满足覆盖数字而补声。一个场景可以有多个 cue，但它们必须承载不同的定位、因果、风险、确认或收束，且通常相隔至少 3 秒。

开发者 UI Feedback 模式下，概念讲解或静态口播通常选 `sparse`；只有可见的代码/UI 状态确实连续变化时才选 `balanced` 或 `dense`。密度档位是复查线，不是允许把每个可点击元素都响一遍的配额。

## 工作流

### 1. 建立覆盖表，再决定哪些动画静音

按场景阅读口播与画面。对每个候选点，先写清：

1. 观众此刻需要理解的关系、状态或结论是什么？
2. 哪个唯一的可见动作可以承载它？写成 `visual_anchor.action`。
3. 旁白中的哪个词句解释它？写成 `narration_anchor`。
4. 没有音效是否会损失定位、因果、确认、风险或结论力度？若不会，记录为 `omissions`，不要建立 cue。

开发者 UI Feedback 模式还要写出这个动作把什么状态变成什么状态。若无法写成 `before -> after`，它通常只是装饰动作，应保持静音；“强调一句话”只有在规则被锁定、异常被拦截或结果被确认时才是有效状态。

同一视觉动作只能有一个主事件。重复的卡片进入、普通硬切、持续背景运动、旁白已经足够强调的句子，默认不加音效；但“同一场景只有一声”不是规则。一个长场景中不同的提问、风险、状态锁定和关系收束可以各有一声。旁白优先于音效；不要让音效盖住术语、数字、转折或 CTA。

### 2. 给保留点赋予事件与意图

选择已有的稳定事件名，例如 `flow.connect`、`file.enter`、`risk.flag`、`check.confirm`。`function` 只能表示这次声音的认知职责：`orientation`、`causality`、`commitment`、`caution`、`resolution`、`emphasis` 或 `transition`。

先按 [references/event-taxonomy.md](references/event-taxonomy.md) 的“口播定位点 → 事件映射”表把稿件中的逻辑事件归类：开篇定调与终场升华用 `conclusion.slam`（全片不超过 3 处、同一身份声），纠错引导与风险预警用 `risk.flag`，定义锁定与通过确认用 `check.confirm`，硬规则与批准闸门用 `card.lock`；旁白明确点名事件（如“文件进来，是 file.enter”）时必须配同名事件声。同一事件在全片固定同一素材（身份声），形成可辨认的音色复现；“破-立”“坑-规则”“闸门-通过”三种两声配对遵循表内间隔约束。

把语义事件与素材特征分开：事件描述“为什么响”，`target` 描述“应该是什么声音”，例如材料、能量、明亮度和最大时长。开发者 UI Feedback 模式下，`state_change` 描述“哪个状态被确认”；不要用模糊的“科技感”代替它。为每条 cue 标注 `primary`、`supporting` 或 `optional`；只让少数关系转折、风险和结论成为 `primary`。

### 3. 从共享库匹配，而不是凭文件名选声

按以下顺序筛选 `sfx-catalog.yaml`：

1. 排除 `duplicate`、`review_required`，并仅在明确的大转折中考虑 `sparing`。
2. 用 `use_for` 命中 `event`，`avoid_for` 命中时直接排除。
3. 再按 `target` 的材料、`energy`、`brightness`、时长和标签排序。
4. 为每条有效 cue 保留最多 2–3 个候选，写明为什么第 1 名适合这个动作。若只有一个素材同时满足事件、排除规则和时长目标，就保留一个，并在理由中说明这是素材库边界；不要为了凑数保留语义不准或过长的备选。

`selected` 是待试听的默认选择，不是内容审批。初始 `gain` 使用低值；`energy` 和 `brightness` 是库内分析尺度，不能当成播放音量。`approved` 只能在目标镜头中听过后使用。

如果库中没有合适事件或素材，写 `status: blocked`，并在 `rationale` 中说明所需声音的语义、材料、时长和能量。不要把不合适的声音硬塞进来，也不要未经请求生成或下载新音频。

### 4. 写入项目产物

生成项目根目录的 `sfx-cues.yaml`。它必须包含：来源、时间轴权威、`density_plan`、每条 cue 的语义事件、视觉/旁白锚点、候选、默认选择、试听状态和理由。对于没有时间码的脚本阶段，`timing.at_s` 保持 `null`，在分镜实现或 SRT 完成后回填。

当需要人工审阅时，同时输出一个简短的 `sfx-spotting.md`：列出密度档位、时长、目标区间、计划数量、每个章节的 cue 数、最长未覆盖语义段、`primary` cue、`blocked` 缺口和重要的 `omissions`。它是审阅说明；机器执行只读取 `sfx-cues.yaml`。

### 5. 验证与试听

先运行：

```bash
ruby /path/to/knowledge-video-sfx/scripts/validate_sfx_cues.rb \
  --catalog /path/to/sfx-catalog.yaml \
  --cues /path/to/project/sfx-cues.yaml
```

修复所有 error。warning 需要结合镜头判断，尤其是 `sparing`、过长尾音、无精确 `use_for` 匹配、缺少 `density_plan` 或过密的提示声。再核对实际数量是否落在目标区间；若偏少，回到未覆盖的**重要状态迁移**补最强锚点，或补充静音理由；若偏多，优先移除重复的同类进入声。最后在旁白、字幕、动画同时存在的目标镜头试听，检查起音、落点、尾音、旁白遮挡和连续几条 cue 的疲劳感。开发者模式额外检查：移除声音后，观众是否仍能准确说出它确认的状态；如果不能，保留。若能，优先静音。

不要自动渲染或导出视频，除非用户明确要求。

## 交付检查

- 每条非 `omitted` cue 都有可见动作和旁白或叙事依据。
- 最终音频/SRT 存在时，所有实际使用 cue 都有真实 `at_s`。
- 有最终时长时，`density_plan.planned_cue_count` 与实际 `needs_audition` + `approved` 数量一致，且计划密度落在所选档位的目标区间；每段超过 20 秒的未覆盖语义动作都有补声或静音理由。
- `selected.asset_id` 存在于 catalog，且不是 `duplicate` 或 `review_required`。
- 事件、目标声音和动画材料一致；结论重击不用于普通卡片，警告不用于成功确认。
- `developer_ui_feedback` 下，每条非 `omitted` cue 都有不同的 `state_change.before` / `after` 以及合适的 `feedback_kind`；代码输入、滚动和装饰性 UI 动作没有被当作音效节点。
- 共享库未混入项目时间码；项目里没有把 `preferred` 当成已批准。
