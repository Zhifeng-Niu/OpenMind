# 高级构建块

> 前沿方向的构建块实现

## 🎯 本章目标

探索 Agent 系统的前沿方向,实现高级构建块。

1. 递归自我改进 (RSI)
2. 自我反思机制
3. 架构演化
4. 代码自我增强
5. Prompt 优化
6. 多模型路由

## 🔬 高级构建块 1: RSI Agent

### 概念

**递归自我改进 (Recursive Self-Improvement)**: Agent 通过自我反馈不断改进输出。

### N 维定位

```
自主性: 半自主 (1)
感知: 内部状态 (1)
时间: 短期循环 (1)
记忆: 短期 (1)
工具: LLM (0)
学习: 在线学习 (1)
社交: 孤立 (0)
目标: 质量最大化 (特殊)
安全: 输出约束 (1)
可解释: 可查询 (1)
```

### 实现

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

    // 初始生成
    currentOutput = await this.generate(input.task, input.context);
    currentQuality = await this.assessQuality(currentOutput, input.task);

    // 递归改进
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

    评估输出质量 (0-1),考虑:
    - 完整性
    - 准确性
    - 清晰度
    - 相关性

    只输出数字: 0.85
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return parseFloat(result.response.trim());
  }

  private async generateFeedback(output: string, task: string): Promise<string> {
    const prompt = `
    Task: ${task}

    Current Output:
    ${output}

    提供具体的改进建议,指出:
    1. 哪些部分需要改进
    2. 如何改进
    3. 缺少什么内容
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

    请根据反馈改进输出,保持整体结构,只修改需要改进的部分。
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return result.response;
  }

  private async regenerate(output: string, feedback: string): Promise<string> {
    const prompt = `
    Task: [从原任务中提取]

    Previous Attempt (有缺陷):
    ${output}

    Feedback:
    ${feedback}

    请重新生成,避免之前的错误。
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return result.response;
  }

  private async hybridImprove(output: string, feedback: string): Promise<string> {
    // 结合 refine 和 regenerate
    const refined = await this.refine(output, feedback);
    const regenerated = await this.regenerate(output, feedback);

    // 选择更好的版本
    const quality1 = await this.assessQuality(refined, "");
    const quality2 = await this.assessQuality(regenerated, "");

    return quality1 > quality2 ? refined : regenerated;
  }
}
```

## 🔬 高级构建块 2: 多顾问反思

### 概念

**多顾问反思**: 使用多个"顾问"从不同角度评估输出。

### 实现

```typescript
interface Advisor {
  name: string;
  focus: string; // 关注点
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

    // 依次调用每个顾问
    for (const advisor of this.advisors) {
      const feedback = await advisor.evaluate(refined, {
        task: input.task,
        previousFeedback: allFeedback
      });

      allFeedback.push(feedback);

      // 如果需要修订
      if (feedback.needsRevision) {
        refined = await this.applyRevision(refined, feedback);
      }
    }

    return { refined, feedback: allFeedback };
  }
}

// 具体顾问实现
class ConsistencyAdvisor implements Advisor {
  name = "consistency";
  focus = "逻辑一致性";

  async evaluate(output: string, context: any): Promise<Feedback> {
    const prompt = `
    检查以下文本的逻辑一致性:

    ${output}

    检查:
    - 前后矛盾
    - 逻辑漏洞
    - 因果关系错误

    输出 JSON:
    {
      "issues": ["问题1", "问题2"],
      "needsRevision": true,
      "suggestions": ["建议1", "建议2"]
    }
    `;

    const result = await this.llm.process({ prompt }, this.createContext());
    return JSON.parse(result.response);
  }
}

class FactCheckAdvisor implements Advisor {
  name = "fact-check";
  focus = "事实准确性";

