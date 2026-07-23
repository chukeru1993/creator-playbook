# Creator Playbook

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

面向中文知识视频创作者与 Agent 工作流的开源方法库，收录三类可复用资产：

- 可分发的 Agent Skill；
- 可跨视频项目复用的视觉样式规范；
- 可跨视频项目复用的分镜方法、镜头卡和验收模板。

它不存放口播稿、项目简报、录屏、音视频、成片、项目专属素材或单支视频的时间码。这些内容应留在各自的视频项目中；本仓库只沉淀任何创作者都能理解、复制和改进的方法。

## 目录

    creator-playbook/
    ├── skills/                  可分发的 Agent Skill
    ├── video/
    │   ├── styles/              视觉样式与设计系统
    │   │   └── previews/        各样式的示例帧截图
    │   └── storyboards/         分镜方法、镜头卡与验收模板
    └── docs/                    资产索引与同步说明

## 当前首批资产

| 目录 | 内容 | 用途 |
| --- | --- | --- |
| skills/video-script-writer/ | 完整视频口播脚本 Skill | 可安装、可改进的完整 Skill |
| skills/video-hook-builder/ | 视频开头与前 30 秒优化 Skill | 可安装、可改进的完整 Skill |
| video/styles/DESIGN.md | Graphite Rule Console | 中文知识视频的默认视觉样式规范（[预览图](video/README.md#样式预览)） |
| video/styles/DESIGN.sticker-workbench.md | Sticker Workbench | 奶油纸面贴纸工作台样式规范（[预览图](video/README.md#样式预览)） |
| video/storyboards/知识讲解视频-设计与演出复用框架.md | 镜头论证与验收框架 | 将内容拆为有明确观众结论的分镜 |
| video/storyboards/templates/镜头卡.template.md | 通用镜头卡 | 新视频项目分镜时复制使用 |

资产的职责、来源和更新规则见 docs/资产索引.md。

## 如何使用与贡献

- 从这里复制 Skill、样式规范或分镜模板到具体项目；项目内允许按真实需求做派生版本。
- 欢迎通过 Issue 或 Pull Request 提出可复用的改进；提交前请说明它解决了哪种重复问题。
- 通用规则经过多个项目验证后，再回收更新到这里；不要把某一项目的专属事实直接写进公共规范。
- Skill 必须完整复制整个目录，不能只复制入口文件。

## 许可证

本仓库采用 [MIT License](LICENSE)。你可以使用、复制、修改、合并、发布、分发、再授权及商业化使用其中的内容；请保留原许可证与版权声明。
