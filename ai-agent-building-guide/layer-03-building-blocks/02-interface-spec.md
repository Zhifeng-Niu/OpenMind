# 接口规范

> 构建块的统一接口定义

## 🎯 核心接口

所有构建块都必须实现 `BuildingBlock` 接口:

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
    author?: string;
    description?: string;
  };

  // 配置
  configure(config: Config): void;

  // 生命周期
  initialize(): Promise<void>;
  dispose(): Promise<void>;
}
```

## 📐 接口详解

### process() 方法

**功能**: 处理输入并产生输出

```typescript
async process(
  input: any,           // 输入数据
  context: Context      // 运行上下文
): Promise<Output>     // 输出结果
```

**实现示例**:

```typescript
class LLMWrapper implements BuildingBlock {
  async process(
    input: { prompt: string },
    context: Context
  ): Promise<{ response: string }> {
    // 1. 验证输入
    if (!input.prompt) {
      throw new Error("Prompt is required");
    }

    // 2. 处理逻辑
    const response = await this.llm.generate(input.prompt);

    // 3. 返回输出
    return { response };
  }
}
```

### metadata 属性

**功能**: 提供构建块的元信息

```typescript
readonly metadata: {
  name: string;           // 构建块名称
  version: string;        // 版本号 (semver)
  capabilities: string[];  // 能力列表
  dependencies: string[];  // 依赖的其他构建块
  author?: string;        // 作者
  description?: string;   // 描述
}
```

**实现示例**:

```typescript
class MyBlock implements BuildingBlock {
  readonly metadata = {
    name: "my-block",
    version: "1.0.0",
    capabilities: ["text-processing", "summarization"],
    dependencies: ["llm-wrapper"],
    author: "Your Name",
    description: "A block for processing text"
  };
}
```

### configure() 方法

**功能**: 配置构建块行为

```typescript
interface Config {
  [key: string]: any;
}

configure(config: Config): void {
  // 应用配置
  this.temperature = config.temperature || 0.7;
  this.maxTokens = config.maxTokens || 2000;
}
```

### 生命周期方法

**initialize()** - 初始化构建块

```typescript
async initialize(): Promise<void> {
  // 初始化资源
  await this.connect();
  await this.loadModels();
}
```

**dispose()** - 清理资源

```typescript
async dispose(): Promise<void> {
  // 释放资源
  await this.disconnect();
  await this.unloadModels();
}
```

## 🎭 上下文和输出

### Context 接口

```typescript
interface Context {
  // 会话 ID
  sessionId: string;

  // 用户 ID
  userId?: string;

  // 额外元数据
  metadata?: Map<string, any>;

  // 共享状态
  state?: Map<string, any>;

  // 日志记录器
  logger?: Logger;
}
```

### Output 接口

```typescript
interface Output {
  // 输出数据
  data: any;

  // 元数据
  metadata?: {
    timestamp: number;
    processingTime: number;
    [key: string]: any;
  };

  // 状态
  status: "success" | "error" | "partial";

  // 错误信息
  error?: Error;
}
```

## 🔌 类型定义

### 类型推断

```typescript
type InputOf<T> = T extends BuildingBlock
  ? Awaited<ReturnType<T['process']>>
  : never;

type OutputOf<T> = T extends BuildingBlock
  ? Awaited<ReturnType<T['process']>>
  : never;
```

### 泛型约束

```typescript
interface TypedBuildingBlock<I, O> extends BuildingBlock {
  process(input: I, context: Context): Promise<O>;
}
```

## 📝 实现模板

### 完整模板

```typescript
import { BuildingBlock, Context, Config } from './interfaces';

export abstract class BaseBuildingBlock implements BuildingBlock {
  protected config: Config = {};
  protected initialized = false;

  // 抽象方法,子类必须实现
  abstract async process(input: any, context: Context): Promise<any>;

  // 元数据 (子类覆盖)
  abstract readonly metadata: BuildingBlockMetadata;

  // 配置
  configure(config: Config): void {
    this.config = { ...this.config, ...config };
  }

  // 生命周期
  async initialize(): Promise<void> {
    if (this.initialized) {
      return;
    }

    // 子类可以覆盖
    await this.onInitialize();
    this.initialized = true;
  }

  async dispose(): Promise<void> {
    if (!this.initialized) {
      return;
    }

    // 子类可以覆盖
    await this.onDispose();
    this.initialized = false;
  }

  // 钩子方法
  protected async onInitialize(): Promise<void> {
    // 默认实现
  }

