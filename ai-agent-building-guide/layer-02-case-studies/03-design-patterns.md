# 设计模式目录

> 从案例中提取的可复用模式

## 🎯 模式分类

基于 10 个项目的深度分析,提取出以下设计模式:

```
架构模式 (4个)
├── 递归分解模式
├── 状态机模式
├── 沙箱执行模式
└── 进化优化模式

处理模式 (5个)
├── ReAct 循环
├── 反思改进
├── 多顾问反馈
├── 并行探索
└── 记忆巩固

协调模式 (3个)
├── 层级协调
├── 平等协商
└── 竞争淘汰

优化模式 (4个)
├── Prompt 优化
├── 模型路由
├── 缓存策略
└── 批处理
```

## 🏗️ 架构模式

### 模式 1: 递归分解 (Recursive Decomposition)

**来源**: AutoGPT

**问题**: 如何完成复杂的多步骤任务?

**解决方案**:
```
目标
  ↓
分解为子任务
  ↓
对每个子任务:
  ├─ 简单? → 直接执行
  └─ 复杂? → 递归分解
      ↓
  执行
      ↓
  验证
      ↓
  综合
```

**实现模板**:
```python
class RecursiveDecomposer:
    async def execute(self, goal: str):
        # 检查复杂度
        if self.is_simple(goal):
            return await self.execute_direct(goal)

        # 分解
        subtasks = await self.decompose(goal)

        # 执行子任务
        results = []
        for subtask in subtasks:
            result = await self.execute(subtask)
            results.append(result)

        # 综合
        return self.synthesize(results)

    def is_simple(self, goal: str) -> bool:
        # 评估复杂度
        return len(goal) < 100 and "and" not in goal

    async def decompose(self, goal: str) -> List[str]:
        # 使用 LLM 分解
        prompt = f"将以下目标分解为 3-5 个子任务: {goal}"
        result = await self.llm.generate(prompt)
        return parse_tasks(result)
```

**适用场景**:
- 复杂任务规划
- 需要灵活调整策略
- 子任务相对独立

**权衡**:
- ✅ 灵活性高
- ✅ 可以处理复杂任务
- ❌ 可能陷入无限分解
- ❌ 缺乏全局优化

**变体**:
- **固定深度分解**: 限制递归层数
- **并行分解**: 同时执行多个子任务
- **增量分解**: 根据执行情况动态调整

---

### 模式 2: 状态机 (State Machine)

**来源**: LangGraph

**问题**: 如何管理复杂的工作流?

**解决方案**:
```
状态 A
  ↓ [条件1]
状态 B ←─┐
  ↓       │
[条件2]    │
  ↓       │
状态 C ───┘
```

**实现模板**:
```python
from enum import Enum

class State(Enum):
    THINKING = "thinking"
    PLANNING = "planning"
    EXECUTING = "executing"
    REFLECTING = "reflecting"
    DONE = "done"

class StateMachineAgent:
    def __init__(self):
        self.state = State.THINKING
        self.transitions = {
            State.THINKING: {
                "has_plan": State.PLANNING,
                "needs_info": State.THINKING
            },
            State.PLANNING: {
                "plan_ready": State.EXECUTING,
                "plan_failed": State.THINKING
            },
            State.EXECUTING: {
                "success": State.REFLECTING,
                "failed": State.PLANNING
            },
            State.REFLECTING: {
                "satisfied": State.DONE,
                "needs_improvement": State.PLANNING
            }
        }

    async def step(self, context: Context):
        # 执行当前状态
        result = await self.execute_state(self.state, context)

        # 决定下一个状态
        next_state = self.transitions[self.state].get(result.condition)
        if next_state:
            self.state = next_state

        return result

    async def execute_state(self, state: State, context: Context):
        if state == State.THINKING:
            return await self.thinking(context)
        elif state == State.PLANNING:
            return await self.planning(context)
        # ...
```

**适用场景**:
- 复杂工作流
- 需要明确状态转换
- 需要可视化流程

**权衡**:
- ✅ 流程清晰
- ✅ 易于调试
- ✅ 可以可视化
- ❌ 状态可能爆炸
- ❌ 难以处理不确定性

**变体**:
- **层次状态机**: 状态可以包含子状态
- **并发状态机**: 多个状态机并行运行
- **概率状态机**: 状态转移有概率

---

### 模式 3: 沙箱执行 (Sandboxed Execution)

**来源**: OpenDevin

**问题**: 如何安全地执行不可信代码?

**解决方案**:
```
Agent
  ↓
生成代码
  ↓
沙箱环境
  ├─ Docker 容器
  ├─ 受限文件系统
  ├─ 受控网络
  └─ 资源限制
      ↓
  执行
      ↓
  观察结果
      ↓
  调试/修正
```

