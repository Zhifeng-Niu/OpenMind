# Advanced Building Blocks

> Cutting-edge building block implementations

## 🎯 Chapter Objectives

Explore cutting-edge directions in Agent systems and implement advanced building blocks.

1. Recursive Self-Improvement (RSI)
2. Self-Reflection Mechanisms
3. Architecture Evolution
4. Code Self-Enhancement
5. Prompt Optimization
6. Multi-Model Routing

## 🔬 Advanced Block 1: RSI Agent

### Concept

**Recursive Self-Improvement**: Agent continuously improves output through self-feedback.

### N-Dimensional Positioning

```
Autonomy: Semi-autonomous (1)
Perception: Internal state (1)
Time: Short-term loop (1)
Memory: Short-term (1)
Tools: LLM (0)
Learning: Online learning (1)
Social: Isolated (0)
Goal: Maximize quality (special)
Safety: Output constraints (1)
Explainability: Queryable (1)
```

### Implementation

```typescript
class RSIAgent implements BuildingBlock {
  readonly metadata = {
    name: "rsi-agent",
    version: "1.0.0",
    capabilities: ["recursive-improvement", "self-reflection"],
    dependencies: ["llm-wrapper"]
  };

  private config = {
    maxIterations: 3,
    qualityThreshold: 0.8,
    improvementStrategy: "refine" // refine, regenerate, hybrid
  };

  constructor(private llm: LLMWrapper) {}

  async process(
    input: { task: string; context?: string },
    context: Context
  ): Promise<{ output: string; iterations: number; quality: number }> {

    let currentOutput = "";
    let currentQuality = 0;
    let iteration = 0;

    // Initial generation
    currentOutput = await this.generate(input.task, input.context);
    currentQuality = await this.assessQuality(currentOutput, input.task);

    // Recursive improvement
    while (currentQuality < this.config.qualityThreshold &&
           iteration < this.config.maxIterations) {

      const feedback = await this.generateFeedback(currentOutput, input.task);
      currentOutput = await this.improve(currentOutput, feedback);
      currentQuality = await this.assessQuality(currentOutput, input.task);
      iteration++;
    }

    return {
      output: currentOutput,
      iterations: iteration,
      quality: currentQuality
    };
  }

  private async generate(task: string, context?: string): Promise<string> {
    const prompt = context
      ? `Context: ${context}\n\nTask: ${task}`
      : task;

    const result = await this.llm.process({ prompt }, this.createContext());
    return result.response;
  }

  private async assessQuality(output: string, task: string): Promise<number> {
    const prompt = `
    Task: ${task}

    Output:
    ${output}

    Evaluate output quality (0-1), considering:
    - Completeness
    - Accuracy
    - Clarity
    - Relevance

    Output only a number: 0.85
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return parseFloat(result.response.trim());
  }

  private async generateFeedback(output: string, task: string): Promise<string> {
    const prompt = `
    Task: ${task}

    Current Output:
    ${output}

    Provide specific improvement suggestions, pointing out:
    1. Which parts need improvement
    2. How to improve them
    3. What content is missing
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return result.response;
  }

  private async improve(output: string, feedback: string): Promise<string> {
    const strategy = this.config.improvementStrategy;

    if (strategy === "refine") {
      return this.refine(output, feedback);
    } else if (strategy === "regenerate") {
      return this.regenerate(output, feedback);
    } else {
      return this.hybridImprove(output, feedback);
    }
  }

  private async refine(output: string, feedback: string): Promise<string> {
    const prompt = `
    Original Output:
    ${output}

    Feedback:
    ${feedback}

    Please improve the output based on the feedback, keeping the overall structure, only modifying parts that need improvement.
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return result.response;
  }

  private async regenerate(output: string, feedback: string): Promise<string> {
    const prompt = `
    Task: [Extracted from original task]

    Previous Attempt (flawed):
    ${output}

    Feedback:
    ${feedback}

    Please regenerate, avoiding previous errors.
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return result.response;
  }

  private async hybridImprove(output: string, feedback: string): Promise<string> {
    // Combine refine and regenerate
    const refined = await this.refine(output, feedback);
    const regenerated = await this.regenerate(output, feedback);

    // Choose the better version
    const quality1 = await this.assessQuality(refined, "");
    const quality2 = await this.assessQuality(regenerated, "");

    return quality1 > quality2 ? refined : regenerated;
  }
}
```

## 🔬 Advanced Block 2: Multi-Advisor Reflection

### Concept

**Multi-Advisor Reflection**: Use multiple "advisors" to evaluate output from different perspectives.

### Implementation

```typescript
interface Advisor {
  name: string;
  focus: string; // Focus area
  evaluate(output: string, context: any): Promise<Feedback>;
}

class MultiAdvisorReflector implements BuildingBlock {
  private advisors: Advisor[];

  constructor() {
    this.advisors = [
      new ConsistencyAdvisor(),
      new FactCheckAdvisor(),
      new ClarityAdvisor(),
      new CompletenessAdvisor(),
      new SafetyAdvisor()
    ];
  }

  async process(
    input: { output: string; task: string },
    context: Context
  ): Promise<{ refined: string; feedback: Feedback[] }> {

    let refined = input.output;
    const allFeedback: Feedback[] = [];

    // Call each advisor in sequence
    for (const advisor of this.advisors) {
      const feedback = await advisor.evaluate(refined, {
        task: input.task,
        previousFeedback: allFeedback
      });

      allFeedback.push(feedback);

      // If revision needed
      if (feedback.needsRevision) {
        refined = await this.applyRevision(refined, feedback);
      }
    }

    return { refined, feedback: allFeedback };
  }
}

// Specific advisor implementations
class ConsistencyAdvisor implements Advisor {
  name = "consistency";
  focus = "Logical consistency";

  async evaluate(output: string, context: any): Promise<Feedback> {
    const prompt = `
    Check logical consistency in the following text:

    ${output}

    Check for:
    - Contradictions
    - Logical gaps
    - Causal relationship errors

    Output JSON:
    {
      "issues": ["issue1", "issue2"],
      "needsRevision": true,
      "suggestions": ["suggestion1", "suggestion2"]
    }
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return JSON.parse(result.response);
  }
}

