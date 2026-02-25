# Interface Specification

> Unified interface definitions for building blocks

## 🎯 Core Interface

All building blocks must implement the `BuildingBlock` interface:

```typescript
interface BuildingBlock {
  // Core functionality
  process(input: any, context: Context): Promise<Output>;

  // Metadata
  readonly metadata: {
    name: string;
    version: string;
    capabilities: string[];
    dependencies: string[];
    author?: string;
    description?: string;
  };

  // Configuration
  configure(config: Config): void;

  // Lifecycle
  initialize(): Promise<void>;
  dispose(): Promise<void>;
}
```

## 📐 Interface Details

### process() Method

**Function**: Process input and produce output

```typescript
async process(
  input: any,           // Input data
  context: Context      // Runtime context
): Promise<Output>     // Output result
```

**Implementation Example**:

```typescript
class LLMWrapper implements BuildingBlock {
  async process(
    input: { prompt: string },
    context: Context
  ): Promise<{ response: string }> {
    // 1. Validate input
    if (!input.prompt) {
      throw new Error("Prompt is required");
    }

    // 2. Processing logic
    const response = await this.llm.generate(input.prompt);

    // 3. Return output
    return { response };
  }
}
```

### metadata Property

**Function**: Provides building block metadata

```typescript
readonly metadata: {
  name: string;           // Building block name
  version: string;        // Version number (semver)
  capabilities: string[];  // Capability list
  dependencies: string[];  // Dependencies on other building blocks
  author?: string;        // Author
  description?: string;   // Description
}
```

**Implementation Example**:

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

### configure() Method

**Function**: Configure building block behavior

```typescript
interface Config {
  [key: string]: any;
}

configure(config: Config): void {
  // Apply configuration
  this.temperature = config.temperature || 0.7;
  this.maxTokens = config.maxTokens || 2000;
}
```

### Lifecycle Methods

**initialize()** - Initialize building block

```typescript
async initialize(): Promise<void> {
  // Initialize resources
  await this.connect();
  await this.loadModels();
}
```

**dispose()** - Clean up resources

```typescript
async dispose(): Promise<void> {
  // Release resources
  await this.disconnect();
  await this.unloadModels();
}
```

## 🎭 Context and Output

### Context Interface

```typescript
interface Context {
  // Session ID
  sessionId: string;

  // User ID
  userId?: string;

  // Extra metadata
  metadata?: Map<string, any>;

  // Shared state
  state?: Map<string, any>;

  // Logger
  logger?: Logger;
}
```

### Output Interface

```typescript
interface Output {
  // Output data
  data: any;

  // Metadata
  metadata?: {
    timestamp: number;
    processingTime: number;
    [key: string]: any;
  };

  // Status
  status: "success" | "error" | "partial";

  // Error information
  error?: Error;
}
```

## 🔌 Type Definitions

### Type Inference

```typescript
type InputOf<T> = T extends BuildingBlock
  ? Awaited<ReturnType<T['process']>>
  : never;

type OutputOf<T> = T extends BuildingBlock
  ? Awaited<ReturnType<T['process']>>
  : never;
```

### Generic Constraints

```typescript
interface TypedBuildingBlock<I, O> extends BuildingBlock {
  process(input: I, context: Context): Promise<O>;
}
```

## 📝 Implementation Template

### Complete Template

```typescript
import { BuildingBlock, Context, Config } from './interfaces';

export abstract class BaseBuildingBlock implements BuildingBlock {
  protected config: Config = {};
  protected initialized = false;

  // Abstract methods, subclasses must implement
  abstract async process(input: any, context: Context): Promise<any>;

  // Metadata (subclass override)
  abstract readonly metadata: BuildingBlockMetadata;

  // Configuration
  configure(config: Config): void {
    this.config = { ...this.config, ...config };
  }

  // Lifecycle
  async initialize(): Promise<void> {
    if (this.initialized) {
      return;
    }

    // Subclasses can override
    await this.onInitialize();
    this.initialized = true;
  }

  async dispose(): Promise<void> {
    if (!this.initialized) {
      return;
    }

    // Subclasses can override
    await this.onDispose();
    this.initialized = false;
  }

  // Hook methods
  protected async onInitialize(): Promise<void> {
    // Default implementation
  }

  protected async onDispose(): Promise<void> {
    // Default implementation
  }

  // Utility methods
  protected log(level: string, message: string): void {
    // Logging
  }

  protected handleError(error: Error, context: Context): never {
    // Error handling
    throw error;
  }
}
```

### Using the Template

```typescript
class MyBlock extends BaseBuildingBlock {
  readonly metadata = {
    name: "my-block",
    version: "1.0.0",
    capabilities: [],
    dependencies: []
  };

  async process(input: any, context: Context): Promise<any> {
    // Verify initialization
    if (!this.initialized) {
      throw new Error("Block not initialized");
    }

    // Processing logic
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
    // Actual processing logic
  }

  protected async onInitialize(): Promise<void> {
    // Initialization logic
  }

  protected async onDispose(): Promise<void> {
    // Cleanup logic
  }
}
```

## 🔍 Type Checking

### Runtime Validation

```typescript
class BlockValidator {
  static validate(block: BuildingBlock): ValidationResult {
    const errors: string[] = [];

    // Check metadata
    if (!block.metadata.name) {
      errors.push("Missing name in metadata");
    }

    // Check dependencies
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

### Compile-time Checking

```typescript
// Use TypeScript generics to ensure type safety
function createPipeline<I, O>(
  blocks: TypedBuildingBlock<any, any>[]
): TypedBuildingBlock<I, O> {
  // Compile-time type checking
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

## 📚 Best Practices

### 1. Type Safety

```typescript
// ✅ Good practice
interface MyInput {
  text: string;
  options?: MyOptions;
}

// ❌ Bad practice
async process(input: any): Promise<any> {
  // Loses type checking
}
```

### 2. Error Handling

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

### 3. Resource Management

```typescript
async initialize(): Promise<void> {
  // Use try-finally to ensure resource cleanup
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

### 4. Configuration Validation

```typescript
configure(config: Config): void {
  // Validate configuration
  if (config.temperature !== undefined) {
    if (config.temperature < 0 || config.temperature > 2) {
      throw new Error("Temperature must be between 0 and 2");
    }
  }

  // Apply configuration
  this.config = { ...this.config, ...config };
}
```

## 📝 Exercises

### Exercise 1: Implement Simple Building Block

Implement a `ToUpperBlock`:
- Interface: `process(input: {text: string}): Promise<{text: string}>`
- Function: Convert text to uppercase
- Include metadata and configuration

### Exercise 2: Implement Stateful Building Block

Implement a `CounterBlock`:
- Maintain internal counter
- Provide `getCount()` method
- Use `configure()` to set initial value

### Exercise 3: Implement Async Building Block

Implement a `DelayBlock`:
- Delay input processing
- Configurable delay time
- Support cancellation

## 📚 Summary

### Key Points

1. **Unified Interface**: All building blocks follow the same interface
2. **Type Safety**: Use TypeScript to ensure correct types
3. **Lifecycle**: Properly implement initialization and cleanup
4. **Error Handling**: Gracefully handle errors

### Next Steps

- [Connector System](03-connector-system.md) - How to compose building blocks
- [Creating Building Blocks](04-creating-blocks.md) - How to create new building blocks