**实现模板**:
```python
class SandboxedExecutor:
    def __init__(self):
        self.container = None

    async def execute(self, code: str, timeout: int = 30):
        # 创建沙箱
        await self.create_sandbox()

        try:
            # 写入代码
            await self.write_code(code)

            # 执行 (带超时)
            result = await asyncio.wait_for(
                self.run_code(),
                timeout=timeout
            )

            return result

        except Exception as e:
            # 获取错误信息
            error = await self.get_error()
            return {"success": False, "error": error}

        finally:
            # 清理沙箱
            await self.cleanup()

    async def create_sandbox(self):
        # 使用 Docker 创建隔离环境
        self.container = await docker.containers.create(
            image="python:3.11",
            cpu_quota=100000,
            mem_limit="512m",
            network_mode="isolated"
        )
        await self.container.start()

    async def run_code(self):
        # 在容器中执行
        exec_result = await self.container.exec(
            f"python /workspace/main.py"
        )
        return exec_result.output
```

**适用场景**:
- 需要执行用户代码
- 需要测试生成的代码
- 需要隔离运行环境

**权衡**:
- ✅ 安全性高
- ✅ 可以限制资源
- ❌ 沙箱开销大
- ❌ 某些操作受限

**变体**:
- **进程沙箱**: 使用进程隔离
- **虚拟机沙箱**: 使用 VM
- **Web 沙箱**: 浏览器隔离

---

### 模式 4: 进化优化 (Evolutionary Optimization)

**来源**: EvoAgentX

**问题**: 如何自动找到最优架构?

**解决方案**:
```
初始化种群
  ↓
评估适应度
  ↓
选择 (Selection)
  ↓
交叉 (Crossover)
  ↓
变异 (Mutation)
  ↓
新一代
  ↓
[重复]
```

**实现模板**:
```python
class EvolutionaryOptimizer:
    def __init__(self, population_size=20, generations=50):
        self.population_size = population_size
        self.generations = generations

    async def optimize(self, task: Task):
        # 1. 初始化种群
        population = self.initialize_population()

        best = None

        for gen in range(self.generations):
            # 2. 评估适应度
            fitness = await self.evaluate(population, task)

            # 3. 记录最优
            generation_best = max(
                zip(population, fitness),
                key=lambda x: x[1]
            )
            if not best or generation_best[1] > best[1]:
                best = generation_best

            # 4. 选择
            selected = self.select(population, fitness)

            # 5. 交叉
            offspring = self.crossover(selected)

            # 6. 变异
            self.mutate(offspring)

            # 7. 更新种群
            population = selected + offspring

        return best[0]

    def select(self, population, fitness):
        # 锦标赛选择
        selected = []
        for _ in range(len(population) // 2):
            # 随机选 3 个,取最优
            candidates = random.sample(
                list(zip(population, fitness)), 3
            )
            winner = max(candidates, key=lambda x: x[1])
            selected.append(winner[0])
        return selected

    def crossover(self, parents):
        offspring = []
        for i in range(0, len(parents), 2):
            parent1, parent2 = parents[i], parents[i+1]
            # 单点交叉
            point = random.randint(1, len(parent1)-1)
            child1 = parent1[:point] + parent2[point:]
            child2 = parent2[:point] + parent1[point:]
            offspring.extend([child1, child2])
        return offspring

    def mutate(self, population):
        for individual in population:
            if random.random() < 0.1:  # 10% 变异率
                # 随机修改一个基因
                idx = random.randint(0, len(individual)-1)
                individual[idx] = self.random_gene()
```

**适用场景**:
- 架构空间巨大
- 没有明确设计规则
- 需要探索多种可能

**权衡**:
- ✅ 自动化搜索
- ✅ 可以跳出局部最优
- ❌ 计算成本高
- ❌ 收敛速度慢

**变体**:
- **遗传编程**: 进化程序树
- **神经架构搜索**: 进化神经网络
- **多目标进化**: 优化多个目标

---

## 🔄 处理模式

### 模式 5: ReAct 循环 (ReAct Loop)

**来源**: 通用模式

**问题**: 如何结合推理和行动?

**解决方案**:
```
Observation (观察)
  ↓
Thought (思考)
  ↓
Action (行动)
  ↓
Observation (观察)
  ↓
[循环]
```

