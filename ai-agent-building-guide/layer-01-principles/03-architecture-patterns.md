# 架构模式

> 所有 Agent 共享的底层模式

## 🎯 本章目标

理解所有 Agent 共享的底层架构模式。

1. 掌握 4 种核心架构模式
2. 理解每种模式的应用场景
3. 学习如何组合模式
4. 实现各种模式的代码示例

## 3.1 模式概览

### 4 种核心模式

```
1. 循环处理模式 (Loop Processing)
   └─ ReAct, RSI, 自我修正

2. 分层决策模式 (Hierarchical Decision)
   └─ 战略-战术-操作

3. 分布式协作模式 (Distributed Coordination)
   └─ 多 Agent 协调

4. 记忆增强模式 (Memory Augmented)
   └─ RAG, 检索增强
```

**关键洞察:**
- 复杂的 Agent 都是这些模式的组合
- 理解模式后,可以自由组合
- 不是"选择"模式,而是"组合"模式

## 3.2 模式 1: 循环处理模式

### 基本结构

```
输入 → 处理 → 输出
  ↖____________↙
      反馈
```

### ReAct 模式

**Reasoning + Acting**

```python
class ReActAgent:
    async def run(self, query: str):
        # 初始思考
        thought = await self.think(f"问题: {query}")

        # 循环: 思考 → 行动 → 观察
        while not self.is_done():
            # 思考下一步
            thought = await self.think(
                f"当前: {self.context}\n"
                f"上一步: {self.last_action}\n"
                f"结果: {self.last_result}\n"
                f"下一步应该?"
            )

            # 选择行动
            action = self.parse_action(thought)

            # 执行行动
            result = await self.act(action)

            # 观察结果
            observation = await self.observe(result)

            # 更新上下文
            self.update_context(action, observation)

        return self.final_answer()
```

### RSI 模式

**Recursive Self-Improvement**

```python
class RSIAgent:
    async def execute(self, task: Task):
        output = await self.initial_execution(task)
        complexity = self.assess_complexity(output)

        # 递归改进直到满足阈值
        while complexity < self.threshold:
            # 反思
            feedback = await self.reflect(output)

            # 改进
            output = await self.refine(output, feedback)

            # 评估
            complexity = self.assess_complexity(output)

        return output

    async def reflect(self, output):
        """生成改进建议"""
        prompt = f"""
        评估以下输出,提供改进建议:
        {output}

        格式: {{"suggestions": ["..."], "priority": ["..."]}}
        """
        return await self.llm.generate(prompt)

    async def refine(self, output, feedback):
        """根据反馈改进"""
        prompt = f"""
        原始输出:
        {output}

        改进建议:
        {feedback}

        请改进原始输出。
        """
        return await self.llm.generate(prompt)
```

### 应用场景

- **ReAct**: 需要多步推理的任务
- **RSI**: 需要迭代改进的任务
- **自我修正**: 需要验证和修正的任务

## 3.3 模式 2: 分层决策模式

### 基本结构

```
战略层 (Strategy)
    ↓ 分解
战术层 (Tactics)
    ↓ 分配
操作层 (Operations)
```

### 实现

```python
class HierarchicalAgent:
    def __init__(self):
        self.strategic_planner = StrategicPlanner()
        self.tactical_planner = TacticalPlanner()
        self.operator = Operator()

    async def solve(self, goal: str):
        # 战略层: 长期规划
        strategy = await self.strategic_planner.plan(
            f"制定完成 {goal} 的战略"
        )

        # 战术层: 分解为子任务
        tactics = await self.tactical_planner.plan(
            f"将战略 {strategy} 分解为可执行任务"
        )

        # 操作层: 执行具体任务
        results = []
        for task in tactics:
            result = await self.operator.execute(task)
            results.append(result)

        # 整合结果
        return self.aggregate(results)

class StrategicPlanner:
    """战略层: 长期目标、资源分配"""
    async def plan(self, goal):
        # 关注: 一个月、一个季度、一年
        return f"完成 {goal} 的3阶段战略"

class TacticalPlanner:
    """战术层: 任务分解、优先级"""
    async def plan(self, strategy):
        # 关注: 本周、本次任务
        return ["任务1", "任务2", "任务3"]

class Operator:
    """操作层: 具体执行"""
    async def execute(self, task):
        # 关注: 当前操作
        return f"完成 {task}"
```