class FactCheckAdvisor implements Advisor {
  name = "fact-check";
  focus = "Factual accuracy";

  async evaluate(output: string, context: any): Promise<Feedback> {
    // Extract verifiable claims
    const claims = await this.extractClaims(output);

    // Verify each claim
    const verifications = await Promise.all(
      claims.map(claim => this.verifyClaim(claim))
    );

    const issues = verifications
      .filter(v => v.confidence < 0.7)
      .map(v => v.claim);

    return {
      advisor: this.name,
      issues,
      needsRevision: issues.length > 0,
      suggestions: verifications.map(v => v.correction).filter(Boolean)
    };
  }
}
```

## 🔬 Advanced Block 3: Architecture Evolution

### Concept

**Architecture Evolution**: Automatically search for optimal Agent architecture.

### Implementation

```typescript
interface Architecture {
  layers: Layer[];
  connections: Connection[];
  metadata: {
    fitness?: number;
    generation: number;
  };
}

class ArchitectureEvolver implements BuildingBlock {
  private population: Architecture[] = [];
  private populationSize = 10;
  private generations = 20;

  async process(
    input: { task: string; constraints: any },
    context: Context
  ): Promise<Architecture> {

    // 1. Initialize population
    this.initializePopulation();

    // 2. Evolution loop
    for (let gen = 0; gen < this.generations; gen++) {
      // 2.1 Evaluate fitness
      await this.evaluatePopulation(input.task);

      // 2.2 Selection
      const selected = this.select(this.populationSize / 2);

      // 2.3 Crossover
      const offspring = this.crossover(selected);

      // 2.4 Mutation
      this.mutate(offspring);

      // 2.5 Update population
      this.population = [...selected, ...offspring];

      // 2.6 Record best
      const best = this.getBest();
      console.log(`Gen ${gen}: Best fitness = ${best.metadata.fitness}`);
    }

    // 3. Return best architecture
    return this.getBest();
  }

  private initializePopulation(): void {
    for (let i = 0; i < this.populationSize; i++) {
      this.population.push(this.generateRandomArchitecture());
    }
  }

  private generateRandomArchitecture(): Architecture {
    const numLayers = Math.floor(Math.random() * 5) + 2; // 2-6 layers
    const layers: Layer[] = [];

    for (let i = 0; i < numLayers; i++) {
      layers.push({
        type: this.randomLayerType(),
        config: this.randomLayerConfig()
      });
    }

    const connections = this.generateConnections(layers);

    return {
      layers,
      connections,
      metadata: { generation: 0 }
    };
  }

  private async evaluatePopulation(task: string): Promise<void> {
    for (const arch of this.population) {
      const fitness = await this.evaluateArchitecture(arch, task);
      arch.metadata.fitness = fitness;
    }
  }