**实现模板**:
```python
class ReActAgent:
    async def run(self, task: str):
        observation = f"Task: {task}"
        history = []

        for step in range(self.max_steps):
            # 推理
            thought = await self.think(observation, history)

            # 行动
            action = await self.decide_action(thought)

            if action.type == "finish":
                return action.result

            # 执行
            observation = await self.execute(action)

            # 记录
            history.append({
                "thought": thought,
                "action": action,
                "observation": observation
            })

    async def think(self, observation: str, history: List):
        prompt = f"""
        Observation: {observation}
        History: {history}

        What should I do next?
        Thought:"""

        return await self.llm.generate(prompt)

    async def decide_action(self, thought: str):
        # 解析行动
        if "finish" in thought.lower():
            return Action(type="finish")
        elif "search" in thought.lower():
            query = extract_query(thought)
            return Action(type="search", query=query)
        # ...
```

**适用场景**:
- 需要多步推理
- 需要使用工具
- 任务相对简单

**权衡**:
- ✅ 简单直观
- ✅ 易于实现
- ❌ 可能陷入循环
- ❌ 缺乏长期规划

---

### 模式 6: 反思改进 (Reflection and Improvement)

**来源**: Spring AI, Reflexion

**问题**: 如何提升输出质量?

**解决方案**:
```
生成输出
  ↓
自我反思
  ↓
发现问题
  ↓
生成改进
  ↓
[重复直到满意]
```

**实现模板**:
```python
class ReflectiveAgent:
    async def execute(self, task: str):
        output = await self.generate(task)

        for iteration in range(self.max_iterations):
            # 反思
            feedback = await self.reflect(output, task)

            # 评估
            score = await self.evaluate(output, task)

            if score > self.threshold:
                break

            # 改进
            output = await self.improve(output, feedback)

        return output

    async def reflect(self, output: str, task: str):
        prompt = f"""
        Task: {task}
        Output: {output}

        Critique the output:
        1. What's good?
        2. What's missing?
        3. What could be improved?
        """

        return await self.llm.generate(prompt)

    async def improve(self, output: str, feedback: str):
        prompt = f"""
        Original Output: {output}
        Feedback: {feedback}

        Improve the output based on the feedback.
        """

        return await self.llm.generate(prompt)
```

**适用场景**:
- 输出质量要求高
- 可以接受额外延迟
- 有明确的评估标准

**权衡**:
- ✅ 提升质量
- ✅ 自我修正
- ❌ 增加延迟
- ❌ 可能过度优化

---

### 模式 7: 多顾问反馈 (Multi-Advisor Feedback)

**来源**: Spring AI

**问题**: 如何从多角度评估输出?

**解决方案**:
```
输出
  ↓
顾问1评估 → 反馈1
  ↓
顾问2评估 → 反馈2
  ↓
顾问3评估 → 反馈3
  ↓
整合反馈
  ↓
生成改进版本
```

**实现模板**:
```python
class MultiAdvisorSystem:
    def __init__(self):
        self.advisors = [
            ConsistencyAdvisor(),
            FactCheckAdvisor(),
            ClarityAdvisor(),
            CompletenessAdvisor(),
            SafetyAdvisor()
        ]

    async def process(self, task: str):
        # 生成初始输出
        output = await self.generate(task)

        # 依次调用顾问
        all_feedback = []
        for advisor in self.advisors:
            feedback = await advisor.evaluate(output, task)
            all_feedback.append(feedback)

            # 如果需要改进
            if feedback.needs_revision:
                output = await self.revise(output, feedback)

        return output, all_feedback

class ConsistencyAdvisor:
    async def evaluate(self, output: str, task: str):
        prompt = f"""
        Check for logical inconsistencies in:
        {output}

        Output JSON:
        {{
            "needs_revision": true/false,
            "issues": ["issue1", "issue2"],
            "suggestions": ["suggestion1"]
        }}
        """

        result = await self.llm.generate(prompt)
        return json.loads(result)
```

**适用场景**:
- 需要多角度验证
- 输出质量要求高
- 可以接受高延迟

**权衡**:
- ✅ 全面评估
- ✅ 提升质量
- ❌ 延迟高
- ❌ 顾问可能冲突

---

## 🤝 协调模式

### 模式 8: 层级协调 (Hierarchical Coordination)

**问题**: 如何协调多个 Agent?

**解决方案**:
```
Manager (管理器)
  ├─ Agent 1 (执行者)
  ├─ Agent 2 (执行者)
  └─ Agent 3 (执行者)
```

**实现模板**:
```python
class HierarchicalCoordinator:
    def __init__(self):
        self.manager = ManagerAgent()
        self.workers = [
            WorkerAgent("worker1"),
            WorkerAgent("worker2"),
            WorkerAgent("worker3")
        ]

    async def execute(self, goal: str):
        # 管理器分解任务
        subtasks = await self.manager.decompose(goal)

        # 分配任务
        assignments = await self.manager.assign(
            subtasks,
            self.workers
        )

        # 并行执行
        results = await asyncio.gather(*[
            worker.execute(task)
            for worker, task in assignments
        ])

        # 管理器综合结果
        return await self.manager.synthesize(results)
```