  protected async onDispose(): Promise<void> {
    // 默认实现
  }

  // 工具方法
  protected log(level: string, message: string): void {
    // 日志记录
  }

  protected handleError(error: Error, context: Context): never {
    // 错误处理
    throw error;
  }
}
```

### 使用模板

```typescript
class MyBlock extends BaseBuildingBlock {
  readonly metadata = {
    name: "my-block",
    version: "1.0.0",
    capabilities: [],
    dependencies: []
  };

  async process(input: any, context: Context): Promise<any> {
    // 验证初始化
    if (!this.initialized) {
      throw new Error("Block not initialized");
    }

    // 处理逻辑
    try {
      const result = await this.doProcess(input, context);
      return {
        data: result,
        status: "success",
        metadata: {
          timestamp: Date.now(),
          processingTime: performance.now()
        }
      };
    } catch (error) {
      this.handleError(error, context);
    }
  }

  private async doProcess(input: any, context: Context): Promise<any> {
    // 实际处理逻辑
  }

  protected async onInitialize(): Promise<void> {
    // 初始化逻辑
  }

  protected async onDispose(): Promise<void> {
    // 清理逻辑
  }
}
```

## 🔍 类型检查

### 运行时验证

```typescript
class BlockValidator {
  static validate(block: BuildingBlock): ValidationResult {
    const errors: string[] = [];

    // 检查元数据
    if (!block.metadata.name) {
      errors.push("Missing name in metadata");
    }

    // 检查依赖
    for (const dep of block.metadata.dependencies) {
      if (!this.isAvailable(dep)) {
        errors.push(`Dependency ${dep} not available`);
      }
    }

    return {
      valid: errors.length === 0,
      errors
    };
  }
}
```

### 编译时检查

```typescript
// 使用 TypeScript 泛型确保类型安全
function createPipeline<I, O>(
  blocks: TypedBuildingBlock<any, any>[]
): TypedBuildingBlock<I, O> {
  // 编译时类型检查
  return blocks.reduce((prev, curr) => {
    return {
      async process(input: any, context: Context) {
        const prevOutput = await prev.process(input, context);
        return curr.process(prevOutput, context);
      }
    };
  });
}
```

## 📚 最佳实践

### 1. 类型安全

```typescript
// ✅ 好的做法
interface MyInput {
  text: string;
  options?: MyOptions;
}

// ❌ 不好的做法
async process(input: any): Promise<any> {
  // 失去类型检查
}
```

### 2. 错误处理

```typescript
async process(input: any, context: Context): Promise<Output> {
  try {
    const result = await this.doProcess(input);
    return { data: result, status: "success" };
  } catch (error) {
    return {
      data: null,
      status: "error",
      error: error as Error
    };
  }
}
```

### 3. 资源管理

```typescript
async initialize(): Promise<void> {
  // 使用 try-finally 确保资源清理
  const resource = await this.acquireResource();
  try {
    this.resource = resource;
  } catch (error) {
    await this.releaseResource(resource);
    throw error;
  }
}

async dispose(): Promise<void> {
  if (this.resource) {
    await this.releaseResource(this.resource);
  }
}
```

### 4. 配置验证

```typescript
configure(config: Config): void {
  // 验证配置
  if (config.temperature !== undefined) {
    if (config.temperature < 0 || config.temperature > 2) {
      throw new Error("Temperature must be between 0 and 2");
    }
  }

  // 应用配置
  this.config = { ...this.config, ...config };
}
```

## 📝 练习

### 练习 1: 实现简单构建块

实现一个 `ToUpperBlock`:
- 接口: `process(input: {text: string}): Promise<{text: string}>`
- 功能: 将文本转为大写
- 包含元数据和配置

### 练习 2: 实现有状态构建块

实现一个 `CounterBlock`:
- 维护内部计数器
- 提供 `getCount()` 方法
- 使用 `configure()` 配置初始值

### 练习 3: 实现异步构建块

实现一个 `DelayBlock`:
- 延迟处理输入
- 可配置延迟时间
- 支持取消

## 📚 总结

### 关键要点

1. **统一接口**: 所有构建块遵循相同接口
2. **类型安全**: 使用 TypeScript 确保类型正确
3. **生命周期**: 正确实现初始化和清理
4. **错误处理**: 优雅处理错误

### 下一步

- [连接器系统](03-connector-system.md) - 如何组合构建块
- [创建构建块](04-creating-blocks.md) - 如何创建新构建块
