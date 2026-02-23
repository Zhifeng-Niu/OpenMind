# 术语表

> AI Agent 领域的关键术语解释

## A

**Agent (智能体)**
能够感知环境、做出决策并执行行动的自主系统。

**Agent Loop (Agent 循环)**
Agent 的核心执行循环: 感知 → 决策 → 行动 → 记忆。

**Autonomy (自主性)**
Agent 在没有人类干预情况下行动的能力。

## B

**Building Block (构建块)**
可组合的 Agent 组件,遵循统一接口。

**Benchmark (基准测试)**
用于评估 Agent 性能的标准测试集。

## C

**Chain of Thought (CoT, 思维链)**
让 LLM 展示推理过程的技术,通过"一步步思考"提升复杂任务表现。

**Context (上下文)**
提供给 LLM 的背景信息,包括对话历史、任务描述等。

**Context Window (上下文窗口)**
LLM 能处理的最大文本长度。

**Completion (补全)**
LLM 根据提示生成的文本。

**Conversation History (对话历史)**
Agent 与用户或系统的对话记录。

## D

**Decoding (解码)**
从模型输出生成文本的过程。

**Distillation (蒸馏)**
将大模型知识迁移到小模型的技术。

**Dreaming (梦境)**
Agent 在"睡眠"状态重整记忆的过程。

## E

**Embedding (嵌入)**
将文本转换为向量表示的技术。

**Epoch (轮次)**
训练数据被完整使用的次数。

**Evolution (进化)**
通过选择、交叉、变异优化 Agent 架构的方法。

**Explosion (梯度爆炸)**
梯度在反向传播中变得极大的问题。

## F

**Fine-tuning (微调)**
在预训练模型基础上进行额外训练。

**Few-shot Learning (少样本学习)**
只用少量示例学习新任务。

**Foundation Model (基础模型)**
在大规模数据上预训练的通用模型。

**Function Calling (函数调用)**
LLM 调用外部工具的能力。

## G

**Generation (生成)**
LLM 产生新文本的过程。

**Grounding (接地)**
将符号与真实世界连接的过程。

**Guardrails (护栏)**
防止 Agent 产生有害输出的约束。

## H

**Hallucination (幻觉)**
LLM 生成虚假或不合理内容的现象。

**Hyperparameter (超参数)**
训练前设置的参数,如学习率、层数等。

**Hypothesis (假设)**
实验要验证的命题。

## I

**Inference (推理)**
使用训练好的模型进行预测。

**Iteration (迭代)**
重复执行过程以改进结果。

**In-context Learning (上下文学习)**
通过提示中的示例学习,不更新权重。

## L

**LLM (Large Language Model, 大语言模型)**
在海量文本数据上训练的神经网络模型。

**Latent Space (潜在空间)**
模型内部的高维表示空间。

**Learning Rate (学习率)**
优化算法中控制更新步长的参数。

**Logit (逻辑值)**
模型输出层的原始值,经过 softmax 成为概率。

**Loss Function (损失函数)**
衡量模型预测与目标差距的函数。

## M

**Memory (记忆)**
Agent 存储和检索信息的能力。

**Memory Consolidation (记忆巩固)**
将短期记忆转移为长期记忆的过程。

**Multi-Agent (多 Agent)**
多个 Agent 协作或竞争的系统。

**Multimodal (多模态)**
处理多种数据类型(文本、图像、音频等)的模型。

## N

**N-dimensional Space (N 维空间)**
用于描述 Agent 设计的多维特征空间。

**Neural Network (神经网络)**
受人脑启发的计算模型。

**Normalization (归一化)**
将数据缩放到标准范围的技术。

## O

**Orchestration (编排)**
协调多个组件或 Agent 的过程。

**Overfitting (过拟合)**
模型在训练数据上表现好但泛化差。

**Output (输出)**
Agent 产生的结果。

## P

**Parameter (参数)**
模型的可学习权重。

**Perception (感知)**
Agent 获取环境信息的过程。

**Prompt (提示)**
给 LLM 的输入文本。

**Prompt Engineering (提示工程)**
设计优化提示的技术。

**Prompt Template (提示模板)**
可复用的提示结构。

## R

**ReAct (Reasoning + Acting)**
结合推理和行动的 Agent 模式。

