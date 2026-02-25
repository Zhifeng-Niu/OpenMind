# OpenMind - Coding Agent 工程与实验开发行动指南

> **A Practical Guide for Learning and Building Coding Agents**

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC%20BY--NC--SA%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
[![Language: 中文](https://img.shields.io/badge/Language-中文-red.svg)]()
[![English](https://img.shields.io/badge/Read-English-blue.svg)](README_EN.md)

---

## 🌟 项目愿景

**OpenMind** 是我个人整理的一份行动指南，用于学习和指导各类 Coding Agent 进行 Agent 工程和实验性开发。

我将其开源给所有人阅读和非商业使用，欢迎大家不断丰富知识内容，**一起促进人工智能更好地提升人类文明！**

> *"Let us work together to help AI better advance human civilization!"*

---

## 📖 项目简介

本指南深入探讨了"什么样的 Agent 才是真正'自主'的?"这一核心问题,建立了从 Level 0 (被动响应) 到 Level 4 (完全自主) 的完整自主性谱系,并提供了理论框架、设计方法、工程实现和实验验证的全流程方案。

### 🎯 核心目标

- ✅ **建立自主性理论框架** - Level 0-4 清晰定义
- ✅ **设计动机系统** - 好奇心+成就感+生存需求
- ✅ **实现持续运行架构** - 7x24 稳定运行
- ✅ **验证 Level 2-3 自主性** - 完整实验框架

## 🏗️ 内容结构

```
OpenMind/
├── autonomous-agent-guide/          # 自主 Agent 主指南
│   ├── README.md                    # 概览与导航
│   └── docs/
│       ├── chapter-01-theory.md     # 理论基础
│       ├── chapter-02-design.md     # 设计原理
│       ├── chapter-03-mechanisms.md # 核心机制
│       ├── chapter-04-runtime.md    # 运行架构
│       ├── chapter-05-exploration.md # 主动行为
│       ├── chapter-06-implementation.md # 工程实现
│       ├── chapter-07-experiments.md # 实验方法
│       └── chapter-08-frontier.md    # 前沿展望
│
├── ai-agent-building-guide/         # 通用 Agent 构建指南
│   └── ...                          # 10维设计空间 + 构建块系统
│
├── docs/                            # 项目文档
│   └── infinite-context-guide.md    # 无限上下文技术指南
│
└── README_EN.md                     # English Version
```

## 💡 核心创新

1. **自主性谱系** - Level 0-4 清晰定义,从被动到完全自主
2. **合成动机系统** - 好奇心+成就感+生存需求三驱动
3. **混合运行架构** - 事件驱动+轮询+自主探索
4. **自主性指数** - 5维度可量化评估 (目标/时间/空间/学习/社交)
5. **10维设计空间** - 完整的 Agent 设计维度框架

## 🚀 快速开始

### 对于研究者

```bash
# 1. 阅读理论基础
cd autonomous-agent-guide/docs
less chapter-01-theory.md

# 2. 了解前沿问题
less chapter-08-frontier.md
```

### 对于工程师

```bash
# 1. 查看完整实现
cd autonomous-agent-guide/docs
less chapter-06-implementation.md

# 2. 参考通用指南
cd ../../ai-agent-building-guide
less README.md
```

### 对于学习者

```bash
# 按顺序学习所有章节
cd autonomous-agent-guide/docs
for chapter in chapter-*.md; do
    less "$chapter"
done
```

## 📊 自主性评估

**自主性等级定义**:

| Level | 名称 | 描述 | 代表系统 |
|-------|------|------|---------|
| 0 | 被动响应 | 仅响应直接指令 | 传统 ChatBot |
| 1 | 任务自主 | 可完成明确任务 | AutoGPT, OpenDevin |
| 2 | 目标自主 | 可设定子目标 | BabyAGI |
| 3 | 动机自主 | 有内在驱动力 | OpenMind 目标 |
| 4 | 完全自主 | 自我意识与进化 | 理论探索 |

**OpenMind 目标**: Level 3 (动机自主)

## 📚 参考资源

### 论文
- "Intrinsic Motivation for Artificial Agents" (2023)
- "Reflexion: Language Agents with Verbal Reinforcement Learning" (2024)
- "Constitutional AI: Harmlessness from AI Feedback" (2023)

### 项目
- [AutoGPT](https://github.com/Significant-Gravitas/AutoGPT) - 递归任务分解
- [OpenDevin](https://github.com/OpenDevin/OpenDevin) - 自主编程
- [Claude Code](https://www.anthropic.com/claude-code) - AI 辅助开发

### 社区
- [AI Alignment Forum](https://www.alignmentforum.org/)
- [LessWrong](https://www.lesswrong.com/)

## 📄 许可证

本项目采用 **CC BY-NC-SA 4.0** 许可证 - 非商业使用,相同方式共享

这意味着你可以：
- ✅ 自由分享和复制本作品
- ✅ 自由修改和构建本作品
- ❌ 不得用于商业目的
- 🔄 衍生作品需采用相同许可

详见 [LICENSE](LICENSE) 文件。

## 🤝 贡献

欢迎贡献！无论是：
- 📝 修正错别字或改进表述
- 📚 添加新的案例或参考
- 💡 提出新的想法或建议
- 🌐 帮助翻译成其他语言

请查看 [CONTRIBUTING.md](CONTRIBUTING.md) 了解详情。

### 贡献方式

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改
4. 开启 Pull Request

## 📮 联系方式

- **邮箱**: Zhifeng_Niu@outlook.com
- **Issues**: [GitHub Issues](https://github.com/Zhifeng-Niu/OpenMind/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Zhifeng-Niu/OpenMind/discussions)

---

<div align="center">

**让 AI 真正自主起来！** 🚀

**Let's work together to help AI better advance human civilization!**

Made with ❤️ by Zhifeng Niu & Contributors

[English Version](README_EN.md) | [中文版](README.md)

</div>
