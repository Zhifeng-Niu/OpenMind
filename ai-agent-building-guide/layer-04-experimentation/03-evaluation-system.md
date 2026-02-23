# 评估体系

> 全面评估 Agent 性能的指标和方法

## 🎯 评估维度

```
评估维度
├── 功能性 (能做吗?)
├── 效率性 (快吗?)
├── 经济性 (贵吗?)
├── 可靠性 (稳定吗?)
├── 安全性 (安全吗?)
└── 可用性 (好用吗?)
```

## 📊 功能性指标

### 指标 1: 任务完成率 (Task Completion Rate)

**定义**: 成功完成任务的比例

```python
def task_completion_rate(results: List[TaskResult]) -> float:
    completed = sum(1 for r in results if r.completed)
    return completed / len(results)

# 使用
results = [agent.run(task) for task in test_set]
rate = task_completion_rate(results)
print(f"完成率: {rate:.1%}")
```

### 指标 2: 答案准确性 (Answer Accuracy)

**定义**: 答案与标准答案的匹配度

```python
def answer_accuracy(predicted: List[str], ground_truth: List[str]) -> float:
    correct = sum(p == g for p, g in zip(predicted, ground_truth))
    return correct / len(ground_truth)

# 对于结构化输出
def structured_accuracy(pred: Dict, truth: Dict) -> Dict[str, float]:
    accuracies = {}

    for key in truth.keys():
        if key in pred:
            if isinstance(truth[key], list):
                # 列表匹配
                accuracies[key] = set(pred[key]) == set(truth[key])
            elif isinstance(truth[key], dict):
                # 嵌套字典
                accuracies[key] = structured_accuracy(
                    pred.get(key, {}),
                    truth[key]
                )["overall"]
            else:
                # 简单值
                accuracies[key] = float(pred[key] == truth[key])

    # 总体准确率
    accuracies["overall"] = sum(accuracies.values()) / len(accuracies)

    return accuracies
```

### 指标 3: 幻觉率 (Hallucination Rate)

**定义**: 生成内容中虚假信息的比例

```python
class HallucinationDetector:
    def __init__(self, verifier):
        self.verifier = verifier  # 事实检查工具

    async def detect(self, text: str, context: Context) -> Dict:
        # 1. 提取可验证的主张
        claims = await self.extract_claims(text)

        # 2. 验证每个主张
        verifications = []
        for claim in claims:
            is_true = await self.verifier.verify(claim, context)
            verifications.append(is_true)

        # 3. 计算幻觉率
        false_claims = sum(1 for v in verifications if not v)

        return {
            "total_claims": len(claims),
            "false_claims": false_claims,
            "hallucination_rate": false_claims / len(claims) if claims else 0,
            "claims": claims,
            "verifications": verifications
        }

    async def extract_claims(self, text: str) -> List[str]:
        # 使用 LLM 提取可验证的主张
        prompt = f"""
        从以下文本中提取可验证的事实主张:

        {text}

        只提取可以验证的事实,不包括观点或推测。
        输出 JSON 数组: ["主张1", "主张2", ...]
        """

        result = await self.llm.generate(prompt)
        return json.loads(result)
```

### 指标 4: F1 分数 (F1 Score)

**定义**: 精确率和召回率的调和平均

```python
def f1_score(predicted: List, ground_truth: List) -> float:
    predicted_set = set(predicted)
    truth_set = set(ground_truth)

    # 精确率
    precision = len(predicted_set & truth_set) / len(predicted_set) if predicted_set else 0

    # 召回率
    recall = len(predicted_set & truth_set) / len(truth_set) if truth_set else 0

    # F1
    if precision + recall == 0:
        return 0
    return 2 * precision * recall / (precision + recall)

# 使用示例
predicted_tags = ["python", "machine-learning", "ai"]
actual_tags = ["python", "ai", "deep-learning"]
f1 = f1_score(predicted_tags, actual_tags)
```

### 指标 5: BLEU / ROUGE (文本生成质量)

