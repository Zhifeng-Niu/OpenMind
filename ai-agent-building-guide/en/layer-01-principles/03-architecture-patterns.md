# Architecture Patterns

> Underlying patterns shared by all Agents

## 🎯 Chapter Objectives

Understand the underlying architecture patterns shared by all Agents.

1. Master 4 core architecture patterns
2. Understand application scenarios for each pattern
3. Learn how to combine patterns
4. Implement code examples for various patterns

## 3.1 Pattern Overview

### 4 Core Patterns

```
1. Loop Processing Pattern
   └─ ReAct, RSI, Self-correction

2. Hierarchical Decision Pattern
   └─ Strategy-Tactics-Operations

3. Distributed Coordination Pattern
   └─ Multi-Agent coordination

4. Memory Augmented Pattern
   └─ RAG, Retrieval augmentation
```

**Key Insight:**
- Complex Agents are combinations of these patterns
- After understanding patterns, you can freely combine them
- It's not about "choosing" patterns, but "combining" patterns

## 3.2 Pattern 1: Loop Processing Pattern

### Basic Structure

```
Input → Process → Output
  ↖____________↙
      Feedback
```

### ReAct Pattern

**Reasoning + Acting**

```python
class ReActAgent:
    async def run(self, query: str):
        # Initial thought
        thought = await self.think(f"Question: {query}")

        # Loop: Think → Act → Observe
        while not self.is_done():
            # Think about next step
            thought = await self.think(
                f"Current: {self.context}\n"
                f"Previous: {self.last_action}\n"
                f"Result: {self.last_result}\n"
                f"What should we do next?"
            )

            # Select action
            action = self.parse_action(thought)

            # Execute action
            result = await self.act(action)

            # Observe result
            observation = await self.observe(result)

            # Update context
            self.update_context(action, observation)

        return self.final_answer()
```

### RSI Pattern

**Recursive Self-Improvement**

```python
class RSIAgent:
    async def execute(self, task: Task):
        output = await self.initial_execution(task)
        complexity = self.assess_complexity(output)

        # Recursively improve until threshold is met
        while complexity < self.threshold:
            # Reflect
            feedback = await self.reflect(output)

            # Improve
            output = await self.refine(output, feedback)

            # Evaluate
            complexity = self.assess_complexity(output)

        return output

    async def reflect(self, output):
        """Generate improvement suggestions"""
        prompt = f"""
        Evaluate the following output and provide improvement suggestions:
        {output}

        Format: {{"suggestions": ["..."], "priority": ["..."]}}
        """
        return await self.llm.generate(prompt)

    async def refine(self, output, feedback):
        """Improve based on feedback"""
        prompt = f"""
        Original output:
        {output}

        Improvement suggestions:
        {feedback}

        Please improve the original output.
        """
        return await self.llm.generate(prompt)
```

### Application Scenarios

- **ReAct**: Tasks requiring multi-step reasoning
- **RSI**: Tasks requiring iterative improvement
- **Self-correction**: Tasks requiring validation and correction

## 3.3 Pattern 2: Hierarchical Decision Pattern

### Basic Structure

```
Strategy Layer
    ↓ Decompose
Tactics Layer
    ↓ Allocate
Operations Layer
```

### Implementation

```python
class HierarchicalAgent:
    def __init__(self):
        self.strategic_planner = StrategicPlanner()
        self.tactical_planner = TacticalPlanner()
        self.operator = Operator()

    async def solve(self, goal: str):
        # Strategy layer: Long-term planning
        strategy = await self.strategic_planner.plan(
            f"Develop a strategy to complete {goal}"
        )

        # Tactics layer: Decompose into subtasks
        tactics = await self.tactical_planner.plan(
            f"Decompose strategy {strategy} into executable tasks"
        )

        # Operations layer: Execute specific tasks
        results = []
        for task in tactics:
            result = await self.operator.execute(task)
            results.append(result)

        # Aggregate results
        return self.aggregate(results)

class StrategicPlanner:
    """Strategy layer: Long-term goals, resource allocation"""
    async def plan(self, goal):
        # Focus: One month, one quarter, one year
        return f"3-stage strategy to complete {goal}"

class TacticalPlanner:
    """Tactics layer: Task decomposition, prioritization"""
    async def plan(self, strategy):
        # Focus: This week, this task
        return ["Task1", "Task2", "Task3"]

class Operator:
    """Operations layer: Specific execution"""
    async def execute(self, task):
        # Focus: Current operation
        return f"Completed {task}"
```