### 应用场景

- **项目管理**: 战略规划 → 任务分解 → 执行
- **游戏 AI**: 长期策略 → 短期战术 → 即时操作
- **企业规划**: 公司战略 → 部门计划 → 个人任务

## 3.4 模式 3: 分布式协作模式

### 基本结构

```
Agent A ←→ Agent B ←→ Agent C
    ↘         ↙       ↖
      协调层 (Coordinator)
```

### 实现

```python
class MultiAgentSystem:
    def __init__(self):
        self.agents = {}
        self.coordinator = Coordinator()

    def add_agent(self, name, agent):
        self.agents[name] = agent

    async def solve(self, problem):
        # 1. 协调器分析问题
        subproblems = await self.coordinator.decompose(problem)

        # 2. 分配给专门 Agent
        assignments = self.coordinator.assign(subproblems, self.agents)

        # 3. 并行执行
        results = await asyncio.gather(*[
            self.agents[agent].solve(task)
            for agent, task in assignments.items()
        ])

        # 4. 整合结果
        return self.coordinator.integrate(results)

class Coordinator:
    """协调 Agent 之间的协作"""

    async def decompose(self, problem):
        """将问题分解为子问题"""
        # 使用 LLM 分析问题结构
        return ["子问题1", "子问题2", "子问题3"]

    def assign(self, subproblems, agents):
        """根据能力分配任务"""
        assignments = {}
        for i, problem in enumerate(subproblems):
            agent_name = list(agents.keys())[i % len(agents)]
            assignments[agent_name] = problem
        return assignments

    def integrate(self, results):
        """整合多个 Agent 的结果"""
        # 使用 LLM 综合多个结果
        return f"综合结果: {results}"
```

### 协作模式

**1. 协作 (Collaboration)**
```python
# 多个 Agent 共同完成目标
await asyncio.gather(
    agent_a.research(),
    agent_b.write(),
    agent_c.review()
)
```

**2. 竞争 (Competition)**
```python
# 多个 Agent 竞争,选出最好的
results = await asyncio.gather(*[
    agent.solve(problem) for agent in agents
])
best = max(results, key=lambda r: r.score)
```

**3. 协商 (Negotiation)**
```python
# Agent 之间协商达成一致
agreement = await negotiate(agents, proposal)
```

### 应用场景

- **并行处理**: 多个 Agent 同时处理不同部分
- **专家系统**: 不同 Agent 专精不同领域
- **容错系统**: 多个 Agent 验证同一结果

## 3.5 模式 4: 记忆增强模式

### 基本结构

```
查询 → 向量检索 → 上下文注入 → 生成
```

### RAG 实现

```python
class MemoryAugmentedAgent:
    def __init__(self):
        self.vector_db = VectorDB()
        self.llm = LLM()

    async def query(self, question: str):
        # 1. 检索相关记忆
        relevant_docs = await self.vector_db.search(
            question,
            top_k=5
        )

        # 2. 构建增强提示
        prompt = f"""
        使用以下信息回答问题:

        相关信息:
        {format_docs(relevant_docs)}

        问题: {question}
        """

        # 3. 生成回答
        answer = await self.llm.generate(prompt)

        # 4. 更新记忆
        await self.vector_db.add({
            "question": question,
            "answer": answer,
            "timestamp": now()
        })

        return answer
```

### 记忆类型

