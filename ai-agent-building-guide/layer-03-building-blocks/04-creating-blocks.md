# 创建构建块

> 如何实现自定义构建块

## 🎯 核心流程

创建构建块的标准流程:

```
需求分析 → 接口设计 → 实现 → 测试 → 文档 → 发布
```

## 📋 步骤 1: 需求分析

### 1.1 明确功能

**问题**: 你要解决什么问题?

**示例**:
```markdown
问题: LLM 生成的文本可能包含事实错误

目标: 检测并修正事实错误

输入: LLM 生成的文本
输出: 修正后的文本 + 事实检查报告
```

### 1.2 定位维度

使用 N 维定位系统:

```typescript
const factCheckerDimensions = {
  autonomy: "半自主",      // 需要外部验证源
  perception: "文本",      // 处理文本
  time: "短期",           // 单次处理
  memory: "无",           // 不需要记忆
  tools: "搜索工具",       // 需要搜索引擎
  learning: "无",         // 固定规则
  social: "孤立",         // 单独工作
  goal: "外部验证",       // 验证准确性
  safety: "规则约束",     // 不修改敏感内容
  explainability: "可查询" // 可以报告检查结果
};
```

### 1.3 识别依赖

**需要哪些其他构建块?**

- `LLMWrapper` - 生成主张
- `SearchTool` - 验证事实
- `OutputGenerator` - 格式化结果

## 📐 步骤 2: 接口设计

### 2.1 实现 BuildingBlock

```typescript
import { BuildingBlock, Context, Config } from './interfaces';

export class FactChecker implements BuildingBlock {
  readonly metadata = {
    name: "fact-checker",
    version: "1.0.0",
    capabilities: ["fact-verification", "claim-extraction"],
    dependencies: ["llm-wrapper", "search-tool"],
    author: "Your Name",
    description: "Verifies factual claims in generated text"
  };

  private config: FactCheckerConfig = {
    confidenceThreshold: 0.7,
    maxClaims: 10,
    searchDepth: 3
  };

  constructor(
    private llm: LLMWrapper,
    private search: SearchTool
  ) {}

  configure(config: Config): void {
    this.config = { ...this.config, ...config };
  }

  async initialize(): Promise<void> {
    // 验证依赖
    if (!this.llm || !this.search) {
      throw new Error("Missing required dependencies");
    }
  }

  async dispose(): Promise<void> {
    // 清理资源
  }
}
```

### 2.2 定义输入输出

```typescript
interface FactCheckerInput {
  text: string;
  context?: {
    topic?: string;
    timeframe?: string;
  };
}

interface Claim {
  text: string;
  confidence: number;
  sources: string[];
}

interface FactCheckerOutput {
  originalText: string;
  correctedText: string;
  claims: Claim[];
  summary: {
    total: number;
    verified: number;
    corrected: number;
    unknown: number;
  };
}
```

## 💻 步骤 3: 实现

### 3.1 核心逻辑

```typescript
async process(
  input: FactCheckerInput,
  context: Context
): Promise<FactCheckerOutput> {

  // 1. 提取主张
  const claims = await this.extractClaims(input.text);

  // 2. 验证每个主张
  const verifiedClaims = await Promise.all(
    claims.map(claim => this.verifyClaim(claim, input.context))
  );

  // 3. 生成修正后的文本
  const correctedText = await this.generateCorrected(
    input.text,
    verifiedClaims
  );

  // 4. 生成摘要
  const summary = this.generateSummary(verifiedClaims);

  return {
    originalText: input.text,
    correctedText,
    claims: verifiedClaims,
    summary
  };
}
```

### 3.2 提取主张

```typescript
private async extractClaims(text: string): Promise<string[]> {
  const prompt = `
  从以下文本中提取可验证的事实主张:

  ${text}

  只提取可以验证的事实主张,不包括观点或推测。
  输出 JSON 数组: ["主张1", "主张2", ...]
  `;

  const result = await this.llm.process({ prompt }, this.createContext());

  const claims = JSON.parse(result.response);
  return claims.slice(0, this.config.maxClaims);
}
```

