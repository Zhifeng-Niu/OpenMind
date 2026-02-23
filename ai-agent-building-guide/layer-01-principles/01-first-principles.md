# 第一性原理

> 从最基本的问题开始:什么是 Agent?

## 🎯 本章目标

在深入复杂的技术细节之前,我们需要先理解 Agent 的本质。本章将回答:

1. 什么是 Agent?什么不是 Agent?
2. Agent 的核心组件是什么?
3. Agent 与 LLM、Workflow 有什么区别?
4. 为什么我们需要 Agent?
5. 如何实现一个最简单的 Agent?

## 1.1 Agent 的本质定义

### 传统定义的误区

很多人对 Agent 的理解是这样的:

- "Agent 就是能自动完成任务的 AI"
- "ChatGPT Plugin 就是 Agent"
- "能调用工具的 LLM 就是 Agent"

这些理解都不完全准确。它们描述的是 Agent 的**特征**,而不是**本质**。

### 第一性原理定义

让我们从第一性原理出发:

```
Agent = 感知 (Perception) + 决策 (Decision) + 行动 (Action) + 记忆 (Memory)
       │                    │              │              │
       └────────────────────┴──────────────┴──────────────┘
                              │
                       信息处理闭环
```

**关键洞察:**

1. **感知 (Perception)**: 从环境中获取信息
   - 输入: 文本、图像、音频、传感器数据、API 响应...
   - 不是被动接收,而是主动观察

2. **决策 (Decision)**: 基于感知信息做出选择
   - 推理: 分析现状
   - 规划: 制定策略
   - 判断: 评估选项

3. **行动 (Action)**: 对环境产生影响
   - 输出: 文本、API 调用、系统操作、工具使用...
   - 不是简单响应,而是主动改变

4. **记忆 (Memory)**: 存储和检索信息
   - 短期: 当前上下文
   - 长期: 持久化知识
   - 不是静态存储,而是动态更新

### 为什么是闭环?

```
感知 → 决策 → 行动
  ↖_____________↙
       反馈
```

Agent 的关键在于**闭环**:

1. 感知环境状态
2. 基于感知做出决策
3. 执行行动改变环境
4. 新的环境状态被感知
5. 循环继续...

这个闭环使得 Agent 能够:
- **适应**: 根据反馈调整行为
- **学习**: 从经验中改进
- **自主**: 不依赖外部指令

### 什么不是 Agent?

#### ❌ 单纯的 LLM 调用

```python
# 这不是 Agent
response = llm.generate("写一首诗")
print(response)
```

**为什么不是?**
- 只有决策 (LLM 推理)
- 没有感知 (输入是固定的)
- 没有行动 (输出只是文本,不改变环境)
- 没有记忆 (每次调用独立)
- 没有闭环 (单向流程)

#### ✅ 带闭环的 LLM 系统

```python
# 这是 Agent
class Agent:
    def __init__(self):
        self.memory = []
        self.tools = {...}

    async def run(self, goal):
        # 感知: 获取当前状态
        state = self.perceive()

        # 决策: 基于 LLM 推理
        decision = await self.decide(goal, state)

        # 行动: 执行操作
        result = await self.act(decision)

        # 记忆: 更新上下文
        self.memory.append(result)

        # 闭环: 根据结果决定下一步
        if not self.is_complete(result):
            return await self.run(goal)
        return result
```

**为什么是?**
- 有感知 (perceive 方法)
- 有决策 (decide 方法,使用 LLM)
- 有行动 (act 方法,可能调用工具)
- 有记忆 (self.memory)
- 有闭环 (递归调用直到完成)

## 1.2 Agent vs LLM vs Workflow

### 对比表格

| 特性 | LLM | Workflow | Agent |
|------|-----|----------|-------|
| **输入** | 静态提示 | 预定义步骤 | 动态感知 |
| **处理** | 单次推理 | 固定流程 | 自适应决策 |
| **输出** | 文本响应 | 预定义结果 | 主动行动 |
| **记忆** | 无/有限 | 状态机 | 持久化 + 上下文 |
| **闭环** | 无 | 有(但固定) | 有(且动态) |
| **自主性** | 无 | 低 | 高 |
| **适应性** | 无 | 低 | 高 |

