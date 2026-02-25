# Design Patterns Catalog

> Reusable patterns extracted from cases

## 🎯 Pattern Classification

Based on in-depth analysis of 10 projects, the following design patterns were extracted:

```
Architecture Patterns (4)
├── Recursive Decomposition Pattern
├── State Machine Pattern
├── Sandbox Execution Pattern
└── Evolutionary Optimization Pattern

Processing Patterns (5)
├── ReAct Loop
├── Reflection and Improvement
├── Multi-Advisor Feedback
├── Parallel Exploration
└── Memory Consolidation

Coordination Patterns (3)
├── Hierarchical Coordination
├── Equal Negotiation
└── Competitive Elimination

Optimization Patterns (4)
├── Prompt Optimization
├── Model Routing
├── Caching Strategy
└── Batch Processing
```

## 🏗️ Architecture Patterns

### Pattern 1: Recursive Decomposition

**Source**: AutoGPT

**Problem**: How to complete complex multi-step tasks?

**Solution**:
```
Goal
  ↓
Decompose into subtasks
  ↓
For each subtask:
  ├─ Simple? → Execute directly
  └─ Complex? → Recursive decomposition
      ↓
  Execute
      ↓
  Validate
      ↓
  Synthesize
```

**Implementation Template**:
```python
class RecursiveDecomposer:
    async def execute(self, goal: str):
        # Check complexity
        if self.is_simple(goal):
            return await self.execute_direct(goal)

        # Decompose
        subtasks = await self.decompose(goal)

        # Execute subtasks
        results = []
        for subtask in subtasks:
            result = await self.execute(subtask)
            results.append(result)

        # Synthesize
        return self.synthesize(results)

    def is_simple(self, goal: str) -> bool:
        # Evaluate complexity
        return len(goal) < 100 and "and" not in goal

    async def decompose(self, goal: str) -> List[str]:
        # Use LLM to decompose
        prompt = f"Decompose the following goal into 3-5 subtasks: {goal}"
        result = await self.llm.generate(prompt)
        return parse_tasks(result)
```

**Applicable Scenarios**:
- Complex task planning
- Need flexible strategy adjustment
- Subtasks are relatively independent

**Tradeoffs**:
- ✅ High flexibility
- ✅ Can handle complex tasks
- ❌ May fall into infinite decomposition
- ❌ Lack of global optimization

**Variants**:
- **Fixed-depth decomposition**: Limit recursion depth
- **Parallel decomposition**: Execute multiple subtasks simultaneously
- **Incremental decomposition**: Dynamically adjust based on execution

---

### Pattern 2: State Machine

**Source**: LangGraph

**Problem**: How to manage complex workflows?

**Solution**:
```
State A
  ↓ [condition1]
State B ←─┐
  ↓       │
[condition2]
  ↓       │
State C ───┘
```

**Implementation Template**:
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
        # Execute current state
        result = await self.execute_state(self.state, context)

        # Decide next state
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

**Applicable Scenarios**:
- Complex workflows
- Need clear state transitions
- Need visualizable processes

**Tradeoffs**:
- ✅ Clear process
- ✅ Easy to debug
- ✅ Can be visualized
- ❌ State explosion possible
- ❌ Difficult to handle uncertainty

**Variants**:
- **Hierarchical state machine**: States can contain substates
- **Concurrent state machine**: Multiple state machines run in parallel
- **Probabilistic state machine**: State transitions have probabilities

---

### Pattern 3: Sandboxed Execution

**Source**: OpenDevin

**Problem**: How to safely execute untrusted code?

**Solution**:
```
Agent
  ↓
Generate code
  ↓
Sandbox environment
  ├─ Docker container
  ├─ Restricted filesystem
  ├─ Controlled network
  └─ Resource limits
      ↓
  Execute
      ↓
  Observe results
      ↓
  Debug/Fix
```

**Implementation Template**:
```python
class SandboxedExecutor:
    def __init__(self):
        self.container = None

    async def execute(self, code: str, timeout: int = 30):
        # Create sandbox
        await self.create_sandbox()

        try:
            # Write code
            await self.write_code(code)

            # Execute (with timeout)
            result = await asyncio.wait_for(
                self.run_code(),
                timeout=timeout
            )

            return result

        except Exception as e:
            # Get error message
            error = await self.get_error()
            return {"success": False, "error": error}

        finally:
            # Cleanup sandbox
            await self.cleanup()

    async def create_sandbox(self):
        # Create isolated environment using Docker
        self.container = await docker.containers.create(
            image="python:3.11",
            cpu_quota=100000,
            mem_limit="512m",
            network_mode="isolated"
        )
        await self.container.start()

    async def run_code(self):
        # Execute in container
        exec_result = await self.container.exec(
            f"python /workspace/main.py"
        )
        return exec_result.output
```

**Applicable Scenarios**:
- Need to execute user code
- Need to test generated code
- Need isolated runtime environment

**Tradeoffs**:
- ✅ High security
- ✅ Can limit resources
- ❌ High sandbox overhead
- ❌ Some operations restricted