### 3.3 验证主张

```typescript
private async verifyClaim(
  claim: string,
  context?: { topic?: string; timeframe?: string }
): Promise<Claim> {
  // 搜索证据
  const query = this.buildSearchQuery(claim, context);
  const results = await this.search.search({
    query,
    numResults: this.config.searchDepth
  });

  // 使用 LLM 评估证据
  const verificationPrompt = `
  主张: ${claim}

  搜索结果:
  ${this.formatResults(results)}

  评估主张的可信度 (0-1),并列出支持来源。
  输出 JSON: {"confidence": 0.8, "sources": ["url1", "url2"]}
  `;

  const verification = await this.llm.process(
    { prompt: verificationPrompt },
    this.createContext()
  );

  return JSON.parse(verification.response);
}
```

### 3.4 生成修正

```typescript
private async generateCorrected(
  original: string,
  claims: Claim[]
): Promise<string> {
  const corrections = claims
    .filter(c => c.confidence < this.config.confidenceThreshold)
    .map(c => ({
      claim: c.text,
      correction: `置信度仅为 ${c.confidence}`
    }));

  if (corrections.length === 0) {
    return original;
  }

  const prompt = `
  原文: ${original}

  需要修正的部分:
  ${JSON.stringify(corrections, null, 2)}

  请修正原文,保持其他部分不变。
  `;

  const result = await this.llm.process({ prompt }, this.createContext());
  return result.response;
}
```

## 🧪 步骤 4: 测试

### 4.1 单元测试

```typescript
import { describe, it, expect } from 'vitest';

describe('FactChecker', () => {
  it('should extract claims from text', async () => {
    const factChecker = new FactChecker(mockLLM, mockSearch);
    await factChecker.initialize();

    const claims = await factChecker['extractClaims'](
      "Python 创建于 1991 年,由 Guido van Rossum 开发。"
    );

    expect(claims).toHaveLength(2);
    expect(claims[0]).toContain("1991");
  });

  it('should verify claims', async () => {
    const factChecker = new FactChecker(mockLLM, mockSearch);

    const claim = await factChecker['verifyClaim'](
      "Python 创建于 1991 年"
    );

    expect(claim.confidence).toBeGreaterThan(0.5);
    expect(claim.sources).toBeDefined();
  });
});
```

### 4.2 集成测试

```typescript
it('should process full pipeline', async () => {
  const input: FactCheckerInput = {
    text: "Python 是一种编程语言,创建于 1995 年。"
  };

  const output = await factChecker.process(input, mockContext);

  expect(output.correctedText).toBeDefined();
  expect(output.claims.length).toBeGreaterThan(0);
  expect(output.summary.total).toBe(output.claims.length);
});
```

### 4.3 测试数据

```typescript
const testCases = [
  {
    input: "JavaScript 创建于 1995 年",
    expectedConfidence: 0.9
  },
  {
    input: "地球是平的",
    expectedConfidence: 0.1
  },
  {
    input: "Python 是最好的语言",
    expectedConfidence: 0.5 // 主观观点
  }
];
```

## 📚 步骤 5: 文档

### 5.1 README

```markdown
# FactChecker Building Block

## 功能

验证 LLM 生成文本中的事实主张。

## 使用

\`\`\`typescript
const factChecker = new FactChecker(llm, searchTool);
await factChecker.initialize();

const result = await factChecker.process({
  text: "生成的文本..."
}, context);

console.log(result.correctedText);
console.log(result.summary);
\`\`\`

## 配置

- \`confidenceThreshold\`: 信任阈值 (默认: 0.7)
- \`maxClaims\`: 最大检查数量 (默认: 10)
- \`searchDepth\`: 搜索深度 (默认: 3)

## 限制

- 只能验证公开可查的信息
- 依赖搜索引擎质量
- 可能产生误判
```

### 5.2 API 文档