  async evaluate(output: string, context: any): Promise<Feedback> {
    // 提取可验证的主张
    const claims = await this.extractClaims(output);

    // 验证每个主张
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

## 🔬 高级构建块 3: 架构演化

### 概念

**架构演化**: 自动搜索最优的 Agent 架构。

### 实现

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

    // 1. 初始化种群
    this.initializePopulation();

    // 2. 进化循环
    for (let gen = 0; gen < this.generations; gen++) {
      // 2.1 评估适应度
      await this.evaluatePopulation(input.task);

      // 2.2 选择
      const selected = this.select(this.populationSize / 2);

      // 2.3 交叉
      const offspring = this.crossover(selected);

      // 2.4 变异
      this.mutate(offspring);

      // 2.5 更新种群
      this.population = [...selected, ...offspring];

      // 2.6 记录最优
      const best = this.getBest();
      console.log(`Gen ${gen}: Best fitness = ${best.metadata.fitness}`);
    }

    // 3. 返回最优架构
    return this.getBest();
  }

  private initializePopulation(): void {
    for (let i = 0; i < this.populationSize; i++) {
      this.population.push(this.generateRandomArchitecture());
    }
  }

  private generateRandomArchitecture(): Architecture {
    const numLayers = Math.floor(Math.random() * 5) + 2; // 2-6 层
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
    // 实例化架构
    const agent = this.instantiate(arch);

    // 在测试集上评估
    const testCases = await this.getTestCases(task);
    let totalScore = 0;

    for (const testCase of testCases) {
      const result = await agent.process(testCase.input, this.createContext());
      const score = this.scoreResult(result, testCase.expected);
      totalScore += score;
    }

    // 考虑复杂度惩罚
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

      // 层交叉
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
    // 随机选择交叉点
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
      // 随机变异
      if (Math.random() < 0.3) {
        // 添加层
        arch.layers.push({
          type: this.randomLayerType(),
          config: this.randomLayerConfig()
        });
      }

      if (Math.random() < 0.2 && arch.layers.length > 2) {
        // 删除层
        const idx = Math.floor(Math.random() * arch.layers.length);
        arch.layers.splice(idx, 1);
      }

      if (Math.random() < 0.3) {
        // 修改层
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

## 🔬 高级构建块 4: 代码自我增强

### 概念

**代码自我增强**: Agent 可以编写、测试和改进自己的代码。

### 实现

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

    // 1. 生成初始代码 (如果不存在)
    let code = input.currentCode ||
               await this.generateCode(input.task);

    // 2. 生成测试
    const tests = await this.generateTests(code, input.task);

    // 3. 运行测试
    let testResults = await this.tester.run(code, tests);

    // 4. 如果失败,修复
    let iterations = 0;
    while (!testResults.allPassed && iterations < 5) {
      code = await this.fixCode(code, testResults.failures);
      testResults = await this.tester.run(code, tests);
      iterations++;
    }

    // 5. 优化代码
    code = await this.optimizeCode(code, testResults);

    // 6. 计算指标
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

    // 验证优化后代码仍然通过测试
    const optimized = this.extractCode(result.response);
    const newTestResults = await this.tester.run(optimized, "");

    return newTestResults.allPassed ? optimized : code;
  }
}
```

## 🔬 高级构建块 5: Prompt 优化器

### 概念

**Prompt 优化**: 使用多臂赌博机算法优化 Prompt。

### 实现

```typescript
class PromptOptimizer implements BuildingBlock {
  private prompts: Map<string, string> = new Map();
  private scores: Map<string, number> = new Map();
  private counts: Map<string, number> = new Map();

  // EXP3 算法参数
  private gamma = 0.5; // 探索率
  private weights: Map<string, number> = new Map();

  async process(
    input: { task: string; templates: string[] },
    context: Context
  ): Promise<{ bestPrompt: string; bestScore: number }> {

    // 初始化
    input.templates.forEach(template => {
      this.prompts.set(template, template);
      this.weights.set(template, 1.0);
      this.scores.set(template, 0);
      this.counts.set(template, 0);
    });

    // 优化循环
    for (let round = 0; round < 100; round++) {
      // 1. 选择 Prompt (EXP3)
      const prompt = this.selectPrompt(input.task);

      // 2. 执行并评估
      const score = await this.evaluatePrompt(prompt, input.task);

      // 3. 更新权重
      this.updateWeights(prompt, score);
    }

    // 返回最优
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
    // EXP3 选择策略
    const totalWeight = Array.from(this.weights.values())
      .reduce((sum, w) => sum + w, 0);

    // 概率分布
    const probabilities = new Map<string, number>();
    for (const [prompt, weight] of this.weights) {
      const prob = (1 - this.gamma) * (weight / totalWeight) +
                   this.gamma / this.weights.size;
      probabilities.set(prompt, prob);
    }

    // 采样
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
    // 在验证集上评估
    const validationSet = await this.getValidationSet(task);
    let totalScore = 0;

    for (const example of validationSet) {
      const result = await this.executeWithPrompt(prompt, example.input);
      const score = this.compare(result, example.expected);
      totalScore += score;
    }

    const avgScore = totalScore / validationSet.length;

    // 更新统计
    const count = (this.counts.get(prompt) || 0) + 1;
    const currentScore = (this.scores.get(prompt) || 0);
    this.counts.set(prompt, count);
    this.scores.set(prompt, currentScore + avgScore);

    return avgScore;
  }

