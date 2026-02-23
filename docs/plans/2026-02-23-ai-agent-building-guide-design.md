# AI Agent 构建指南 - 设计文档

> **创建日期:** 2026-02-23
> **目标读者:** Claude Code 用户
> **核心定位:** 支持一切可能的实验性 Agent 想法的元框架
> **形式:** 模块化模板系统

---

## 📋 执行摘要

本指南旨在创建一个**元框架(meta-framework)**,用于理解和构建 AI Agent 系统。与传统的"教你构建特定类型 Agent"的教程不同,本指南的核心思想是:

- **授人以渔,而非授人以鱼** - 不固定在特定 Agent 类型,而是提供理解 Agent 的思维框架
- **支持任何实验性想法** - 通过可组合的构建块,让任何创新想法都能快速实现
- **从 0 到部署的完整路径** - 理论、案例、模板、实战全覆盖

**核心理念:**
```
理解原理 → 学习模式 → 组合构建块 → 设计实验 → 快速验证
```

---

## 🏗️ 整体架构

### 四层模块化架构

```
┌─────────────────────────────────────────────────┐
│   Layer 4: 实验方法论层                          │
│   (如何设计、验证、迭代你的 Agent 想法)          │
├─────────────────────────────────────────────────┤
│   Layer 3: 构建块库                              │
│   (可组合的原子组件 + 连接器)                   │
├─────────────────────────────────────────────────┤
│   Layer 2: 案例解析层                            │
│   (OpenClaw 等案例的解构 + 设计模式提取)         │
├─────────────────────────────────────────────────┤
│   Layer 1: 原理与范式层                          │
│   (Agent 的第一性原理 + 设计维度)                │
└─────────────────────────────────────────────────┘
```

**设计原则:**
- 每层可独立使用
- 层与层之间可组合
- 支持自下而上或自上而下的学习路径

---

## Layer 1: 原理与范式层

**目标:** 理解 Agent 的本质,建立分析框架

### 1.1 Agent 的第一性原理

```
Agent = 感知 + 决策 + 行动 + 记忆
       │       │       │       │
       └───────┴───────┴───────┘
               │
        信息处理闭环
```

**核心观点:**
- Agent 不是某个特定产品,而是一种**信息处理模式**
- LLM 是"大脑",但 Agent = 大脑 + 手脚 + 记忆 + 反思
- 关键在于**闭环**:感知→决策→行动→反馈→感知

### 1.2 Agent 设计的 N 维空间

每个 Agent 都可以在以下维度上定位和设计:

| 维度 | 说明 | 可能的取值 |
|------|------|-----------|
| **自主性** | 独立决策程度 | 完全被动 → 半自主 → 完全自主 |
| **感知范围** | 能处理的信息类型 | 仅文本 → 多模态 → 任意数据流 |
| **时间视野** | 决策考虑的时间跨度 | 单次响应 → 短期规划 → 长期策略 |
| **记忆架构** | 信息存储方式 | 无状态 → 短期记忆 → 持久化知识库 |
| **工具使用** | 外部能力集成 | 固定工具集 → 动态工具发现 → 自我生成工具 |
| **学习能力** | 改进自身的方式 | 固定策略 → 在线学习 → 自我演化 |
| **社交性** | 与其他 Agent 的交互 | 孤立 → 协作 → 竞争 → 社会结构 |
| **目标类型** | 驱动目标的形式 | 固定指令 → 参数化目标 → 自生成目标 |
| **安全性** | 对行为的约束 | 无约束 → 规则约束 → 价值对齐 |
| **可解释性** | 决策过程的透明度 | 黑盒 → 可查询 → 完全可解释 |

**关键洞察:**
- 任何实验性想法都可以在这个 N 维空间中定位
- 创新往往发生在维度的极端或组合上
- 理解维度后,可以"设计"新类型的 Agent,而不是"选择"已有类型

### 1.3 通用架构模式

