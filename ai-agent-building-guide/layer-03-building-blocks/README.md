# Layer 3: 构建块库

> 可组合的原子组件,实现任何想法

## 📋 本层目标

提供可组合的构建块系统,让你快速实现任何 Agent 想法。

1. 理解构建块的概念和接口
2. 掌握核心构建块的使用
3. 学习如何创建新构建块
4. 组合构建块实现复杂 Agent

## 🎯 核心理念

### 从"写代码"到"组合组件"

传统方式:
```
需要 Agent → 写代码 → 测试 → 调试
```

构建块方式:
```
需要 Agent → 选择构建块 → 组合 → 运行
```

### 关键优势

- **快速**: 不从零开始,组合现有组件
- **可靠**: 每个构建块都经过测试
- **灵活**: 自由组合,不受框架限制
- **可扩展**: 轻松添加新构建块

## 📚 章节目录

### [1. 构建块目录](01-block-catalog.md)

所有可用的构建块分类:
- 感知构建块
- 决策构建块
- 行动构建块
- 记忆构建块
- 学习构建块
- 协调构建块
- 基础设施构建块

### [2. 接口规范](02-interface-spec.md)

统一的构建块接口定义:
- 核心接口
- 元数据规范
- 配置管理
- 生命周期

### [3. 连接器系统](03-connector-system.md)

如何组合构建块:
- pipe: 串行连接
- branch: 条件分支
- loop: 反馈循环
- parallel: 并行执行

### [4. 创建构建块](04-creating-blocks.md)

如何创建新构建块:
- 定义职责
- 实现接口
- 添加配置
- 编写测试
- 文档化

### [5. 高级构建块](05-advanced-blocks.md)

前沿方向的构建块:
- RSI 模块
- 自我反思机制
- 架构演化引擎
- 代码自增强
- 提示优化器
- 多模型路由器

## 🏗️ 构建块系统

### 基本架构

```
┌─────────────────────────────────┐
│         连接器系统               │
│   (如何组合构建块)               │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│         构建块接口               │
│   (统一的接口规范)               │
└─────────────────────────────────┘
              ↓
┌─────────────────────────────────┐
│         构建块目录               │
│   (可用的构建块)                │
├─────────────────────────────────┤
│ 感知 | 决策 | 行动 | 记忆        │
│ 学习 | 协调 | 基础设施           │
└─────────────────────────────────┘
```

### 核心接口

```typescript
interface BuildingBlock {
  // 核心功能
  process(input: any, context: Context): Promise<Output>;

  // 元数据
  readonly metadata: {
    name: string;
    version: string;
    capabilities: string[];
    dependencies: string[];
  };

  // 配置
  configure(config: Config): void;

  // 生命周期
  initialize(): Promise<void>;
  dispose(): Promise<void>;
}
```

## 🔌 连接器系统

### pipe: 串行连接

```typescript
// 数据流: A → B → C
const pipeline = pipe(
  new InputAdapter(),
  new LLMWrapper(),
  new OutputGenerator()
);
```

### branch: 条件分支

```typescript
// 控制流: 根据条件选择路径
const router = branch(
  (data) => data.type === "text"
).when(true, textHandler)
  .when(false, imageHandler);
```

### loop: 反馈循环

```typescript
// 反馈: 输出回馈到输入
const feedback = loop(
  (output) => output.score < 0.8
).pipe(
  new Reflector(),
  new Improver()
);
```

### parallel: 并行执行

```typescript
// 并行: 同时执行多个构建块
const parallel = parallel([
  new SearchAgent(),
  new AnalyzeAgent(),
  new SummarizeAgent()
]);
```

## 💡 使用示例

### 示例 1: 简单对话 Agent

```typescript
const agent = pipe(
  new TextInputAdapter(),
  new LLMWrapper({ model: "claude-3" }),
  new TextOutputGenerator()
);
```

### 示例 2: RAG Agent

```typescript
const ragAgent = pipe(
  new TextInputAdapter(),
  new VectorRetriever({ index: "docs" }),
  new ContextInjector(),
  new LLMWrapper({ model: "claude-3" }),
  new TextOutputGenerator()
);
```

### 示例 3: 自我反思 Agent

```typescript
const reflectiveAgent = pipe(
  new TextInputAdapter(),
  branch((data) => data.iteration < 3)
    .when(true, pipe(
      new LLMWrapper(),
      new Reflector(),
      new Improver()
    ))
    .when(false, new OutputGenerator())
);
```

### 示例 4: 多 Agent 系统

```typescript
const multiAgent = new Coordinator({
  agents: [
    new ResearchAgent(),
    new WritingAgent(),
    new ReviewAgent()
  ],
  strategy: "hierarchical"
});
```

## 🧩 高级构建块

### RSI 模块

```typescript
const rsiAgent = new RSIAgent({
  threshold: 0.8,
  maxIterations: 10,
  improveStrategy: "reflection"
});
```

### 自我反思机制

```typescript
const reflector = new Reflector({
  advisors: [
    new ConsistencyAdvisor(),
    new FactCheckAdvisor(),
    new QualityAdvisor()
  ]
});
```

### 架构演化引擎

```typescript
const evolver = new Evolver({
  mutationRate: 0.1,
  selectionStrategy: "elitist",
  populationSize: 10
});
```

## 📖 最佳实践

### 1. 单一职责

每个构建块只做一件事:
- ✅ TextInputAdapter
- ❌ TextProcessor (做太多)

### 2. 可配置

通过参数调整行为:
```typescript
const llm = new LLMWrapper({
  model: "claude-3",
  temperature: 0.7,
  maxTokens: 2000
});
```

### 3. 可测试

每个构建块都可以独立测试:
```typescript
describe("LLMWrapper", () => {
  it("should generate response", async () => {
    const llm = new LLMWrapper({ model: "test" });
    const result = await llm.process("test");
    expect(result).toBeDefined();
  });
});
```

### 4. 可组合

构建块应该容易组合:
```typescript
// 好的设计
pipe(a, b, c)

// 不好: 需要复杂配置
pipe(a, { config: {...}, next: b })
```

## 📝 练习

### 练习 1: 使用现有构建块

使用现有构建块创建:
1. 文件分析 Agent
2. 数据查询 Agent
3. 邮件处理 Agent

### 练习 2: 创建新构建块

实现一个新构建块:
1. 定义接口
2. 实现功能
3. 编写测试
4. 文档化

### 练习 3: 组合模式

尝试不同的构建块组合:
- pipe + loop
- branch + parallel
- 所有 4 种连接器

## 📚 总结

### 关键要点

1. **构建块 = 原子组件**: 小而专一
2. **连接器 = 组合方式**: 灵活组合
3. **接口 = 统一规范**: 互操作性
4. **组合 = 复杂系统**: 从简单到复杂

### 下一步

- [Layer 4: 实验方法论](../layer-04-experimentation/) - 设计和验证
- [高级构建块](05-advanced-blocks.md) - 前沿方向
