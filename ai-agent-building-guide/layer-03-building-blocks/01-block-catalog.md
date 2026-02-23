# 构建块目录

> 所有可用的构建块分类和说明

## 📋 目录

本目录提供所有可用的构建块,按功能分类。

### 感知构建块 (Perception)

处理输入信息,提取特征和上下文。

| 构建块 | 功能 | 接口 |
|--------|------|------|
| TextInputAdapter | 文本输入处理 | `process(text: string): Promise<Context>` |
| MultiModalInput | 多模态输入 | `process(inputs: Input[]): Promise<Context>` |
| StreamProcessor | 流式数据处理 | `process(stream: AsyncIterator): Promise<Context>` |

### 决策构建块 (Decision)

使用 LLM 进行推理、规划和决策。

| 构建块 | 功能 | 接口 |
|--------|------|------|
| LLMWrapper | LLM 调用封装 | `process(prompt: string): Promise<Response>` |
| ReActLoop | ReAct 循环 | `process(task: Task): Promise<Result>` |
| Planner | 任务规划 | `process(goal: string): Promise<Plan>` |
| Router | 智能路由 | `process(request: Request): Promise<Route>` |

### 行动构建块 (Action)

执行具体操作和工具调用。

| 构建块 | 功能 | 接口 |
|--------|------|------|
| ToolCaller | 工具调用 | `process(tool: Tool): Promise<Result>` |
| CodeExecutor | 代码执行 | `process(code: string): Promise<Result>` |
| APIClient | API 调用 | `process(api: API): Promise<Response>` |
| OutputGenerator | 输出生成 | `process(data: any): Promise<Output>` |

### 记忆构建块 (Memory)

存储和检索信息。

| 构建块 | 功能 | 接口 |
|--------|------|------|
| ShortTermMemory | 短期记忆 | `store(item: any): void`<br>`retrieve(n: number): any[]` |
| LongTermMemory | 长期存储 | `store(key: string, value: any): void`<br>`retrieve(query: string): Promise<any[]>` |
| VectorRetriever | 向量检索 | `search(query: string, top_k: int): Promise<Result[]>` |
| KnowledgeGraph | 知识图谱 | `add(entity: Entity, relation: string): void`<br>`query(entity: string): Promise<Entity[]>` |

### 学习构建块 (Learning)

从经验中改进。

| 构建块 | 功能 | 接口 |
|--------|------|------|
| Reflector | 自我反思 | `reflect(output: any): Promise<Feedback>` |
| Evaluator | 评估输出 | `evaluate(output: any, metric: string): Promise<number>` |
| Optimizer | 参数优化 | `optimize(params: Params, feedback: Feedback): Params` |
| Evolver | 架构演化 | `evolve(current: Architecture): Promise<Architecture>` |

### 协调构建块 (Coordination)

管理多个 Agent 或组件。

| 构建块 | 功能 | 接口 |
|--------|------|------|
| MessageBus | 消息总线 | `publish(topic: string, message: any): void`<br>`subscribe(topic: string): AsyncIterator<Message>` |
| TaskQueue | 任务队列 | `enqueue(task: Task): void`<br>`dequeue(): Promise<Task>` |
| LockManager | 锁管理 | `acquire(lock: string): Promise<void>`<br>`release(lock: string): void` |
| EventScheduler | 事件调度 | `schedule(event: Event, time: number): void`<br>`trigger(): Promise<Event[]>` |

### 基础设施构建块 (Infrastructure)

支持系统运行的基础功能。

| 构建块 | 功能 | 接口 |
|--------|------|------|
| Logger | 日志系统 | `log(level: string, message: string): void` |
| Monitor | 监控系统 | `metrics(): Promise<Metrics>`<br>`health(): Promise<Health>` |
| Config | 配置管理 | `get(key: string): any`<br>`set(key: string, value: any): void` |
| ErrorHandler | 错误处理 | `handle(error: Error, context: Context): Promise<void>` |

## 🔌 快速参考

### 常用组合

#### 简单对话 Agent
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

#### 自我反思 Agent
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

#### 多 Agent 系统
```typescript
new Coordinator({
  agents: [
    new ResearchAgent(),
    new WritingAgent(),
    new ReviewAgent()
  ]
})
```

## 📖 详细文档

每个构建块的详细文档位于 `blocks/` 目录:

```
blocks/
├── perception/     # 感知构建块详细文档
├── decision/       # 决策构建块详细文档
├── action/         # 行动构建块详细文档
├── memory/         # 记忆构建块详细文档
├── learning/       # 学习构建块详细文档
└── coordination/   # 协调构建块详细文档
```

## 🎯 如何选择构建块

### 决策流程

1. **识别需求**: 我需要什么功能?
2. **查找构建块**: 哪个构建块提供这个功能?
3. **检查接口**: 它的接口是否符合我的需求?
4. **组合**: 如何与其他构建块组合?
5. **测试**: 验证功能是否正常

### 示例

**需求**: 我需要一个能搜索网络并回答问题的 Agent

**流程**:
1. 需要网络搜索 → `WebSearchTool` (行动构建块)
2. 需要理解问题 → `LLMWrapper` (决策构建块)
3. 需要生成答案 → `OutputGenerator` (行动构建块)

**组合**:
```typescript
pipe(
  new TextInputAdapter(),
  new LLMWrapper({
    tools: [new WebSearchTool()]
  }),
  new OutputGenerator()
)
```

## 🔨 创建新构建块

参见 [创建构建块指南](../04-creating-blocks.md)

## 📚 总结

### 关键要点

1. **分类清晰**: 按功能分为 7 大类
2. **接口统一**: 所有构建块遵循相同接口
3. **可组合**: 使用连接器自由组合
4. **可扩展**: 轻松添加新构建块

### 下一步

- [接口规范](02-interface-spec.md) - 了解统一接口
- [连接器系统](03-connector-system.md) - 学习如何组合
- [高级构建块](05-advanced-blocks.md) - 前沿方向
