# Skills

此目录保存可以完整分发、复用和改进的 Agent Skill。

每个 Skill 以 SKILL.md 为入口，并保留运行环境所需要的 agents、scripts、references 等附属文件。安装时复制整个 Skill 目录到目标 Agent 的 Skills 目录，再按该环境的规则验证是否可被发现。

当前包含：

- video-script-writer：负责从选题到完整视频口播脚本的工作流。
- video-hook-builder：负责视频开头和前 30 秒的专项诊断与改写。
- knowledge-video-sfx：从口播、分镜、字幕或动画描述中识别有认知作用的音效事件，生成项目级 `sfx-cues.yaml`，并提供格式校验。它需要调用方提供外部 `sfx-catalog.yaml`，不包含也不管理原始音频；详见 [知识视频音效工作流](../docs/知识视频音效工作流.md)。

复制 `knowledge-video-sfx` 时必须保留 `agents/`、`assets/`、`references/` 和 `scripts/`。`sfx-cues.template.yaml` 里的 catalog 路径是占位符，应在目标项目中替换为实际可访问的共享素材索引。