  private async evaluateArchitecture(
    arch: Architecture,
    task: string
  ): Promise<number> {
    // Instantiate architecture
    const agent = this.instantiate(arch);

    // Evaluate on test set
    const testCases = await this.getTestCases(task);
    let totalScore = 0;

    for (const testCase of testCases) {
      const result = await agent.process(testCase.input, this.createContext());
      const score = this.scoreResult(result, testCase.expected);
      totalScore += score;
    }

    // Consider complexity penalty
    const complexityPenalty = arch.layers.length * 0.01;

    return (totalScore / testCases.length) - complexityPenalty;
  }

  private select(topN: number): Architecture[] {
    return this.population
      .sort((a, b) => (b.metadata.fitness || 0) - (a.metadata.fitness || 0))
      .slice(0, topN);
  }

  private crossover(parents: Architecture[]): Architecture[] {
    const offspring: Architecture[] = [];

    for (let i = 0; i < parents.length - 1; i += 2) {
      const parent1 = parents[i];
      const parent2 = parents[i + 1];

      // Layer crossover
      const child1 = this.crossoverLayers(parent1, parent2);
      const child2 = this.crossoverLayers(parent2, parent1);

      offspring.push(child1, child2);
    }

    return offspring;
  }

  private crossoverLayers(
    parent1: Architecture,
    parent2: Architecture
  ): Architecture {
    // Random crossover point
    const point = Math.floor(Math.random() * parent1.layers.length);

    const layers = [
      ...parent1.layers.slice(0, point),
      ...parent2.layers.slice(point)
    ];

    return {
      layers,
      connections: this.generateConnections(layers),
      metadata: { generation: parent1.metadata.generation + 1 }
    };
  }

  private mutate(architectures: Architecture[]): void {
    for (const arch of architectures) {
      // Random mutation
      if (Math.random() < 0.3) {
        // Add layer
        arch.layers.push({
          type: this.randomLayerType(),
          config: this.randomLayerConfig()
        });
      }

      if (Math.random() < 0.2 && arch.layers.length > 2) {
        // Remove layer
        const idx = Math.floor(Math.random() * arch.layers.length);
        arch.layers.splice(idx, 1);
      }

      if (Math.random() < 0.3) {
        // Modify layer
        const idx = Math.floor(Math.random() * arch.layers.length);
        arch.layers[idx].config = this.randomLayerConfig();
      }
    }
  }

  private getBest(): Architecture {
    return this.population.reduce((best, current) =>
      (current.metadata.fitness || 0) > (best.metadata.fitness || 0)
        ? current
        : best
    );
  }
}
```

## 🔬 Advanced Block 4: Code Self-Enhancement

### Concept

**Code Self-Enhancement**: Agent can write, test, and improve its own code.

### Implementation

```typescript
class CodeSelfEnhancer implements BuildingBlock {
  readonly metadata = {
    name: "code-self-enhancer",
    version: "1.0.0",
    capabilities: ["code-generation", "self-testing", "self-improvement"],
    dependencies: ["llm-wrapper", "code-executor", "test-runner"]
  };

  constructor(
    private llm: LLMWrapper,
    private executor: CodeExecutor,
    private tester: TestRunner
  ) {}

  async process(
    input: { task: string; currentCode?: string },
    context: Context
  ): Promise<{ code: string; tests: string; metrics: any }> {

    // 1. Generate initial code (if not exists)
    let code = input.currentCode ||
               await this.generateCode(input.task);

    // 2. Generate tests
    const tests = await this.generateTests(code, input.task);

    // 3. Run tests
    let testResults = await this.tester.run(code, tests);

    // 4. If failed, fix
    let iterations = 0;
    while (!testResults.allPassed && iterations < 5) {
      code = await this.fixCode(code, testResults.failures);
      testResults = await this.tester.run(code, tests);
      iterations++;
    }

    // 5. Optimize code
    code = await this.optimizeCode(code, testResults);

    // 6. Calculate metrics
    const metrics = await this.calculateMetrics(code, testResults);

    return { code, tests, metrics };
  }

  private async generateCode(task: string): Promise<string> {
    const prompt = `
    Task: ${task}

    Generate clean, well-documented Python code to solve this task.
    Include type hints and docstrings.
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return this.extractCode(result.response);
  }

  private async generateTests(code: string, task: string): Promise<string> {
    const prompt = `
    Task: ${task}

    Code:
    ${code}

    Generate comprehensive unit tests using pytest.
    Include edge cases and normal cases.
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return this.extractCode(result.response);
  }

