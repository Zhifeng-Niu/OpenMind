# Creating Building Blocks

> How to implement custom building blocks

## 🎯 Core Process

Standard process for creating building blocks:

```
Requirements Analysis → Interface Design → Implementation → Testing → Documentation → Publishing
```

## 📋 Step 1: Requirements Analysis

### 1.1 Define Functionality

**Question**: What problem are you solving?

**Example**:
```markdown
Problem: LLM-generated text may contain factual errors

Goal: Detect and correct factual errors

Input: LLM-generated text
Output: Corrected text + fact-check report
```

### 1.2 Dimensional Positioning

Use the N-dimensional positioning system:

```typescript
const factCheckerDimensions = {
  autonomy: "semi-autonomous",      // Requires external verification sources
  perception: "text",               // Processes text
  time: "short-term",               // Single processing
  memory: "none",                   // No memory needed
  tools: "search tools",            // Needs search engine
  learning: "none",                 // Fixed rules
  social: "isolated",               // Works alone
  goal: "external verification",    // Verify accuracy
  safety: "rule-constrained",       // Don't modify sensitive content
  explainability: "queryable"       // Can report check results
};
```

### 1.3 Identify Dependencies

**What other building blocks are needed?**

- `LLMWrapper` - Generate claims
- `SearchTool` - Verify facts
- `OutputGenerator` - Format results

## 📐 Step 2: Interface Design

### 2.1 Implement BuildingBlock

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
    // Validate dependencies
    if (!this.llm || !this.search) {
      throw new Error("Missing required dependencies");
    }
  }

  async dispose(): Promise<void> {
    // Clean up resources
  }
}
```

### 2.2 Define Input/Output

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

## 💻 Step 3: Implementation

### 3.1 Core Logic

```typescript
async process(
  input: FactCheckerInput,
  context: Context
): Promise<FactCheckerOutput> {

  // 1. Extract claims
  const claims = await this.extractClaims(input.text);

  // 2. Verify each claim
  const verifiedClaims = await Promise.all(
    claims.map(claim => this.verifyClaim(claim, input.context))
  );

  // 3. Generate corrected text
  const correctedText = await this.generateCorrected(
    input.text,
    verifiedClaims
  );

  // 4. Generate summary
  const summary = this.generateSummary(verifiedClaims);

  return {
    originalText: input.text,
    correctedText,
    claims: verifiedClaims,
    summary
  };
}
```

### 3.2 Extract Claims

```typescript
private async extractClaims(text: string): Promise<string[]> {
  const prompt = `
  Extract verifiable factual claims from the following text:

  ${text}

  Only extract verifiable factual claims, not opinions or speculation.
  Output JSON array: ["claim1", "claim2", ...]
  `;

  const result = await this.llm.process({ prompt }, this.createContext());

  const claims = JSON.parse(result.response);
  return claims.slice(0, this.config.maxClaims);
}
```

### 3.3 Verify Claims

```typescript
private async verifyClaim(
  claim: string,
  context?: { topic?: string; timeframe?: string }
): Promise<Claim> {
  // Search for evidence
  const query = this.buildSearchQuery(claim, context);
  const results = await this.search.search({
    query,
    numResults: this.config.searchDepth
  });

  // Use LLM to evaluate evidence
  const verificationPrompt = `
  Claim: ${claim}

  Search results:
  ${this.formatResults(results)}

  Evaluate the credibility of the claim (0-1) and list supporting sources.
  Output JSON: {"confidence": 0.8, "sources": ["url1", "url2"]}
  `;

  const verification = await this.llm.process(
    { prompt: verificationPrompt },
    this.createContext()
  );

  return JSON.parse(verification.response);
}
```

### 3.4 Generate Corrections

```typescript
private async generateCorrected(
  original: string,
  claims: Claim[]
): Promise<string> {
  const corrections = claims
    .filter(c => c.confidence < this.config.confidenceThreshold)
    .map(c => ({
      claim: c.text,
      correction: `Confidence only ${c.confidence}`
    }));

  if (corrections.length === 0) {
    return original;
  }

  const prompt = `
  Original text: ${original}

  Parts needing correction:
  ${JSON.stringify(corrections, null, 2)}

  Please correct the original text, keeping other parts unchanged.
  `;

  const result = await this.llm.process({ prompt }, this.createContext());
  return result.response;
}
```

## 🧪 Step 4: Testing

### 4.1 Unit Tests

```typescript
import { describe, it, expect } from 'vitest';