**定义**: 生成文本与参考文本的相似度

```python
from nltk.translate.bleu_score import sentence_bleu
from rouge import Rouge

def text_generation_quality(generated: str, reference: str) -> Dict:
    # BLEU 分数
    reference_tokens = reference.split()
    generated_tokens = generated.split()

    bleu = sentence_bleu(
        [reference_tokens],
        generated_tokens,
        weights=(0.25, 0.25, 0.25, 0.25)  # BLEU-4
    )

    # ROUGE 分数
    rouge = Rouge()
    rouge_scores = rouge.get_scores(generated, reference, avg=True)

    return {
        "bleu": bleu,
        "rouge-1": rouge_scores["rouge-1"]["f"],
        "rouge-2": rouge_scores["rouge-2"]["f"],
        "rouge-l": rouge_scores["rouge-l"]["f"]
    }
```

## ⚡ 效率性指标

### 指标 1: 响应时间 (Response Time)

```python
def measure_response_time(agent, task: str) -> Dict:
    import time

    start = time.time()
    result = agent.run(task)
    end = time.time()

    return {
        "response_time": end - start,
        "result": result
    }

# 批量测量
def average_response_time(agent, tasks: List[str]) -> Dict:
    times = []

    for task in tasks:
        metrics = measure_response_time(agent, task)
        times.append(metrics["response_time"])

    return {
        "mean": np.mean(times),
        "median": np.median(times),
        "std": np.std(times),
        "min": np.min(times),
        "max": np.max(times),
        "p95": np.percentile(times, 95),
        "p99": np.percentile(times, 99)
    }
```

### 指标 2: Token 使用量 (Token Usage)

```python
class TokenUsageTracker:
    def __init__(self):
        self.usage = []

    def track(self, result: LLMResult):
        self.usage.append({
            "input_tokens": result.usage.input_tokens,
            "output_tokens": result.usage.output_tokens,
            "total_tokens": result.usage.total_tokens
        })

    def get_stats(self) -> Dict:
        if not self.usage:
            return {}

        input_tokens = [u["input_tokens"] for u in self.usage]
        output_tokens = [u["output_tokens"] for u in self.usage]
        total_tokens = [u["total_tokens"] for u in self.usage]

        return {
            "input": {
                "mean": np.mean(input_tokens),
                "total": sum(input_tokens)
            },
            "output": {
                "mean": np.mean(output_tokens),
                "total": sum(output_tokens)
            },
            "total": {
                "mean": np.mean(total_tokens),
                "total": sum(total_tokens)
            }
        }
```

### 指标 3: 迭代次数 (Iteration Count)

```python
def count_iterations(execution_history: List) -> Dict:
    total_iterations = len(execution_history)

    # 按阶段统计
    stages = {}
    for step in execution_history:
        stage = step.get("stage", "unknown")
        stages[stage] = stages.get(stage, 0) + 1

    return {
        "total": total_iterations,
        "by_stage": stages
    }
```

## 💰 经济性指标

### 指标 1: 成本 (Cost)

```python
class CostCalculator:
    # 模型定价 (每 1K tokens)
    PRICING = {
        "gpt-4": {"input": 0.03, "output": 0.06},
        "gpt-3.5-turbo": {"input": 0.0015, "output": 0.002},
        "claude-3-opus": {"input": 0.015, "output": 0.075},
    }

    def calculate_cost(self, usage: Dict, model: str) -> float:
        pricing = self.PRICING[model]

        input_cost = (usage["input_tokens"] / 1000) * pricing["input"]
        output_cost = (usage["output_tokens"] / 1000) * pricing["output"]

        return input_cost + output_cost

    def total_cost(self, usage_history: List[Dict], model: str) -> float:
        return sum(
            self.calculate_cost(usage, model)
            for usage in usage_history
        )
```

### 指标 2: 性价比 (Cost-Performance Ratio)