  private async fixCode(code: string, failures: TestFailure[]): Promise<string> {
    const prompt = `
    Code (has bugs):
    ${code}

    Test Failures:
    ${this.formatFailures(failures)}

    Fix the bugs to make all tests pass.
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return this.extractCode(result.response);
  }

  private async optimizeCode(code: string, testResults: any): Promise<string> {
    const prompt = `
    Code (working but may not be optimal):
    ${code}

    Test Results: All tests pass

    Optimize the code for:
    1. Performance
    2. Readability
    3. Maintainability

    Keep functionality identical.
    `;

    const result = await this.llm.process({ prompt }, this.createContext());

    // Verify optimized code still passes tests
    const optimized = this.extractCode(result.response);
    const newTestResults = await this.tester.run(optimized, "");

    return newTestResults.allPassed ? optimized : code;
  }
}
```

## 🔬 Advanced Block 5: Prompt Optimizer

### Concept

**Prompt Optimization**: Use multi-armed bandit algorithms to optimize prompts.

### Implementation

```typescript
class PromptOptimizer implements BuildingBlock {
  private prompts: Map<string, string> = new Map();
  private scores: Map<string, number> = new Map();
  private counts: Map<string, number> = new Map();

  // EXP3 algorithm parameters
  private gamma = 0.5; // Exploration rate
  private weights: Map<string, number> = new Map();

  async process(
    input: { task: string; templates: string[] },
    context: Context
  ): Promise<{ bestPrompt: string; bestScore: number }> {

    // Initialize
    input.templates.forEach(template => {
      this.prompts.set(template, template);
      this.weights.set(template, 1.0);
      this.scores.set(template, 0);
      this.counts.set(template, 0);
    });

    // Optimization loop
    for (let round = 0; round < 100; round++) {
      // 1. Select prompt (EXP3)
      const prompt = this.selectPrompt(input.task);

      // 2. Execute and evaluate
      const score = await this.evaluatePrompt(prompt, input.task);

      // 3. Update weights
      this.updateWeights(prompt, score);
    }

    // Return best
    let bestPrompt = "";
    let bestScore = -Infinity;

    for (const [prompt, score] of this.scores) {
      if (score > bestScore) {
        bestScore = score;
        bestPrompt = prompt;
      }
    }

    return { bestPrompt, bestScore };
  }

  private selectPrompt(task: string): string {
    // EXP3 selection strategy
    const totalWeight = Array.from(this.weights.values())
      .reduce((sum, w) => sum + w, 0);

    // Probability distribution
    const probabilities = new Map<string, number>();
    for (const [prompt, weight] of this.weights) {
      const prob = (1 - this.gamma) * (weight / totalWeight) +
                   this.gamma / this.weights.size;
      probabilities.set(prompt, prob);
    }

    // Sample
    const rand = Math.random();
    let cumulative = 0;

    for (const [prompt, prob] of probabilities) {
      cumulative += prob;
      if (rand <= cumulative) {
        return prompt;
      }
    }

    // fallback
    return Array.from(this.prompts.keys())[0];
  }

  private async evaluatePrompt(prompt: string, task: string): Promise<number> {
    // Evaluate on validation set
    const validationSet = await this.getValidationSet(task);
    let totalScore = 0;

    for (const example of validationSet) {
      const result = await this.executeWithPrompt(prompt, example.input);
      const score = this.compare(result, example.expected);
      totalScore += score;
    }

    const avgScore = totalScore / validationSet.length;

    // Update statistics
    const count = (this.counts.get(prompt) || 0) + 1;
    const currentScore = (this.scores.get(prompt) || 0);
    this.counts.set(prompt, count);
    this.scores.set(prompt, currentScore + avgScore);

    return avgScore;
  }

  private updateWeights(prompt: string, score: number): void {
    // EXP3 weight update
    const count = this.counts.get(prompt) || 0;
    const avgScore = score;

    // Estimate reward
    const estimatedReward = avgScore / this.getProbability(prompt);

    // Update weight
    const currentWeight = this.weights.get(prompt) || 1;
    const newWeight = currentWeight * Math.exp(
      (this.gamma / this.weights.size) * estimatedReward
    );

    this.weights.set(prompt, newWeight);
  }

  private getProbability(prompt: string): number {
    const totalWeight = Array.from(this.weights.values())
      .reduce((sum, w) => sum + w, 0);
    const weight = this.weights.get(prompt) || 1;

    return (1 - this.gamma) * (weight / totalWeight) +
           this.gamma / this.weights.size;
  }
}
```

## 🔬 Advanced Block 6: Multi-Model Router

### Concept

**Multi-Model Routing**: Intelligently select the most suitable model.

### Implementation

```typescript
class MultiModelRouter implements BuildingBlock {
  private models: Model[] = [
    { name: "local-small", cost: 0, speed: 100, quality: 0.7 },
    { name: "local-medium", cost: 0, speed: 50, quality: 0.85 },
    { name: "cloud-fast", cost: 0.001, speed: 30, quality: 0.8 },
    { name: "cloud-high-quality", cost: 0.01, speed: 10, quality: 0.95 }
  ];

  private taskHistory: Map<string, TaskHistory[]> = new Map();

  async process(
    input: { task: string; priority: "speed" | "quality" | "cost" },
    context: Context
  ): Promise<{ response: string; modelUsed: string; metrics: any }> {

    // 1. Analyze task complexity
    const complexity = await this.assessComplexity(input.task);

    // 2. Select model
    const model = this.selectModel(complexity, input.priority);

    // 3. Execute
    const startTime = Date.now();
    const response = await this.executeWithModel(model, input.task);
    const duration = Date.now() - startTime;

    // 4. Record history
    this.recordHistory(input.task, model, {
      complexity,
      duration,
      response
    });

    // 5. Calculate metrics
    const metrics = {
      model: model.name,
      cost: model.cost,
      duration,
      complexity,
      quality: model.quality
    };

    return { response, modelUsed: model.name, metrics };
  }

  private async assessComplexity(task: string): Promise<number> {
    // Use rules + LLM to evaluate complexity
    let complexity = 0;

    // Rules
    complexity += task.length > 1000 ? 0.3 : 0;
    complexity += task.includes("code") ? 0.2 : 0;
    complexity += task.includes("analyze") ? 0.2 : 0;
    complexity += task.includes("creative") ? 0.3 : 0;

    // LLM evaluation
    const prompt = `
    Task: ${task}

    Evaluate task complexity (0-1), considering:
    - Required reasoning depth
    - Creativity requirements
    - Domain expertise needs

    Output only a number: 0.75
    `;

    // Use smallest model for evaluation
    const result = await this.executeWithModel(this.models[0], prompt);
    const llmScore = parseFloat(result.trim());

    return Math.min(1, complexity + llmScore * 0.5);
  }

  private selectModel(
    complexity: number,
    priority: "speed" | "quality" | "cost"
  ): Model {

    // Select based on priority and complexity
    if (priority === "speed") {
      // Choose fastest model
      return this.models.reduce((best, model) =>
        model.speed > best.speed ? model : best
      );
    } else if (priority === "cost") {
      // Choose cheapest model
      return this.models.reduce((best, model) =>
        model.cost < best.cost ? model : best
      );
    } else { // quality
      // Select based on complexity
      if (complexity > 0.8) {
        return this.models.find(m => m.name === "cloud-high-quality")!;
      } else if (complexity > 0.5) {
        return this.models.find(m => m.name === "local-medium")!;
      } else {
        return this.models.find(m => m.name === "local-small")!;
      }
    }
  }

  private async executeWithModel(
    model: Model,
    task: string
  ): Promise<string> {
    // Call specific model
    if (model.name.startsWith("local")) {
      return this.callLocalModel(model, task);
    } else {
      return this.callCloudModel(model, task);
    }
  }

  private recordHistory(
    task: string,
    model: Model,
    result: any
  ): void {
    const taskType = this.classifyTask(task);

    if (!this.taskHistory.has(taskType)) {
      this.taskHistory.set(taskType, []);
    }

    this.taskHistory.get(taskType)!.push({
      model: model.name,
      timestamp: Date.now(),
      ...result
    });

    // Keep last 100 records
    const history = this.taskHistory.get(taskType)!;
    if (history.length > 100) {
      history.shift();
    }
  }

  private classifyTask(task: string): string {
    // Simple classification
    if (task.includes("code")) return "code";
    if (task.includes("write")) return "writing";
    if (task.includes("analyze")) return "analysis";
    return "general";
  }
}
```

## 📚 Summary

### Key Points

1. **RSI**: Recursive self-improvement enhances quality
2. **Multi-Advisor**: Evaluate output from multiple perspectives
3. **Architecture Evolution**: Automatically search for optimal architecture
4. **Code Enhancement**: Self-write and improve code
5. **Prompt Optimization**: Optimize using EXP3
6. **Multi-Model Routing**: Intelligent model selection

### Application Scenarios

| Building Block | Suitable Scenarios |
|--------|----------|
| RSI | Need high-quality output |
| Multi-Advisor | Need multi-perspective validation |
| Architecture Evolution | Architecture design uncertain |
| Code Enhancement | Code generation tasks |
| Prompt Optimization | Prompt tuning |
| Multi-Model Routing | Cost-sensitive |

### Next Steps

- [Experimental Framework](../layer-04-experimentation/01-experimental-framework.md) - How to design experiments
- [Case Demos](../layer-04-experimentation/07-case-demos.md) - Complete experimental cases