```typescript
/**
 * 验证文本中的事实主张
 *
 * @param input - 输入文本和上下文
 * @param context - 运行上下文
 * @returns 验证结果,包括修正后的文本和报告
 *
 * @example
 * ```ts
 * const result = await factChecker.process({
 *   text: "Python 创建于 1991 年",
 *   context: { topic: "编程语言" }
 * }, context);
 * ```
 */
async process(
  input: FactCheckerInput,
  context: Context
): Promise<FactCheckerOutput>
```

## 🚀 步骤 6: 发布

### 6.1 打包

```json
{
  "name": "@my-blocks/fact-checker",
  "version": "1.0.0",
  "main": "dist/index.js",
  "types": "dist/index.d.ts",
  "dependencies": {
    "@my-blocks/interfaces": "^1.0.0"
  },
  "peerDependencies": {
    "llm-wrapper": "^1.0.0",
    "search-tool": "^1.0.0"
  }
}
```

### 6.2 导出

```typescript
// src/index.ts
export { FactChecker };
export type { FactCheckerInput, FactCheckerOutput, Claim };

// package.json
"exports": {
  ".": {
    "import": "./dist/index.js",
    "types": "./dist/index.d.ts"
  }
}
```

## 💡 最佳实践

### 1. 单一职责

```typescript
// ✅ 好: 单一功能
class FactChecker { /* 只验证事实 */ }

// ❌ 不好: 多个功能
class TextProcessor {
  async spellCheck() { /* ... */ }
  async grammarCheck() { /* ... */ }
  async factCheck() { /* ... */ }
}
```

### 2. 可配置

```typescript
class ConfigurableBlock {
  private config: Required<Config>;

  constructor(config: Config = {}) {
    this.config = {
      timeout: 30000,
      retries: 3,
      ...config
    };
  }
}
```

### 3. 错误处理

```typescript
async process(input: any, context: Context): Promise<Output> {
  try {
    return await this.doProcess(input);
  } catch (error) {
    context.logger?.error("Processing failed", error);

    // 返回错误状态而非抛出
    return {
      data: null,
      status: "error",
      error: error as Error
    };
  }
}
```

### 4. 日志记录

```typescript
class LoggingBlock {
  private logger: Logger;

  async process(input: any, context: Context): Promise<Output> {
    this.logger.debug("Processing started", { input });

    try {
      const result = await this.doProcess(input);
      this.logger.info("Processing completed", { result });
      return result;
    } catch (error) {
      this.logger.error("Processing failed", { error });
      throw error;
    }
  }
}
```

## 📝 练习

### 练习 1: 创建文本摘要块

实现一个 `SummarizerBlock`:
- 输入: 长文本
- 输出: 摘要 + 关键点
- 配置: 摘要长度、关键点数量

### 练习 2: 创建情感分析块

实现一个 `SentimentBlock`:
- 输入: 文本
- 输出: 情感分数 + 分类
- 支持批量处理

### 练习 3: 创建翻译块

实现一个 `TranslatorBlock`:
- 输入: 文本 + 目标语言
- 输出: 翻译结果
- 支持多语言

## 📚 总结

### 关键要点

1. **需求分析**: 明确问题、定位维度、识别依赖
2. **接口设计**: 遵循 BuildingBlock 接口、定义输入输出
3. **实现**: 核心逻辑、辅助方法、错误处理
4. **测试**: 单元测试、集成测试、测试数据
5. **文档**: README、API 文档、示例
6. **发布**: 打包、导出、版本管理

### 检查清单

创建构建块前确认:

- [ ] 功能明确且单一
- [ ] 遵循 BuildingBlock 接口
- [ ] 元数据完整
- [ ] 可配置
- [ ] 错误处理完善
- [ ] 有日志记录
- [ ] 测试覆盖
- [ ] 文档完整
- [ ] 版本管理

### 下一步

- [高级构建块](05-advanced-blocks.md) - 前沿方向的构建块
- [构建块目录](01-block-catalog.md) - 查看现有构建块