**Recursive Self-Improvement (RSI, 递归自我改进)**
Agent 通过自我反馈不断提升输出的方法。

**Reinforcement Learning (强化学习)**
通过奖励信号学习最优策略的方法。

**Reflection (反思)**
Agent 审查和改进自己输出的过程。

**Replay (回放)**
重新处理记忆或经验的过程。

**RAG (Retrieval-Augmented Generation, 检索增强生成)**
结合外部知识检索的生成方法。

## S

**Sandbox (沙箱)**
隔离的执行环境,用于安全运行代码。

**Score (分数)**
评估 Agent 性能的数值。

**Self-Correction (自我修正)**
Agent 主动发现并修复错误的能力。

**State (状态)**
Agent 在特定时刻的完整信息。

**Sub-agent (子 Agent)**
大型 Agent 系统中的组成 Agent。

**Supervised Learning (监督学习)**
使用标注数据训练模型的方法。

## T

**Temperature (温度)**
控制 LLM 输出随机性的参数。

**Threshold (阈值)**
用于决策的临界值。

**Token**
文本的基本单位,可以是词、子词或字符。

**Top-p Sampling**
从累积概率达到 p 的最小集合中采样。

**Training (训练)**
优化模型参数的过程。

**Transformer**
基于自注意力的神经网络架构。

## U

**Uncertainty (不确定性)**
模型对预测的不确定程度。

**Underfitting (欠拟合)**
模型太简单无法拟合数据。

**Unsupervised Learning (无监督学习)**
不使用标注数据训练的方法。

## V

**Validation Set (验证集)**
用于调参和模型选择的数据集。

**Vector Database (向量数据库)**
存储和检索向量嵌入的数据库。

**Verification (验证)**
确认 Agent 输出正确性的过程。

## W

**Weight (权重)**
神经网络的连接参数。

**Working Memory (工作记忆)**
Agent 的短期信息存储。

**Workflow (工作流)**
任务执行的流程和步骤。

## Z

**Zero-shot Learning (零样本学习)**
没有任何示例直接完成任务。

## 缩写对照

| 缩写 | 全称 | 中文 |
|------|------|------|
| AI | Artificial Intelligence | 人工智能 |
| AGI | Artificial General Intelligence | 通用人工智能 |
| API | Application Programming Interface | 应用程序接口 |
| CoT | Chain of Thought | 思维链 |
| LLM | Large Language Model | 大语言模型 |
| RAG | Retrieval-Augmented Generation | 检索增强生成 |
| ReAct | Reasoning and Acting | 推理和行动 |
| RSI | Recursive Self-Improvement | 递归自我改进 |
| RNN | Recurrent Neural Network | 循环神经网络 |
| CNN | Convolutional Neural Network | 卷积神经网络 |
| NLP | Natural Language Processing | 自然语言处理 |
| CV | Computer Vision | 计算机视觉 |
| RL | Reinforcement Learning | 强化学习 |
| ML | Machine Learning | 机器学习 |
| DL | Deep Learning | 深度学习 |

## 相关概念关系

```
AI (人工智能)
├── ML (机器学习)
│   ├── DL (深度学习)
│   │   ├── LLM (大语言模型)
│   │   └── 其他神经网络
│   └── RL (强化学习)
└── 其他 AI 技术

Agent
├── Perception (感知)
├── Decision (决策)
├── Action (行动)
└── Memory (记忆)

LLM 能力
├── Generation (生成)
├── Understanding (理解)
├── Reasoning (推理)
└── Tool Use (工具使用)
```

## 常见错误认知

### ❌ Agent = LLM
**✅ 正确**: Agent 使用 LLM 作为决策引擎,但还包括记忆、工具等组件。

### ❌ Prompt Engineering = 模型训练
**✅ 正确**: Prompt Engineering 是设计输入,不改变模型权重。

### ❌ 多轮对话 = 长上下文
**✅ 正确**: 长上下文指单次处理大量文本,多轮对话是多次交互。

### ❌幻觉 = 错误
**✅ 正确**: 幻觉是模型"自信地"生成虚假内容,普通错误可能是不确定的。

## 延伸阅读

- [Layer 1: 原理与范式](../layer-01-principles/) - 深入理解 Agent
- [设计维度](../layer-01-principles/02-design-dimensions.md) - N 维设计空间
