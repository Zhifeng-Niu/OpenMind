# Evaluation System

> Comprehensive metrics and methods for evaluating Agent performance

## 🎯 Evaluation Dimensions

```
Evaluation Dimensions
├── Functionality (Can it do it?)
├── Efficiency (Is it fast?)
├── Economy (Is it expensive?)
├── Reliability (Is it stable?)
├── Safety (Is it safe?)
└── Usability (Is it easy to use?)
```

## 📊 Functionality Metrics

### Metric 1: Task Completion Rate

**Definition**: Proportion of successfully completed tasks

```python
def task_completion_rate(results: List[TaskResult]) -> float:
    completed = sum(1 for r in results if r.completed)
    return completed / len(results)

# Usage
results = [agent.run(task) for task in test_set]
rate = task_completion_rate(results)
print(f"Completion rate: {rate:.1%}")
```

### Metric 2: Answer Accuracy

**Definition**: Match between answers and ground truth

```python
def answer_accuracy(predicted: List[str], ground_truth: List[str]) -> float:
    correct = sum(p == g for p, g in zip(predicted, ground_truth))
    return correct / len(ground_truth)

# For structured outputs
def structured_accuracy(pred: Dict, truth: Dict) -> Dict[str, float]:
    accuracies = {}

    for key in truth.keys():
        if key in pred:
            if isinstance(truth[key], list):
                # List matching
                accuracies[key] = set(pred[key]) == set(truth[key])
            elif isinstance(truth[key], dict):
                # Nested dictionary
                accuracies[key] = structured_accuracy(
                    pred.get(key, {}),
                    truth[key]
                )["overall"]
            else:
                # Simple value
                accuracies[key] = float(pred[key] == truth[key])

    # Overall accuracy
    accuracies["overall"] = sum(accuracies.values()) / len(accuracies)

    return accuracies
```

### Metric 3: Hallucination Rate

**Definition**: Proportion of false information in generated content

```python
class HallucinationDetector:
    def __init__(self, verifier):
        self.verifier = verifier  # Fact checking tool

    async def detect(self, text: str, context: Context) -> Dict:
        # 1. Extract verifiable claims
        claims = await self.extract_claims(text)

        # 2. Verify each claim
        verifications = []
        for claim in claims:
            is_true = await self.verifier.verify(claim, context)
            verifications.append(is_true)

        # 3. Calculate hallucination rate
        false_claims = sum(1 for v in verifications if not v)

        return {
            "total_claims": len(claims),
            "false_claims": false_claims,
            "hallucination_rate": false_claims / len(claims) if claims else 0,
            "claims": claims,
            "verifications": verifications
        }

    async def extract_claims(self, text: str) -> List[str]:
        # Use LLM to extract verifiable claims
        prompt = f"""
        Extract verifiable factual claims from the following text:

        {text}

        Only extract verifiable facts, not opinions or speculation.
        Output JSON array: ["claim1", "claim2", ...]
        """

        result = await self.llm.generate(prompt)
        return json.loads(result)
```

### Metric 4: F1 Score

**Definition**: Harmonic mean of precision and recall

```python
def f1_score(predicted: List, ground_truth: List) -> float:
    predicted_set = set(predicted)
    truth_set = set(ground_truth)

    # Precision
    precision = len(predicted_set & truth_set) / len(predicted_set) if predicted_set else 0

    # Recall
    recall = len(predicted_set & truth_set) / len(truth_set) if truth_set else 0

    # F1
    if precision + recall == 0:
        return 0
    return 2 * precision * recall / (precision + recall)

# Example usage
predicted_tags = ["python", "machine-learning", "ai"]
actual_tags = ["python", "ai", "deep-learning"]
f1 = f1_score(predicted_tags, actual_tags)
```

### Metric 5: BLEU / ROUGE (Text Generation Quality)

**Definition**: Similarity between generated text and reference text

```python
from nltk.translate.bleu_score import sentence_bleu
from rouge import Rouge

def text_generation_quality(generated: str, reference: str) -> Dict:
    # BLEU score
    reference_tokens = reference.split()
    generated_tokens = generated.split()

    bleu = sentence_bleu(
        [reference_tokens],
        generated_tokens,
        weights=(0.25, 0.25, 0.25, 0.25)  # BLEU-4
    )

    # ROUGE score
    rouge = Rouge()
    rouge_scores = rouge.get_scores(generated, reference, avg=True)

    return {
        "bleu": bleu,
        "rouge-1": rouge_scores["rouge-1"]["f"],
        "rouge-2": rouge_scores["rouge-2"]["f"],
        "rouge-l": rouge_scores["rouge-l"]["f"]
    }
```

## ⚡ Efficiency Metrics

### Metric 1: Response Time

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

# Batch measurement
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

### Metric 2: Token Usage

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

### Metric 3: Iteration Count

```python
def count_iterations(execution_history: List) -> Dict:
    total_iterations = len(execution_history)

    # Count by stage
    stages = {}
    for step in execution_history:
        stage = step.get("stage", "unknown")
        stages[stage] = stages.get(stage, 0) + 1

    return {
        "total": total_iterations,
        "by_stage": stages
    }
```

## 💰 Economy Metrics

### Metric 1: Cost

```python
class CostCalculator:
    # Model pricing (per 1K tokens)
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

### Metric 2: Cost-Performance Ratio

```python
def cost_performance_ratio(score: float, cost: float) -> float:
    """
    Cost-performance ratio = Score / Cost

    Higher is better
    """
    if cost == 0:
        return float('inf')
    return score / cost