**1. 短期记忆 (Working Memory)**
```python
class ShortTermMemory:
    def __init__(self, size=10):
        self.buffer = deque(maxlen=size)

    def add(self, item):
        self.buffer.append(item)

    def get_recent(self, n=5):
        return list(self.buffer)[-n:]
```

**2. 长期记忆 (Long-term Memory)**
```python
class LongTermMemory:
    def __init__(self):
        self.vector_db = VectorDB()
        self.key_value_db = KVStore()

    async def store(self, memory):
        # 向量化
        embedding = await self.embed(memory)
        # 存储
        await self.vector_db.add(embedding, memory)

    async def retrieve(self, query, top_k=5):
        embedding = await self.embed(query)
        return await self.vector_db.search(embedding, top_k)
```

**3. 程序性记忆 (Procedural Memory)**
```python
class ProceduralMemory:
    """存储技能和工具"""

    def __init__(self):
        self.skills = {}  # 技能库
        self.tools = {}   # 工具库

    def learn_skill(self, name, implementation):
        """学习新技能"""
        self.skills[name] = implementation

    def use_tool(self, name, *args):
        """使用工具"""
        return self.tools[name](*args)
```

### 应用场景

- **知识问答**: RAG 系统常见场景
- **对话系统**: 维护对话历史
- **个人助理**: 记住用户偏好
- **代码助手**: 记住代码模式和最佳实践

## 3.6 模式组合

### 实际 Agent 都是模式组合

**例子: Coding Agent**

```python
class CodingAgent:
    """组合多种模式"""

    def __init__(self):
        # 模式1: 循环处理
        self.loop = ReActLoop()

        # 模式2: 分层决策
        self.hierarchy = HierarchicalPlanner()

        # 模式3: 记忆增强
        self.memory = MemorySystem()

        # 模式4: (可选) 分布式
        # self.multi_agent = MultiAgentSystem()

    async def solve(self, task):
        # 分层: 规划 → 执行
        plan = await self.hierarchy.plan(task)

        # 循环: 每个子任务
        results = []
        for subtask in plan:
            # 记忆增强: 检索相关代码
            context = await self.memory.retrieve(subtask)

            # ReAct: 思考-行动-观察
            result = await self.loop.run(subtask, context)
            results.append(result)

        # 记忆: 存储经验
        await self.memory.store(task, results)
        return results
```

### 组合策略

**1. 顺序组合**
```python
# 先模式A,后模式B
result = await mode_a(input)
result = await mode_b(result)
```

**2. 并行组合**
```python
# 同时使用多个模式
result_a, result_b = await asyncio.gather(
    mode_a(input),
    mode_b(input)
)
```

**3. 嵌套组合**
```python
# 模式A内部使用模式B
class CompositeAgent:
    async def run(self):
        # 外层: 循环
        while not done:
            # 内层: 分层
            strategy = await self.plan()
            tactics = await self.decompose(strategy)
            # 更内层: 记忆增强
            context = await self.retrieve(tactics)
```

## 3.7 练习

### 练习 1: 模式识别

识别以下 Agent 使用了哪些模式:
1. ChatGPT
2. AutoGPT
3. GitHub Copilot
4. 一个你设计的 Agent

### 练习 2: 模式组合

组合不同模式创建新 Agent:
- ReAct + RAG
- 分层 + 多 Agent
- 循环 + 记忆增强 + 分布式

### 练习 3: 实现

实现一个组合模式的 Agent:
- 选择至少 2 种模式
- 代码实现
- 测试功能

## 3.8 总结

### 关键要点

1. **4 种核心模式**: 循环、分层、分布式、记忆增强
2. **组合而非选择**: 实际 Agent 都是多种模式组合
3. **模块化设计**: 每种模式都可以独立实现和测试
4. **灵活组合**: 顺序、并行、嵌套

### 下一步

- [设计决策树](04-design-decision-tree.md) - 如何做设计决策
- [Layer 2: 案例解析](../layer-02-case-studies/) - 从真实项目中学习
