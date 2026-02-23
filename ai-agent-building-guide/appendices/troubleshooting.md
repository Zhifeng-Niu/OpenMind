# 故障排除

> 常见问题的诊断和解决方案

## 🎯 问题分类

```
问题类型
├── 性能问题 (慢、贵、效果差)
├── 行为问题 (循环、卡住、崩溃)
├── 集成问题 (API、工具、环境)
└── 设计问题 (架构、选择、权衡)
```

## ⚡ 性能问题

### 问题 1: 响应太慢

**症状**:
- 单次请求超过 30 秒
- 用户等待时间过长

**诊断**:
```python
import time

class PerformanceProfiler:
    def profile_agent(self, agent, task):
        timings = {}

        # 记录每个步骤的时间
        start = time.time()

        # 感知
        t1 = time.time()
        context = agent.perceive()
        timings["perceive"] = time.time() - t1

        # 决策
        t1 = time.time()
        decision = await agent.decide(context)
        timings["decide"] = time.time() - t1

        # 行动
        t1 = time.time()
        result = await agent.act(decision)
        timings["act"] = time.time() - t1

        timings["total"] = time.time() - start

        return timings

    def diagnose(self, timings):
        print("性能分析:")
        for step, duration in timings.items():
            percentage = (duration / timings["total"]) * 100
            print(f"  {step}: {duration:.2f}s ({percentage:.1f}%)")

        # 识别瓶颈
        bottleneck = max(timings.items(), key=lambda x: x[1])
        print(f"\n⚠️  瓶颈: {bottleneck[0]}")
```

**解决方案**:

1. **减少 LLM 调用**
```python
# ❌ 不好: 每步都调用 LLM
for item in items:
    result = await llm.generate(f"Process {item}")

# ✅ 好: 批量处理
batch_result = await llm.generate(f"Process: {items}")
```

2. **使用缓存**
```python
from functools import lru_cache

@lru_cache(maxsize=100)
async def cached_llm(prompt: str):
    return await llm.generate(prompt)
```

3. **并行执行**
```python
# ❌ 顺序
results = []
for task in tasks:
    result = await agent.run(task)
    results.append(result)

# ✅ 并行
results = await asyncio.gather(*[
    agent.run(task) for task in tasks
])
```

4. **选择更快模型**
```python
# 简单任务用小模型
if complexity < 0.3:
    model = "gpt-3.5-turbo"
else:
    model = "gpt-4"
```

---

### 问题 2: 成本太高

**症状**:
- Token 使用量过大
- API 费用超出预算

**诊断**:
```python
class CostTracker:
    def track_usage(self, agent):
        usage = {
            "input_tokens": [],
            "output_tokens": []
        }

        # Hook 到 LLM 调用
        original_generate = agent.llm.generate

        async def tracked_generate(prompt):
            result = await original_generate(prompt)
            usage["input_tokens"].append(result.usage.input_tokens)
            usage["output_tokens"].append(result.usage.output_tokens)
            return result

        agent.llm.generate = tracked_generate
        return usage

    def analyze(self, usage):
        total_input = sum(usage["input_tokens"])
        total_output = sum(usage["output_tokens"])

        print(f"Token 使用:")
        print(f"  Input: {total_input:,}")
        print(f"  Output: {total_output:,}")
        print(f"  Total: {total_input + total_output:,}")

        # 估算成本
        cost = (total_input * 0.0015 + total_output * 0.002) / 1000
        print(f"  成本: ${cost:.2f}")
```

**解决方案**:

1. **优化 Prompt**
```python
# ❌ 冗长
prompt = """
I would like you to please help me with the following task...
"""

# ✅ 简洁
prompt = "Task: ... \nOutput:"
```

2. **限制输出长度**
```python
result = await llm.generate(
    prompt,
    max_tokens=500  # 限制输出
)
```

3. **使用本地模型**
```python
# 简单任务用本地模型
if task.simple:
    result = local_llm.generate(prompt)
else:
    result = api_llm.generate(prompt)
```

---

### 问题 3: 效果不佳

**症状**:
- 答案不准确
- 频繁出现幻觉
- 任务完成率低

