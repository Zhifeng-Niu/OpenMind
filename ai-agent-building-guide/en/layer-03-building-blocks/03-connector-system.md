# Connector System

> How to compose building blocks to implement complex functionality

## 🎯 Core Concept

Connectors are tools for composing building blocks, like Lego connectors.

```
Building Block A ←→ Connector ←→ Building Block B ←→ Connector ←→ Building Block C
```

## 🔌 4 Types of Connectors

### 1. pipe: Sequential Connection

**Function**: Connect multiple building blocks sequentially, data flows through all blocks

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

// Usage
const pipeline = pipe(
  new InputAdapter(),
  new Processor(),
  new OutputGenerator()
);
```

**Use Cases**:
- Data processing pipelines
- Multi-step transformations
- Sequential tasks

### 2. branch: Conditional Branching

**Function**: Select different processing paths based on conditions

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

  // Chainable API
  when(condition: boolean, block: BuildingBlock): Branch {
    if (condition) {
      this.trueBranch = block;
    } else {
      this.falseBranch = block;
    }
    return this;
  }
}

// Usage
const router = branch((data) => data.type === "text")
  .when(true, textHandler)
  .when(false, imageHandler);
```

**Use Cases**:
- Select processing method based on input type
- A/B testing
- Feature toggles

### 3. loop: Feedback Loop

**Function**: Create feedback loops, output can feed back to input

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

// Usage
const feedback = loop(
  (output) => output.score < 0.8
).pipe(
  new Reflector(),
  new Improver()
);
```

**Use Cases**:
- Iterative refinement
- Self-correction
- Recursive algorithms
- Feedback systems

### 4. parallel: Parallel Execution

**Function**: Execute multiple building blocks in parallel, aggregate results

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
    // Execute all building blocks in parallel
    const promises = this.blocks.map(block =>
      block.process(input, context)
    );

    const results = await Promise.all(promises);

    // Aggregate results
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

// Usage
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

**Use Cases**:
- Parallel processing
- Multi-agent collaboration
- Redundant computation
- Performance optimization

## 🎨 Advanced Composition

### Nested Composition

```typescript
// Use branch inside pipe
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

### Dynamic Composition

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

// Usage
const composer = new DynamicComposer();
composer.register("a", blockA);
composer.register("b", blockB);

const pipeline = composer.compose({
  type: "pipe",
  steps: [{ block: "a" }, { block: "b" }]
});
```

## 🔍 Implementation Details

### Error Handling

```typescript
class SafePipeline extends Pipeline {
  async process(input: any, context: Context): Promise<any> {
    let result = input;

    for (const block of this.blocks) {
      try {
        result = await block.process(result, context);
      } catch (error) {
        // Log error but continue
        context.logger.error(`Block ${block.metadata.name} failed:`, error);
        // Can choose to continue or interrupt
        if (context.stopOnError) {
          throw error;
        }
      }
    }

    return result;
  }
}
```

### Performance Monitoring

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

    // Record metrics
    context.metrics.record("pipeline", metrics);

    return result;
  }
}
```

### Timeout Control

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

## 📊 Composition Pattern Examples

### Example 1: Complex RAG Agent

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

### Example 2: Self-Evolving Agent

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
  new Selector(),  // Select best
  new Archive()     // Archive history
);
```

### Example 3: Multi-Agent Collaboration

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

## 📝 Exercises

### Exercise 1: Implement pipe

Implement the `pipe()` function that supports sequential connection of multiple building blocks.

### Exercise 2: Implement loop

Implement the `loop()` function that supports conditional feedback loops.

### Exercise 3: Compose Connectors

Combine pipe, branch, loop to create complex data flows.

### Exercise 4: Implement Custom Connector

Implement a new connector type, such as `roundrobin`.

## 📚 Summary

### Key Points

1. **4 Types of Connectors**: pipe, branch, loop, parallel
2. **Free Composition**: Connectors can be freely combined
3. **Nested Support**: Connectors can be nested
4. **Extensibility**: New connector types can be implemented

### Composition Strategies

- **Sequential Processing**: Use pipe
- **Conditional Routing**: Use branch
- **Iterative Refinement**: Use loop
- **Parallel Acceleration**: Use parallel

### Next Steps

- [Creating Building Blocks](04-creating-blocks.md) - Create custom building blocks
- [Advanced Building Blocks](05-advanced-blocks.md) - Cutting-edge building blocks