**模式 1: 循环处理模式**
```
输入 → 处理 → 输出 → 反馈 → 输入 ...
```
- ReAct 是这个模式的一个实例
- RSI (递归自我提升) 是带阈值的递归版本
- 任何需要迭代改进的想法都适用

**模式 2: 分层决策模式**
```
战略层 → 战术层 → 操作层
```
- 用于分解复杂任务
- 支持多时间尺度规划
- 允许在不同层级上实验

**模式 3: 分布式协作模式**
```
Agent A ↔ Agent B ↔ Agent C
    ↘         ↙       ↖
      协调层
```
- 任何多 Agent 系统
- 可探索: 通信协议、协调机制、拓扑结构

**模式 4: 记忆增强模式**
```
查询 → 向量检索 → 上下文注入 → 生成
```
- 不限于 RAG
- 可用于: 工具记忆、策略记忆、经验记忆

### 1.4 设计决策树

帮助在设计新 Agent 时做决策:

```
你的 Agent 需要持续改进吗?
├─ 是 → 进入演化系统设计分支
│   ├─ 需要修改自身代码吗?
│   │   ├─ 是 → 代码自生成 + 沙箱测试
│   │   └─ 否 → 参数/策略优化
│   └─ 改进基于什么?
│       ├─ 自身反馈 → RSI
│       ├─ 外部评价 → 强化学习
│       └─ 两者结合 → 混合优化
└─ 否 → 进入静态系统设计分支
    └─ 任务类型?
        ├─ 单次响应 → 简单对话 Agent
        ├─ 多步任务 → 规划型 Agent
        └─ 持续监控 → 守护进程 Agent
```

### 1.5 Claude Code 作为开发工具

- Claude Code 的 Agent 能力概述
- Skills、MCP、Tools 的使用方式
- 如何用 Claude Code 构建和测试 Agent 框架

---

## Layer 2: 案例解析层

**目标:** 通过解构真实项目,提取可复用的设计模式

### 2.1 OpenClaw 深度解构

#### 项目概述
- 定位: 生产级多通道 AI Agent 平台
- 核心功能: 统一接口支持 WhatsApp/Telegram/Signal 等多平台
- 技术栈: Node.js/TypeScript + 多 LLM 支持 + Docker 沙箱

#### 解构方法论

**解构维度 1: 信息流**
```
用户输入 → 通道适配 → 消息路由 →
LLM 处理 ← 工具调用 → 外部系统
    ↓
响应生成 → 通道适配 → 用户输出
```

**提取模式:**
- 通道抽象层: 如何统一不同通信平台
- 工具注册表: 如何动态发现和调用工具
- 消息中间件: 如何处理异步和并发

**解构维度 2: 控制流**
```
事件触发 → 权限检查 → 任务调度 →
执行监控 → 错误处理 → 结果记录
```

**提取模式:**
- 事件驱动架构
- 权限边界控制
- 执行状态机

**解构维度 3: 数据流**
```
原始数据 → 解析 → 验证 →
存储/检索 → 缓存策略 → 清理
```

**提取模式:**
- 数据生命周期管理
- 多存储引擎协调
- 向量检索集成

#### 代码组织结构
```
src/
├── agents/          # Agent 核心逻辑
├── channels/        # 通信通道适配器
├── tools/           # 工具集成
├── memory/          # 记忆管理
├── plugins/         # 插件系统
└── extensions/      # 扩展实现
```

#### 关键实现细节

**1. 多模型支持**
```typescript
// 统一的 LLM 接口
interface LLMProvider {
  chat(messages: Message[]): Promise<Response>;
  stream(messages: Message[]): AsyncIterator<Response>;
}

// 支持多种提供商
class ClaudeProvider implements LLMProvider { }
class OpenAIProvider implements LLMProvider { }
class GeminiProvider implements LLMProvider { }
```

**2. 工具调用系统**
```typescript
// 工具定义
interface Tool {
  name: string;
  description: string;
  parameters: JSONSchema;
  execute(params: any): Promise<Result>;
}

// 工具注册表
class ToolRegistry {
  register(tool: Tool): void;
  get(name: string): Tool;
  list(): Tool[];
}
```