**诊断**:
```python
class QualityAnalyzer:
    def analyze_results(self, results, ground_truth):
        issues = {
            "hallucinations": [],
            "errors": [],
            "incomplete": []
        }

        for pred, truth in zip(results, ground_truth):
            # 检查幻觉
            if not self.verify_facts(pred, truth):
                issues["hallucinations"].append(pred)

            # 检查错误
            if pred != truth:
                issues["errors"].append((pred, truth))

            # 检查完整性
            if not self.is_complete(pred):
                issues["incomplete"].append(pred)

        return issues

    def print_report(self, issues):
        print(f"幻觉: {len(issues['hallucinations'])}")
        print(f"错误: {len(issues['errors'])}")
        print(f"未完成: {len(issues['incomplete'])}")
```

**解决方案**:

1. **改进 Prompt**
```python
# 添加 CoT
prompt = f"""
Let's think step by step.

{task}

Step 1:
"""

# 添加示例
prompt = f"""
Example:
Input: {example_input}
Output: {example_output}

Now:
Input: {task}
Output:
"""
```

2. **增加反思**
```python
async def self_reflect(agent, output):
    prompt = f"""
    Original Output: {output}

    Critique:
    1. Is it accurate?
    2. Is it complete?
    3. What could be improved?

    Improved Output:
    """
    return await agent.llm.generate(prompt)
```

3. **使用检索增强**
```python
# 先检索相关信息
context = await vector_db.search(query)

# 再生成
prompt = f"""
Context: {context}

Question: {query}

Answer:
"""
```

---

## 🔄 行为问题

### 问题 4: 陷入无限循环

**症状**:
- Agent 重复相同动作
- 无法完成目标

**诊断**:
```python
class LoopDetector:
    def __init__(self, max_repetitions=3):
        self.max_repetitions = max_repetitions
        self.history = []

    def check_loop(self, action):
        self.history.append(action)

        # 检查最近的动作
        recent = self.history[-self.max_repetitions:]

        if len(recent) == self.max_repetitions and len(set(recent)) == 1:
            return True  # 检测到循环

        return False

    def reset(self):
        self.history = []
```

**解决方案**:

1. **添加最大迭代限制**
```python
MAX_STEPS = 10

for step in range(MAX_STEPS):
    # ...
    if done:
        break
```

2. **检测重复状态**
```python
if loop_detector.check_loop(action):
    # 改变策略
    action = await agent.alternative_strategy()
```

3. **添加随机性**
```python
# 探索不同选项
actions = await agent.generate_actions()
action = random.choice(actions)
```

---

### 问题 5: Agent 卡住

**症状**:
- 长时间无响应
- CPU/内存使用正常但不产生输出

**诊断**:
```python
class HangDetector:
    def __init__(self, timeout=30):
        self.timeout = timeout

    async def run_with_timeout(self, coro):
        try:
            result = await asyncio.wait_for(coro, timeout=self.timeout)
            return result
        except asyncio.TimeoutError:
            print("⚠️  Agent 响应超时")
            return None
```

**解决方案**:

1. **设置超时**
```python
result = await asyncio.wait_for(
    agent.run(task),
    timeout=30.0
)
```

2. **添加心跳**
```python
async def run_with_heartbeat(agent, task):
    heartbeat = asyncio.create_task(send_heartbeat())

    try:
        result = await agent.run(task)
    finally:
        heartbeat.cancel()

    return result
```

---

## 🔌 集成问题

### 问题 6: API 调用失败

**症状**:
- 连接错误
- 认证失败
- 速率限制

**诊断**:
```python
class APIDiagnostics:
    async def test_connection(self, api_client):
        try:
            response = await api_client.test()
            print("✅ 连接正常")
            return True
        except ConnectionError:
            print("❌ 连接失败")
            return False
        except AuthenticationError:
            print("❌ 认证失败")
            return False
        except RateLimitError:
            print("❌ 速率限制")
            return False
```

**解决方案**:

1. **重试机制**
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10)
)
async def call_api_with_retry(prompt):
    return await api_client.generate(prompt)
```

2. **回退策略**
```python
async def call_with_fallback(primary, fallback, prompt):
    try:
        return await primary.generate(prompt)
    except Exception as e:
        print(f"Primary failed: {e}, using fallback")
        return await fallback.generate(prompt)
```

---

### 问题 7: 工具调用失败

**症状**:
- 工具返回错误
- 参数格式错误

**诊断**:
```python
class ToolValidator:
    def validate_tool_call(self, tool_name, args):
        # 检查工具存在
        if tool_name not in available_tools:
            return False, f"Tool {tool_name} not found"

        # 检查参数
        tool_schema = get_tool_schema(tool_name)
        if not self.validate_args(args, tool_schema):
            return False, "Invalid arguments"

        return True, "OK"
