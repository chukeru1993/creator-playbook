# `sfx-cues.yaml` 格式

## 顶层字段

```yaml
schema_version: 1
project:
  id: agent-handoff
  catalog: /path/to/shared/sfx-catalog.yaml
  sources:
    narration: Agent-handoff-口播稿.md
    storyboard: video-spec.md
    animation: hyperframes-build/index.html
  timing_authority: script_anchors
  sound_style: developer_ui_feedback
density_plan:
  profile: balanced
  duration_s: 600
  target_cues_per_min: [3.5, 5.0]
  target_count: [35, 50]
  planned_cue_count: 42
  planned_cues_per_min: 4.2
  max_uncovered_semantic_gap_s: 18
```

`timing_authority` 只能为 `final_audio_or_srt`、`scene_timeline` 或 `script_anchors`。前两者表示已经有可核对时间轴；`final_audio_or_srt` 下，每条实际使用的 cue 必须填写 `timing.at_s`。脚本阶段只能写相对锚点，`at_s: null` 是正确结果。

`sound_style` 可省略，或为 `general_knowledge`、`developer_ui_feedback`。后者用于 AI Agent、编程和开发工具画面，并要求每条非 `omitted` cue 写 `state_change`。它不会改变共享 catalog 的事件命名或既有项目的兼容性。

## `density_plan` 字段

新建 Spotting 必须写入 `density_plan`；旧项目缺失时校验器只给 warning，便于渐进迁移。

- `profile`：`sparse`、`balanced` 或 `dense`。选择依据是可见语义动作密度，不是主观想“多一点”。
- `duration_s`：最终音频/SRT 已存在时填写实际时长；尚无最终时长时可为 `null`。
- `target_cues_per_min`：本项目目标区间。默认档位分别为 2.0–3.5、3.5–5.0、4.5–6.0。
- `target_count`：根据时长换算、向内取整后的候选数区间。
- `planned_cue_count`：所有 `needs_audition` 与 `approved` cue 的数量，必须与实际一致。
- `planned_cues_per_min`：`planned_cue_count / duration_s * 60`，校验器允许四舍五入差异。
- `max_uncovered_semantic_gap_s`：只测量含新语义动作的段；不把黑场、纯口播停顿或有明确 `omissions` 的段算作覆盖缺失。

## Cue 字段

```yaml
- id: sfx-003
  scene_id: s03-compact-boundary
  event: flow.connect
  function: causality
  priority: primary
  state_change:
    before: 旧会话只有压缩摘要，无法在新会话中核对完整状态
    after: HANDOFF.md 成为新会话可读取的状态入口
    feedback_kind: state_connect
  visual_anchor:
    action: 阶段边界卡片经由 HANDOFF.md 连到新会话
    trigger: impact
  narration_anchor:
    text: Handoff 管会话之间可验证的项目状态
    position: after
  timing:
    at_s: null
    offset_ms: 0
  target:
    material: paper
    energy: [0.45, 0.75]
    brightness: [0.15, 0.45]
    max_duration_ms: 800
  candidates:
    - asset_id: transition.whoosh.paper.01
      rank: 1
      rationale: 纸质短擦拭与跨文件的连接动作一致，且 use_for 命中 flow.connect。
  selected:
    asset_id: transition.whoosh.paper.01
    gain: 0.18
  status: needs_audition
  rationale: 连接动作承载了 compact 与 Handoff 的职责边界；普通箭头动画不再重复加声。
```

字段要求：

- `event` 使用共享 catalog 的 `use_for` 事件；无法匹配时设 `status: blocked`，在 `rationale` 说明缺口。
- `function` 为 `orientation`、`causality`、`commitment`、`caution`、`resolution`、`emphasis` 或 `transition`。
- `priority` 为 `primary`、`supporting` 或 `optional`。
- `visual_anchor.action` 必须描述一个可见、可定位的动作；`trigger` 为 `onset`、`impact` 或 `settle`。
- `candidates` 按 `rank` 排序；`selected.asset_id` 必须是其中之一，且素材不能是 `duplicate` 或 `review_required`。通常保留最多 2–3 个候选；只有一个候选同时满足事件、排除规则和时长目标时，保留一个并说明素材库边界。
- `status` 为 `needs_audition`、`approved`、`omitted` 或 `blocked`。只有实际试听通过后才可设为 `approved`。
- `gain` 是项目播放增益的 0..1 起始值，不等于 catalog 的 `energy`。

`omissions` 用于记录有画面动作却故意不配声的原因，防止下一次编辑重新把所有动画都加声。

## `state_change`（开发者 UI Feedback 模式）

当 `project.sound_style` 为 `developer_ui_feedback` 时，每条非 `omitted` cue 必须包含：

- `before`：声音发生前、观众可理解的状态。
- `after`：声音确认后、观众应感知到的新状态；不能与 `before` 相同。
- `feedback_kind`：`execution_start`、`result_ready`、`rule_highlight`、`error_warning`、`state_connect`、`state_lock` 或 `section_transition`。

`feedback_kind` 和 `function` 必须一致：`execution_start` 对应 `orientation` 或 `transition`；`result_ready` 对应 `resolution` 或 `commitment`；`rule_highlight` 对应 `emphasis` 或 `commitment`；`error_warning` 对应 `caution`；`state_connect` 对应 `causality`；`state_lock` 对应 `commitment` 或 `resolution`；`section_transition` 对应 `transition`。`event` 仍必须是 catalog 的实际 `use_for` 值。