**3. 插件系统**
```typescript
// 插件接口
interface Plugin {
  name: string;
  version: string;
  init(context: PluginContext): Promise<void>;
  dispose(): Promise<void>;
}
```

### 2.2 其他项目解构

| 项目 | 核心实验点 | 可提取模式 |
|------|-----------|-----------|
| AutoGPT | 自主任务分解 | 递归目标拆解 |
| OpenDevin | 代码自主生成 | 沙箱化执行 |
| EvoAgentX | 架构自动优化 | 神经进化搜索 |
| Spring AI | 递归反思 | 多顾问反馈链 |
| LangGraph | 状态机工作流 | 图化任务编排 |

每个项目的解构都遵循统一格式:
- **实验假设**: 作者想验证什么
- **核心创新**: 有什么独特设计
- **实现机制**: 技术上如何实现
- **可复用模式**: 可以抽象成什么通用模式
- **局限性**: 什么场景不适用

### 2.3 设计模式目录

提取所有可复用的设计模式,按功能分类:

**交互模式**
- 请求-响应
- 流式对话
- 主动推送
- 事件订阅

**协调模式**
- 中央协调器
- 点对点通信
- 发布-订阅
- 共享内存

**学习模式**
- 监督学习
- 强化学习
- 元学习
- 自监督学习

**演化模式**
- 遗传算法
- 梯度优化
- 搜索算法
- 混合策略

---

## Layer 3: 构建块库

**目标:** 提供可组合的原子组件,支持任何实验想法

### 3.1 核心构建块分类

```
构建块目录
│
├─ 感知构建块
│   ├─ 输入适配器
│   ├─ 数据解析器
│   └─ 上下文提取器
│
├─ 决策构建块
│   ├─ LLM 包装器
│   ├─ 推理引擎
│   ├─ 规划器
│   └─ 路由器
│
├─ 行动构建块
│   ├─ 工具调用器
│   ├─ 代码执行器
│   ├─ API 客户端
│   └─ 输出生成器
│
├─ 记忆构建块
│   ├─ 短期记忆
│   ├─ 长期存储
│   ├─ 向量检索
│   └─ 知识图谱
│
├─ 学习构建块
│   ├─ 反思器
│   ├─ 评估器
│   ├─ 优化器
│   └─ 演化器
│
├─ 协调构建块
│   ├─ 消息总线
│   ├─ 任务队列
│   ├─ 锁管理器
│   └─ 事件调度器
│
└─ 基础设施构建块
    ├─ 日志系统
    ├─ 监控系统
    ├─ 配置管理
    └─ 错误处理
```

### 3.2 构建块接口规范

每个构建块都遵循统一接口:

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

### 3.3 连接器系统

构建块通过连接器组合:

```typescript
interface Connector {
  // 数据流连接
  pipe(source: BuildingBlock, target: BuildingBlock): Pipeline;

  // 控制流连接
  branch(condition: (data: any) => boolean): Branch;

  // 反馈连接
  loop(condition: (data: any) => boolean): Loop;

  // 并行连接
  parallel(blocks: BuildingBlock[]): Parallel;
}
```

### 3.4 示例: 构建一个自定义 Agent

假设你想实验"带梦境处理的 Agent":

```typescript
// 1. 选择构建块
const awakeCycle = pipe(
  new InputAdapter(),
  new LLMWrapper(),
  new ToolCaller(),
  new OutputGenerator()
);

const dreamCycle = pipe(
  new MemoryReplay(),
  new DreamProcessor(),  // 自定义构建块
  new MemoryConsolidator()
);

// 2. 定义切换逻辑
const controller = branch(
  (data) => data.isSleeping
);

// 3. 组合
const agent = controller
  .when(true, dreamCycle)
  .when(false, awakeCycle)
  .build();
```