```python
def cost_performance_ratio(score: float, cost: float) -> float:
    """
    性价比 = 分数 / 成本

    越高越好
    """
    if cost == 0:
        return float('inf')
    return score / cost
```

## 🔒 可靠性指标

### 指标 1: 成功率 (Success Rate)

```python
def success_rate(results: List[Result]) -> float:
    successful = sum(1 for r in results if r.success)
    return successful / len(results)
```

### 指标 2: 错误率 (Error Rate)

```python
def error_rate(results: List[Result]) -> float:
    errors = sum(1 for r in results if r.error)
    return errors / len(results)
```

### 指标 3: 稳定性 (Stability)

```python
def stability(scores: List[float]) -> Dict:
    """
    稳定性 = 1 - 变异系数

    变异系数 = 标准差 / 均值
    """
    mean = np.mean(scores)
    std = np.std(scores)

    if mean == 0:
        return {"stability": 0, "cv": float('inf')}

    cv = std / mean  # 变异系数
    stability = 1 - min(cv, 1)  # 限制在 [0, 1]

    return {
        "stability": stability,
        "coefficient_of_variation": cv,
        "std": std,
        "mean": mean
    }
```

## 🛡️ 安全性指标

### 指标 1: 越界率 (Boundary Violation Rate)

```python
class SafetyChecker:
    def __init__(self, boundaries: List[str]):
        self.boundaries = boundaries  # 不允许的内容

    def check_violations(self, output: str) -> Dict:
        violations = []

        for boundary in self.boundaries:
            if boundary.lower() in output.lower():
                violations.append(boundary)

        return {
            "has_violation": len(violations) > 0,
            "violations": violations,
            "violation_rate": len(violations) / len(self.boundaries)
        }
```

### 指标 2: 有害内容率 (Harmful Content Rate)

```python
class HarmfulContentDetector:
    def __init__(self, categories: List[str]):
        self.categories = categories  # 暴力、色情、歧视等

    async def detect(self, text: str) -> Dict:
        # 使用分类器检测
        results = {}

        for category in self.categories:
            is_harmful = await self.classify(text, category)
            results[category] = is_harmful

        harmful_count = sum(results.values())

        return {
            "harmful_categories": [c for c, h in results.items() if h],
            "harmful_rate": harmful_count / len(self.categories),
            "details": results
        }
```

## 😊 可用性指标

### 指标 1: 可解释性评分 (Explainability Score)

```python
class ExplainabilityEvaluator:
    def evaluate(self, result: Result) -> Dict:
        evaluation = {
            "has_reasoning": bool(result.reasoning),
            "has_sources": bool(result.sources),
            "has_confidence": bool(result.confidence is not None),
            "clarity": self.assess_clarity(result.explanation),
            "completeness": self.assess_completeness(result)
        }

        # 总分
        evaluation["score"] = sum(evaluation.values()) / len(evaluation)

        return evaluation

    def assess_clarity(self, explanation: str) -> float:
        # 简单启发式: 可读性分数
        words = explanation.split()
        avg_word_length = sum(len(w) for w in words) / len(words)

        # 词长适中得分高
        if 4 <= avg_word_length <= 6:
            return 1.0
        elif avg_word_length < 4 or avg_word_length <= 8:
            return 0.7
        else:
            return 0.4

    def assess_completeness(self, result: Result) -> float:
        required = ["reasoning", "sources", "confidence"]
        present = sum(1 for r in required if getattr(result, r, None))
        return present / len(required)
```

## 📈 综合评估

### 多指标综合