**Variants**:
- **Process sandbox**: Use process isolation
- **VM sandbox**: Use VM
- **Web sandbox**: Browser isolation

---

### Pattern 4: Evolutionary Optimization

**Source**: EvoAgentX

**Problem**: How to automatically find optimal architecture?

**Solution**:
```
Initialize population
  ↓
Evaluate fitness
  ↓
Selection
  ↓
Crossover
  ↓
Mutation
  ↓
New generation
  ↓
[Repeat]
```

**Implementation Template**:
```python
class EvolutionaryOptimizer:
    def __init__(self, population_size=20, generations=50):
        self.population_size = population_size
        self.generations = generations

    async def optimize(self, task: Task):
        # 1. Initialize population
        population = self.initialize_population()

        best = None

        for gen in range(self.generations):
            # 2. Evaluate fitness
            fitness = await self.evaluate(population, task)

            # 3. Record best
            generation_best = max(
                zip(population, fitness),
                key=lambda x: x[1]
            )
            if not best or generation_best[1] > best[1]:
                best = generation_best

            # 4. Selection
            selected = self.select(population, fitness)

            # 5. Crossover
            offspring = self.crossover(selected)

            # 6. Mutation
            self.mutate(offspring)

            # 7. Update population
            population = selected + offspring

        return best[0]

    def select(self, population, fitness):
        # Tournament selection
        selected = []
        for _ in range(len(population) // 2):
            # Randomly select 3, take best
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
            # Single-point crossover
            point = random.randint(1, len(parent1)-1)
            child1 = parent1[:point] + parent2[point:]
            child2 = parent2[:point] + parent1[point:]
            offspring.extend([child1, child2])
        return offspring

    def mutate(self, population):
        for individual in population:
            if random.random() < 0.1:  # 10% mutation rate
                # Randomly modify a gene
                idx = random.randint(0, len(individual)-1)
                individual[idx] = self.random_gene()
```

**Applicable Scenarios**:
- Huge architecture space
- No clear design rules
- Need to explore multiple possibilities

**Tradeoffs**:
- ✅ Automated search
- ✅ Can escape local optima
- ❌ High computational cost
- ❌ Slow convergence

**Variants**:
- **Genetic programming**: Evolve program trees
- **Neural architecture search**: Evolve neural networks
- **Multi-objective evolution**: Optimize multiple objectives

---

## 🔄 Processing Patterns

### Pattern 5: ReAct Loop

**Source**: Universal pattern

**Problem**: How to combine reasoning and action?

**Solution**:
```
Observation
  ↓
Thought
  ↓
Action
  ↓
Observation
  ↓
[Loop]
```

**Implementation Template**:
```python
class ReActAgent:
    async def run(self, task: str):
        observation = f"Task: {task}"
        history = []

        for step in range(self.max_steps):
            # Reasoning
            thought = await self.think(observation, history)

            # Action
            action = await self.decide_action(thought)

            if action.type == "finish":
                return action.result

            # Execute
            observation = await self.execute(action)

            # Record
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
        # Parse action
        if "finish" in thought.lower():
            return Action(type="finish")
        elif "search" in thought.lower():
            query = extract_query(thought)
            return Action(type="search", query=query)
        # ...
```

**Applicable Scenarios**:
- Need multi-step reasoning
- Need to use tools
- Tasks are relatively simple

**Tradeoffs**:
- ✅ Simple and intuitive
- ✅ Easy to implement
- ❌ May fall into loops
- ❌ Lack of long-term planning

---

### Pattern 6: Reflection and Improvement

**Source**: Spring AI, Reflexion

**Problem**: How to improve output quality?

**Solution**:
```
Generate output
  ↓
Self-reflection
  ↓
Identify issues
  ↓
Generate improvements
  ↓
[Repeat until satisfied]
```

**Implementation Template**:
```python
class ReflectiveAgent:
    async def execute(self, task: str):
        output = await self.generate(task)

        for iteration in range(self.max_iterations):
            # Reflect
            feedback = await self.reflect(output, task)

            # Evaluate
            score = await self.evaluate(output, task)

            if score > self.threshold:
                break

            # Improve
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

**Applicable Scenarios**:
- High output quality requirements
- Can accept extra latency
- Have clear evaluation criteria

**Tradeoffs**:
- ✅ Improve quality
- ✅ Self-correction
- ❌ Increase latency
- ❌ May over-optimize

---

### Pattern 7: Multi-Advisor Feedback

**Source**: Spring AI

**Problem**: How to evaluate output from multiple perspectives?

**Solution**:
```
Output
  ↓
Advisor1 evaluation → Feedback1
  ↓
Advisor2 evaluation → Feedback2
  ↓
Advisor3 evaluation → Feedback3
  ↓
Consolidate feedback
  ↓