### 3.5 高级构建块: 自我演化系统

基于最新的研究成果,提供支持自我演化的构建块:

#### 3.5.1 递归自我提升 (RSI) 模块

```typescript
class RSIModule {
  async execute(task: Task): Promise<Result> {
    let output = await this.initialExecution(task);
    let complexity = this.assessComplexity(output);

    while (complexity < this.threshold) {
      output = await this.refine(output);
      complexity = this.assessComplexity(output);
    }
    return output;
  }
}
```

**应用场景:**
- 需要迭代改进的任务
- 递归优化问题
- 自我验证和修正

#### 3.5.2 自我反思机制

```typescript
class Reflector {
  async reflect(output: any, context: Context): Promise<Feedback> {
    const advisors = [
      new ConsistencyAdvisor(),
      new FactCheckAdvisor(),
      new OptimizationAdvisor()
    ];

    for (const advisor of advisors) {
      const feedback = await advisor.evaluate(output, context);
      if (feedback.needsRevision) {
        return feedback;
      }
    }
    return { needsRevision: false };
  }
}
```

**应用场景:**
- 多轮迭代验证
- 现实检查
- 质量控制

#### 3.5.3 架构演化引擎

```typescript
class Evolver {
  async evolve(currentArchitecture: Architecture): Promise<Architecture> {
    const candidates = await this.generateVariants(currentArchitecture);
    const scores = await this.evaluateCandidates(candidates);
    return this.selectBest(scores);
  }
}
```

**应用场景:**
- 自动架构搜索
- 神经进化
- 多目标优化

#### 3.5.4 自我代码增强

```typescript
class CodeSelfEnhancer {
  async enhance(): Promise<void> {
    const currentCode = await this.readOwnCode();
    const improvements = await this.llm.suggestImprovements(currentCode);

    for (const improvement of improvements) {
      const result = await this.testInSandbox(improvement);
      if (result.success) {
        await this.applyImprovement(improvement);
      }
    }
  }
}
```

**安全机制:**
- Docker 沙箱隔离
- 版本控制集成
- 回滚机制

#### 3.5.5 提示自适应优化

```typescript
class PromptOptimizer {
  private weights = new Map<string, number>();

  selectPrompt(): string {
    return this.exp3Algorithm();
  }

  updateWeights(promptId: string, reward: number) {
    // EXP3 权重更新算法
  }
}
```

**应用场景:**
- 元提示优化
- 多臂老虎机
- 自适应策略

#### 3.5.6 多模型智能路由

```typescript
class ModelRouter {
  async route(task: Task): Promise<LLMProvider> {
    const complexity = this.assessComplexity(task);
    const cost = this.estimateCost(task);

    if (complexity < 0.3 && cost < 0.01) {
      return this.localModel;  // DeepSeek/LlaMA
    } else if (complexity > 0.7) {
      return this.premiumModel;  // Claude Opus/GPT-4
    } else {
      return this.standardModel;
    }
  }
}
```

**路由策略:**
- 简单任务 → 本地模型
- 复杂推理 → 云端大模型
- 并行处理 → 多模型集成

### 3.6 构建块创建指南

教你如何创建新构建块:

**Step 1: 定义职责**
- 单一职责原则
- 明确输入输出

**Step 2: 实现接口**
- 继承基础类
- 实现 process 方法

**Step 3: 添加配置**
- 参数化关键行为
- 提供合理默认值

**Step 4: 编写测试**
- 单元测试
- 集成测试

**Step 5: 文档化**
- 功能说明
- 使用示例
- 适用场景

---

## Layer 4: 实验方法论层

**目标:** 教你如何设计、验证、迭代任何 Agent 想法

### 4.1 实验设计框架

**Phase 1: 构思阶段**
```
问题观察 → 假设形成 → 文献调研 →
差距分析 → 研究问题
```

**工具:**
- 想法记录模板
- 假设验证检查表
- 相关工作地图

**Phase 2: 设计阶段**
```
需求分析 → 架构设计 →
构建块选择 → 原型实现
```

