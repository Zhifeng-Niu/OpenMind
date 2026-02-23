# Claude Code 作为工具

> 使用 Claude Code 构建和测试 Agent

## 🎯 本章目标

了解如何使用 Claude Code 实现 Agent 系统。

1. 理解 Claude Code 的 Agent 能力
2. 掌握 Skills、MCP、Tools 的使用
3. 学习实战工作流
4. 构建第一个 Agent

## 5.1 Claude Code 的 Agent 能力

### 核心能力

Claude Code 不仅是开发工具,也是 Agent 平台:

| 能力 | 描述 | 用途 |
|------|------|------|
| **文件操作** | 读取、编辑、创建文件 | 代码生成、文档编写 |
| **命令执行** | 运行 shell 命令 | 测试、部署、自动化 |
| **工具调用** | 调用外部工具 | API 集成、数据分析 |
| **记忆系统** | 跨会话记忆 | 上下文保持 |
| **技能系统** | 可复用的技能 | 能力扩展 |

### 与传统开发的区别

```
传统开发:
写代码 → 测试 → 调试 → 修改 → 重复

Claude Code:
描述意图 → 生成代码 → 测试 → 自动修复 → 完成
```

## 5.2 Skills 系统

### 什么是 Skills?

Skills 是可复用的能力单元,类似于 Agent 的"插件"。

### 使用 Skills

```bash
# 列出可用技能
/skills

# 使用特定技能
/skill superpowers:brainstorming
```

### 创建自定义 Skill

```markdown
<!-- .claude/skills/my-skill/skill.md -->
# My Custom Skill

## 触发条件
当用户提到"分析数据"时触发

## 功能
分析用户提供的数据

## 步骤
1. 读取数据
2. 分析模式
3. 生成报告
```

## 5.3 Model Context Protocol (MCP)

### 什么是 MCP?

MCP 是连接 AI 系统与外部工具的标准化协议。

### 使用 MCP Servers

```typescript
// mcp-server-example.ts
import { MCPServer } from '@modelcontextprotocol/sdk';

const server = new MCPServer({
  name: "my-tools",
  version: "1.0.0"
});

// 注册工具
server.registerTool({
  name: "search-database",
  description: "搜索数据库",
  parameters: {
    type: "object",
    properties: {
      query: { type: "string" }
    }
  },
  execute: async (params) => {
    // 实现搜索逻辑
    return results;
  }
});
```

### 常用 MCP Servers

- **文件系统**: 访问本地文件
- **数据库**: 查询数据
- **API**: 调用外部服务
- **自定义**: 你的工具

## 5.4 Tools 系统

### 定义工具

```python
# tools.py
from typing import Any, Dict

class Tool:
    name: str
    description: str
    parameters: Dict[str, Any]

    async def execute(self, **kwargs) -> Any:
        pass

class SearchTool(Tool):
    name = "search"
    description = "搜索信息"
    parameters = {
        "query": {"type": "string", "description": "搜索查询"}
    }

    async def execute(self, query: str):
        # 实现搜索
        return results
```

### 在 Claude Code 中使用

```python
# Claude Code 会自动发现工具
@tool
def search_web(query: str) -> str:
    """搜索网络"""
    # 实现搜索逻辑
    return results
```

## 5.5 实战工作流

### 工作流 1: 快速原型

```bash
# 1. 描述想法
"我想做一个能自动分析代码仓库的 Agent"

# 2. Claude Code 生成框架
# 3. 运行和测试
# 4. 迭代改进
```

### 工作流 2: 测试驱动开发

```bash
# 1. 编写测试
"为我的 Agent 编写测试用例"

# 2. Claude Code 生成实现
# 3. 验证测试
# 4. 重构和优化
```

### 工作流 3: 文档同步

```bash
# 1. 修改代码
# 2. 让 Claude Code 更新文档
"更新 README 以反映新的 API"

# 3. 生成示例
"为这个功能写一个使用示例"
```

## 5.6 构建第一个 Agent

### 示例: 文件分析 Agent

