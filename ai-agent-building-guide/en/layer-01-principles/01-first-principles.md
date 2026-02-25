# First Principles

> Start with the most fundamental question: What is an Agent?

## 🎯 Chapter Objectives

Before diving into complex technical details, we need to first understand the essence of Agents. This chapter will answer:

1. What is an Agent? What is not an Agent?
2. What are the core components of an Agent?
3. What is the difference between Agent, LLM, and Workflow?
4. Why do we need Agents?
5. How to implement the simplest Agent?

## 1.1 Essential Definition of an Agent

### Misconceptions in Traditional Definitions

Many people understand Agents like this:

- "An Agent is an AI that can automatically complete tasks"
- "ChatGPT Plugins are Agents"
- "An LLM that can call tools is an Agent"

These understandings are not entirely accurate. They describe the **characteristics** of Agents, not their **essence**.

### First Principles Definition

Let's start from first principles:

```
Agent = Perception + Decision + Action + Memory
       │              │        │       │
       └──────────────┴────────┴───────┘
                    │
            Information Processing Loop
```

**Key Insights:**

1. **Perception**: Getting information from the environment
   - Input: Text, images, audio, sensor data, API responses...
   - Not passive reception, but active observation

2. **Decision**: Making choices based on perceived information
   - Reasoning: Analyzing current state
   - Planning: Formulating strategies
   - Judgment: Evaluating options

3. **Action**: Producing effects on the environment
   - Output: Text, API calls, system operations, tool usage...
   - Not simple responses, but active changes

4. **Memory**: Storing and retrieving information
   - Short-term: Current context
   - Long-term: Persistent knowledge
   - Not static storage, but dynamic updates

### Why a Loop?

```
Perception → Decision → Action
  ↖________________↙
        Feedback
```

The key to an Agent is the **loop**:

1. Perceive environment state
2. Make decisions based on perception
3. Execute actions to change the environment
4. New environment state is perceived
5. The loop continues...

This loop enables the Agent to:
- **Adapt**: Adjust behavior based on feedback
- **Learn**: Improve from experience
- **Be Autonomous**: Not depend on external instructions

### What is NOT an Agent?

#### ❌ Simple LLM Call

```python
# This is NOT an Agent
response = llm.generate("Write a poem")
print(response)
```

