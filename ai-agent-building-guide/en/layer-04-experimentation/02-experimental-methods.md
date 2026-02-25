# Experimental Methods

> Specific experimental techniques and implementation guides

## 🎯 Chapter Objectives

Provide detailed experimental methods to guide how to scientifically validate Agent innovation ideas.

## 📋 Table of Contents

1. Controlled Experiments
2. Parameter Tuning
3. Ablation Studies
4. Case Studies
5. User Studies
6. Longitudinal Tracking

## 🔬 Method 1: Controlled Experiments

### Purpose

Validate whether an innovation is truly effective.

### Core Principles

**Control Variables**: Only change one variable, keep others constant.

### Implementation Steps

#### Step 1: Define Hypothesis

```python
# Good hypothesis
hypothesis = """
If Agent is given a memory consolidation mechanism,
then accuracy on long-term memory tasks improves by 20%,
because consolidation reinforces important memories.
"""

# Elements:
# - Independent Variable: Presence/absence of memory consolidation
# - Dependent Variable: Long-term memory accuracy
# - Expected Effect: 20% improvement
# - Mechanism: Consolidation reinforces important memories
```

#### Step 2: Design Control and Treatment Groups

```python
class ExperimentDesign:
    def __init__(self):
        # Control group: Baseline Agent
        self.control = {
            "name": "Baseline Agent",
            "features": {
                "memory_consolidation": False,
                "other_features": "same_as_treatment"
            }
        }

        # Treatment group: Innovative Agent
        self.treatment = {
            "name": "Enhanced Agent",
            "features": {
                "memory_consolidation": True,  # Only difference
                "other_features": "same_as_control"
            }
        }

    def validate_design(self):
        # Validate only independent variable differs
        control_keys = set(self.control["features"].keys())
        treatment_keys = set(self.treatment["features"].keys())

        assert control_keys == treatment_keys, "Features must be the same"

        different = []
        for key in control_keys:
            if (self.control["features"][key] !=
                self.treatment["features"][key]):
                different.append(key)

        assert len(different) == 1, f"Only one variable should differ, found: {different}"
        print("✅ Experimental design valid")
```

#### Step 3: Prepare Test Data

```python
class TestDataset:
    def __init__(self, task_type: str):
        self.task_type = task_type

    async def prepare(self):
        # 1. Collect data
        raw_data = await self.collect_data()

        # 2. Split dataset
        splits = self.split_data(raw_data)
        return {
            "train": splits["train"],    # For training (if needed)
            "val": splits["val"],        # For parameter tuning
            "test": splits["test"]       # For final evaluation
        }

    def split_data(self, data, ratio=(0.7, 0.15, 0.15)):
        n = len(data)
        train_end = int(n * ratio[0])
        val_end = train_end + int(n * ratio[1])

        # Random shuffle
        shuffled = random.sample(data, n)

        return {
            "train": shuffled[:train_end],
            "val": shuffled[train_end:val_end],
            "test": shuffled[val_end:]
        }
```

#### Step 4: Run Experiment

```python
import asyncio
from typing import List, Dict
import numpy as np
from scipy import stats

class ControlledExperiment:
    def __init__(self, control_agent, treatment_agent, test_data):
        self.control = control_agent
        self.treatment = treatment_agent
        self.test_data = test_data

    async def run(self) -> Dict:
        # Run control group
        control_results = []
        for example in self.test_data:
            result = await self.control.run(example)
            control_results.append(result)

        # Run treatment group
        treatment_results = []
        for example in self.test_data:
            result = await self.treatment.run(example)
            treatment_results.append(result)

        # Analyze results
        analysis = self.analyze(control_results, treatment_results)

        return {
            "control": control_results,
            "treatment": treatment_results,
            "analysis": analysis
        }

    def analyze(self, control, treatment):
        control_scores = [r.score for r in control]
        treatment_scores = [r.score for r in treatment]

        # Descriptive statistics
        stats_dict = {
            "control_mean": np.mean(control_scores),
            "control_std": np.std(control_scores),
            "treatment_mean": np.mean(treatment_scores),
            "treatment_std": np.std(treatment_scores),
            "improvement": (
                np.mean(treatment_scores) - np.mean(control_scores)
            ) / np.mean(control_scores) * 100
        }

        # Statistical testing
        t_stat, p_value = stats.ttest_ind(
            control_scores,
            treatment_scores
        )

        stats_dict["t_statistic"] = t_stat
        stats_dict["p_value"] = p_value
        stats_dict["significant"] = p_value < 0.05

        # Effect size (Cohen's d)
        pooled_std = sqrt(
            (len(control) - 1) * np.std(control_scores)**2 +
            (len(treatment) - 1) * np.std(treatment_scores)**2
        ) / (len(control) + len(treatment) - 2)

        cohens_d = (
            np.mean(treatment_scores) - np.mean(control_scores)
        ) / pooled_std

        stats_dict["effect_size"] = cohens_d

        return stats_dict
```

