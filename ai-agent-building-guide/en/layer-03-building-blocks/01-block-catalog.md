# Building Block Catalog

> Classification and descriptions of all available building blocks

## 📋 Table of Contents

This catalog provides all available building blocks, organized by functionality.

### Perception Building Blocks

Process input information, extract features and context.

| Building Block | Function | Interface |
|--------|------|------|
| TextInputAdapter | Text input processing | `process(text: string): Promise<Context>` |
| MultiModalInput | Multi-modal input | `process(inputs: Input[]): Promise<Context>` |
| StreamProcessor | Stream data processing | `process(stream: AsyncIterator): Promise<Context>` |

### Decision Building Blocks

Use LLM for reasoning, planning, and decision-making.

| Building Block | Function | Interface |
|--------|------|------|
| LLMWrapper | LLM call wrapper | `process(prompt: string): Promise<Response>` |
| ReActLoop | ReAct loop | `process(task: Task): Promise<Result>` |
| Planner | Task planning | `process(goal: string): Promise<Plan>` |
| Router | Intelligent routing | `process(request: Request): Promise<Route>` |

### Action Building Blocks

Execute specific operations and tool calls.

| Building Block | Function | Interface |
|--------|------|------|
| ToolCaller | Tool calling | `process(tool: Tool): Promise<Result>` |
| CodeExecutor | Code execution | `process(code: string): Promise<Result>` |
| APIClient | API calls | `process(api: API): Promise<Response>` |
| OutputGenerator | Output generation | `process(data: any): Promise<Output>` |

### Memory Building Blocks

Store and retrieve information.

| Building Block | Function | Interface |
|--------|------|------|
| ShortTermMemory | Short-term memory | `store(item: any): void`<br>`retrieve(n: number): any[]` |
| LongTermMemory | Long-term storage | `store(key: string, value: any): void`<br>`retrieve(query: string): Promise<any[]>` |
| VectorRetriever | Vector retrieval | `search(query: string, top_k: int): Promise<Result[]>` |
| KnowledgeGraph | Knowledge graph | `add(entity: Entity, relation: string): void`<br>`query(entity: string): Promise<Entity[]>` |

### Learning Building Blocks

Improve from experience.

| Building Block | Function | Interface |
|--------|------|------|
| Reflector | Self-reflection | `reflect(output: any): Promise<Feedback>` |
| Evaluator | Evaluate output | `evaluate(output: any, metric: string): Promise<number>` |
| Optimizer | Parameter optimization | `optimize(params: Params, feedback: Feedback): Params` |
| Evolver | Architecture evolution | `evolve(current: Architecture): Promise<Architecture>` |

### Coordination Building Blocks

Manage multiple agents or components.

| Building Block | Function | Interface |
|--------|------|------|
| MessageBus | Message bus | `publish(topic: string, message: any): void`<br>`subscribe(topic: string): AsyncIterator<Message>` |
| TaskQueue | Task queue | `enqueue(task: Task): void`<br>`dequeue(): Promise<Task>` |
| LockManager | Lock management | `acquire(lock: string): Promise<void>`<br>`release(lock: string): void` |
| EventScheduler | Event scheduling | `schedule(event: Event, time: number): void`<br>`trigger(): Promise<Event[]>` |

### Infrastructure Building Blocks

Support foundational system functionality.

| Building Block | Function | Interface |
|--------|------|------|
| Logger | Logging system | `log(level: string, message: string): void` |
| Monitor | Monitoring system | `metrics(): Promise<Metrics>`<br>`health(): Promise<Health>` |
| Config | Configuration management | `get(key: string): any`<br>`set(key: string, value: any): void` |
| ErrorHandler | Error handling | `handle(error: Error, context: Context): Promise<void>` |

## 🔌 Quick Reference

### Common Combinations

#### Simple Dialogue Agent
```typescript
pipe(
  new TextInputAdapter(),
  new LLMWrapper(),
  new TextOutputGenerator()
)
```

#### RAG Agent
```typescript
pipe(
  new TextInputAdapter(),
  new VectorRetriever(),
  new ContextInjector(),
  new LLMWrapper(),
  new TextOutputGenerator()
)
```

#### Self-Reflecting Agent
```typescript
pipe(
  new TextInputAdapter(),
  branch((data) => data.iteration < 3)
    .when(true, pipe(
      new LLMWrapper(),
      new Reflector(),
      new Improver()
    ))
    .when(false, new OutputGenerator())
)
```

#### Multi-Agent System
```typescript
new Coordinator({
  agents: [
    new ResearchAgent(),
    new WritingAgent(),
    new ReviewAgent()
  ]
})
```

## 📖 Detailed Documentation

Detailed documentation for each building block is located in the `blocks/` directory:

```
blocks/
├── perception/     # Perception building block details
├── decision/       # Decision building block details
├── action/         # Action building block details
├── memory/         # Memory building block details
├── learning/       # Learning building block details
└── coordination/   # Coordination building block details
```

## 🎯 How to Choose Building Blocks

### Decision Process

1. **Identify Needs**: What functionality do I need?
2. **Find Building Blocks**: Which building block provides this functionality?
3. **Check Interface**: Does its interface meet my needs?
4. **Compose**: How to combine with other building blocks?
5. **Test**: Verify functionality works correctly

### Example

**Need**: I want an Agent that can search the web and answer questions

**Process**:
1. Need web search → `WebSearchTool` (Action building block)
2. Need to understand questions → `LLMWrapper` (Decision building block)
3. Need to generate answers → `OutputGenerator` (Action building block)

**Composition**:
```typescript
pipe(
  new TextInputAdapter(),
  new LLMWrapper({
    tools: [new WebSearchTool()]
  }),
  new OutputGenerator()
)
```

## 🔨 Creating New Building Blocks

See [Creating Building Blocks Guide](../04-creating-blocks.md)

## 📚 Summary

### Key Points

1. **Clear Classification**: Divided into 7 major categories by functionality
2. **Unified Interface**: All building blocks follow the same interface
3. **Composable**: Freely combine using connectors
4. **Extensible**: Easily add new building blocks

### Next Steps

- [Interface Specification](02-interface-spec.md) - Learn about unified interfaces
- [Connector System](03-connector-system.md) - Learn how to compose
- [Advanced Building Blocks](05-advanced-blocks.md) - Cutting-edge directions