describe('FactChecker', () => {
  it('should extract claims from text', async () => {
    const factChecker = new FactChecker(mockLLM, mockSearch);
    await factChecker.initialize();

    const claims = await factChecker['extractClaims'](
      "Python was created in 1991 by Guido van Rossum."
    );

    expect(claims).toHaveLength(2);
    expect(claims[0]).toContain("1991");
  });

  it('should verify claims', async () => {
    const factChecker = new FactChecker(mockLLM, mockSearch);

    const claim = await factChecker['verifyClaim'](
      "Python was created in 1991"
    );

    expect(claim.confidence).toBeGreaterThan(0.5);
    expect(claim.sources).toBeDefined();
  });
});
```

### 4.2 Integration Tests

```typescript
it('should process full pipeline', async () => {
  const input: FactCheckerInput = {
    text: "Python is a programming language created in 1995."
  };

  const output = await factChecker.process(input, mockContext);

  expect(output.correctedText).toBeDefined();
  expect(output.claims.length).toBeGreaterThan(0);
  expect(output.summary.total).toBe(output.claims.length);
});
```

### 4.3 Test Data

```typescript
const testCases = [
  {
    input: "JavaScript was created in 1995",
    expectedConfidence: 0.9
  },
  {
    input: "The Earth is flat",
    expectedConfidence: 0.1
  },
  {
    input: "Python is the best language",
    expectedConfidence: 0.5  // Subjective opinion
  }
];
```

## 📚 Step 5: Documentation

### 5.1 README

```markdown
# FactChecker Building Block

## Functionality

Verifies factual claims in LLM-generated text.

## Usage

\`\`\`typescript
const factChecker = new FactChecker(llm, searchTool);
await factChecker.initialize();

const result = await factChecker.process({
  text: "Generated text..."
}, context);

console.log(result.correctedText);
console.log(result.summary);
\`\`\`

## Configuration

- \`confidenceThreshold\`: Trust threshold (default: 0.7)
- \`maxClaims\`: Maximum number of checks (default: 10)
- \`searchDepth\`: Search depth (default: 3)

## Limitations

- Can only verify publicly available information
- Depends on search engine quality
- May produce false positives/negatives
```

### 5.2 API Documentation

```typescript
/**
 * Verifies factual claims in text
 *
 * @param input - Input text and context
 * @param context - Runtime context
 * @returns Verification results including corrected text and report
 *
 * @example
 * ```ts
 * const result = await factChecker.process({
 *   text: "Python was created in 1991",
 *   context: { topic: "Programming Languages" }
 * }, context);
 * ```
 */
async process(
  input: FactCheckerInput,
  context: Context
): Promise<FactCheckerOutput>
```

## 🚀 Step 6: Publishing

### 6.1 Packaging

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

### 6.2 Exports

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

## 💡 Best Practices

### 1. Single Responsibility

```typescript
// ✅ Good: Single function
class FactChecker { /* Only verifies facts */ }

// ❌ Bad: Multiple functions
class TextProcessor {
  async spellCheck() { /* ... */ }
  async grammarCheck() { /* ... */ }
  async factCheck() { /* ... */ }
}
```

### 2. Configurable

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

### 3. Error Handling

```typescript
async process(input: any, context: Context): Promise<Output> {
  try {
    return await this.doProcess(input);
  } catch (error) {
    context.logger?.error("Processing failed", error);

    // Return error status instead of throwing
    return {
      data: null,
      status: "error",
      error: error as Error
    };
  }
}
```

### 4. Logging

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

## 📝 Exercises

### Exercise 1: Create Text Summarizer Block

Implement a `SummarizerBlock`:
- Input: Long text
- Output: Summary + key points
- Configuration: Summary length, number of key points

### Exercise 2: Create Sentiment Analysis Block

Implement a `SentimentBlock`:
- Input: Text
- Output: Sentiment score + classification
- Support batch processing

### Exercise 3: Create Translator Block

Implement a `TranslatorBlock`:
- Input: Text + target language
- Output: Translation result
- Support multiple languages

## 📚 Summary

### Key Points

1. **Requirements Analysis**: Clarify problem, positioning, dependencies
2. **Interface Design**: Follow BuildingBlock interface, define input/output
3. **Implementation**: Core logic, helper methods, error handling
4. **Testing**: Unit tests, integration tests, test data
5. **Documentation**: README, API docs, examples
6. **Publishing**: Packaging, exports, version management

### Checklist

Before creating a building block, confirm:

- [ ] Clear and single functionality
- [ ] Follows BuildingBlock interface
- [ ] Complete metadata
- [ ] Configurable
- [ ] Proper error handling
- [ ] Has logging
- [ ] Test coverage
- [ ] Complete documentation
- [ ] Version management

### Next Steps

- [Advanced Building Blocks](05-advanced-blocks.md) - Cutting-edge building blocks
- [Building Block Catalog](01-block-catalog.md) - View existing building blocks