### 详细对比

#### LLM: 静态预测器

```python
# LLM 的典型使用
response = llm.generate(
    "分析这段文本的情感: {text}"
)
# 单次输入 → 单次输出
# 无状态,无记忆,无闭环
```

**特点:**
- 输入和输出都是静态的
- 每次调用独立
- 无法从过往经验学习
- 无法主动获取信息

**适用场景:**
- 单次问答
- 内容生成
- 简单分析

#### Workflow: 固定流程

```python
# Workflow 的典型使用
def process_text(text):
    # 步骤 1: 预处理
    cleaned = preprocess(text)

    # 步骤 2: 分析
    sentiment = analyze_sentiment(cleaned)

    # 步骤 3: 后处理
    result = format_result(sentiment)

    return result

# 固定步骤顺序
# 有状态,但状态转换固定
# 有闭环,但反馈路径固定
```

**特点:**
- 流程预设
- 状态转换确定
- 可以处理复杂任务
- 但适应性有限

**适用场景:**
- 数据处理流水线
- ETL 任务
- 自动化脚本

#### Agent: 自适应系统

```python
# Agent 的典型使用
class Agent:
    async def solve(self, problem):
        # 动态决定做什么
        while not self.solved(problem):
            # 感知当前状态
            context = await self.perceive()

            # 推理下一步行动
            action = await self.reason(context)

            # 执行并观察结果
            result = await self.execute(action)

            # 根据结果调整策略
            self.learn(result)

        return self.solution
```

**特点:**
- 流程动态
- 状态转换自适应
- 可以处理不确定任务
- 高度适应环境

**适用场景:**
- 复杂问题求解
- 动态环境
- 需要长期规划的任务

## 1.3 为什么需要 Agent?

### LLM 的局限

虽然 LLM 很强大,但它有一些根本性的局限:

1. **无状态**: 每次调用独立,无法积累经验
2. **无工具**: 只能生成文本,无法操作世界
3. **无规划**: 单次推理,无法处理多步任务
4. **无学习**: 无法从反馈中改进

### Agent 的优势

Agent 通过架构设计克服了这些局限:

| 局限 | Agent 的解决方案 |
|------|-----------------|
| 无状态 | 记忆系统:短期记忆 + 长期存储 |
| 无工具 | 工具调用:API、代码执行、系统操作 |
| 无规划 | 规划器:任务分解、策略制定 |
| 无学习 | 学习机制:反思、评估、优化 |

### 实际案例

#### 案例 1: 编程任务

**使用 LLM:**
```python
# 只能生成代码,无法运行
code = llm.generate("写一个快速排序")
# 用户需要自己复制、运行、调试
```

**使用 Agent:**
```python
# 可以完整完成编程任务
agent.solve("实现并测试快速排序")
# 自动:编写代码 → 运行测试 → 调试错误 → 验证结果
```

#### 案例 2: 研究任务

**使用 LLM:**
```python
# 只能基于训练数据回答
answer = llm.generate("2025 年 AI 领域有什么突破?")
# 可能过时或不准确
```

**使用 Agent:**
```python
# 可以主动搜索最新信息
agent.solve("研究 2025 年 AI 领域的突破")
# 自动:搜索网络 → 阅读论文 → 综合分析 → 生成报告
```

## 1.4 最简单的 Agent 实现

让我们实现一个最简单的 Agent,理解核心组件:

```python
import asyncio
from typing import List, Dict, Any

class SimpleAgent:
    """最简单的 Agent 实现"""

    def __init__(self, llm):
        self.llm = llm
        self.memory: List[Dict[str, Any]] = []
        self.tools = {
            "search": self.search,
            "calculate": self.calculate,
        }

    def perceive(self) -> str:
        """感知:收集当前上下文"""
        context = "当前对话历史:\n"
        for item in self.memory[-5:]:  # 最近 5 条
            context += f"- {item['role']}: {item['content']}\n"
        return context

    async def decide(self, goal: str, context: str) -> Dict[str, Any]:
        """决策:基于 LLM 推理下一步行动"""
        prompt = f"""
目标: {goal}

上下文:
{context}

可用工具:
- search: 搜索信息
- calculate: 执行计算

请决定下一步行动,格式: {{"action": "tool_name", "input": "..."}}
如果目标已完成,返回: {{"action": "done", "result": "..."}}
"""

        response = await self.llm.generate(prompt)
        return self.parse_action(response)

    async def act(self, action: Dict[str, Any]) -> Any:
        """行动:执行决策"""
        if action["action"] == "done":
            return action["result"]

        tool = self.tools.get(action["action"])
        if tool:
            return await tool(action.get("input", ""))
        return "未知工具"

    def remember(self, role: str, content: str):
        """记忆:存储信息"""
        self.memory.append({"role": role, "content": content})

    async def run(self, goal: str, max_steps: int = 10) -> str:
        """运行 Agent 主循环"""
        self.remember("user", goal)

        for step in range(max_steps):
            # 1. 感知
            context = self.perceive()

            # 2. 决策
            action = await self.decide(goal, context)

            # 3. 行动
            result = await self.act(action)

            # 4. 记忆
            self.remember("assistant", str(result))

            # 5. 检查是否完成
            if action.get("action") == "done":
                return result

        return "达到最大步数"

    # 工具实现
    async def search(self, query: str) -> str:
        return f"搜索 '{query}' 的结果: [模拟数据]"

    async def calculate(self, expression: str) -> str:
        try:
            return f"计算结果: {eval(expression)}"
        except:
            return "计算错误"

    def parse_action(self, response: str) -> Dict[str, Any]:
        """解析 LLM 输出为行动"""
        import json
        try:
            return json.loads(response.strip())
        except:
            return {"action": "done", "result": response}

# 使用示例
async def main():
    class MockLLM:
        async def generate(self, prompt: str) -> str:
            # 简化的 LLM 模拟
            return '{"action": "done", "result": "任务完成"}'

    agent = SimpleAgent(MockLLM())
    result = await agent.run("帮我搜索最新的 AI 论文")
    print(result)

# asyncio.run(main())
```

### 代码解析

这个简单 Agent 展示了所有核心组件:

1. **感知** (`perceive`): 从记忆中获取上下文
2. **决策** (`decide`): 使用 LLM 推理下一步
3. **行动** (`act`): 执行工具或完成任务
4. **记忆** (`remember`): 存储对话历史
5. **闭环** (`run`): 递归调用直到完成

## 1.5 练习

### 练习 1: 识别 Agent

判断以下系统是否是 Agent,为什么?

1. 聊天机器人
2. 自动驾驶系统
3. 数据库查询系统
4. 游戏 AI

### 练习 2: 设计 Agent

为以下场景设计 Agent:

1. **个人助理**: 管理日程、发送邮件、预订餐厅
2. **代码审查员**: 分析代码、提出建议、生成修复
3. **研究员**: 搜索文献、综合信息、撰写报告

对每个 Agent:
- 列出感知、决策、行动、记忆组件
- 在 N 维空间中定位
- 说明与 LLM/Workflow 的区别

### 练习 3: 实现扩展

扩展 `SimpleAgent`:

1. 添加更多工具
2. 改进记忆机制(区分短期/长期)
3. 添加反思能力(评估自己的输出)

## 1.6 总结

### 关键要点

1. **Agent 本质**: 感知-决策-行动-记忆的闭环系统
2. **vs LLM**: Agent 有状态、工具、规划、学习能力
3. **vs Workflow**: Agent 的流程是动态的、自适应的
4. **核心价值**: 通过架构设计克服 LLM 的局限

### 下一步

理解了 Agent 的本质后,让我们学习:

- [设计维度](02-design-dimensions.md) - 如何在 N 维空间中设计 Agent
- [架构模式](03-architecture-patterns.md) - 所有 Agent 共享的底层模式
