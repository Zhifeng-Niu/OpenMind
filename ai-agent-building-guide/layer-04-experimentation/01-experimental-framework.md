# 实验框架

> 科学地验证 Agent 创新想法

## 🎯 核心理念

Agent 开发应该像科学实验一样严谨:

```
想法 → 假设 → 设计 → 实验 → 分析 → 迭代
```

## 📋 实验框架五阶段

### 阶段 1: 想法生成 (Ideation)

**目标**: 产生创新想法

**方法**:
1. 阅读论文和项目
2. 观察问题
3. 类比其他领域
4. 自由联想

**输出**: 想法描述文档

### 阶段 2: 假设制定 (Hypothesis)

**目标**: 将想法转化为可验证的假设

**要素**:
- **自变量**: 你要改变的东西
- **因变量**: 你要测量的东西
- **控制变量**: 保持不变的东西

**格式**:
```
如果 [自变量],那么 [因变量],因为 [机制]。
```

**示例**:
```
如果 Agent 有记忆重整机制,
那么长期记忆质量提高 20%,
因为重整巩固了重要记忆。
```

### 阶段 3: 实验设计 (Design)

**目标**: 设计验证假设的实验

**要素**:
1. **对照组**: 基准 Agent
2. **实验组**: 创新Agent
3. **评估指标**: 量化指标
4. **测试任务**: 代表性任务

**模板**:
```markdown
## 实验设计

### 假设
[清晰描述]

### 变量
- 自变量: [name]
- 因变量: [metrics]
- 控制变量: [list]

### 对照组
[配置描述]

### 实验组
[配置描述]

### 评估指标
- 功能性: [metrics]
- 效率性: [metrics]
- 经济性: [metrics]

### 测试任务
[任务描述]
```

### 阶段 4: 实验执行 (Implementation)

**目标**: 实现并运行实验

**步骤**:
1. 实现 Agent
2. 准备数据集
3. 运行实验
4. 收集数据

### 阶段 5: 结果分析 (Analysis)

**目标**: 分析数据,得出结论

**方法**:
1. 统计分析
2. 可视化
3. 误差分析
4. 结论验证

## 🔬 实验类型

### 类型 1: A/B 测试

**目的**: 对比两个版本

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
            # 对照组
            control_result = await self.control.run(case)
            results["control"].append(control_result)

            # 实验组
            treatment_result = await self.treatment.run(case)
            results["treatment"].append(treatment_result)

        return self.analyze(results)

    def analyze(self, results):
        # 统计检验
        from scipy import stats

        control_scores = [r.score for r in results["control"]]
        treatment_scores = [r.score for r in results["treatment"]]

        # t 检验
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

### 类型 2: 参数扫描

**目的**: 找到最优参数

```python
class ParameterSweep:
    def __init__(self, agent_class, param_grid):
        self.agent_class = agent_class
        self.param_grid = param_grid

    async def run(self, test_cases):
        results = []

        # 生成所有参数组合
        from itertools import product
        keys = self.param_grid.keys()
        values = self.param_grid.values()

        for combination in product(*values):
            params = dict(zip(keys, combination))

            # 创建 Agent
            agent = self.agent_class(**params)

            # 评估
            scores = []
            for case in test_cases:
                result = await agent.run(case)
                scores.append(result.score)

            results.append({
                "params": params,
                "mean_score": np.mean(scores),
                "std_score": np.std(scores)
            })

        # 返回最优参数
        best = max(results, key=lambda r: r["mean_score"])
        return best
```

### 类型 3: 消融实验

**目的**: 验证每个组件的贡献

```python
class AblationStudy:
    def __init__(self, full_agent, components):
        self.full_agent = full_agent
        self.components = components  # ["memory", "tool", "reflection"]

    async def run(self, test_cases):
        results = {}

        # 完整版本
        full_score = await self.evaluate(self.full_agent, test_cases)
        results["full"] = full_score

        # 移除每个组件
        for component in self.components:
            ablated_agent = self.remove_component(
                self.full_agent,
                component
            )
            score = await self.evaluate(ablated_agent, test_cases)
            results[f"without_{component}"] = score

        # 分析贡献
        contributions = {}
        for component in self.components:
            contribution = (
                results["full"] - results[f"without_{component}"]
            ) / results["full"]
            contributions[component] = contribution

        return contributions

    def remove_component(self, agent, component):
        # 创建没有该组件的 Agent
        config = agent.config.copy()
        config[component] = None
        return agent.__class__(**config)
```

## 📊 评估指标库

### 功能性指标

**任务完成度**
```python
def task_completion(result, expected):
    """任务是否完成"""
    return 1.0 if result.completed else 0.0
```