```

**解决方案**:

1. **参数验证**
```python
def validate_args(args, schema):
    # 使用 JSON Schema 验证
    from jsonschema import validate

    try:
        validate(instance=args, schema=schema)
        return True
    except ValidationError as e:
        print(f"参数验证失败: {e}")
        return False
```

2. **错误处理**
```python
async def safe_tool_call(tool, args):
    try:
        return await tool.execute(**args)
    except Exception as e:
        return {
            "error": str(e),
            "tool": tool.name,
            "args": args
        }
```

---

## 🏗️ 设计问题

### 问题 8: 架构选择困难

**症状**:
- 不确定使用哪种架构
- 在多个方案间犹豫

**决策树**:
```
任务复杂度?
├─ 简单 → ReAct
├─ 中等 → ReAct + Reflection
└─ 复杂 → 递归分解

需要记忆?
├─ 短期 → 列表
├─ 中期 → 向量数据库
└─ 长期 → 知识图谱

多 Agent?
├─ 独立任务 → 并行
├─ 依赖任务 → 层级
└─ 协作任务 → 协商
```

---

### 问题 9: 参数调优困难

**症状**:
- 不确定最优参数
- 调参效果不明显

**方法**:

1. **网格搜索**
```python
for temp in [0.1, 0.5, 1.0, 1.5]:
    for top_p in [0.8, 0.9, 1.0]:
        score = evaluate(temp, top_p)
        print(f"{temp}, {top_p}: {score}")
```

2. **贝叶斯优化**
```python
from skopt import gp_minimize

def objective(params):
    temp, top_p = params
    return -evaluate(temp, top_p)  # 最小化负分数

result = gp_minimize(
    objective,
    [(0.0, 2.0), (0.5, 1.0)],  # 参数范围
    n_calls=20
)
```

---

## 📊 调试工具

### 综合诊断工具

```python
class AgentDebugger:
    def __init__(self, agent):
        self.agent = agent
        self.metrics = {
            "performance": PerformanceProfiler(),
            "cost": CostTracker(),
            "quality": QualityAnalyzer()
        }

    async def diagnose(self, test_task):
        print("=== Agent 诊断报告 ===\n")

        # 性能
        print("1. 性能分析")
        timings = self.metrics["performance"].profile_agent(
            self.agent, test_task
        )
        self.metrics["performance"].diagnose(timings)

        # 成本
        print("\n2. 成本分析")
        usage = self.metrics["cost"].track_usage(self.agent)
        result = await self.agent.run(test_task)
        self.metrics["cost"].analyze(usage)

        # 质量
        print("\n3. 质量分析")
        # ... 需要测试集

        return {
            "timings": timings,
            "usage": usage
        }
```

---

## 📚 常见错误模式

### ❌ 错误 1: 过度设计

```
问题: 简单任务用了复杂架构
解决: 从简单开始,逐步增加复杂度
```

### ❌ 错误 2: 忽略评估

```
问题: 不评估就认为有效
解决: 始终用测试集验证
```

### ❌ 错误 3: 过度优化

```
问题: 在测试集上调参导致过拟合
解决: 使用验证集调参,测试集只用于最终评估
```

### ❌ 错误 4: 忽视成本

```
问题: 只关注效果不考虑成本
解决: 平衡效果和成本
```

---

## 🔍 快速检查清单

### 性能检查
- [ ] Profile 代码找瓶颈
- [ ] 减少不必要的 LLM 调用
- [ ] 使用缓存
- [ ] 考虑并行执行
- [ ] 选择合适的模型

### 行为检查
- [ ] 设置最大迭代
- [ ] 检测循环
- [ ] 添加超时
- [ ] 实现回退策略

### 质量检查
- [ ] 在测试集上评估
- [ ] 分析错误案例
- [ ] 添加反思机制
- [ ] 使用检索增强

### 集成检查
- [ ] 验证 API 连接
- [ ] 实现重试机制
- [ ] 处理错误响应
- [ ] 监控速率限制

## 📚 总结

### 调试原则

1. **隔离问题**: 一次只改一个变量
2. **度量优先**: 用数据而非感觉
3. **逐步增加**: 从简单开始
4. **记录一切**: 便于复现问题

### 获取帮助

- [术语表](glossary.md) - 理解关键术语
- [设计模式](../layer-02-case-studies/03-design-patterns.md) - 参考模式
- [实验方法](../layer-04-experimentation/02-experimental-methods.md) - 科学方法