**工具:**
- N 维空间定位图
- 设计决策树
- 构建块选择器

**Phase 3: 实现阶段**
```
最小实现 → 测试用例 →
基线对比 → 初步评估
```

**工具:**
- 快速原型模板
- 评估指标库
- 对比测试框架

**Phase 4: 验证阶段**
```
实验设计 → 数据收集 →
统计分析 → 结论提炼
```

**工具:**
- A/B 测试框架
- 统计显著性检验
- 结果可视化工具

**Phase 5: 迭代阶段**
```
结果分析 → 失败案例研究 →
新假设生成 → 下一轮实验
```

**工具:**
- 复盘模板
- 迭代规划器
- 版本对比工具

### 4.2 实验模板库

**模板 A: 新架构验证**
- 假设: 新架构在某方面优于现有方案
- 方法: 对照实验
- 指标: 性能、成本、质量
- 工具: 基准测试套件

**模板 B: 新组件探索**
- 假设: 新组件能解决特定问题
- 方法: 消融实验
- 指标: 组件贡献度
- 工具: 组件隔离测试

**模板 C: 新组合实验**
- 假设: 现有构建块的组合产生新能力
- 方法: 组合搜索
- 指标: 涌现能力
- 工具: 组合枚举器

**模板 D: 边界探索**
- 假设: 方法在特定条件下失效
- 方法: 压力测试
- 指标: 失效模式
- 工具: 边界测试生成器

### 4.3 评估指标体系

**功能性指标**
- 任务完成率
- 输出质量
- 错误率

**效率性指标**
- 响应延迟
- 吞吐量
- 资源消耗

**经济性指标**
- Token 成本
- 开发时间
- 维护成本

**可靠性指标**
- 稳定性
- 容错能力
- 恢复时间

**可演化性指标**
- 改进空间
- 扩展性
- 组合潜力

### 4.4 实验记录标准

每个实验都应该记录:

```markdown
# 实验报告模板

## 元信息
- 日期:
- 实验者:
- 实验ID:

## 实验设计
### 研究问题
[明确要验证的问题]

### 假设
[清晰的假设陈述]

### 方法
[实验设计细节]

## 实验结果
### 定量结果
[数据表格和图表]

### 定性观察
[非数值化的发现]

## 分析与结论
### 主要发现
[结论列表]

### 失败分析
[哪些地方没达到预期]

### 下一步
[后续实验方向]

## 可复现性
### 环境
[软件、硬件配置]

### 数据
[数据集来源]

### 代码
[代码仓库链接]
```

### 4.5 迭代优化策略

**策略 1: 快速试错**
- 最小可行实验
- 快速反馈循环
- 及早放弃死胡同

**策略 2: 渐进式改进**
- 单变量优化
- 控制对比
- 累积小胜利

**策略 3: 概念验证**
- 先验证核心假设
- 再完善实现
- 避免过度工程

**策略 4: 并行探索**
- 同时测试多个方向
- 比较不同方法
- 择优深化

### 4.6 从想法到运行的完整工作流

**Stage 1: 想法捕获**
```bash
# 快速记录灵感
agent idea capture "我想做一个会做梦的 Agent"
```

系统会引导你回答:
- 这个想法要解决什么问题?
- 与现有 Agent 的本质区别是什么?
- 核心假设是什么?
- 如何验证是否成功?

**Stage 2: 可行性分析**
系统自动分析:
- 在 N 维空间中的定位
- 需要哪些构建块
- 哪些已有,哪些需要创建
- 潜在的技术风险

**Stage 3: 原型设计**
- 生成最小架构图
- 选择构建块组合
- 生成初始配置
- 创建项目骨架

**Stage 4: 快速实现**
- 生成核心代码框架
- 提供测试用例模板
- 集成监控和日志

**Stage 5: 实验验证**
- 运行测试场景
- 收集评估数据
- 生成对比报告

