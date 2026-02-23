# 实验方法

> 具体的实验技术和实施指南

## 🎯 章节目标

提供详细的实验方法,指导如何科学地验证 Agent 创新想法。

## 📋 目录

1. 对照实验
2. 参数调优
3. 消融研究
4. 案例研究
5. 用户研究
6. 长期跟踪

## 🔬 方法 1: 对照实验 (Controlled Experiments)

### 目的

验证某个创新是否真正有效。

### 核心原则

**控制变量**: 只改变一个变量,其他保持不变。

### 实施步骤

#### 步骤 1: 定义假设

```python
# 好的假设
hypothesis = """
如果给 Agent 添加记忆重整机制,
那么在长期记忆任务上的准确率提高 20%,
因为重整巩固了重要记忆。
"""

# 要素:
# - 自变量: 有无记忆重整
# - 因变量: 长期记忆准确率
# - 预期效果: 提高 20%
# - 机制: 巩固重要记忆
```

#### 步骤 2: 设计对照组和实验组

```python
class ExperimentDesign:
    def __init__(self):
        # 对照组: 基准 Agent
        self.control = {
            "name": "Baseline Agent",
            "features": {
                "memory_consolidation": False,
                "other_features": "same_as_treatment"
            }
        }

        # 实验组: 创新Agent
        self.treatment = {
            "name": "Enhanced Agent",
            "features": {
                "memory_consolidation": True,  # 唯一不同
                "other_features": "same_as_control"
            }
        }

    def validate_design(self):
        # 验证只有自变量不同
        control_keys = set(self.control["features"].keys())
        treatment_keys = set(self.treatment["features"].keys())

        assert control_keys == treatment_keys, "特征必须相同"

        different = []
        for key in control_keys:
            if (self.control["features"][key] !=
                self.treatment["features"][key]):
                different.append(key)

        assert len(different) == 1, f"只能有一个变量不同,发现: {different}"
        print("✅ 实验设计有效")
```

#### 步骤 3: 准备测试数据

```python
class TestDataset:
    def __init__(self, task_type: str):
        self.task_type = task_type

    async def prepare(self):
        # 1. 收集数据
        raw_data = await self.collect_data()

        # 2. 划分数据集
        splits = self.split_data(raw_data)
        return {
            "train": splits["train"],    # 用于训练(如需要)
            "val": splits["val"],        # 用于调参
            "test": splits["test"]       # 用于最终评估
        }

    def split_data(self, data, ratio=(0.7, 0.15, 0.15)):
        n = len(data)
        train_end = int(n * ratio[0])
        val_end = train_end + int(n * ratio[1])

        # 随机打乱
        shuffled = random.sample(data, n)

        return {
            "train": shuffled[:train_end],
            "val": shuffled[train_end:val_end],
            "test": shuffled[val_end:]
        }
```

#### 步骤 4: 运行实验

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
        # 运行对照组
        control_results = []
        for example in self.test_data:
            result = await self.control.run(example)
            control_results.append(result)

        # 运行实验组
        treatment_results = []
        for example in self.test_data:
            result = await self.treatment.run(example)
            treatment_results.append(result)

        # 分析结果
        analysis = self.analyze(control_results, treatment_results)

        return {
            "control": control_results,
            "treatment": treatment_results,
            "analysis": analysis
        }

    def analyze(self, control, treatment):
        control_scores = [r.score for r in control]
        treatment_scores = [r.score for r in treatment]

        # 描述统计
        stats_dict = {
            "control_mean": np.mean(control_scores),
            "control_std": np.std(control_scores),
            "treatment_mean": np.mean(treatment_scores),
            "treatment_std": np.std(treatment_scores),
            "improvement": (
                np.mean(treatment_scores) - np.mean(control_scores)
            ) / np.mean(control_scores) * 100
        }

        # 统计检验
        t_stat, p_value = stats.ttest_ind(
            control_scores,
            treatment_scores
        )

        stats_dict["t_statistic"] = t_stat
        stats_dict["p_value"] = p_value
        stats_dict["significant"] = p_value < 0.05

        # 效应量 (Cohen's d)
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

#### 步骤 5: 报告结果