#### Step 5: Report Results

```python
class ExperimentReporter:
    def generate_report(self, experiment_results: Dict) -> str:
        analysis = experiment_results["analysis"]

        report = f"""
# Experimental Results Report
## Descriptive Statistics
- Control group mean: {analysis['control_mean']:.3f} ± {analysis['control_std']:.3f}
- Treatment group mean: {analysis['treatment_mean']:.3f} ± {analysis['treatment_std']:.3f}
- Improvement: {analysis['improvement']:.1f}%

## Statistical Testing
- t-statistic: {analysis['t_statistic']:.3f}
- p-value: {analysis['p_value']:.4f}
- Significance: {'Yes' if analysis['significant'] else 'No'} (α=0.05)

## Effect Size
- Cohen's d: {analysis['effect_size']:.3f}
- Interpretation: {self.interpret_effect_size(analysis['effect_size'])}

## Conclusion
{self.draw_conclusion(analysis)}
        """

        return report

    def interpret_effect_size(self, d: float) -> str:
        if abs(d) < 0.2:
            return "Small effect"
        elif abs(d) < 0.5:
            return "Medium effect"
        elif abs(d) < 0.8:
            return "Large effect"
        else:
            return "Very large effect"

    def draw_conclusion(self, analysis: Dict) -> str:
        if analysis["significant"] and analysis["improvement"] > 0:
            return "Treatment group significantly outperformed control group, hypothesis supported."
        elif analysis["significant"] and analysis["improvement"] < 0:
            return "Treatment group significantly underperformed control group, hypothesis rejected."
        else:
            return "No significant difference between groups, need more data or adjust experimental design."
```

---

## 🔬 Method 2: Parameter Tuning

### Purpose

Find optimal parameter configuration.

### Method Classification

#### Method 1: Grid Search

```python
class GridSearch:
    def __init__(self, agent_class, param_grid):
        """
        param_grid = {
            "temperature": [0.1, 0.5, 0.9, 1.3],
            "max_tokens": [500, 1000, 2000],
            "top_p": [0.8, 0.9, 1.0]
        }
        """
        self.agent_class = agent_class
        self.param_grid = param_grid

    def search(self, validation_data):
        # Generate all combinations
        from itertools import product
        keys = list(self.param_grid.keys())
        values = list(self.param_grid.values())

        all_combinations = []
        for combination in product(*values):
            params = dict(zip(keys, combination))
            all_combinations.append(params)

        print(f"Total {len(all_combinations)} combinations")

        results = []
        for i, params in enumerate(all_combinations):
            print(f"\n[{i+1}/{len(all_combinations)}] Testing: {params}")

            # Create Agent
            agent = self.agent_class(**params)

            # Evaluate
            score = self.evaluate(agent, validation_data)

            results.append({
                "params": params,
                "score": score
            })

        # Sort
        results.sort(key=lambda x: x["score"], reverse=True)

        return results

    def evaluate(self, agent, data):
        scores = []
        for example in data:
            result = agent.run(example)
            scores.append(result.score)
        return np.mean(scores)
```

#### Method 2: Random Search

```python
class RandomSearch:
    def __init__(self, agent_class, param_bounds, n_iter=50):
        """
        param_bounds = {
            "temperature": (0.0, 2.0),
            "max_tokens": (100, 4000),
            "top_p": (0.5, 1.0)
        }
        """
        self.agent_class = agent_class
        self.param_bounds = param_bounds
        self.n_iter = n_iter

    def search(self, validation_data):
        results = []

        for i in range(self.n_iter):
            # Random sampling
            params = self.sample_params()

            print(f"\n[{i+1}/{self.n_iter}] Testing: {params}")

            # Evaluate
            agent = self.agent_class(**params)
            score = self.evaluate(agent, validation_data)

            results.append({
                "params": params,
                "score": score
            })

        return sorted(results, key=lambda x: x["score"], reverse=True)

    def sample_params(self):
        params = {}
        for param, (low, high) in self.param_bounds.items():
            if isinstance(low, int) and isinstance(high, int):
                params[param] = random.randint(low, high)
            else:
                params[param] = random.uniform(low, high)
        return params
```