**Stage 6: 迭代优化**
- 分析失败案例
- 生成改进建议
- 规划下一步实验

### 4.7 实验案例演示

**案例 1: 会做梦的 Agent**
- 想法: Agent 在"睡眠"时重整记忆
- N 维定位: 高记忆架构 + 内部处理循环
- 需要的构建块: 记忆重放器 + 梦境处理器 + 记忆巩固器
- 实现路径: 创建 3 个新构建块 + 组合现有块
- 验证方法: 对比有/无梦境周期的记忆质量

**案例 2: 自我怀疑的 Agent**
- 想法: Agent 对自己输出保持怀疑,主动寻找反例
- N 维定位: 高反思性 + 对抗性搜索
- 需要构建块: 反例生成器 + 置信度评估器 + 观点整合器
- 实现路径: 扩展反思器 + 添加对抗工具
- 验证方法: 测量幻觉率下降

**案例 3: 进化竞争的多 Agent 系统**
- 想法: 多个 Agent 竞争资源,优胜劣汰
- N 维定位: 社交性 + 学习性 + 竞争性
- 需要构建块: 资源管理器 + 竞争仲裁器 + 适应度评估器
- 实现路径: 新增竞争协调层
- 验证方法: 观察群体性能随代数变化

**案例 4: 量子叠加态的 Agent**
- 想法: 同时探索多个可能路径,根据反馈坍缩
- N 维定位: 高并行性 + 概率性决策
- 需要构建块: 路径生成器 + 并行执行器 + 状态坍缩器
- 实现路径: 概率工作流引擎
- 验证方法: 对比单路径 vs 多路径探索效率

### 4.8 前沿探索指南

**研究方向地图**
```
当前边界 → 可探索区域 → 未知领域

认知架构
├─ 当前: 反思、规划、工具使用
├─ 探索: 元认知、直觉推理、创造力
└─ 未知: 意识、自我意识、主观体验

学习机制
├─ 当前: 在线学习、迁移学习
├─ 探索: 终身学习、元学习、自主探索
└─ 未知: 通用学习、零样本泛化

社交智能
├─ 当前: 协作、通信
├─ 探索: 涌现组织、文化演化
└─ 未知: 集体意识、社会智能

自我演化
├─ 当前: 参数优化、提示优化
├─ 探索: 架构演化、代码自生成
└─ 未知: 递归自我提升、开放性进化
```

**开放问题列表**
- 如何定义和测量 Agent 的"创造力"?
- 如何让 Agent 产生真正的"新想法",而不是重组已有知识?
- 如何平衡自主性和安全性?
- 如何验证 Agent 是否具有"理解"而非只是模仿?
- 多 Agent 系统中如何涌现"群体智能"?

**实验伦理指南**
- 实验边界设定
- 风险评估框架
- 紧急停止机制
- 对齐性验证

---

## 补充部分

### 开发者工作台

为了支持快速实验,提供工具链:

**CLI 工具**
```bash
# 创建新实验项目
agent experiment create my-experiment

# 添加构建块
agent block add memory --type vector

# 运行实验
agent run --config config.yaml

# 评估结果
agent evaluate --baseline baseline.json

# 生成报告
agent report --format markdown
```

**配置管理**
```yaml
# experiment.yaml
name: "自我反思型写作助手"
hypothesis: "通过多轮反思可以提升写作质量"

dimensions:
  autonomy: "semi-autonomous"
  learning: "reflection-based"
  memory: "persistent"

architecture:
  blocks:
    - type: LLMWrapper
      config:
        model: "claude-opus-4"
    - type: Reflector
      config:
        iterations: 3
        advisors:
          - ConsistencyAdvisor
          - QualityAdvisor
    - type: MemoryStore
      config:
        type: "vector"
        embedder: "text-embedding-3"

evaluation:
  metrics:
    - TaskCompletionRate
    - OutputQuality
    - ReflectionEffectiveness
  baseline:
    type: "simple-llm"
```

---

## 附录

### 附录 A: 构建块完整目录