```python
class ExperimentReporter:
    def generate_report(self, experiment_results: Dict) -> str:
        analysis = experiment_results["analysis"]

        report = f"""
# 实验结果报告

## 描述统计
- 对照组平均分: {analysis['control_mean']:.3f} ± {analysis['control_std']:.3f}
- 实验组平均分: {analysis['treatment_mean']:.3f} ± {analysis['treatment_std']:.3f}
- 改进幅度: {analysis['improvement']:.1f}%

## 统计检验
- t 统计量: {analysis['t_statistic']:.3f}
- p 值: {analysis['p_value']:.4f}
- 显著性: {'是' if analysis['significant'] else '否'} (α=0.05)

## 效应量
- Cohen's d: {analysis['effect_size']:.3f}
- 解释: {self.interpret_effect_size(analysis['effect_size'])}

## 结论
{self.draw_conclusion(analysis)}
        """

        return report

    def interpret_effect_size(self, d: float) -> str:
        if abs(d) < 0.2:
            return "小效应"
        elif abs(d) < 0.5:
            return "中等效应"
        elif abs(d) < 0.8:
            return "大效应"
        else:
            return "很大效应"

    def draw_conclusion(self, analysis: Dict) -> str:
        if analysis["significant"] and analysis["improvement"] > 0:
            return "实验组显著优于对照组,假设得到支持。"
        elif analysis["significant"] and analysis["improvement"] < 0:
            return "实验组显著差于对照组,假设被拒绝。"
        else:
            return "两组无显著差异,需要更多数据或调整实验设计。"
```

---

## 🔬 方法 2: 参数调优 (Parameter Tuning)

### 目的

找到最优的参数配置。

### 方法分类

#### 方法 1: 网格搜索 (Grid Search)

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
        # 生成所有组合
        from itertools import product
        keys = list(self.param_grid.keys())
        values = list(self.param_grid.values())

        all_combinations = []
        for combination in product(*values):
            params = dict(zip(keys, combination))
            all_combinations.append(params)

        print(f"总共 {len(all_combinations)} 种组合")

        results = []
        for i, params in enumerate(all_combinations):
            print(f"\n[{i+1}/{len(all_combinations)}] 测试: {params}")

            # 创建 Agent
            agent = self.agent_class(**params)

            # 评估
            score = self.evaluate(agent, validation_data)

            results.append({
                "params": params,
                "score": score
            })

        # 排序
        results.sort(key=lambda x: x["score"], reverse=True)

        return results

    def evaluate(self, agent, data):
        scores = []
        for example in data:
            result = agent.run(example)
            scores.append(result.score)
        return np.mean(scores)
```

#### 方法 2: 随机搜索 (Random Search)

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
            # 随机采样
            params = self.sample_params()

            print(f"\n[{i+1}/{self.n_iter}] 测试: {params}")

            # 评估
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

#### 方法 3: 贝叶斯优化 (Bayesian Optimization)

```python
class BayesianOptimizer:
    def __init__(self, agent_class, param_bounds, n_iter=30):
        from skopt import Optimizer
        self.agent_class = agent_class
        self.param_bounds = list(param_bounds.values())
        self.param_names = list(param_bounds.keys())
        self.n_iter = n_iter

        # 创建优化器
        self.optimizer = Optimizer(
            dimensions=self.param_bounds,
            base_estimator="GP",
            n_initial_points=10
        )

    def search(self, validation_data):
        results = []

        for i in range(self.n_iter):
            # 建议下一个点
            params_list = self.optimizer.ask(n_points=1)
            params = dict(zip(self.param_names, params_list[0]))

            print(f"\n[{i+1}/{self.n_iter}] 测试: {params}")

            # 评估
            agent = self.agent_class(**params)
            score = self.evaluate(agent, validation_data)

            # 告诉优化器结果
            self.optimizer.tell(params_list, -score)  # 最小化负分数

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

## 🔬 方法 3: 消融研究 (Ablation Study)

### 目的

验证每个组件的贡献。

### 实施

```python
class AblationStudy:
    def __init__(self, full_agent_config, components):
        """
        components = ["memory", "tool_use", "reflection", "planning"]
        """
        self.full_config = full_agent_config
        self.components = components

    async def run(self, test_data):
        # 1. 完整版本
        full_agent = self.build_agent(self.full_config)
        full_score = await self.evaluate(full_agent, test_data)

        results = {
            "full": full_score,
            "ablations": {}
        }

        # 2. 移除每个组件
        for component in self.components:
            print(f"\n移除组件: {component}")

            # 创建配置
            ablated_config = self.full_config.copy()
            ablated_config[component] = None

            # 构建 Agent
            ablated_agent = self.build_agent(ablated_config)

            # 评估
            score = await self.evaluate(ablated_agent, test_data)

            # 计算贡献
            contribution = (full_score - score) / full_score

            results["ablations"][component] = {
                "score": score,
                "contribution": contribution
            }

        # 3. 分析
        return self.analyze(results)

    def analyze(self, results):
        print("\n=== 消融研究分析 ===")
        print(f"完整版本分数: {results['full']:.3f}\n")

        # 排序组件
        ablations = results["ablations"]
        sorted_components = sorted(
            ablations.items(),
            key=lambda x: x[1]["contribution"],
            reverse=True
        )

        for component, data in sorted_components:
            impact = "高" if data["contribution"] > 0.1 else "中" if data["contribution"] > 0.05 else "低"
            print(f"{component}:")
            print(f"  - 分数: {data['score']:.3f}")
            print(f"  - 贡献: {data['contribution']:.1%}")
            print(f"  - 影响: {impact}")

        return {
            "most_important": sorted_components[0][0],
            "least_important": sorted_components[-1][0]
        }
```