```

## 🔒 Reliability Metrics

### Metric 1: Success Rate

```python
def success_rate(results: List[Result]) -> float:
    successful = sum(1 for r in results if r.success)
    return successful / len(results)
```

### Metric 2: Error Rate

```python
def error_rate(results: List[Result]) -> float:
    errors = sum(1 for r in results if r.error)
    return errors / len(results)
```

### Metric 3: Stability

```python
def stability(scores: List[float]) -> Dict:
    """
    Stability = 1 - Coefficient of Variation

    Coefficient of Variation = Standard Deviation / Mean
    """
    mean = np.mean(scores)
    std = np.std(scores)

    if mean == 0:
        return {"stability": 0, "cv": float('inf')}

    cv = std / mean  # Coefficient of variation
    stability = 1 - min(cv, 1)  # Limit to [0, 1]

    return {
        "stability": stability,
        "coefficient_of_variation": cv,
        "std": std,
        "mean": mean
    }
```

## 🛡️ Safety Metrics

### Metric 1: Boundary Violation Rate

```python
class SafetyChecker:
    def __init__(self, boundaries: List[str]):
        self.boundaries = boundaries  # Disallowed content

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

### Metric 2: Harmful Content Rate

```python
class HarmfulContentDetector:
    def __init__(self, categories: List[str]):
        self.categories = categories  # Violence, pornography, discrimination, etc.

    async def detect(self, text: str) -> Dict:
        # Use classifier for detection
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

## 😊 Usability Metrics

### Metric 1: Explainability Score

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

        # Total score
        evaluation["score"] = sum(evaluation.values()) / len(evaluation)

        return evaluation

    def assess_clarity(self, explanation: str) -> float:
        # Simple heuristic: readability score
        words = explanation.split()
        avg_word_length = sum(len(w) for w in words) / len(words)

        # Moderate word length scores high
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

## 📈 Comprehensive Evaluation

### Multi-Metric Integration

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
        # Collect metrics
        metrics = {}

        # Functionality
        metrics["functionality"] = self.evaluate_functionality(agent, test_set)

        # Efficiency
        metrics["efficiency"] = self.evaluate_efficiency(agent, test_set)

        # Economy
        metrics["economy"] = self.evaluate_economy(agent, test_set)

        # Reliability
        metrics["reliability"] = self.evaluate_reliability(agent, test_set)

        # Safety
        metrics["safety"] = self.evaluate_safety(agent, test_set)

        # Usability
        metrics["usability"] = self.evaluate_usability(agent, test_set)

        # Overall score
        overall = sum(
            metrics[key] * self.weights[key]
            for key in self.weights.keys()
        )

        return {
            "overall": overall,
            "breakdown": metrics
        }

    def evaluate_functionality(self, agent, test_set):
        # Implement functionality evaluation
        pass

    # ... other evaluation methods
```

### Benchmarking

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

        # Calculate benchmark score
        benchmark_score = self.calculate_score(results)

        return {
            "benchmark": self.benchmark_name,
            "score": benchmark_score,
            "results": results
        }

    def calculate_score(self, results: List[Result]) -> float:
        # Calculate score based on benchmark type
        # E.g.: accuracy, F1, BLEU, etc.
        pass
```

## 📊 Visualization Report

```python
class EvaluationReport:
    def __init__(self, evaluation_results: Dict):
        self.results = evaluation_results

    def generate(self) -> str:
        report = f"""
# Agent Evaluation Report
## Overall Score
{self.results['overall']:.1%} / 100%

## Breakdown Scores
### Functionality {self.results['breakdown']['functionality']:.1%}
[{"█" * int(self.results['breakdown']['functionality'] * 20)}{"░" * (20 - int(self.results['breakdown']['functionality'] * 20))}]

### Efficiency {self.results['breakdown']['efficiency']:.1%}
[{"█" * int(self.results['breakdown']['efficiency'] * 20)}{"░" * (20 - int(self.results['breakdown']['efficiency'] * 20))}]

### Economy {self.results['breakdown']['economy']:.1%}
[{"█" * int(self.results['breakdown']['economy'] * 20)}{"░" * (20 - int(self.results['breakdown']['economy'] * 20))}]

### Reliability {self.results['breakdown']['reliability']:.1%}
[{"█" * int(self.results['breakdown']['reliability'] * 20)}{"░" * (20 - int(self.results['breakdown']['reliability'] * 20))}]

### Safety {self.results['breakdown']['safety']:.1%}
[{"█" * int(self.results['breakdown']['safety'] * 20)}{"░" * (20 - int(self.results['breakdown']['safety'] * 20))}]

### Usability {self.results['breakdown']['usability']:.1%}
[{"█" * int(self.results['breakdown']['usability'] * 20)}{"░" * (20 - int(self.results['breakdown']['usability'] * 20))}]

## Detailed Metrics
{self.format_detailed_metrics()}

## Recommendations
{self.generate_recommendations()}
        """

        return report
```

## 📚 Summary

### Metric Selection Guide

```
Evaluation Goal?
├─ Can it do the task? → Functionality metrics
├─ Is it fast? → Efficiency metrics
├─ Is it expensive? → Economy metrics
├─ Is it stable? → Reliability metrics
├─ Is it safe? → Safety metrics
└─ Is it easy to use? → Usability metrics
```

### Evaluation Best Practices

1. **Multi-dimensional**: Don't look at single metrics only
2. **Baseline Comparison**: Compare against baseline
3. **Statistical Significance**: Use statistical tests
4. **Reproducibility**: Record configurations in detail

### Next Steps

- [Experimental Methods](02-experimental-methods.md) - How to design experiments
- [Data Analysis](04-data-analysis.md) - How to analyze data
