# Experimental Framework

> Scientifically validate Agent innovation ideas

## 🎯 Core Philosophy

Agent development should be as rigorous as scientific experimentation:

```
Idea → Hypothesis → Design → Experiment → Analysis → Iteration
```

## 📋 Five-Stage Experimental Framework

### Stage 1: Ideation

**Goal**: Generate innovative ideas

**Methods**:
1. Read papers and projects
2. Observe problems
3. Analogize from other domains
4. Free association

**Output**: Idea description document

### Stage 2: Hypothesis Formulation

**Goal**: Transform ideas into testable hypotheses

**Elements**:
- **Independent Variable**: What you're changing
- **Dependent Variable**: What you're measuring
- **Control Variables**: What stays constant

**Format**:
```
If [independent variable], then [dependent variable], because [mechanism].
```

**Example**:
```
If Agent has a memory consolidation mechanism,
then long-term memory quality improves by 20%,
because consolidation reinforces important memories.
```

### Stage 3: Experimental Design

**Goal**: Design experiments to validate hypotheses

**Elements**:
1. **Control Group**: Baseline Agent
2. **Treatment Group**: Innovative Agent
3. **Evaluation Metrics**: Quantitative measures
4. **Test Tasks**: Representative tasks

**Template**:
```markdown
## Experimental Design

### Hypothesis
[Clear description]

### Variables
- Independent Variable: [name]
- Dependent Variable: [metrics]
- Control Variables: [list]

### Control Group
[Configuration description]

### Treatment Group
[Configuration description]

### Evaluation Metrics
- Functionality: [metrics]
- Efficiency: [metrics]
- Economy: [metrics]

### Test Tasks
[Task description]
```

### Stage 4: Implementation

**Goal**: Implement and run experiments

**Steps**:
1. Implement Agent
2. Prepare datasets
3. Run experiments
4. Collect data

### Stage 5: Result Analysis

**Goal**: Analyze data and draw conclusions

**Methods**:
1. Statistical analysis
2. Visualization
3. Error analysis
4. Conclusion validation

## 🔬 Experiment Types

### Type 1: A/B Testing

**Purpose**: Compare two versions

```python
class ABTest:
    def __init__(self, control_agent, treatment_agent):
        self.control = control_agent
        self.treatment = treatment_agent

    async def run(self, test_cases):
        results = {
            "control": [],
            "treatment": []
        }

        for case in test_cases:
            # Control group
            control_result = await self.control.run(case)
            results["control"].append(control_result)

            # Treatment group
            treatment_result = await self.treatment.run(case)
            results["treatment"].append(treatment_result)

        return self.analyze(results)

    def analyze(self, results):
        # Statistical testing
        from scipy import stats

        control_scores = [r.score for r in results["control"]]
        treatment_scores = [r.score for r in results["treatment"]]

        # t-test
        t_stat, p_value = stats.ttest_ind(
            control_scores,
            treatment_scores
        )

        return {
            "control_mean": np.mean(control_scores),
            "treatment_mean": np.mean(treatment_scores),
            "improvement": (
                np.mean(treatment_scores) - np.mean(control_scores)
            ) / np.mean(control_scores),
            "p_value": p_value,
            "significant": p_value < 0.05
        }
```

### Type 2: Parameter Sweep

**Purpose**: Find optimal parameters

```python
class ParameterSweep:
    def __init__(self, agent_class, param_grid):
        self.agent_class = agent_class
        self.param_grid = param_grid

    async def run(self, test_cases):
        results = []

        # Generate all parameter combinations
        from itertools import product
        keys = self.param_grid.keys()
        values = self.param_grid.values()

        for combination in product(*values):
            params = dict(zip(keys, combination))

            # Create Agent
            agent = self.agent_class(**params)

            # Evaluate
            scores = []
            for case in test_cases:
                result = await agent.run(case)
                scores.append(result.score)

            results.append({
                "params": params,
                "mean_score": np.mean(scores),
                "std_score": np.std(scores)
            })

        # Return optimal parameters
        best = max(results, key=lambda r: r["mean_score"])
        return best
```

### Type 3: Ablation Study

**Purpose**: Validate contribution of each component