### Application Scenarios

- **Project Management**: Strategic planning → Task decomposition → Execution
- **Game AI**: Long-term strategy → Short-term tactics → Immediate operations
- **Enterprise Planning**: Company strategy → Department plans → Individual tasks

## 3.4 Pattern 3: Distributed Coordination Pattern

### Basic Structure

```
Agent A ←→ Agent B ←→ Agent C
    ↘         ↙       ↖
      Coordinator
```

### Implementation

```python
class MultiAgentSystem:
    def __init__(self):
        self.agents = {}
        self.coordinator = Coordinator()

    def add_agent(self, name, agent):
        self.agents[name] = agent

    async def solve(self, problem):
        # 1. Coordinator analyzes problem
        subproblems = await self.coordinator.decompose(problem)

        # 2. Assign to specialized Agents
        assignments = self.coordinator.assign(subproblems, self.agents)

        # 3. Execute in parallel
        results = await asyncio.gather(*[
            self.agents[agent].solve(task)
            for agent, task in assignments.items()
        ])

        # 4. Integrate results
        return self.coordinator.integrate(results)

class Coordinator:
    """Coordinates collaboration between Agents"""

    async def decompose(self, problem):
        """Decompose problem into subproblems"""
        # Use LLM to analyze problem structure
        return ["Subproblem1", "Subproblem2", "Subproblem3"]

    def assign(self, subproblems, agents):
        """Assign tasks based on capabilities"""
        assignments = {}
        for i, problem in enumerate(subproblems):
            agent_name = list(agents.keys())[i % len(agents)]
            assignments[agent_name] = problem
        return assignments

    def integrate(self, results):
        """Integrate results from multiple Agents"""
        # Use LLM to synthesize multiple results
        return f"Synthesized result: {results}"
```

### Collaboration Patterns

**1. Collaboration**
```python
# Multiple Agents work together toward a goal
await asyncio.gather(
    agent_a.research(),
    agent_b.write(),
    agent_c.review()
)
```

**2. Competition**
```python
# Multiple Agents compete, select the best
results = await asyncio.gather(*[
    agent.solve(problem) for agent in agents
])
best = max(results, key=lambda r: r.score)
```

**3. Negotiation**
```python
# Agents negotiate to reach agreement
agreement = await negotiate(agents, proposal)
```

### Application Scenarios

- **Parallel Processing**: Multiple Agents process different parts simultaneously
- **Expert Systems**: Different Agents specialize in different domains
- **Fault-tolerant Systems**: Multiple Agents verify the same result

## 3.5 Pattern 4: Memory Augmented Pattern

### Basic Structure

```
Query → Vector Retrieval → Context Injection → Generation
```

### RAG Implementation

```python
class MemoryAugmentedAgent:
    def __init__(self):
        self.vector_db = VectorDB()
        self.llm = LLM()

    async def query(self, question: str):
        # 1. Retrieve relevant memories
        relevant_docs = await self.vector_db.search(
            question,
            top_k=5
        )

        # 2. Build augmented prompt
        prompt = f"""
        Answer the question using the following information:

        Relevant Information:
        {format_docs(relevant_docs)}

        Question: {question}
        """

        # 3. Generate answer
        answer = await self.llm.generate(prompt)

        # 4. Update memory
        await self.vector_db.add({
            "question": question,
            "answer": answer,
            "timestamp": now()
        })

        return answer
```

### Memory Types