Generate improved version
```

**Implementation Template**:
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
        # Generate initial output
        output = await self.generate(task)

        # Call advisors sequentially
        all_feedback = []
        for advisor in self.advisors:
            feedback = await advisor.evaluate(output, task)
            all_feedback.append(feedback)

            # If improvement needed
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

**Applicable Scenarios**:
- Need multi-perspective verification
- High output quality requirements
- Can accept high latency

**Tradeoffs**:
- ✅ Comprehensive evaluation
- ✅ Improve quality
- ❌ High latency
- ❌ Advisors may conflict

---

## 🤝 Coordination Patterns

### Pattern 8: Hierarchical Coordination

**Problem**: How to coordinate multiple Agents?

**Solution**:
```
Manager
  ├─ Agent 1 (Worker)
  ├─ Agent 2 (Worker)
  └─ Agent 3 (Worker)
```

**Implementation Template**:
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
        # Manager decomposes task
        subtasks = await self.manager.decompose(goal)

        # Assign tasks
        assignments = await self.manager.assign(
            subtasks,
            self.workers
        )

        # Execute in parallel
        results = await asyncio.gather(*[
            worker.execute(task)
            for worker, task in assignments
        ])

        # Manager synthesizes results
        return await self.manager.synthesize(results)
```

---

## ⚡ Optimization Patterns

### Pattern 9: Prompt Optimization

**Problem**: How to find optimal Prompts?

**Solution**: Use multi-armed bandit algorithms

**Implementation Template**:
```python
class PromptOptimizer:
    def __init__(self, templates: List[str]):
        self.templates = templates
        self.scores = [0.0] * len(templates)
        self.counts = [0] * len(templates)

    async def optimize(self, task: str, iterations=100):
        for _ in range(iterations):
            # Select Prompt (UCB algorithm)
            idx = self.select_prompt()

            # Execute
            result = await self.execute(
                self.templates[idx],
                task
            )

            # Update score
            self.scores[idx] += result.score
            self.counts[idx] += 1

        # Return best
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
                return i  # Not tried yet

            avg = self.scores[i] / self.counts[i]
            exploration = sqrt(2 * log(total) / self.counts[i])
            ucb = avg + exploration
            ucb_values.append(ucb)

        return np.argmax(ucb_values)
```

---

### Pattern 10: Model Routing

**Problem**: How to choose the appropriate model?

**Solution**: Intelligently route based on task characteristics

**Implementation Template**:
```python
class ModelRouter:
    def __init__(self):
        self.models = {
            "fast": CheapModel(),
            "balanced": MediumModel(),
            "quality": ExpensiveModel()
        }

    async def route(self, task: str, priority: str):
        # Analyze task
        complexity = self.assess_complexity(task)

        # Select based on priority and complexity
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
        # Rule-based + LLM
        score = 0.0
        score += len(task) / 1000
        score += 0.2 if "code" in task else 0
        score += 0.3 if "analyze" in task else 0
        return min(score, 1.0)
```

---

## 📊 Pattern Comparison

| Pattern | Complexity | Flexibility | Applicable Scenarios | Cost |
|---------|------------|-------------|---------------------|------|
| Recursive Decomposition | Medium | High | Complex tasks | Medium |
| State Machine | Low | Low | Fixed workflows | Low |
| Sandbox Execution | High | Medium | Code execution | High |
| Evolutionary Optimization | High | High | Architecture search | Very high |
| ReAct | Low | Medium | Simple tasks | Low |
| Reflection & Improvement | Medium | Medium | Quality optimization | Medium |
| Multi-Advisor | Medium | Low | Strict verification | High |
| Hierarchical Coordination | Medium | Medium | Multi-Agent | Medium |
| Prompt Optimization | Medium | High | Prompt tuning | Medium |
| Model Routing | Low | Medium | Cost optimization | Low |

## 💡 Pattern Combination

### Combination 1: ReAct + Reflection

```
ReAct Loop
  ↓
Reflect after each step
  ↓
If issues found → Re-plan
```

### Combination 2: Recursive Decomposition + Multi-Agent

```
Recursive decomposition
  ↓
Each subtask assigned to different Agent
  ↓
Hierarchical coordination
```

### Combination 3: Evolution + Reflection

```
Evolutionary optimization of architecture
  ↓
Each architecture uses reflection improvement
  ↓
Select best
```

## 📚 Summary

### Usage Principles

1. **Start Simple**: Prioritize simple patterns like ReAct, reflection
2. **Choose Based on Need**: Select appropriate patterns based on problems
3. **Flexible Combination**: Don't be limited to single patterns
4. **Continuous Optimization**: Adjust patterns based on results

### Pattern Selection Flow

```
Problem type?
├─ Simple tasks → ReAct
├─ Complex tasks → Recursive decomposition
├─ Need verification → Reflection/Multi-advisor
├─ Code execution → Sandbox
├─ Architecture design → Evolution
└─ Multi-Agent → Hierarchical coordination
```

### Next Steps

- [Layer 3: Building Blocks Library](../layer-03-building-blocks/) - Apply these patterns
- [Experiment Cases](../layer-04-experimentation/07-case-demos.md) - See practical applications