---

## 🔬 方法 4: 案例研究 (Case Study)

### 目的

深入研究特定场景下的 Agent 行为。

### 实施

```python
class CaseStudy:
    def __init__(self, agent, case_name):
        self.agent = agent
        self.case_name = case_name
        self.observations = []

    async def conduct(self, task: str):
        print(f"\n=== 案例研究: {self.case_name} ===\n")

        # 1. 记录初始状态
        self.record_state("initial", {
            "task": task,
            "agent_config": self.agent.config
        })

        # 2. 执行并记录
        result = await self.execute_with_observation(task)

        # 3. 分析行为
        analysis = self.analyze_behavior()

        # 4. 生成报告
        report = self.generate_report(result, analysis)

        return report

    async def execute_with_observation(self, task: str):
        # Hook 到 Agent 的执行过程
        original_step = self.agent.step

        async def observed_step(*args, **kwargs):
            # 记录步骤前
            self.record_state("pre_step", {
                "args": args,
                "kwargs": kwargs
            })

            # 执行
            result = await original_step(*args, **kwargs)

            # 记录步骤后
            self.record_state("post_step", {
                "result": result
            })

            return result

        # 替换 step 方法
        self.agent.step = observed_step

        # 执行
        result = await self.agent.run(task)

        # 恢复
        self.agent.step = original_step

        return result

    def record_state(self, phase: str, data: Dict):
        self.observations.append({
            "timestamp": datetime.now(),
            "phase": phase,
            "data": data
        })

    def analyze_behavior(self):
        # 分析观察记录
        analysis = {
            "total_steps": len([o for o in self.observations if o["phase"] == "post_step"]),
            "decisions": [],
            "patterns": []
        }

        # 提取决策
        for obs in self.observations:
            if obs["phase"] == "post_step":
                if "decision" in obs["data"]:
                    analysis["decisions"].append(obs["data"]["decision"])

        # 识别模式
        # ...

        return analysis

    def generate_report(self, result, analysis):
        report = f"""
# 案例研究: {self.case_name}

## 任务
{self.observations[0]['data']['task']}

## 执行过程
- 总步数: {analysis['total_steps']}

## 关键决策
{self.format_decisions(analysis['decisions'])}

## 结果
{result}

## 行为模式
{self.format_patterns(analysis['patterns'])}
        """

        return report
```

---

## 📊 数据分析

### 可视化

```python
import matplotlib.pyplot as plt
import seaborn as sns

class ExperimentVisualizer:
    @staticmethod
    def plot_comparison(control_scores, treatment_scores):
        fig, axes = plt.subplots(1, 3, figsize=(15, 5))

        # 箱线图
        axes[0].boxplot([control_scores, treatment_scores])
        axes[0].set_xticklabels(['Control', 'Treatment'])
        axes[0].set_ylabel('Score')
        axes[0].set_title('Score Distribution')

        # 直方图
        axes[1].hist(control_scores, alpha=0.5, label='Control', bins=20)
        axes[1].hist(treatment_scores, alpha=0.5, label='Treatment', bins=20)
        axes[1].set_xlabel('Score')
        axes[1].set_ylabel('Frequency')
        axes[1].set_title('Score Histogram')
        axes[1].legend()

        # 累积分布
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

## 📚 总结

### 方法选择指南

```
实验目标?
├─ 验证创新 → 对照实验
├─ 找最优参数 → 参数调优
├─ 理解组件 → 消融研究
├─ 深入理解 → 案例研究
└─ 真实效果 → 用户研究
```

### 实验检查清单

- [ ] 假设清晰
- [ ] 变量控制
- [ ] 数据充分
- [ ] 统计显著
- [ ] 可复现
- [ ] 记录完整

### 下一步

- [评估体系](03-evaluation-system.md) - 如何评估Agent
- [数据分析](04-data-analysis.md) - 如何分析实验数据
