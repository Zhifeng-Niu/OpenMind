# 连接器系统

> 如何组合构建块实现复杂功能

## 🎯 核心概念

连接器是组合构建块的工具,就像乐高积木的连接件。

```
构建块 A ←→ 连接器 ←→ 构建块 B ←→ 连接器 ←→ 构建块 C
```

## 🔌 4 种连接器

### 1. pipe: 串行连接

**功能**: 将多个构建块串行连接,数据流经所有构建块

```typescript
interface PipeConnector {
  pipe(...blocks: BuildingBlock[]): Pipeline;
}

class Pipeline implements BuildingBlock {
  constructor(private blocks: BuildingBlock[]) {
    this.metadata = {
      name: "pipeline",
      version: "1.0.0",
      capabilities: ["sequential-processing"],
      dependencies: blocks.map(b => b.metadata.name)
    };
  }

  async process(input: any, context: Context): Promise<any> {
    let result = input;

    for (const block of this.blocks) {
      result = await block.process(result, context);
    }

    return result;
  }

  async initialize(): Promise<void> {
    for (const block of this.blocks) {
      await block.initialize();
    }
  }

  async dispose(): Promise<void> {
    for (const block of this.blocks) {
      await block.dispose();
    }
  }
}

// 使用
const pipeline = pipe(
  new InputAdapter(),
  new Processor(),
  new OutputGenerator()
);
```

**应用场景**:
- 数据处理流水线
- 多步转换
- 顺序执行的任务

### 2. branch: 条件分支

**功能**: 根据条件选择不同的处理路径

```typescript
interface BranchConnector {
  branch(condition: (data: any) => boolean): Branch;
}

class Branch implements BuildingBlock {
  private condition: (data: any) => boolean;
  private trueBranch: BuildingBlock;
  private falseBranch: BuildingBlock;

  constructor(
    condition: (data: any) => boolean,
    trueBranch: BuildingBlock,
    falseBranch: BuildingBlock
  ) {
    this.condition = condition;
    this.trueBranch = trueBranch;
    this.falseBranch = falseBranch;

    this.metadata = {
      name: "branch",
      version: "1.0.0",
      capabilities: ["conditional-routing"],
      dependencies: [
        trueBranch.metadata.name,
        falseBranch.metadata.name
      ]
    };
  }

  async process(input: any, context: Context): Promise<any> {
    const branch = this.condition(input) ? this.trueBranch : this.falseBranch;
    return await branch.process(input, context);
  }

  // 链式 API
  when(condition: boolean, block: BuildingBlock): Branch {
    if (condition) {
      this.trueBranch = block;
    } else {
      this.falseBranch = block;
    }
    return this;
  }
}

// 使用
const router = branch((data) => data.type === "text")
  .when(true, textHandler)
  .when(false, imageHandler);
```

**应用场景**:
- 根据输入类型选择处理方式
- A/B 测试
- 特性开关

### 3. loop: 反馈循环

**功能**: 创建反馈循环,输出可以回馈到输入

```typescript
interface LoopConnector {
  loop(condition: (output: any) => boolean): Loop;
}

class Loop implements BuildingBlock {
  private condition: (output: any) => boolean;
  private body: BuildingBlock;
  private maxIterations: number;

  constructor(
    condition: (output: any) => boolean,
    body: BuildingBlock,
    maxIterations: number = 10
  ) {
    this.condition = condition;
    this.body = body;
    this.maxIterations = maxIterations;

    this.metadata = {
      name: "loop",
      version: "1.0.0",
      capabilities: ["feedback-loop"],
      dependencies: [body.metadata.name]
    };
  }

  async process(input: any, context: Context): Promise<any> {
    let result = input;
    let iteration = 0;

    while (this.condition(result) && iteration < this.maxIterations) {
      result = await this.body.process(result, context);
      iteration++;
    }

    if (iteration >= this.maxIterations) {
      console.warn("Loop reached max iterations");
    }

    return result;
  }
}

// 使用
const feedback = loop(
  (output) => output.score < 0.8
).pipe(
  new Reflector(),
  new Improver()
);
```

**应用场景**:
- 迭代优化
- 自我修正
- 递归算法
- 反馈系统

### 4. parallel: 并行执行

**功能**: 并行执行多个构建块,聚合结果

```typescript
interface ParallelConnector {
  parallel(...blocks: BuildingBlock[]): Parallel;
}

class Parallel implements BuildingBlock {
  private blocks: BuildingBlock[];
  private aggregator: (results: any[]) => any;

  constructor(
    blocks: BuildingBlock[],
    aggregator: (results: any[]) => any = (r) => r[0]
  ) {
    this.blocks = blocks;
    this.aggregator = aggregator;

    this.metadata = {
      name: "parallel",
      version: "1.0.0",
      capabilities: ["parallel-execution"],
      dependencies: blocks.map(b => b.metadata.name)
    };
  }

  async process(input: any, context: Context): Promise<any> {
    // 并行执行所有构建块
    const promises = this.blocks.map(block =>
      block.process(input, context)
    );

    const results = await Promise.all(promises);

    // 聚合结果
    return this.aggregator(results);
  }

  async initialize(): Promise<void> {
    await Promise.all(
      this.blocks.map(block => block.initialize())
    );
  }

  async dispose(): Promise<void> {
    await Promise.all(
      this.blocks.map(block => block.dispose())
    );
  }
}

// 使用
const parallel = parallel([
  new SearchAgent(),
  new AnalyzeAgent(),
  new SummarizeAgent()
], (results) => ({
  search: results[0],
  analysis: results[1],
  summary: results[2]
}));
```