#### Method 3: Bayesian Optimization

```python
class BayesianOptimizer:
    def __init__(self, agent_class, param_bounds, n_iter=30):
        from skopt import Optimizer
        self.agent_class = agent_class
        self.param_bounds = list(param_bounds.values())
        self.param_names = list(param_bounds.keys())
        self.n_iter = n_iter

        # Create optimizer
        self.optimizer = Optimizer(
            dimensions=self.param_bounds,
            base_estimator="GP",
            n_initial_points=10
        )

    def search(self, validation_data):
        results = []

        for i in range(self.n_iter):
            # Suggest next point
            params_list = self.optimizer.ask(n_points=1)
            params = dict(zip(self.param_names, params_list[0]))

            print(f"\n[{i+1}/{self.n_iter}] Testing: {params}")

            # Evaluate
            agent = self.agent_class(**params)
            score = self.evaluate(agent, validation_data)

            # Tell optimizer the result
            self.optimizer.tell(params_list, -score)  # Minimize negative score

            results.append({
                "params": params,
                "score": score
            })

        return sorted(results, key=lambda x: x["score"], reverse=True)

    def evaluate(self, agent, data):
        scores = []
        for example in data:
            result = agent.run(example)
            scores.append(result.score)
        return np.mean(scores)
```

---

## 🔬 Method 3: Ablation Study

### Purpose

Validate each component's contribution.

### Implementation

```python
class AblationStudy:
    def __init__(self, full_agent_config, components):
        """
        components = ["memory", "tool_use", "reflection", "planning"]
        """
        self.full_config = full_agent_config
        self.components = components

    async def run(self, test_data):
        # 1. Full version
        full_agent = self.build_agent(self.full_config)
        full_score = await self.evaluate(full_agent, test_data)

        results = {
            "full": full_score,
            "ablations": {}
        }

        # 2. Remove each component
        for component in self.components:
            print(f"\nRemoving component: {component}")

            # Create configuration
            ablated_config = self.full_config.copy()
            ablated_config[component] = None

            # Build Agent
            ablated_agent = self.build_agent(ablated_config)

            # Evaluate
            score = await self.evaluate(ablated_agent, test_data)

            # Calculate contribution
            contribution = (full_score - score) / full_score

            results["ablations"][component] = {
                "score": score,
                "contribution": contribution
            }

        # 3. Analysis
        return self.analyze(results)

    def analyze(self, results):
        print("\n=== Ablation Study Analysis ===")
        print(f"Full version score: {results['full']:.3f}\n")

        # Sort components
        ablations = results["ablations"]
        sorted_components = sorted(
            ablations.items(),
            key=lambda x: x[1]["contribution"],
            reverse=True
        )

        for component, data in sorted_components:
            impact = "High" if data["contribution"] > 0.1 else "Medium" if data["contribution"] > 0.05 else "Low"
            print(f"{component}:")
            print(f"  - Score: {data['score']:.3f}")
            print(f"  - Contribution: {data['contribution']:.1%}")
            print(f"  - Impact: {impact}")

        return {
            "most_important": sorted_components[0][0],
            "least_important": sorted_components[-1][0]
        }
```

---

## 🔬 Method 4: Case Study

### Purpose

In-depth study of Agent behavior in specific scenarios.

### Implementation