**1. Working Memory**
```python
class ShortTermMemory:
    def __init__(self, size=10):
        self.buffer = deque(maxlen=size)

    def add(self, item):
        self.buffer.append(item)

    def get_recent(self, n=5):
        return list(self.buffer)[-n:]
```

**2. Long-term Memory**
```python
class LongTermMemory:
    def __init__(self):
        self.vector_db = VectorDB()
        self.key_value_db = KVStore()

    async def store(self, memory):
        # Vectorize
        embedding = await self.embed(memory)
        # Store
        await self.vector_db.add(embedding, memory)

    async def retrieve(self, query, top_k=5):
        embedding = await self.embed(query)
        return await self.vector_db.search(embedding, top_k)
```

**3. Procedural Memory**
```python
class ProceduralMemory:
    """Stores skills and tools"""

    def __init__(self):
        self.skills = {}  # Skill library
        self.tools = {}   # Tool library

    def learn_skill(self, name, implementation):
        """Learn a new skill"""
        self.skills[name] = implementation

    def use_tool(self, name, *args):
        """Use a tool"""
        return self.tools[name](*args)
```

### Application Scenarios

- **Knowledge Q&A**: Common RAG system scenario
- **Dialogue Systems**: Maintaining conversation history
- **Personal Assistants**: Remembering user preferences
- **Code Assistants**: Remembering code patterns and best practices

## 3.6 Pattern Combination

### Real Agents Are Pattern Combinations

**Example: Coding Agent**

```python
class CodingAgent:
    """Combining multiple patterns"""

    def __init__(self):
        # Pattern 1: Loop Processing
        self.loop = ReActLoop()

        # Pattern 2: Hierarchical Decision
        self.hierarchy = HierarchicalPlanner()

        # Pattern 3: Memory Augmented
        self.memory = MemorySystem()

        # Pattern 4: (Optional) Distributed
        # self.multi_agent = MultiAgentSystem()

    async def solve(self, task):
        # Hierarchical: Plan → Execute
        plan = await self.hierarchy.plan(task)

        # Loop: Each subtask
        results = []
        for subtask in plan:
            # Memory Augmented: Retrieve relevant code
            context = await self.memory.retrieve(subtask)

            # ReAct: Think-Act-Observe
            result = await self.loop.run(subtask, context)
            results.append(result)

        # Memory: Store experience
        await self.memory.store(task, results)
        return results
```

### Combination Strategies

**1. Sequential Combination**
```python
# Pattern A first, then Pattern B
result = await pattern_a(input)
result = await pattern_b(result)
```

**2. Parallel Combination**
```python
# Use multiple patterns simultaneously
result_a, result_b = await asyncio.gather(
    pattern_a(input),
    pattern_b(input)
)
```

**3. Nested Combination**
```python
# Pattern A uses Pattern B internally
class CompositeAgent:
    async def run(self):
        # Outer: Loop
        while not done:
            # Inner: Hierarchical
            strategy = await self.plan()
            tactics = await self.decompose(strategy)
            # Even deeper: Memory Augmented
            context = await self.retrieve(tactics)
```

## 3.7 Exercises

### Exercise 1: Pattern Recognition

Identify which patterns the following Agents use:
1. ChatGPT
2. AutoGPT
3. GitHub Copilot
4. An Agent you designed

### Exercise 2: Pattern Combination

Combine different patterns to create new Agents:
- ReAct + RAG
- Hierarchical + Multi-Agent
- Loop + Memory Augmented + Distributed

### Exercise 3: Implementation

Implement a pattern-combined Agent:
- Select at least 2 patterns
- Code implementation
- Test functionality

## 3.8 Summary

### Key Takeaways

1. **4 Core Patterns**: Loop, Hierarchical, Distributed, Memory Augmented
2. **Combine Not Choose**: Real Agents are combinations of multiple patterns
3. **Modular Design**: Each pattern can be implemented and tested independently
4. **Flexible Combination**: Sequential, parallel, nested

### Next Steps

- [Design Decision Tree](04-design-decision-tree.md) - How to make design decisions
- [Layer 2: Case Studies](../layer-02-case-studies/) - Learn from real projects