```python
# file_agent.py
import os
from pathlib import Path
from typing import List, Dict

class FileAnalysisAgent:
    """使用 Claude Code 构建的文件分析 Agent"""

    def __init__(self):
        self.tools = {
            "read_file": self.read_file,
            "list_files": self.list_files,
            "search_content": self.search_content
        }

    async def analyze(self, directory: str, goal: str):
        """分析目录中的文件"""

        # 1. 感知: 列出文件
        files = await self.list_files(directory)

        # 2. 决策: 确定分析策略
        strategy = await self.plan_strategy(goal, files)

        # 3. 行动: 执行分析
        results = []
        for file in files:
            content = await self.read_file(file)
            analysis = await self.analyze_file(content, goal)
            results.append({
                "file": file,
                "analysis": analysis
            })

        # 4. 记忆: 保存结果
        return self.summarize(results)

    async def list_files(self, directory: str) -> List[str]:
        """列出目录中的文件"""
        path = Path(directory)
        return [str(f) for f in path.rglob("*") if f.is_file()]

    async def read_file(self, filepath: str) -> str:
        """读取文件内容"""
        return Path(filepath).read_text()

    async def plan_strategy(self, goal: str, files: List[str]) -> Dict:
        """规划分析策略"""
        # 使用 LLM 决定如何分析
        return {
            "focus": files[:10],  # 先分析前10个
            "depth": "deep" if "详细" in goal else "shallow"
        }

    async def analyze_file(self, content: str, goal: str) -> str:
        """分析单个文件"""
        # 这里可以调用 Claude Code API
        # 或者使用本地 LLM
        prompt = f"""
        分析以下代码,目标: {goal}

        代码:
        {content[:1000]}  # 限制长度
        """
        return await self.llm_generate(prompt)

    async def search_content(self, directory: str, pattern: str) -> List[str]:
        """搜索文件内容"""
        results = []
        for file in Path(directory).rglob("*"):
            if file.is_file():
                content = file.read_text()
                if pattern in content:
                    results.append(str(file))
        return results

    def summarize(self, results: List[Dict]) -> str:
        """总结分析结果"""
        summary = f"分析了 {len(results)} 个文件:\n\n"
        for result in results:
            summary += f"## {result['file']}\n"
            summary += f"{result['analysis']}\n\n"
        return summary

# 使用
async def main():
    agent = FileAnalysisAgent()
    result = await agent.analyze(
        "./src",
        "查找安全问题"
    )
    print(result)

# asyncio.run(main())
```

## 5.7 高级技巧

### 技巧 1: 使用 Ralph Loop

```bash
/ralph-loop "改进这个 Agent 的性能" --max-iterations 10
```

### 技巧 2: 并行处理

```python
# 并行分析多个文件
import asyncio

async def analyze_parallel(agent, files):
    tasks = [agent.analyze_file(f) for f in files]
    return await asyncio.gather(*tasks)
```

### 技巧 3: 增量开发

```bash
# 先实现核心功能
"实现基本的文件读取和分析"

# 然后逐步添加
"添加缓存机制"
"添加并行处理"
"添加结果导出"
```

## 5.8 调试和测试

### 调试技巧

1. **日志记录**
```python
import logging

logging.basicConfig(level=logging.DEBUG)
logger = logging.getLogger("agent")

logger.debug(f"分析文件: {filepath}")
```

2. **断点调试**
```python
# 在 Claude Code 中设置断点
breakpoint()
```

3. **逐步验证**
```python
# 每个组件独立测试
async def test_components():
    # 测试感知
    files = await agent.list_files(".")
    assert len(files) > 0

    # 测试决策
    strategy = await agent.plan_strategy("test", files)
    assert "focus" in strategy

    # 测试行动
    # ...
```

## 5.9 练习

### 练习 1: 构建简单 Agent

使用 Claude Code 构建:
1. 日志分析 Agent
2. 代码重构 Agent
3. 文档生成 Agent

### 练习 2: 集成 MCP

为你的 Agent 添加:
1. 文件系统 MCP
2. 数据库 MCP
3. 自定义 MCP

### 练习 3: 使用 Skills

创建自定义 Skill 来扩展 Agent 能力。

## 5.10 总结

### 关键要点

1. **Claude Code = 开发工具 + Agent 平台**
2. **Skills = 可复用能力单元**
3. **MCP = 标准化工具协议**
4. **实战 = 快速原型 → 测试 → 迭代**

### Layer 1 总结

恭喜!你已完成 Layer 1 的学习,现在你能够:

1. ✅ 理解 Agent 的第一性原理
2. ✅ 在 N 维空间中设计 Agent
3. ✅ 掌握核心架构模式
4. ✅ 使用决策树系统化设计
5. ✅ 使用 Claude Code 实现 Agent

### 下一步

- [Layer 2: 案例解析](../layer-02-case-studies/) - 从真实项目中学习
- [Layer 3: 构建块库](../layer-03-building-blocks/) - 组合组件实现
