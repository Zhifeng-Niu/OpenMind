# Glossary

> Terminology explanations for key concepts in the Agent Building Guide

## 🔤 A

### Agent
An autonomous software entity capable of perceiving its environment, making decisions, and taking actions to achieve specific goals.

### Autonomy
The degree to which an Agent can operate independently without human intervention. Ranges from Level 0 (completely passive) to Level 4 (fully autonomous).

### Ablation Study
An experimental method that systematically removes components to understand each component's contribution to overall performance.

## 🔤 B

### Building Block
A reusable, composable module used to construct Agent systems. Includes perception, decision, action, memory, learning blocks, etc.

### Branch
A connector type that selects different processing paths based on conditions.

## 🔤 C

### Chain-of-Thought (CoT)
A prompting technique that guides LLMs to output step-by-step reasoning processes.

### Connector
A tool for composing building blocks. Includes pipe, branch, loop, parallel.

### Context
Runtime state information passed during Agent execution, including session ID, user information, etc.

### Control Variable
Variables kept constant during experiments to ensure only the independent variable affects results.

## 🔤 D

### Dependent Variable
The outcome variable measured in experiments to evaluate the effect of changes.

### Decision Block
A building block that uses LLM for reasoning, planning, and decision-making.

## 🔤 E

### Effect Size
A measure of the magnitude of an effect, independent of sample size. Common measures include Cohen's d.

### Evaluation Metric
Quantitative measures used to assess Agent performance, such as accuracy, response time, cost.

## 🔤 F

### Few-Shot Learning
A technique where LLMs learn new tasks from a small number of examples.

### Fine-tuning
The process of training a pre-trained model on specific data to adapt it to particular tasks.

## 🔤 G

### Goal Generation
The ability of an Agent to autonomously identify and formulate objectives to pursue.

### Ground Truth
The correct or true values used as reference for evaluating Agent outputs.

## 🔤 H

### Hallucination
When an LLM generates content that appears plausible but is actually incorrect or fabricated.

### Hypothesis
A testable prediction about the relationship between variables in an experiment.

## 🔤 I

### Independent Variable
The variable manipulated in experiments to observe its effect on dependent variables.

### Intrinsic Motivation
Internal drives that cause Agents to act without external rewards, such as curiosity or achievement.

### IMRAD
Standard structure for academic papers: Introduction, Methods, Results, and Discussion.

## 🔤 L

### LLM (Large Language Model)
A large-scale neural network trained on text data, capable of understanding and generating human language.

### Loop
A connector type that creates feedback loops, where output can feed back to input.

## 🔤 M

### Memory Block
A building block for storing and retrieving information. Includes short-term memory, long-term memory, etc.

### Multi-Agent System
A system composed of multiple interacting Agents working together to solve problems.

## 🔤 N

### N-Dimensional Positioning
A framework for describing Agent characteristics across 10 dimensions, used to compare and design Agents.

### N-Shot Learning
Learning from N examples in prompts, including zero-shot, few-shot, etc.

## 🔤 O

### Output
The result produced by a building block, including data and metadata.

## 🔤 P

### Parallel
A connector type that executes multiple building blocks simultaneously and aggregates results.

### Parameter Sweep
An experimental method that tests all combinations of parameters to find optimal configuration.

### Pipe
A connector type that connects building blocks sequentially, with data flowing through all blocks.

### Prompt
Input text provided to an LLM to guide its generation.

### Prompt Engineering
The art of designing effective prompts to get desired outputs from LLMs.

## 🔤 R

### RAG (Retrieval-Augmented Generation)
A technique that combines document retrieval with LLM generation to improve accuracy.

### ReAct
An Agent architecture that alternates between reasoning and acting.

### Reflection
A mechanism where an Agent analyzes and improves its own output.

### RSI (Recursive Self-Improvement)
A technique where Agents continuously improve output through self-feedback.

## 🔤 S

### Safety
Ensuring Agent behavior is harmless, reliable, and aligned with human values.

### Self-Attention
A mechanism in Transformer models that allows the model to weigh the importance of different parts of the input.

### Statistical Significance
The probability that experimental results are not due to random chance (typically p < 0.05).

### Supervised Learning
A machine learning paradigm where models learn from labeled examples.

## 🔤 T

### Task Completion Rate
The percentage of tasks that an Agent successfully completes.

### Token
The basic unit of text that LLMs process, which can be a word, character, or subword.

### Tool
An external function or API that an Agent can call to perform specific actions.

### Transfer Learning
A technique where knowledge learned in one domain is applied to another domain.

## 🔤 U

### Unsupervised Learning
A machine learning paradigm where models learn patterns from unlabeled data.

## 🔤 V

### Vector Database
A database optimized for storing and retrieving high-dimensional vectors, commonly used in RAG systems.

## 🔤 Z

### Zero-Shot Learning
The ability of LLMs to perform tasks without seeing any examples.

## 📊 Common Formulas

### F1 Score
```
F1 = 2 × (Precision × Recall) / (Precision + Recall)
```

### Cohen's d (Effect Size)
```
d = (μ1 - μ2) / σ_pooled
```

### Cost-Benefit Ratio
```
CBR = Score / Cost
```

### Hallucination Rate
```
Hallucination Rate = False Claims / Total Claims
```

## 📚 Related Resources

- [Troubleshooting](troubleshooting.md) - Solutions to common problems
- [Layer 1: Principles](../layer-01-principles/) - Theoretical foundations
- [Layer 2: Case Studies](../layer-02-case-studies/) - Real-world examples
