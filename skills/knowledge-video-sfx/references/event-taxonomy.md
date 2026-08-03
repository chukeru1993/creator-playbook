# 知识视频事件分类

## 先判断是否需要声音

只有当声音能补足以下任一认知职责时，才建立 cue：定位对象或阶段、建立因果关系、确认不可逆状态、提示风险或例外、收束结论。纯装饰、重复出现、普通切镜和旁白已完成强调的画面，默认静音。开发者内容进一步要求：cue 必须确认一个可见状态改变，或标记一个必须立即注意的规则/异常。

| 事件 | 何时使用 | 可见锚点 | 目标声音 |
| --- | --- | --- | --- |
| `card.enter` / `file.enter` | 新的规则、文件、证据进入工作区 | 卡片完全落位 | 短、轻、纸片或柔和 UI 质感 |
| `card.move` / `paper.replace` | 信息被移动、替换或归档 | 对象离开或抵达目标位置 | 与移动方向一致的短滑动声 |
| `flow.connect` | 两个概念、步骤或节点建立关系 | 连接线抵达终点或节点点亮 | 清晰而克制的连接/擦拭声 |
| `card.lock` / `node.select` | 选项被选中、状态被固定 | 勾选、落锁、节点高亮 | 短点击或轻确认声 |
| `step.tick` / `sequence.advance` | 少数关键步骤推进 | 关键编号或进度节点落位 | 低能量、无长尾的短 tick |
| `risk.flag` / `retrieval.miss` / `boundary.warning` | 错误、风险、未命中或边界条件出现 | 错误分支亮起、路径中断、警示标记出现 | 短、低调、不可与成功声混淆 |
| `check.confirm` / `guard.resolve` | 人工复述、验证通过、护栏生效 | 勾选确认、验证卡闭合 | 柔和、明亮、短确认声 |
| `conclusion.slam` | 全片少数结论、关键数字或立场落点 | 结论被锁定或画面停住 | 可感知但不压旁白的强调声 |
| `scene.transition` | 章节之间有明确论点转移 | 旧结构离场且新结构接管 | 短、低频率使用的过渡声 |

## 口播定位点 → 事件映射

Spotting 时先把稿件中的逻辑事件按下表归类，再结合可见锚点决定是否建 cue。表中的“语义理由”是这类声音存在的认知依据，写 cue `rationale` 时应能回指到它。

| 定位点 | 典型口播句式 | event | function | 语义理由 | 约束 |
| --- | --- | --- | --- | --- | --- |
| 开篇定调 | “差的不是 X，是 Y”首次亮出核心命题 | `conclusion.slam` | emphasis | 锤定全片立场，建立认知轴 | 与终场同一身份声；全片 ≤3 处 |
| 纠错引导 | “先纠正一个误区”“不是装饰/不是文件名” | `risk.flag` | caution | 标记认知偏差，与后续定义声构成“破-立” | 与纠错卡落位同拍 |
| 定义/职责锁定 | “X 只负责 Y”“留下可回查的锚点” | `check.confirm` | resolution | 确认职责或边界成立 | 常接在纠错声之后 |
| 事件点名示范 | “文件进来，是 file.enter” | 被点名的同名事件 | 随事件 | 旁白点名即声义同步，示范“不同事件不同声音” | 每个点名一声，音色随事件而异 |
| 逻辑/因果接通 | “A 才变成 B”“接到 C” | `flow.connect` | causality | 关系首次建立，观众获得因果感 | 全片同一身份声 |
| 风险预警 | 错误支路、“全部错位”“都不等于 approved” | `risk.flag` | caution | 坑、边界、易混淆概念首次出现 | 与 FLAG 动作同拍；同类风险复用同一音色 |
| 规则/闸门锁定 | “这条规矩看着小”“批准之后才…” | `card.lock` | commitment | 硬约束或前置条件被固定 | 可与前置 risk.flag 构成“坑-规则”对照 |
| 结果/通过确认 | 校验通过、三问对上、闸门通过 | `check.confirm` | resolution | 不可逆状态被确认 | 与闸门 lock 间隔 ≥3s，避免连续通知感 |
| 价值升华/终场命题 | 核心口号在结尾复述 | `conclusion.slam` | emphasis | 全片收束，与开篇呼应 | 同一身份声；尾音不得侵入下一镜 |
| CTA/收尾诉求 | “收藏”“仓库在简介”“可以私聊” | 静音 | — | 旁白主导，加声即抢 CTA | 写入 omissions |

### 跨模块一致性规则

- **身份声**：同一事件在全片固定同一素材。听众靠音色识别事件复现（如 `flow.connect` 始终是同一声纸质擦拭），换音色等于换语义。
- **Slam 经济学**：`conclusion.slam` 全片不超过 3 处（建议开篇定调 / 中段支点 / 终场收束），全部使用同一素材；其余结论用 HOLD 与旁白承担。
- **配对语法**：三种合法的两声结构——“破-立”（risk.flag → check.confirm）、“坑-规则”（risk.flag → card.lock）、“闸门-通过”（card.lock → check.confirm，间隔 ≥3s）。除此之外避免相邻两声承担相同职责。
- **点名优先**：旁白明确念出事件名时必须配声，即使它处在通常静音的 CASCADE 序列中；未被点名的同类入场保持静音。
- **提升路径**：原本 omission 的项，在审阅指出明确语义锚点后提升为正式 cue，同时改写对应 omission 记录，保持静音清单与实际一致。

## 开发者 UI Feedback 适配矩阵

