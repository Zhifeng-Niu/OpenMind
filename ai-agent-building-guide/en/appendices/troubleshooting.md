# Troubleshooting

> Diagnosis and solutions for common problems

## 🎯 Problem Classification

```
Problem Types
├── Performance Issues (slow, expensive, poor results)
├── Behavioral Issues (loops, stuck, crashes)
├── Integration Issues (API, tools, environment)
└── Design Issues (architecture, choices, trade-offs)
```

## ⚡ Performance Issues

### Problem 1: Response Too Slow

**Symptoms**:
- Single request exceeds 30 seconds
- User wait time too long

**Diagnosis**:
```python
import time

class PerformanceProfiler:
    def profile_agent(self, agent, task):
        timings = {}

        # Record time for each step
        start = time.time()

        # Perception
        t1 = time.time()
        context = agent.perceive()
        timings["perceive"] = time.time() - t1

        # Decision
        t1 = time.time()
        decision = await agent.decide(context)
        timings["decide"] = time.time() - t1

        # Action
        t1 = time.time()
        result = await agent.act(decision)
        timings["act"] = time.time() - t1

        timings["total"] = time.time() - start

        return timings

    def diagnose(self, timings):
        print("Performance Analysis:")
        for step, duration in timings.items():
            percentage = (duration / timings["total"]) * 100
            print(f"  {step}: {duration:.2f}s ({percentage:.1f}%)")

        # Identify bottleneck
        bottleneck = max(timings.items(), key=lambda x: x[1])
        print(f"\n⚠️  Bottleneck: {bottleneck[0]}")
```

**Solutions**:

1. **Reduce LLM Calls**
```python
# ❌ Bad: Call LLM for each step
for item in items:
    result = await llm.generate(f"Process {item}")

# ✅ Good: Batch processing
batch_result = await llm.generate(f"Process: {items}")
```

2. **Use Caching**
```python
from functools import lru_cache

@lru_cache(maxsize=100)
async def cached_llm(prompt: str):
    return await llm.generate(prompt)
```

3. **Parallel Execution**
```python
# ❌ Sequential
results = []
for task in tasks:
    result = await agent.run(task)
    results.append(result)

# ✅ Parallel
results = await asyncio.gather(*[
    agent.run(task) for task in tasks
])
```

4. **Choose Faster Models**
```python
# Use smaller models for simple tasks
if complexity < 0.3:
    model = "gpt-3.5-turbo"
else:
    model = "gpt-4"
```

---

### Problem 2: Cost Too High

**Symptoms**:
- Excessive token usage
- API costs exceeding budget

**Diagnosis**:
```python
class CostTracker:
    def track_usage(self, agent):
        usage = {
            "input_tokens": [],
            "output_tokens": []
        }

        # Hook into LLM calls
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

        print(f"Token Usage:")
        print(f"  Input: {total_input:,}")
        print(f"  Output: {total_output:,}")
        print(f"  Total: {total_input + total_output:,}")

        # Estimate cost
        cost = (total_input * 0.0015 + total_output * 0.002) / 1000
        print(f"  Cost: ${cost:.2f}")
```

**Solutions**:

1. **Optimize Prompts**
```python
# ❌ Verbose
prompt = """
I would like you to please help me with the following task...
"""

# ✅ Concise
prompt = "Task: ... \nOutput:"
```

2. **Limit Output Length**
```python
result = await llm.generate(
    prompt,
    max_tokens=500  # Limit output
)
```

3. **Use Local Models**
```python
# Use local models for simple tasks
if task.simple:
    result = local_llm.generate(prompt)
else:
    result = api_llm.generate(prompt)
```

---

### Problem 3: Poor Results

**Symptoms**:
- Inaccurate answers
- Frequent hallucinations
- Low task completion rate

**Diagnosis**:
```python
class QualityAnalyzer:
    def analyze_results(self, results, ground_truth):
        issues = {
            "hallucinations": [],
            "errors": [],
            "incomplete": []
        }

        for pred, truth in zip(results, ground_truth):
            # Check hallucinations
            if not self.verify_facts(pred, truth):
                issues["hallucinations"].append(pred)

            # Check errors
            if pred != truth:
                issues["errors"].append((pred, truth))

            # Check completeness
            if not self.is_complete(pred):
                issues["incomplete"].append(pred)

        return issues

    def print_report(self, issues):
        print(f"Hallucinations: {len(issues['hallucinations'])}")
        print(f"Errors: {len(issues['errors'])}")
        print(f"Incomplete: {len(issues['incomplete'])}")
```