```python
class CaseStudy:
    def __init__(self, agent, case_name):
        self.agent = agent
        self.case_name = case_name
        self.observations = []

    async def conduct(self, task: str):
        print(f"\n=== Case Study: {self.case_name} ===\n")

        # 1. Record initial state
        self.record_state("initial", {
            "task": task,
            "agent_config": self.agent.config
        })

        # 2. Execute and record
        result = await self.execute_with_observation(task)

        # 3. Analyze behavior
        analysis = self.analyze_behavior()

        # 4. Generate report
        report = self.generate_report(result, analysis)

        return report

    async def execute_with_observation(self, task: str):
        # Hook into Agent's execution process
        original_step = self.agent.step

        async def observed_step(*args, **kwargs):
            # Record pre-step
            self.record_state("pre_step", {
                "args": args,
                "kwargs": kwargs
            })

            # Execute
            result = await original_step(*args, **kwargs)

            # Record post-step
            self.record_state("post_step", {
                "result": result
            })

            return result

        # Replace step method
        self.agent.step = observed_step

        # Execute
        result = await self.agent.run(task)

        # Restore
        self.agent.step = original_step

        return result

    def record_state(self, phase: str, data: Dict):
        self.observations.append({
            "timestamp": datetime.now(),
            "phase": phase,
            "data": data
        })

    def analyze_behavior(self):
        # Analyze observation records
        analysis = {
            "total_steps": len([o for o in self.observations if o["phase"] == "post_step"]),
            "decisions": [],
            "patterns": []
        }

        # Extract decisions
        for obs in self.observations:
            if obs["phase"] == "post_step":
                if "decision" in obs["data"]:
                    analysis["decisions"].append(obs["data"]["decision"])

        # Identify patterns
        # ...

        return analysis

    def generate_report(self, result, analysis):
        report = f"""
# Case Study: {self.case_name}
## Task
{self.observations[0]['data']['task']}

## Execution Process
- Total steps: {analysis['total_steps']}

## Key Decisions
{self.format_decisions(analysis['decisions'])}

## Result
{result}

## Behavior Patterns
{self.format_patterns(analysis['patterns'])}
        """

        return report
```

---

## 📊 Data Analysis

### Visualization

```python
import matplotlib.pyplot as plt
import seaborn as sns

class ExperimentVisualizer:
    @staticmethod
    def plot_comparison(control_scores, treatment_scores):
        fig, axes = plt.subplots(1, 3, figsize=(15, 5))

        # Box plot
        axes[0].boxplot([control_scores, treatment_scores])
        axes[0].set_xticklabels(['Control', 'Treatment'])
        axes[0].set_ylabel('Score')
        axes[0].set_title('Score Distribution')

        # Histogram
        axes[1].hist(control_scores, alpha=0.5, label='Control', bins=20)
        axes[1].hist(treatment_scores, alpha=0.5, label='Treatment', bins=20)
        axes[1].set_xlabel('Score')
        axes[1].set_ylabel('Frequency')
        axes[1].set_title('Score Histogram')
        axes[1].legend()

        # Cumulative Distribution
        control_sorted = np.sort(control_scores)
        treatment_sorted = np.sort(treatment_scores)
        axes[2].plot(control_sorted, np.arange(1, len(control_sorted)+1) / len(control_sorted), label='Control')
        axes[2].plot(treatment_sorted, np.arange(1, len(treatment_sorted)+1) / len(treatment_sorted), label='Treatment')
        axes[2].set_xlabel('Score')
        axes[2].set_ylabel('CDF')
        axes[2].set_title('Cumulative Distribution')
        axes[2].legend()

        plt.tight_layout()
        plt.savefig('comparison.png', dpi=300)
        plt.show()

    @staticmethod
    def plot_ablation(ablation_results):
        components = list(ablation_results.keys())
        scores = [ablation_results[c] for c in components]

        plt.figure(figsize=(10, 6))
        plt.bar(components, scores)
        plt.xlabel('Component')
        plt.ylabel('Score')
        plt.title('Ablation Study')
        plt.xticks(rotation=45)
        plt.grid(True, axis='y')
        plt.tight_layout()
        plt.savefig('ablation.png', dpi=300)
        plt.show()

    @staticmethod
    def plot_learning_curve(scores_over_time):
        plt.figure(figsize=(10, 6))
        plt.plot(scores_over_time)
        plt.xlabel('Iteration')
        plt.ylabel('Score')
        plt.title('Learning Curve')
        plt.grid(True)
        plt.savefig('learning_curve.png', dpi=300)
        plt.show()
```

## 📚 Summary
### Method Selection Guide
```
Experimental Goal?
├─ Validate innovation → Controlled experiment
├─ Find optimal parameters → Parameter tuning
├─ Understand components → Ablation study
├─ Deep understanding → Case study
└─ Real-world effect → User study
```
### Experimental Checklist
- [ ] Clear hypothesis
- [ ] Variable control
- [ ] Sufficient data
- [ ] Statistical significance
- [ ] Reproducible
- [ ] Complete records

### Next Steps
- [Evaluation System](03-evaluation-system.md) - How to evaluate Agents
- [Data Analysis](04-data-analysis.md) - How to analyze experimental data