在 `project.sound_style: developer_ui_feedback` 下，`event` 继续匹配 catalog 的 `use_for`；另用 `state_change` 表达实际的 UI 状态。不要因为矩阵里有一行就给每次动作加声。

| `feedback_kind` | 何时成立 | `event` 的优先映射 | 目标声音 | 排除规则 |
| --- | --- | --- | --- | --- |
| `execution_start` | 用户提交命令后，运行状态第一次明确出现 | `step.tick` / `sequence.advance` | 80–350 ms，极轻的 `mechanical` 或 `synthetic` 摩擦/信号切入 | 代码逐字输入、光标移动、加载装饰不响；若马上出结果，优先结果声 |
| `result_ready` | Agent、代码或部署从运行中变为结果可读、验证通过或可执行 | `check.confirm` / `guard.resolve` | 80–350 ms，短促、干净的 `glass` 或明亮 `synthetic` ping | 不把普通日志滚动或未验证的中间输出当结果确认 |
| `rule_highlight` | 一条硬规则被锁定、约束生效或必须记住的禁止项首次出现 | `card.lock` / `node.select` | 100–400 ms，极轻的 `mechanical` 碰撞或数据处理感 | 旁白只是提高音量、字幕变色或普通粗体不响 |
| `error_warning` | 错误、反面案例、边界条件或护栏拦截第一次明确出现 | `risk.flag` / `boundary.warning` / `retrieval.miss` | 120–450 ms，低调的低中频 `synthetic` / 电流干扰，和成功声可辨 | 不使用重低音、警报长鸣或喜剧失败音；重复报错只保留第一次或最终阻断 |

其他确有必要的开发者状态可使用：`state_connect`（因果链接通，`flow.connect`）、`state_lock`（配置/权限/决策固定，`card.lock`）和 `section_transition`（论点级切换，`scene.transition`）。它们仍需写出明确的 `before -> after`，不得把普通进入动画改名为状态。

单次状态迁移最多一声。运行开始到结果落地少于约 2 秒时，通常只保留 `result_ready`；若两声都保留，必须各自代表不同状态，且试听后不会形成连续通知。开发者模式下，默认最大时长为 800 ms，只有 `section_transition` 可在试听后放宽到 1,000 ms；这不是响度限制，最终增益仍以目标镜头中的旁白可懂度为准。

## 密度覆盖复查

按主 Skill 的 `density_plan` 先选择 `sparse`、`balanced` 或 `dense`，再检查数量。不要把每张卡片都算成事件，也不要让“默认静音”变成漏检：

- 每个连续 20 秒段，若有两个以上新的、重要且离散的状态迁移，检查是否至少有一个 cue；没有时补最强锚点，或写明静音原因。普通输入、滚动、重复进入和装饰动画不参与这项计数。
- 同一长场景可使用多个 cue，但每条必须对应不同的事件类别或不同的认知职责；普通卡片的连续进入仍只选一个。
- 默认相邻 cue 至少相隔 3 秒。因果接通后立刻确认、或风险出现后立刻回退等不可分的单一事件，合成一条 cue，而不是两声叠加。
- 数量偏少时，优先补新问题、状态确认、风险旗标、可恢复状态和最终职责锁定；不要补 CTA、普通 bullet、硬切、代码输入或日志滚动。

## 功能、强度与材料

| `function` | 观众获得什么 | 常见事件 | 默认强度 |
| --- | --- | --- | --- |
| `orientation` | 知道新对象或阶段出现 | `file.enter`、`card.enter` | low |
| `causality` | 感到两个对象发生连接或移动 | `flow.connect`、`card.move` | low-medium |
| `commitment` | 感到选择已经确认或锁定 | `card.lock`、`node.select` | low-medium |
| `caution` | 注意到限制、失败或风险 | `risk.flag`、`boundary.warning` | medium |
| `resolution` | 感到验证和问题收束 | `check.confirm`、`guard.resolve` | low-medium |
| `emphasis` | 记住一个结论或数字 | `conclusion.slam` | medium-high, rare |
| `transition` | 感到论点结构切换 | `scene.transition` | medium, rare |

`material` 应服从画面隐喻：纸片/文档优先 `paper`，轻量流程和连接优先 `air` 或柔和 `synthetic`，选择和确认可用 `plastic`、`mechanical` 或 `glass`。不要因为素材名称好听而引入与画面无关的自然拟音、科幻声或重低音。

## 时间锚点

`visual_anchor.trigger` 使用 `onset`、`impact` 或 `settle`：

- `onset`：对象开始进入、线开始绘制。声音通常可在视觉前 20–80 ms 进入。
- `impact`：对象落位、线接通、勾选出现。通常对齐 0 ms。
- `settle`：对象已稳定，语义才成立。通常在视觉后 40–120 ms。

这些是试听起点，不是固定公式。带明显长尾的素材要检查是否跨过下一句旁白或下一次画面变化。

## 排除与克制

- 不给每次卡片入场、每个 bullet 或每次镜头硬切加声音。
- 同一 3–5 秒内存在多个视觉动作时，只选择最能表达关系变化的一个。
- 旁白说出专业术语、数字、反转或 CTA 时，避免同时使用强起音或高亮度声音。
- `sparing` 只用于章节级转场或结论；不能用于普通连接、点击和步骤。
- 不能从现有库匹配时，保持静音优于语义错误的声音。
- 不用打字声、连续键盘声、游戏化升级音、喜剧失败音、长 whoosh 或泛泛“赛博”氛围声冒充系统反馈。