**Why not?**
- Only has decision (LLM reasoning)
- No perception (input is fixed)
- No action (output is just text, doesn't change environment)
- No memory (each call is independent)
- No loop (one-way flow)

#### ✅ LLM System with a Loop

```python
# This IS an Agent
class Agent:
    def __init__(self):
        self.memory = []
        self.tools = {...}

    async def run(self, goal):
        # Perception: Get current state
        state = self.perceive()

        # Decision: Based on LLM reasoning
        decision = await self.decide(goal, state)

        # Action: Execute operation
        result = await self.act(decision)

        # Memory: Update context
        self.memory.append(result)

        # Loop: Decide next step based on result
        if not self.is_complete(result):
            return await self.run(goal)
        return result
```

**Why yes?**
- Has perception (perceive method)
- Has decision (decide method, using LLM)
- Has action (act method, possibly calling tools)
- Has memory (self.memory)
- Has loop (recursive call until complete)

## 1.2 Agent vs LLM vs Workflow

### Comparison Table

| Feature | LLM | Workflow | Agent |
|---------|-----|----------|-------|
| **Input** | Static prompt | Predefined steps | Dynamic perception |
| **Processing** | Single inference | Fixed flow | Adaptive decision |
| **Output** | Text response | Predefined result | Active action |
| **Memory** | None/Limited | State machine | Persistent + Context |
| **Loop** | None | Yes (but fixed) | Yes (and dynamic) |
| **Autonomy** | None | Low | High |
| **Adaptability** | None | Low | High |

### Detailed Comparison

#### LLM: Static Predictor

```python
# Typical LLM usage
response = llm.generate(
    "Analyze the sentiment of this text: {text}"
)
# Single input → Single output
# Stateless, memoryless, loopless
```

**Characteristics:**
- Input and output are both static
- Each call is independent
- Cannot learn from past experience
- Cannot actively obtain information

**Use Cases:**
- Single Q&A
- Content generation
- Simple analysis

#### Workflow: Fixed Process

```python
# Typical Workflow usage
def process_text(text):
    # Step 1: Preprocess
    cleaned = preprocess(text)

    # Step 2: Analyze
    sentiment = analyze_sentiment(cleaned)

    # Step 3: Post-process
    result = format_result(sentiment)

    return result

# Fixed step order
# Has state, but state transitions are fixed
# Has loop, but feedback path is fixed
```

**Characteristics:**
- Predefined process
- Deterministic state transitions
- Can handle complex tasks
- But limited adaptability

**Use Cases:**
- Data processing pipelines
- ETL tasks
- Automation scripts

#### Agent: Adaptive System

```python
# Typical Agent usage
class Agent:
    async def solve(self, problem):
        # Dynamically decide what to do
        while not self.solved(problem):
            # Perceive current state
            context = await self.perceive()

            # Reason about next action
            action = await self.reason(context)

            # Execute and observe result
            result = await self.execute(action)

            # Adjust strategy based on result
            self.learn(result)

        return self.solution
```

**Characteristics:**
- Dynamic process
- Adaptive state transitions
- Can handle uncertain tasks
- Highly adaptable to environment

**Use Cases:**
- Complex problem solving
- Dynamic environments
- Tasks requiring long-term planning

## 1.3 Why Do We Need Agents?

### Limitations of LLMs

While LLMs are powerful, they have some fundamental limitations:

1. **Stateless**: Each call is independent, cannot accumulate experience
2. **Tool-less**: Can only generate text, cannot operate on the world
3. **Planning-less**: Single inference, cannot handle multi-step tasks
4. **Learning-less**: Cannot improve from feedback

### Advantages of Agents

Agents overcome these limitations through architectural design:

| Limitation | Agent's Solution |
|------------|-----------------|
| Stateless | Memory system: short-term memory + long-term storage |
| Tool-less | Tool calling: APIs, code execution, system operations |
| Planning-less | Planner: task decomposition, strategy formulation |
| Learning-less | Learning mechanism: reflection, evaluation, optimization |

### Practical Cases

#### Case 1: Programming Task

**Using LLM:**
```python
# Can only generate code, cannot run
code = llm.generate("Write quicksort")
# User needs to copy, run, debug themselves
```

**Using Agent:**
```python
# Can complete programming task end-to-end
agent.solve("Implement and test quicksort")
# Automatically: write code → run tests → debug errors → verify results
```

#### Case 2: Research Task

**Using LLM:**
```python
# Can only answer based on training data
answer = llm.generate("What breakthroughs in AI in 2025?")
# May be outdated or inaccurate
```

**Using Agent:**
```python
# Can actively search for latest information
agent.solve("Research breakthroughs in AI in 2025")
# Automatically: search web → read papers → synthesize analysis → generate report
```

## 1.4 Simplest Agent Implementation

Let's implement the simplest Agent to understand the core components:

```python
import asyncio
from typing import List, Dict, Any

class SimpleAgent:
    """Simplest Agent implementation"""

    def __init__(self, llm):
        self.llm = llm
        self.memory: List[Dict[str, Any]] = []
        self.tools = {
            "search": self.search,
            "calculate": self.calculate,
        }

    def perceive(self) -> str:
        """Perception: Collect current context"""
        context = "Current conversation history:\n"
        for item in self.memory[-5:]:  # Last 5 items
            context += f"- {item['role']}: {item['content']}\n"
        return context

    async def decide(self, goal: str, context: str) -> Dict[str, Any]:
        """Decision: Reason about next action based on LLM"""
        prompt = f"""
Goal: {goal}

Context:
{context}

Available tools:
- search: Search for information
- calculate: Perform calculations

Decide the next action, format: {{"action": "tool_name", "input": "..."}}
If goal is complete, return: {{"action": "done", "result": "..."}}
"""

        response = await self.llm.generate(prompt)
        return self.parse_action(response)

    async def act(self, action: Dict[str, Any]) -> Any:
        """Action: Execute decision"""
        if action["action"] == "done":
            return action["result"]

        tool = self.tools.get(action["action"])
        if tool:
            return await tool(action.get("input", ""))
        return "Unknown tool"

    def remember(self, role: str, content: str):
        """Memory: Store information"""
        self.memory.append({"role": role, "content": content})

    async def run(self, goal: str, max_steps: int = 10) -> str:
        """Run Agent main loop"""
        self.remember("user", goal)

        for step in range(max_steps):
            # 1. Perception
            context = self.perceive()

            # 2. Decision
            action = await self.decide(goal, context)

            # 3. Action
            result = await self.act(action)

            # 4. Memory
            self.remember("assistant", str(result))

            # 5. Check if complete
            if action.get("action") == "done":
                return result

        return "Max steps reached"

    # Tool implementations
    async def search(self, query: str) -> str:
        return f"Search results for '{query}': [mock data]"

    async def calculate(self, expression: str) -> str:
        try:
            return f"Calculation result: {eval(expression)}"
        except:
            return "Calculation error"

    def parse_action(self, response: str) -> Dict[str, Any]:
        """Parse LLM output to action"""
        import json
        try:
            return json.loads(response.strip())
        except:
            return {"action": "done", "result": response}

# Usage example
async def main():
    class MockLLM:
        async def generate(self, prompt: str) -> str:
            # Simplified LLM simulation
            return '{"action": "done", "result": "Task complete"}'

    agent = SimpleAgent(MockLLM())
    result = await agent.run("Help me search for latest AI papers")
    print(result)

# asyncio.run(main())
```

### Code Analysis

This simple Agent demonstrates all core components:

1. **Perception** (`perceive`): Get context from memory
2. **Decision** (`decide`): Use LLM to reason about next step
3. **Action** (`act`): Execute tools or complete task
4. **Memory** (`remember`): Store conversation history
5. **Loop** (`run`): Recursive call until complete

## 1.5 Exercises

### Exercise 1: Identify Agents

Determine whether the following systems are Agents, and why:

1. Chatbot
2. Self-driving system
3. Database query system
4. Game AI

### Exercise 2: Design Agents

Design Agents for the following scenarios:

1. **Personal Assistant**: Manage schedules, send emails, book restaurants
2. **Code Reviewer**: Analyze code, provide suggestions, generate fixes
3. **Researcher**: Search literature, synthesize information, write reports

For each Agent:
- List perception, decision, action, memory components
- Position in N-dimensional space
- Explain the difference from LLM/Workflow

### Exercise 3: Implementation Extension

Extend `SimpleAgent`:

1. Add more tools
2. Improve memory mechanism (distinguish short-term/long-term)
3. Add reflection capability (evaluate own output)

## 1.6 Summary

### Key Takeaways

1. **Agent Essence**: A loop system of perception-decision-action-memory
2. **vs LLM**: Agent has state, tools, planning, learning capabilities
3. **vs Workflow**: Agent's process is dynamic and adaptive
4. **Core Value**: Overcomes LLM limitations through architectural design

### Next Steps

After understanding the essence of Agents, let's learn:

- [Design Dimensions](02-design-dimensions.md) - How to design Agents in N-dimensional space
- [Architecture Patterns](03-architecture-patterns.md) - Underlying patterns shared by all Agents