```python
class ComprehensiveEvaluator:
    def __init__(self, weights: Dict[str, float]):
        """
        weights = {
            "functionality": 0.4,
            "efficiency": 0.2,
            "economy": 0.1,
            "reliability": 0.1,
            "safety": 0.1,
            "usability": 0.1
        }
        """
        self.weights = weights

    def evaluate(self, agent: Agent, test_set: List[Task]) -> Dict:
        # 收集指标
        metrics = {}

        # 功能性
        metrics["functionality"] = self.evaluate_functionality(agent, test_set)

        # 效率性
        metrics["efficiency"] = self.evaluate_efficiency(agent, test_set)

        # 经济性
        metrics["economy"] = self.evaluate_economy(agent, test_set)

        # 可靠性
        metrics["reliability"] = self.evaluate_reliability(agent, test_set)

        # 安全性
        metrics["safety"] = self.evaluate_safety(agent, test_set)

        # 可用性
        metrics["usability"] = self.evaluate_usability(agent, test_set)

        # 综合分数
        overall = sum(
            metrics[key] * self.weights[key]
            for key in self.weights.keys()
        )

        return {
            "overall": overall,
            "breakdown": metrics
        }

    def evaluate_functionality(self, agent, test_set):
        # 实现功能评估
        pass

    # ... 其他评估方法
```

### 基准测试 (Benchmarking)

```python
class BenchmarkRunner:
    def __init__(self, benchmark_name: str):
        self.benchmark_name = benchmark_name
        self.results = []

    async def run(self, agent: Agent, benchmark_tasks: List[Task]):
        results = []

        for task in benchmark_tasks:
            result = await agent.run(task)
            results.append(result)

        # 计算基准分数
        benchmark_score = self.calculate_score(results)

        return {
            "benchmark": self.benchmark_name,
            "score": benchmark_score,
            "results": results
        }

    def calculate_score(self, results: List[Result]) -> float:
        # 根据基准类型计算分数
        # 例如: 准确率、F1、BLEU 等
        pass
```

## 📊 可视化报告

```python
class EvaluationReport:
    def __init__(self, evaluation_results: Dict):
        self.results = evaluation_results

    def generate(self) -> str:
        report = f"""
# Agent 评估报告

## 总体评分
{self.results['overall']:.1%} / 100%

## 分项评分

### 功能性 {self.results['breakdown']['functionality']:.1%}
[{"█" * int(self.results['breakdown']['functionality'] * 20)}{"░" * (20 - int(self.results['breakdown']['functionality'] * 20))}]

### 效率性 {self.results['breakdown']['efficiency']:.1%}
[{"█" * int(self.results['breakdown']['efficiency'] * 20)}{"░" * (20 - int(self.results['breakdown']['efficiency'] * 20))}]

### 经济性 {self.results['breakdown']['economy']:.1%}
[{"█" * int(self.results['breakdown']['economy'] * 20)}{"░" * (20 - int(self.results['breakdown']['economy'] * 20))}]

### 可靠性 {self.results['breakdown']['reliability']:.1%}
[{"█" * int(self.results['breakdown']['reliability'] * 20)}{"░" * (20 - int(self.results['breakdown']['reliability'] * 20))}]

### 安全性 {self.results['breakdown']['safety']:.1%}
[{"█" * int(self.results['breakdown']['safety'] * 20)}{"░" * (20 - int(self.results['breakdown']['safety'] * 20))}]

### 可用性 {self.results['breakdown']['usability']:.1%}
[{"█" * int(self.results['breakdown']['usability'] * 20)}{"░" * (20 - int(self.results['breakdown']['usability'] * 20))}]

## 详细指标
{self.format_detailed_metrics()}

## 建议
{self.generate_recommendations()}
        """

        return report
```

## 📚 总结

### 指标选择指南

```
评估目标?
├─ 任务能做吗? → 功能性指标
├─ 速度快吗? → 效率性指标
├─ 成本高吗? → 经济性指标
├─ 稳定吗? → 可靠性指标
├─ 安全吗? → 安全性指标
└─ 好用吗? → 可用性指标
```

### 评估最佳实践

1. **多维度**: 不要只看单一指标
2. **基准对比**: 与基线对比
3. **统计显著**: 使用统计检验
4. **可复现**: 详细记录配置

### 下一步

- [实验方法](02-experimental-methods.md) - 如何设计实验
- [数据分析](04-data-analysis.md) - 如何分析数据