  private updateWeights(prompt: string, score: number): void {
    // EXP3 权重更新
    const count = this.counts.get(prompt) || 0;
    const avgScore = score;

    // 估计奖励
    const estimatedReward = avgScore / this.getProbability(prompt);

    // 更新权重
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

## 🔬 高级构建块 6: 多模型路由

### 概念

**多模型路由**: 智能选择最适合的模型。

### 实现

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

    // 1. 分析任务复杂度
    const complexity = await this.assessComplexity(input.task);

    // 2. 选择模型
    const model = this.selectModel(complexity, input.priority);

    // 3. 执行
    const startTime = Date.now();
    const response = await this.executeWithModel(model, input.task);
    const duration = Date.now() - startTime;

    // 4. 记录历史
    this.recordHistory(input.task, model, {
      complexity,
      duration,
      response
    });

    // 5. 计算指标
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
    // 使用规则 + LLM 评估复杂度
    let complexity = 0;

    // 规则
    complexity += task.length > 1000 ? 0.3 : 0;
    complexity += task.includes("code") ? 0.2 : 0;
    complexity += task.includes("analyze") ? 0.2 : 0;
    complexity += task.includes("creative") ? 0.3 : 0;

    // LLM 评估
    const prompt = `
    Task: ${task}

    评估任务复杂度 (0-1),考虑:
    - 需要的推理深度
    - 创造性要求
    - 专业知识需求

    只输出数字: 0.75
    `;

    // 使用最小模型评估
    const result = await this.executeWithModel(this.models[0], prompt);
    const llmScore = parseFloat(result.trim());

    return Math.min(1, complexity + llmScore * 0.5);
  }

  private selectModel(
    complexity: number,
    priority: "speed" | "quality" | "cost"
  ): Model {

    // 根据优先级和复杂度选择
    if (priority === "speed") {
      // 选择最快的模型
      return this.models.reduce((best, model) =>
        model.speed > best.speed ? model : best
      );
    } else if (priority === "cost") {
      // 选择最便宜的模型
      return this.models.reduce((best, model) =>
        model.cost < best.cost ? model : best
      );
    } else { // quality
      // 根据复杂度选择
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
    // 调用具体模型
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

    // 保持最近 100 条
    const history = this.taskHistory.get(taskType)!;
    if (history.length > 100) {
      history.shift();
    }
  }

  private classifyTask(task: string): string {
    // 简单分类
    if (task.includes("code")) return "code";
    if (task.includes("write")) return "writing";
    if (task.includes("analyze")) return "analysis";
    return "general";
  }
}
```

## 📚 总结

### 关键要点

1. **RSI**: 递归自我改进提升质量
2. **多顾问**: 多角度评估输出
3. **架构演化**: 自动搜索最优架构
4. **代码增强**: 自我编写和改进代码
5. **Prompt 优化**: 使用 EXP3 优化
6. **多模型路由**: 智能模型选择

### 应用场景

| 构建块 | 适用场景 |
|--------|----------|
| RSI | 需要高质量输出 |
| 多顾问 | 需要多角度验证 |
| 架构演化 | 架构设计不确定 |
| 代码增强 | 代码生成任务 |
| Prompt 优化 | Prompt 调优 |
| 多模型路由 | 成本敏感 |

### 下一步

- [实验框架](../layer-04-experimentation/01-experimental-framework.md) - 如何设计实验
- [案例演示](../layer-04-experimentation/07-case-demos.md) - 完整实验案例