**应用场景**:
- 并行处理
- 多 Agent 协作
- 冗余计算
- 性能优化

## 🎨 高级组合

### 嵌套组合

```typescript
// 在 pipe 中使用 branch
const complex = pipe(
  new InputAdapter(),
  branch((data) => data.complexity > 0.5)
    .when(true, pipe(
      new ComplexProcessor(),
      loop((output) => !output.done)
    ))
    .when(false, new SimpleProcessor()),
  new OutputGenerator()
);
```

### 动态组合

```typescript
class DynamicComposer {
  private blocks: Map<string, BuildingBlock> = new Map();

  register(name: string, block: BuildingBlock): void {
    this.blocks.set(name, block);
  }

  compose(spec: ComposeSpec): BuildingBlock {
    const blocks = spec.steps.map(step => this.blocks.get(step.block));

    switch (spec.type) {
      case "pipe":
        return pipe(...blocks);
      case "parallel":
        return parallel(...blocks);
      case "branch":
        return branch(spec.condition, ...blocks);
      default:
        throw new Error(`Unknown type: ${spec.type}`);
    }
  }
}

// 使用
const composer = new DynamicComposer();
composer.register("a", blockA);
composer.register("b", blockB);

const pipeline = composer.compose({
  type: "pipe",
  steps: [{ block: "a" }, { block: "b" }]
});
```

## 🔍 实现细节

### 错误处理

```typescript
class SafePipeline extends Pipeline {
  async process(input: any, context: Context): Promise<any> {
    let result = input;

    for (const block of this.blocks) {
      try {
        result = await block.process(result, context);
      } catch (error) {
        // 记录错误但继续
        context.logger.error(`Block ${block.metadata.name} failed:`, error);
        // 可以选择继续或中断
        if (context.stopOnError) {
          throw error;
        }
      }
    }

    return result;
  }
}
```

### 性能监控

```typescript
class MonitoredPipeline extends Pipeline {
  async process(input: any, context: Context): Promise<any> {
    const metrics = {
      blocks: [],
      totalTime: 0
    };

    let result = input;
    const startTime = performance.now();

    for (const block of this.blocks) {
      const blockStart = performance.now();

      result = await block.process(result, context);

      const blockTime = performance.now() - blockStart;
      metrics.blocks.push({
        name: block.metadata.name,
        time: blockTime
      });
    }

    metrics.totalTime = performance.now() - startTime;

    // 记录指标
    context.metrics.record("pipeline", metrics);

    return result;
  }
}
```

### 超时控制

```typescript
class TimeoutPipeline extends Pipeline {
  constructor(
    blocks: BuildingBlock[],
    private timeout: number = 30000
  ) {
    super(blocks);
  }

  async process(input: any, context: Context): Promise<any> {
    const promises = this.blocks.map(async (block, index) => {
      const prevResult = index === 0 ? input : await this.blocks[index - 1].process(input, context);

      const timeoutPromise = new Promise((_, reject) =>
        setTimeout(() => reject(new Error("Timeout")), this.timeout)
      );

      return Promise.race([
        block.process(prevResult, context),
        timeoutPromise
      ]);
    });

    return Promise.all(promises);
  }
}
```

## 📊 组合模式示例

### 示例 1: 复杂 RAG Agent

```typescript
const ragAgent = pipe(
  new TextInputAdapter(),
  parallel([
    new VectorRetriever(),
    new KeywordSearcher()
  ], (results) => ({
    vector: results[0],
    keyword: results[1]
  })),
  new ContextMerger(),
  new LLMWrapper(),
  branch((data) => data.needsRefinement)
    .when(true, pipe(
      new Reflector(),
      new Improver()
    ))
    .when(false, new OutputGenerator()),
  new OutputGenerator()
);
```

### 示例 2: 自我演化 Agent

```typescript
const evolvingAgent = loop(
  (output) => output.generation < 10 && output.score < 0.9
).pipe(
  parallel([
    new Mutator(),
    new Evaluator()
  ], (results) => ({
    mutated: results[0],
    evaluated: results[1]
  })),
  new Selector(),  // 选择最优
  new Archive()     // 归档历史
);
```

### 示例 3: 多 Agent 协作

```typescript
const multiAgent = new Coordinator({
  agents: [
    new Researcher(),
    new Writer(),
    new Reviewer()
  ],
  strategy: "hierarchical",
  router: branch((task) => {
    if (task.type === "research") return 0;
    if (task.type === "write") return 1;
    if (task.type === "review") return 2;
  })
});
```

## 📝 练习

### 练习 1: 实现 pipe

实现 `pipe()` 函数,支持串行连接多个构建块。

### 练习 2: 实现 loop

实现 `loop()` 函数,支持条件反馈循环。

### 练习 3: 组合连接器

结合 pipe、branch、loop 创建复杂的数据流。

### 练习 4: 实现自定义连接器

实现一个新的连接器类型,如 `roundrobin`。

## 📚 总结

### 关键要点

1. **4 种连接器**: pipe、branch、loop、parallel
2. **自由组合**: 可以任意组合连接器
3. **嵌套支持**: 连接器可以嵌套使用
4. **扩展性**: 可以实现新的连接器类型

### 组合策略

- **顺序处理**: 使用 pipe
- **条件路由**: 使用 branch
- **迭代优化**: 使用 loop
- **并行加速**: 使用 parallel

### 下一步

- [创建构建块](04-creating-blocks.md) - 创建自定义构建块
- [高级构建块](05-advanced-blocks.md) - 前沿方向的构建块
