# Creator Playbook

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

面向中文知识视频创作者与 Agent 工作流的开源方法库，收录可跨项目复用的方法资产：

- 可分发的 Agent Skill；
- 可跨视频项目复用的视觉样式规范；
- 可跨视频项目复用的分镜方法、镜头卡和验收模板。
- 支撑上述资产使用边界、外部依赖与维护方式的说明文档。

它不存放口播稿、项目简报、录屏、音视频、成片、项目专属素材或单支视频的时间码。这些内容应留在各自的视频项目中；本仓库只沉淀任何创作者都能理解、复制和改进的方法。

## 目录

    creator-playbook/
    ├── skills/                  可分发的 Agent Skill
    │   └── knowledge-video-sfx/ 知识视频语义音效 Spotting Skill
    ├── video/
    │   ├── styles/              视觉样式与设计系统
    │   │   └── previews/        各样式的示例帧截图
    │   └── storyboards/         分镜方法、镜头卡与验收模板
    └── docs/                    资产索引、同步说明与工作流文档

## 当前首批资产

| 目录 | 内容 | 用途 |
| --- | --- | --- |
| skills/video-script-writer/ | 完整视频口播脚本 Skill | 可安装、可改进的完整 Skill |
| skills/video-hook-builder/ | 视频开头与前 30 秒优化 Skill | 可安装、可改进的完整 Skill |
| skills/knowledge-video-sfx/ | 知识视频语义音效 Spotting Skill | 从口播、分镜和动画描述生成可试听、可校验的项目级 `sfx-cues.yaml` |
| video/styles/DESIGN.md | Graphite Rule Console | 中文知识视频的默认视觉样式规范（[预览图](video/README.md#样式预览)） |
| video/styles/DESIGN.sticker-workbench.md | Sticker Workbench | 奶油纸面贴纸工作台样式规范（[预览图](video/README.md#样式预览)） |
| video/storyboards/知识讲解视频-设计与演出复用框架.md | 镜头论证与验收框架 | 将内容拆为有明确观众结论的分镜 |
| video/storyboards/templates/镜头卡.template.md | 通用镜头卡 | 新视频项目分镜时复制使用 |
| docs/知识视频音效工作流.md | 音效工作流说明 | 说明 Skill、外部音效库与项目 cue 表之间的职责边界 |

资产的职责、来源和更新规则见 [docs/资产索引.md](docs/资产索引.md)。知识视频音效的输入、输出与外部素材库边界见 [docs/知识视频音效工作流.md](docs/知识视频音效工作流.md)。

## 音效资产边界

`knowledge-video-sfx` 是方法和校验工具，不是音频素材包。本仓库当前不随附原始音效文件或 `sfx-catalog.yaml`；使用者应为项目提供一个有明确来源与授权信息的共享 catalog。Skill 只从该 catalog 匹配候选，不会根据文件名猜测语义，也不会生成或下载素材。

因此，项目级的 `sfx-cues.yaml`、试听结果和最终时间码留在视频项目中；共享音频及其来源、许可和索引留在独立的受控素材库中。不要把任一项目的时间码、选用结果或未授权音频提交到本仓库。

## 如何使用与贡献

- 从这里复制 Skill、样式规范或分镜模板到具体项目；项目内允许按真实需求做派生版本。
- 欢迎通过 Issue 或 Pull Request 提出可复用的改进；提交前请说明它解决了哪种重复问题。
- 通用规则经过多个项目验证后，再回收更新到这里；不要把某一项目的专属事实直接写进公共规范。
- Skill 必须完整复制整个目录，不能只复制入口文件。
- 新增或更新音效方法时，同步检查根 README、[Skills 索引](skills/README.md)、[资产索引](docs/资产索引.md)和对应工作流文档；不要让文档声称仓库包含并不存在的媒体或本机路径。

## 许可证

本仓库采用 [MIT License](LICENSE)。你可以使用、复制、修改、合并、发布、分发、再授权及商业化使用其中的内容；请保留原许可证与版权声明。