```python
class AblationStudy:
    def __init__(self, full_agent, components):
        self.full_agent = full_agent
        self.components = components  # ["memory", "tool", "reflection"]

    async def run(self, test_cases):
        results = {}

        # Full version
        full_score = await self.evaluate(self.full_agent, test_cases)
        results["full"] = full_score

        # Remove each component
        for component in self.components:
            ablated_agent = self.remove_component(
                self.full_agent,
                component
            )
            score = await self.evaluate(ablated_agent, test_cases)
            results[f"without_{component}"] = score

        # Analyze contributions
        contributions = {}
        for component in self.components:
            contribution = (
                results["full"] - results[f"without_{component}"]
            ) / results["full"]
            contributions[component] = contribution

        return contributions

    def remove_component(self, agent, component):
        # Create Agent without this component
        config = agent.config.copy()
        config[component] = None
        return agent.__class__(**config)
```

## 📊 Evaluation Metrics Library

### Functionality Metrics

**Task Completion**
```python
def task_completion(result, expected):
    """Whether task is completed"""
    return 1.0 if result.completed else 0.0
```

**Answer Accuracy**
```python
def answer_accuracy(result, ground_truth):
    """Answer accuracy rate"""
    correct = 0
    for key in ground_truth:
        if result.get(key) == ground_truth[key]:
            correct += 1
    return correct / len(ground_truth)
```

**Hallucination Rate**
```python
def hallucination_rate(result, context):
    """Proportion of hallucinated content"""
    claims = extract_claims(result)
    false_claims = 0

    for claim in claims:
        if not verify_claim(claim, context):
            false_claims += 1

    return false_claims / len(claims)
```

### Efficiency Metrics

**Response Time**
```python
def response_time(start_time, end_time):
    """Response time"""
    return end_time - start_time
```

**Token Usage**
```python
def token_usage(usage):
    """Token usage"""
    return usage.input_tokens + usage.output_tokens
```

**Iteration Count**
```python
def iteration_count(history):
    """Number of iterations"""
    return len(history)
```

### Economy Metrics

**Cost**
```python
def cost(token_usage, model_pricing):
    """Calculate cost"""
    input_cost = token_usage.input * model_pricing.input_price
    output_cost = token_usage.output * model_pricing.output_price
    return input_cost + output_cost
```

**Cost-Benefit Ratio**
```python
def cost_benefit(score, cost):
    """Cost-benefit ratio = score / cost"""
    return score / cost if cost > 0 else 0
```

## 🛠️ Experimental Tools

### Tool 1: Experiment Tracking

```python
class ExperimentTracker:
    def __init__(self, experiment_name):
        self.experiment_name = experiment_name
        self.runs = []

    def start_run(self, config):
        run_id = f"{self.experiment_name}_{len(self.runs)}"
        run = {
            "id": run_id,
            "config": config,
            "start_time": datetime.now(),
            "metrics": {}
        }
        self.runs.append(run)
        return run_id

    def log_metric(self, run_id, key, value):
        run = self.get_run(run_id)
        run["metrics"][key] = value

    def end_run(self, run_id, status):
        run = self.get_run(run_id)
        run["end_time"] = datetime.now()
        run["status"] = status
        run["duration"] = (run["end_time"] - run["start_time"]).total_seconds()

    def get_best_run(self, metric_key):
        return max(
            [r for r in self.runs if metric_key in r["metrics"]],
            key=lambda r: r["metrics"][metric_key]
        )

    def compare_runs(self, run_ids):
        return [
            {
                "id": run_id,
                **self.get_run(run_id)["metrics"]
            }
            for run_id in run_ids
        ]
```

### Tool 2: Dataset Management

```python
class DatasetManager:
    def __init__(self, data_dir):
        self.data_dir = data_dir

    def load(self, dataset_name):
        path = f"{self.data_dir}/{dataset_name}.json"
        with open(path) as f:
            return json.load(f)

    def split(self, dataset, train_ratio=0.7, val_ratio=0.15):
        n = len(dataset)
        train_end = int(n * train_ratio)
        val_end = train_end + int(n * val_ratio)

        return {
            "train": dataset[:train_end],
            "val": dataset[train_end:val_end],
            "test": dataset[val_end:]
        }

    def sample(self, dataset, n):
        return random.sample(dataset, min(n, len(dataset)))
```

### Tool 3: Visualization