提供所有构建块的详细文档:
- 功能描述
- 接口定义
- 配置选项
- 使用示例
- 性能特征
- 已知限制
- 替代方案
- 相关构建块

### 附录 B: 评估指标库

提供所有可用的评估指标:
- 指标定义
- 计算方法
- 工具实现
- 适用场景
- 基准值

### 附录 C: 参考实现集合

收录高质量的开源实现:
- 按构建块分类
- 按模式分类
- 按应用场景分类
- 代码质量评估
- 学习难度评级

### 附录 D: 术语表

统一定义所有术语,避免歧义。

### 附录 E: 故障排除指南

常见问题和解决方案。

---

## 文档组织结构

最终文档将采用以下组织方式:

```
ai-agent-building-guide/
├── README.md (总览)
├── layer-01-principles/
│   ├── 01-first-principles.md
│   ├── 02-design-dimensions.md
│   ├── 03-architecture-patterns.md
│   └── 04-design-decision-tree.md
├── layer-02-case-studies/
│   ├── 01-openclaw-deconstruction.md
│   ├── 02-other-projects.md
│   └── 03-design-patterns.md
├── layer-03-building-blocks/
│   ├── 01-block-catalog.md
│   ├── 02-interface-spec.md
│   ├── 03-connector-system.md
│   ├── 04-creating-blocks.md
│   └── blocks/ (每个构建块的详细文档)
├── layer-04-experimentation/
│   ├── 01-experimental-framework.md
│   ├── 02-experiment-templates.md
│   ├── 03-evaluation-metrics.md
│   ├── 04-recording-standards.md
│   ├── 05-iteration-strategies.md
│   ├── 06-complete-workflow.md
│   ├── 07-case-demos.md
│   └── 08-frontier-exploration.md
├── tools/
│   ├── cli-spec.md
│   └── dashboard-spec.md
├── appendices/
│   ├── block-catalog.md
│   ├── metrics-library.md
│   ├── reference-implementations.md
│   ├── glossary.md
│   └── troubleshooting.md
└── examples/
    ├── dreaming-agent/
    ├── self-doubting-agent/
    ├── evolutionary-multiagent/
    └── quantum-superposition-agent/
```

---

## 执行计划

### 阶段 1: 设计阶段 (当前)
- ✅ Brainstorming 技能
- ✅ 设计文档撰写
- ⏳ 设计审核
- ⏳ 调用 writing-plans

### 阶段 2: 初稿撰写 (Ralph Loop)
```bash
/ralph-loop "根据设计文档,撰写指南的完整初稿。
每一章都包含:概念、原理、代码示例、练习。
输出 <promise>DRAFT_COMPLETE</promise>" \
  --completion-promise "DRAFT_COMPLETE" \
  --max-iterations 30
```

### 阶段 3: 审核和改进 (Ralph Loop)
```bash
/ralph-loop "审核指南初稿,搜索补充信息,修改完善内容。
每完成一轮审核输出 <promise>REVIEW_ROUND_N_COMPLETE</promise>" \
  --max-iterations 10
```

### 阶段 4: 示例实现 (Ralph Loop)
```bash
/ralph-loop "实现指南中的所有代码示例,确保可运行。
每个示例都包含:代码、测试、文档、运行说明。
输出 <promise>EXAMPLES_COMPLETE</promise>" \
  --completion-promise "EXAMPLES_COMPLETE"
```

---

## 设计完成 ✅

这个设计文档提供了一个**元框架**,可以支持任何实验性 Agent 想法,而不是固定在特定类型上。

**核心价值:**
1. **理解原理** (Layer 1) - 知道设计的自由度在哪里
2. **学习模式** (Layer 2) - 从成功案例中提取可复用的设计
3. **组合构建块** (Layer 3) - 像搭积木一样快速实现想法
4. **科学实验** (Layer 4) - 系统化地验证和迭代

**下一步:**
调用 writing-plans 技能创建详细的实现计划。