**答案准确性**
```python
def answer_accuracy(result, ground_truth):
    """答案准确率"""
    correct = 0
    for key in ground_truth:
        if result.get(key) == ground_truth[key]:
            correct += 1
    return correct / len(ground_truth)
```

**幻觉率**
```python
def hallucination_rate(result, context):
    """幻觉内容比例"""
    claims = extract_claims(result)
    false_claims = 0

    for claim in claims:
        if not verify_claim(claim, context):
            false_claims += 1

    return false_claims / len(claims)
```

### 效率性指标

**响应时间**
```python
def response_time(start_time, end_time):
    """响应时间"""
    return end_time - start_time
```

**Token 使用量**
```python
def token_usage(usage):
    """Token 使用量"""
    return usage.input_tokens + usage.output_tokens
```

**迭代次数**
```python
def iteration_count(history):
    """迭代次数"""
    return len(history)
```

### 经济性指标

**成本**
```python
def cost(token_usage, model_pricing):
    """计算成本"""
    input_cost = token_usage.input * model_pricing.input_price
    output_cost = token_usage.output * model_pricing.output_price
    return input_cost + output_cost
```

**性价比**
```python
def cost_benefit(score, cost):
    """性价比 = 分数 / 成本"""
    return score / cost if cost > 0 else 0
```

## 🛠️ 实验工具

### 工具 1: 实验跟踪

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

### 工具 2: 数据集管理

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

### 工具 3: 可视化

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

        # 箱线图
        axes[0].boxplot([control_scores, treatment_scores])
        axes[0].set_xticklabels(["Control", "Treatment"])
        axes[0].set_ylabel("Score")
        axes[0].set_title("Score Distribution")

        # 直方图
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

## 📝 实验报告模板

```markdown
# 实验报告: [实验名称]

## 元信息
- **日期**: YYYY-MM-DD
- **实验者**: Name
- **实验ID**: EXP-XXX

## 1. 研究问题

### 背景
[为什么做这个实验]

### 问题陈述
[明确要回答的问题]

## 2. 假设

### 主要假设
如果 [自变量],那么 [因变量],因为 [机制]。

### 次要假设
[其他假设]

## 3. 方法

### 3.1 实验设计

#### 变量
- **自变量**: [name, type, levels]
- **因变量**: [metrics]
- **控制变量**: [list]

#### N 维定位
```
[10个维度的位置]
```

### 3.2 架构

#### 系统架构图
```
[ASCII 架构图]
```

#### 关键组件
- **组件1**: [description]
- **组件2**: [description]

### 3.3 实现

#### 代码结构
```
[目录结构]
```

#### 关键代码
```python
[核心代码片段]
```

## 4. 实验配置

### 4.1 对照组
[配置详情]

### 4.2 实验组
[配置详情]

### 4.3 测试任务
[任务描述]
- 任务1: [description]
- 任务2: [description]

### 4.4 评估指标
- 功能性: [metrics]
- 效率性: [metrics]
- 经济性: [metrics]

## 5. 结果

### 5.1 定量结果

| 指标 | 对照组 | 实验组 | 改进 |
|------|--------|--------|------|
| [metric] | [value] | [value] | [%] |

### 5.2 统计显著性
- [检验方法]: [统计量], [p值]
- 结论: [显著/不显著]

### 5.3 可视化
```
[图表]
```

### 5.4 定性观察
[非数值发现]

## 6. 分析

### 6.1 主要发现
1. [finding 1]
2. [finding 2]

### 6.2 误差分析
[哪些情况没达到预期]

### 6.3 讨论
[解释结果]

## 7. 结论

### 7.1 假设验证
- ✅ 支持 / ❌ 不支持

### 7.2 局限性
[研究的局限]

### 7.3 下一步
[后续方向]

## 8. 附录

### A. 详细数据
[原始数据]

### B. 配置文件
[完整配置]

### C. 运行日志
[关键日志]
```

## 📚 总结

### 关键要点

1. **五阶段**: 想法 → 假设 → 设计 → 实验 → 分析
2. **三种实验**: A/B 测试、参数扫描、消融实验
3. **三类指标**: 功能性、效率性、经济性
4. **完整报告**: 使用标准模板

### 实验原则

1. **控制变量**: 只改变一个变量
2. **重复实验**: 多次运行确保稳定
3. **统计检验**: 验证显著性
4. **完整记录**: 所有配置和结果

### 下一步

- [实验方法](02-experimental-methods.md) - 具体实验方法
- [案例演示](07-case-demos.md) - 完整实验案例