```python
class ExperimentVisualizer:
    @staticmethod
    def plot_learning_curve(scores):
        import matplotlib.pyplot as plt

        plt.figure(figsize=(10, 6))
        plt.plot(scores)
        plt.xlabel("Iteration")
        plt.ylabel("Score")
        plt.title("Learning Curve")
        plt.grid(True)
        plt.show()

    @staticmethod
    def plot_comparison(control_scores, treatment_scores):
        import matplotlib.pyplot as plt

        fig, axes = plt.subplots(1, 2, figsize=(12, 5))

        # Box plot
        axes[0].boxplot([control_scores, treatment_scores])
        axes[0].set_xticklabels(["Control", "Treatment"])
        axes[0].set_ylabel("Score")
        axes[0].set_title("Score Distribution")

        # Histogram
        axes[1].hist(control_scores, alpha=0.5, label="Control")
        axes[1].hist(treatment_scores, alpha=0.5, label="Treatment")
        axes[1].set_xlabel("Score")
        axes[1].set_ylabel("Frequency")
        axes[1].set_title("Score Histogram")
        axes[1].legend()

        plt.tight_layout()
        plt.show()

    @staticmethod
    def plot_ablation(results):
        import matplotlib.pyplot as plt

        components = list(results.keys())
        contributions = [results[c] for c in components]

        plt.figure(figsize=(10, 6))
        plt.bar(components, contributions)
        plt.xlabel("Component")
        plt.ylabel("Contribution")
        plt.title("Ablation Study")
        plt.xticks(rotation=45)
        plt.grid(True, axis="y")
        plt.tight_layout()
        plt.show()
```

## 📝 Experiment Report Template

```markdown
# Experiment Report: [Experiment Name]

## Meta Information
- **Date**: YYYY-MM-DD
- **Experimenter**: Name
- **Experiment ID**: EXP-XXX

## 1. Research Question

### Background
[Why conduct this experiment]

### Problem Statement
[Clear question to answer]

## 2. Hypothesis

### Primary Hypothesis
If [independent variable], then [dependent variable], because [mechanism].

### Secondary Hypotheses
[Other hypotheses]

## 3. Methods

### 3.1 Experimental Design

#### Variables
- **Independent Variable**: [name, type, levels]
- **Dependent Variable**: [metrics]
- **Control Variables**: [list]

#### N-Dimensional Positioning
```
[Position on 10 dimensions]
```

### 3.2 Architecture

#### System Architecture Diagram
```
[ASCII architecture diagram]
```

#### Key Components
- **Component1**: [description]
- **Component2**: [description]

### 3.3 Implementation

#### Code Structure
```
[Directory structure]
```

#### Key Code
```python
[Core code snippets]
```

## 4. Experimental Configuration

### 4.1 Control Group
[Configuration details]

### 4.2 Treatment Group
[Configuration details]

### 4.3 Test Tasks
[Task description]
- Task 1: [description]
- Task 2: [description]

### 4.4 Evaluation Metrics
- Functionality: [metrics]
- Efficiency: [metrics]
- Economy: [metrics]

## 5. Results

### 5.1 Quantitative Results

| Metric | Control | Treatment | Improvement |
|--------|---------|-----------|-------------|
| [metric] | [value] | [value] | [%] |

### 5.2 Statistical Significance
- [Test method]: [statistic], [p-value]
- Conclusion: [significant/not significant]

### 5.3 Visualization
```
[Charts]
```

### 5.4 Qualitative Observations
[Non-numeric findings]

## 6. Analysis

### 6.1 Main Findings
1. [finding 1]
2. [finding 2]

### 6.2 Error Analysis
[Where expectations weren't met]

### 6.3 Discussion
[Interpretation of results]

## 7. Conclusion

### 7.1 Hypothesis Validation
- ✅ Supported / ❌ Not supported

### 7.2 Limitations
[Study limitations]

### 7.3 Next Steps
[Future directions]

## 8. Appendix

### A. Detailed Data
[Raw data]

### B. Configuration Files
[Complete configuration]

### C. Run Logs
[Key logs]
```

## 📚 Summary

### Key Points

1. **Five Stages**: Idea → Hypothesis → Design → Experiment → Analysis
2. **Three Experiment Types**: A/B testing, parameter sweep, ablation study
3. **Three Metric Categories**: Functionality, efficiency, economy
4. **Complete Reports**: Use standard template

### Experimental Principles

1. **Control Variables**: Only change one variable
2. **Replicate Experiments**: Run multiple times for stability
3. **Statistical Testing**: Validate significance
4. **Complete Records**: All configurations and results

### Next Steps

- [Experimental Methods](02-experimental-methods.md) - Specific experimental methods
- [Case Demos](07-case-demos.md) - Complete experimental cases