---

## ⚡ 优化模式

### 模式 9: Prompt 优化 (Prompt Optimization)

**问题**: 如何找到最优 Prompt?

**解决方案**: 使用多臂赌博机算法

**实现模板**:
```python
class PromptOptimizer:
    def __init__(self, templates: List[str]):
        self.templates = templates
        self.scores = [0.0] * len(templates)
        self.counts = [0] * len(templates)

    async def optimize(self, task: str, iterations=100):
        for _ in range(iterations):
            # 选择 Prompt (UCB 算法)
            idx = self.select_prompt()

            # 执行
            result = await self.execute(
                self.templates[idx],
                task
            )

            # 更新分数
            self.scores[idx] += result.score
            self.counts[idx] += 1

        # 返回最优
        best_idx = np.argmax([
            s / c if c > 0 else 0
            for s, c in zip(self.scores, self.counts)
        ])
        return self.templates[best_idx]

    def select_prompt(self):
        # Upper Confidence Bound
        total = sum(self.counts)
        ucb_values = []

        for i in range(len(self.templates)):
            if self.counts[i] == 0:
                return i  # 未尝试过

            avg = self.scores[i] / self.counts[i]
            exploration = sqrt(2 * log(total) / self.counts[i])
            ucb = avg + exploration
            ucb_values.append(ucb)

        return np.argmax(ucb_values)
```

---

### 模式 10: 模型路由 (Model Routing)

**问题**: 如何选择合适的模型?

**解决方案**: 根据任务特征智能路由

**实现模板**:
```python
class ModelRouter:
    def __init__(self):
        self.models = {
            "fast": CheapModel(),
            "balanced": MediumModel(),
            "quality": ExpensiveModel()
        }

    async def route(self, task: str, priority: str):
        # 分析任务
        complexity = self.assess_complexity(task)

        # 根据优先级和复杂度选择
        if priority == "speed":
            return self.models["fast"]
        elif priority == "quality":
            if complexity > 0.8:
                return self.models["quality"]
            else:
                return self.models["balanced"]
        else:  # cost
            return self.models["fast"]

    def assess_complexity(self, task: str) -> float:
        # 基于规则 + LLM
        score = 0.0
        score += len(task) / 1000
        score += 0.2 if "code" in task else 0
        score += 0.3 if "analyze" in task else 0
        return min(score, 1.0)
```

---

## 📊 模式对比

| 模式 | 复杂度 | 灵活性 | 适用场景 | 成本 |
|------|--------|--------|----------|------|
| 递归分解 | 中 | 高 | 复杂任务 | 中 |
| 状态机 | 低 | 低 | 固定流程 | 低 |
| 沙箱执行 | 高 | 中 | 代码执行 | 高 |
| 进化优化 | 高 | 高 | 架构搜索 | 很高 |
| ReAct | 低 | 中 | 简单任务 | 低 |
| 反思改进 | 中 | 中 | 质量优化 | 中 |
| 多顾问 | 中 | 低 | 严格验证 | 高 |
| 层级协调 | 中 | 中 | 多 Agent | 中 |
| Prompt 优化 | 中 | 高 | Prompt 调优 | 中 |
| 模型路由 | 低 | 中 | 成本优化 | 低 |

## 💡 模式组合

### 组合 1: ReAct + 反思

```
ReAct 循环
  ↓
每步后反思
  ↓
如果问题多 → 重新规划
```

### 组合 2: 递归分解 + 多 Agent

```
递归分解
  ↓
每个子任务分配给不同 Agent
  ↓
层级协调
```

### 组合 3: 进化 + 反思

```
进化优化架构
  ↓
每个架构用反思改进
  ↓
选择最优
```

## 📚 总结

### 使用原则

1. **从简单开始**: ReAct、反思等简单模式优先
2. **按需选择**: 根据问题选择合适的模式
3. **灵活组合**: 不要拘泥于单一模式
4. **持续优化**: 根据效果调整模式

### 模式选择流程

```
问题类型?
├─ 简单任务 → ReAct
├─ 复杂任务 → 递归分解
├─ 需要验证 → 反思/多顾问
├─ 代码执行 → 沙箱
├─ 架构设计 → 进化
└─ 多 Agent → 层级协调
```

### 下一步

- [Layer 3: 构建块库](../layer-03-building-blocks/) - 应用这些模式
- [实验案例](../layer-04-experimentation/07-case-demos.md) - 查看实际应用