**Solutions**:

1. **Improve Prompts**
```python
# Add CoT
prompt = f"""
Let's think step by step.

{task}

Step 1:
"""

# Add examples
prompt = f"""
Example:
Input: {example_input}
Output: {example_output}

Now:
Input: {task}
Output:
"""
```

2. **Add Reflection**
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

3. **Use Retrieval Augmentation**
```python
# First retrieve relevant information
context = await vector_db.search(query)

# Then generate
prompt = f"""
Context: {context}

Question: {query}

Answer:
"""
```

---

## 🔄 Behavioral Issues

### Problem 4: Stuck in Infinite Loop

**Symptoms**:
- Agent repeats same actions
- Cannot complete goal

**Diagnosis**:
```python
class LoopDetector:
    def __init__(self, max_repetitions=3):
        self.max_repetitions = max_repetitions
        self.history = []

    def check_loop(self, action):
        self.history.append(action)

        # Check recent actions
        recent = self.history[-self.max_repetitions:]

        if len(recent) == self.max_repetitions and len(set(recent)) == 1:
            return True  # Loop detected

        return False

    def reset(self):
        self.history = []
```

**Solutions**:

1. **Add Maximum Iteration Limit**
```python
MAX_STEPS = 10

for step in range(MAX_STEPS):
    # ...
    if done:
        break
```

2. **Detect Repeated States**
```python
if loop_detector.check_loop(action):
    # Change strategy
    action = await agent.alternative_strategy()
```

3. **Add Randomness**
```python
# Explore different options
actions = await agent.generate_actions()
action = random.choice(actions)
```

---

### Problem 5: Agent Stuck

**Symptoms**:
- No response for extended time
- CPU/memory usage normal but no output

**Diagnosis**:
```python
class HangDetector:
    def __init__(self, timeout=30):
        self.timeout = timeout

    async def run_with_timeout(self, coro):
        try:
            result = await asyncio.wait_for(coro, timeout=self.timeout)
            return result
        except asyncio.TimeoutError:
            print("⚠️  Agent response timeout")
            return None
```

**Solutions**:

1. **Set Timeout**
```python
result = await asyncio.wait_for(
    agent.run(task),
    timeout=30.0
)
```

2. **Add Heartbeat**
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

## 🔌 Integration Issues

### Problem 6: API Call Failures

**Symptoms**:
- Connection errors
- Authentication failures
- Rate limiting

**Diagnosis**:
```python
class APIDiagnostics:
    async def test_connection(self, api_client):
        try:
            response = await api_client.test()
            print("✅ Connection OK")
            return True
        except ConnectionError:
            print("❌ Connection failed")
            return False
        except AuthenticationError:
            print("❌ Authentication failed")
            return False
        except RateLimitError:
            print("❌ Rate limited")
            return False
```

**Solutions**:

1. **Retry Mechanism**
```python
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=1, min=2, max=10)
)
async def call_api_with_retry(prompt):
    return await api_client.generate(prompt)
```

2. **Fallback Strategy**
```python
async def call_with_fallback(primary, fallback, prompt):
    try:
        return await primary.generate(prompt)
    except Exception as e:
        print(f"Primary failed: {e}, using fallback")
        return await fallback.generate(prompt)
```

---

### Problem 7: Tool Call Failures

**Symptoms**:
- Tool returns errors
- Parameter format errors

**Diagnosis**:
```python
class ToolValidator:
    def validate_tool_call(self, tool_name, args):
        # Check tool exists
        if tool_name not in available_tools:
            return False, f"Tool {tool_name} not found"

        # Check parameters
        tool_schema = get_tool_schema(tool_name)
        if not self.validate_args(args, tool_schema):
            return False, "Invalid arguments"

        return True, "OK"
```

**Solutions**:

1. **Parameter Validation**
```python
def validate_args(args, schema):
    # Use JSON Schema validation
    from jsonschema import validate

    try:
        validate(instance=args, schema=schema)
        return True
    except ValidationError as e:
        print(f"Parameter validation failed: {e}")
        return False
```

2. **Error Handling**
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

## 🏗️ Design Issues

### Problem 8: Architecture Choice Difficulty

**Symptoms**:
- Unsure which architecture to use
- Hesitating between multiple approaches

**Decision Tree**:
```
Task Complexity?
├─ Simple → ReAct
├─ Medium → ReAct + Reflection
└─ Complex → Recursive Decomposition

Need Memory?
├─ Short-term → List
├─ Medium-term → Vector Database
└─ Long-term → Knowledge Graph

Multiple Agents?
├─ Independent Tasks → Parallel
├─ Dependent Tasks → Hierarchical
└─ Collaborative Tasks → Negotiation
```

---

### Problem 9: Parameter Tuning Difficulty

**Symptoms**:
- Unsure of optimal parameters
- Tuning effects not obvious

**Methods**:

1. **Grid Search**
```python
for temp in [0.1, 0.5, 1.0, 1.5]:
    for top_p in [0.8, 0.9, 1.0]:
        score = evaluate(temp, top_p)
        print(f"{temp}, {top_p}: {score}")
```

2. **Bayesian Optimization**
```python
from skopt import gp_minimize

def objective(params):
    temp, top_p = params
    return -evaluate(temp, top_p)  # Minimize negative score

result = gp_minimize(
    objective,
    [(0.0, 2.0), (0.5, 1.0)],  # Parameter ranges
    n_calls=20
)
```

---

## 📊 Debugging Tools

### Comprehensive Diagnostic Tool

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
        print("=== Agent Diagnostic Report ===\n")

        # Performance
        print("1. Performance Analysis")
        timings = self.metrics["performance"].profile_agent(
            self.agent, test_task
        )
        self.metrics["performance"].diagnose(timings)

        # Cost
        print("\n2. Cost Analysis")
        usage = self.metrics["cost"].track_usage(self.agent)
        result = await self.agent.run(test_task)
        self.metrics["cost"].analyze(usage)

        # Quality
        print("\n3. Quality Analysis")
        # ... needs test set

        return {
            "timings": timings,
            "usage": usage
        }
```

---

## 📚 Common Error Patterns

### ❌ Error 1: Over-Engineering

```
Problem: Simple task with complex architecture
Solution: Start simple, add complexity gradually
```

### ❌ Error 2: Ignoring Evaluation

```
Problem: Assuming effectiveness without evaluation
Solution: Always validate with test sets
```

### ❌ Error 3: Over-Optimization

```
Problem: Tuning on test set leads to overfitting
Solution: Use validation set for tuning, test set only for final evaluation
```

### ❌ Error 4: Ignoring Cost

```
Problem: Only focusing on results, not cost
Solution: Balance results and cost
```

---

## 🔍 Quick Checklist

### Performance Check
- [ ] Profile code to find bottlenecks
- [ ] Reduce unnecessary LLM calls
- [ ] Use caching
- [ ] Consider parallel execution
- [ ] Choose appropriate models

### Behavior Check
- [ ] Set maximum iterations
- [ ] Detect loops
- [ ] Add timeouts
- [ ] Implement fallback strategies

### Quality Check
- [ ] Evaluate on test sets
- [ ] Analyze error cases
- [ ] Add reflection mechanisms
- [ ] Use retrieval augmentation

### Integration Check
- [ ] Verify API connections
- [ ] Implement retry mechanisms
- [ ] Handle error responses
- [ ] Monitor rate limits

## 📚 Summary

### Debugging Principles

1. **Isolate Problems**: Change only one variable at a time
2. **Measure First**: Use data, not feelings
3. **Incremental Addition**: Start simple
4. **Record Everything**: For reproducibility

### Getting Help

- [Glossary](glossary.md) - Understand key terms
- [Design Patterns](../layer-02-case-studies/03-design-patterns.md) - Reference patterns
- [Experimental Methods](../layer-04-experimentation/02-experimental-methods.md) - Scientific methods
