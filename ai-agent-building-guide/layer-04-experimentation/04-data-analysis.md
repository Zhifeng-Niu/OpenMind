# 数据分析方法

> **如何从实验数据中提取洞察**

---

## 4.1 数据分析基础

### 4.1.1 实验数据的类型

**定量数据** (Quantitative):
```python
# 数值型数据
response_time = [1.2, 1.5, 0.9, 2.1, 1.8]  # 秒
accuracy = [0.85, 0.92, 0.78, 0.95, 0.88]  # 正确率
token_usage = [1500, 2100, 1800, 2500, 1900]  # tokens
```

**定性数据** (Qualitative):
```python
# 描述型数据
feedback = [
    "Agent 在处理复杂任务时表现良好",
    "决策过程透明度有待提高",
    "响应速度在高峰期较慢"
]
```

**时间序列数据**:
```python
# 随时间变化的数据
performance_over_time = [
    {"timestamp": "2026-02-23T10:00:00", "metric": 0.75},
    {"timestamp": "2026-02-23T10:05:00", "metric": 0.78},
    {"timestamp": "2026-02-23T10:10:00", "metric": 0.82},
]
```

---

### 4.1.2 Python 数据分析工具链

**安装**:
```bash
pip install numpy pandas scipy matplotlib seaborn
```

**核心库**:
```python
import numpy as np          # 数值计算
import pandas as pd         # 数据分析
import scipy.stats as stats  # 统计检验
import matplotlib.pyplot as plt  # 基础绘图
import seaborn as sns        # 高级可视化
```

---

## 4.2 描述性统计

### 4.2.1 集中趋势分析

```python
def analyze_central_tendency(data):
    """分析集中趋势"""
    return {
        "mean": np.mean(data),          # 平均值
        "median": np.median(data),      # 中位数
        "mode": stats.mode(data).mode[0] if len(stats.mode(data).mode) > 0 else None,  # 众数
    }

# 示例
response_times = [1.2, 1.5, 0.9, 2.1, 1.8, 1.3, 1.6]
central = analyze_central_tendency(response_times)

print("集中趋势:")
print(f"  平均值: {central['mean']:.2f} 秒")
print(f"  中位数: {central['median']:.2f} 秒")
print(f"  众数: {central['mode']:.2f} 秒")
```

---

### 4.2.2 离散程度分析

```python
def analyze_dispersion(data):
    """分析离散程度"""
    return {
        "variance": np.var(data, ddof=1),           # 方差
        "std_dev": np.std(data, ddof=1),             # 标准差
        "range": np.max(data) - np.min(data),        # 极差
        "iqr": np.percentile(data, 75) - np.percentile(data, 25),  # 四分位距
        "cv": np.std(data, ddof=1) / np.mean(data),   # 变异系数
    }

# 示例
dispersion = analyze_dispersion(response_times)

print("离散程度:")
print(f"  方差: {dispersion['variance']:.4f}")
print(f"  标准差: {dispersion['std_dev']:.4f}")
print(f"  极差: {dispersion['range']:.2f}")
print(f"  四分位距: {dispersion['iqr']:.2f}")
print(f"  变异系数: {dispersion['cv']:.2%}")
```

---

### 4.2.3 分布形状分析

```python
def analyze_distribution(data):
    """分析分布形状"""
    return {
        "skewness": stats.skew(data),       # 偏度
        "kurtosis": stats.kurtosis(data),    # 峰度
    }

# 示例
shape = analyze_distribution(response_times)

print("分布形状:")
print(f"  偏度: {shape['skewness']:.4f}")
print(f"  峰度: {shape['kurtosis']:.4f}")

# 解释
if shape['skewness'] > 0:
    print("  → 右偏分布 (长尾在右侧)")
elif shape['skewness'] < 0:
    print("  → 左偏分布 (长尾在左侧)")
else:
    print("  → 对称分布")

if shape['kurtosis'] > 0:
    print("  → 尖峰分布 (比正态分布更陡峭)")
elif shape['kurtosis'] < 0:
    print("  → 平峰分布 (比正态分布更平坦)")
```

---

## 4.3 推断性统计

### 4.3.1 假设检验

**t 检验** (比较两组均值):
```python
def compare_two_groups(group1, group2):
    """比较两组数据"""
    # 独立样本 t 检验
    t_stat, p_value = stats.ttest_ind(group1, group2)

    print("两组比较 (t 检验):")
    print(f"  t 统计量: {t_stat:.4f}")
    print(f"  p 值: {p_value:.4f}")

    # 效应量 (Cohen's d)
    pooled_std = np.sqrt(
        ((len(group1) - 1) * np.var(group1, ddof=1) +
         (len(group2) - 1) * np.var(group2, ddof=1)) /
        (len(group1) + len(group2) - 2)
    )
    cohens_d = (np.mean(group1) - np.mean(group2)) / pooled_std

    print(f"  Cohen's d: {cohens_d:.4f}")
    print(f"  效应量大小: {interpret_effect_size(cohens_d)}")

    # 显著性判断
    alpha = 0.05
    if p_value < alpha:
        print(f"  结论: 差异显著 (p < {alpha})")
    else:
        print(f"  结论: 差异不显著 (p >= {alpha})")

    return t_stat, p_value, cohens_d

def interpret_effect_size(d):
    """解释效应量大小"""
    abs_d = abs(d)
    if abs_d < 0.2:
        return "小"
    elif abs_d < 0.5:
        return "中等"
    elif abs_d < 0.8:
        return "大"
    else:
        return "很大"

# 示例
group_a = [1.2, 1.5, 0.9, 2.1, 1.8]
group_b = [2.1, 2.5, 1.9, 2.8, 2.3]

compare_two_groups(group_a, group_b)
```

---

### 4.3.2 方差分析 (ANOVA)

**单因素 ANOVA**:
```python
from scipy.stats import f_oneway

def anova_test(*groups):
    """单因素方差分析"""
    f_stat, p_value = f_oneway(*groups)

    print("单因素 ANOVA:")
    print(f"  F 统计量: {f_stat:.4f}")
    print(f"  p 值: {p_value:.4f}")

    alpha = 0.05
    if p_value < alpha:
        print(f"  结论: 各组均值存在显著差异 (p < {alpha})")
    else:
        print(f"  结论: 各组均值无显著差异 (p >= {alpha})")

    return f_stat, p_value

# 示例
method_a = [0.75, 0.82, 0.78, 0.85, 0.80]
method_b = [0.88, 0.92, 0.85, 0.95, 0.90]
method_c = [0.65, 0.72, 0.68, 0.75, 0.70]

anova_test(method_a, method_b, method_c)
```

---

### 4.3.3 卡方检验

**独立性检验**:
```python
from scipy.stats import chi2_contingency

def chi_square_test(observed):
    """卡方独立性检验"""
    chi2, p_value, dof, expected = chi2_contingency(observed)

    print("卡方检验:")
    print(f"  卡方值: {chi2:.4f}")
    print(f"  p 值: {p_value:.4f}")
    print(f"  自由度: {dof}")

    alpha = 0.05
    if p_value < alpha:
        print(f"  结论: 变量间存在显著关联 (p < {alpha})")
    else:
        print(f"  结论: 变量间无显著关联 (p >= {alpha})")

    return chi2, p_value

# 示例: Agent 类型和结果成功率的关联
observed = np.array([
    [45, 15],  # ReAct Agent: 成功 45, 失败 15
    [30, 30],  # Reflexion Agent: 成功 30, 失败 30
    [50, 10],  # Plan-and-Execute: 成功 50, 失败 10
])

chi_square_test(observed)
```

---

## 4.4 可视化分析

### 4.4.1 分布可视化

```python
import matplotlib.pyplot as plt
import seaborn as sns

def plot_distribution(data, title="数据分布"):
    """绘制数据分布图"""
    fig, axes = plt.subplots(1, 2, figsize=(12, 4))

    # 直方图
    axes[0].hist(data, bins=20, edgecolor='black', alpha=0.7)
    axes[0].set_title(f"{title} - 直方图")
    axes[0].set_xlabel("值")
    axes[0].set_ylabel("频数")

    # 箱线图
    axes[1].boxplot(data, vert=True)
    axes[1].set_title(f"{title} - 箱线图")
    axes[1].set_ylabel("值")

    plt.tight_layout()
    plt.savefig(f"{title.replace(' ', '_')}_distribution.png", dpi=300)
    plt.show()

# 示例
response_times = [1.2, 1.5, 0.9, 2.1, 1.8, 1.3, 1.6, 2.0, 1.4, 1.7]
plot_distribution(response_times, "响应时间分布")
```

---

### 4.4.2 对比可视化

```python
def plot_group_comparison(groups_dict, title="组间对比"):
    """绘制组间对比图"""
    fig, ax = plt.subplots(figsize=(10, 6))

    positions = list(range(len(groups_dict)))
    data = [groups_dict[key] for key in groups_dict.keys()]

    # 箱线图
    bp = ax.boxplot(data, positions=positions, widths=0.6, patch_artist=True)

    # 美化
    colors = ['#FF9999', '#66B2FF', '#99FF99', '#FFCC99', '#DFA8FF']
    for patch, color in zip(bp['boxes'], colors):
        patch.set_facecolor(color)

    ax.set_xticks(positions)
    ax.set_xticklabels(groups_dict.keys())
    ax.set_title(title)
    ax.set_ylabel("值")

    plt.tight_layout()
    plt.savefig(f"{title.replace(' ', '_')}_comparison.png", dpi=300)
    plt.show()

# 示例
methods = {
    "ReAct": [0.75, 0.82, 0.78, 0.85, 0.80],
    "Reflexion": [0.88, 0.92, 0.85, 0.95, 0.90],
    "Planning": [0.65, 0.72, 0.68, 0.75, 0.70],
}

plot_group_comparison(methods, "不同 Agent 方法的准确率对比")
```

---

### 4.4.3 时间序列可视化

```python
def plot_time_series(timestamps, values, title="时间序列"):
    """绘制时间序列图"""
    fig, ax = plt.subplots(figsize=(14, 6))

    ax.plot(timestamps, values, marker='o', linestyle='-', linewidth=2)
    ax.set_title(title)
    ax.set_xlabel("时间")
    ax.set_ylabel("值")
    ax.grid(True, alpha=0.3)

    # 旋转 x 轴标签
    plt.xticks(rotation=45)

    plt.tight_layout()
    plt.savefig(f"{title.replace(' ', '_')}_timeseries.png", dpi=300)
    plt.show()

# 示例
import datetime

timestamps = [
    datetime.datetime(2026, 2, 23, 10, 0),
    datetime.datetime(2026, 2, 23, 10, 5),
    datetime.datetime(2026, 2, 23, 10, 10),
    datetime.datetime(2026, 2, 23, 10, 15),
    datetime.datetime(2026, 2, 23, 10, 20),
]

autonomy_scores = [0.65, 0.68, 0.72, 0.75, 0.78]

plot_time_series(timestamps, autonomy_scores, "自主性指数随时间变化")
```

---

### 4.4.4 相关性可视化

```python
def plot_correlation_heatmap(dataframe, title="相关性热图"):
    """绘制相关性热图"""
    # 计算相关矩阵
    corr_matrix = dataframe.corr()

    # 绘制热图
    fig, ax = plt.subplots(figsize=(10, 8))

    sns.heatmap(
        corr_matrix,
        annot=True,
        fmt=".2f",
        cmap='coolwarm',
        center=0,
        vmin=-1,
        vmax=1,
        ax=ax
    )

    ax.set_title(title)

    plt.tight_layout()
    plt.savefig(f"{title.replace(' ', '_')}_heatmap.png", dpi=300)
    plt.show()

# 示例
import pandas as pd

data = {
    "自主性": [0.65, 0.72, 0.78, 0.82, 0.85],
    "准确性": [0.75, 0.78, 0.82, 0.85, 0.88],
    "效率": [0.60, 0.68, 0.72, 0.75, 0.80],
    "稳定性": [0.70, 0.75, 0.78, 0.82, 0.85],
}

df = pd.DataFrame(data)
plot_correlation_heatmap(df, "Agent 性能指标相关性")
```

---

## 4.5 高级分析

### 4.5.1 回归分析

```python
from scipy import stats

def linear_regression(x, y):
    """线性回归分析"""
    # 执行回归
    slope, intercept, r_value, p_value, std_err = stats.linregress(x, y)

    print("线性回归结果:")
    print(f"  斜率: {slope:.4f}")
    print(f"  截距: {intercept:.4f}")
    print(f"  R²: {r_value**2:.4f}")
    print(f"  p 值: {p_value:.4e}")
    print(f"  标准误: {std_err:.4f}")

    # 预测
    def predict(x_new):
        return slope * x_new + intercept

    # 可视化
    plt.figure(figsize=(10, 6))
    plt.scatter(x, y, alpha=0.7, label='数据点')

    x_fit = np.linspace(min(x), max(x), 100)
    y_fit = predict(x_fit)
    plt.plot(x_fit, y_fit, 'r-', label=f'拟合线 (y={slope:.2f}x+{intercept:.2f})')

    plt.xlabel("X")
    plt.ylabel("Y")
    plt.title("线性回归分析")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.savefig("linear_regression.png", dpi=300)
    plt.show()

    return slope, intercept, r_value**2

# 示例
# 探索次数 vs 准确率的关系
exploration_count = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]
accuracy = [0.65, 0.70, 0.75, 0.78, 0.80, 0.82, 0.83, 0.84, 0.85, 0.86]

linear_regression(exploration_count, accuracy)
```

---

### 4.5.2 聚类分析

```python
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

def cluster_analysis(data, n_clusters=3):
    """聚类分析"""
    # 标准化
    scaler = StandardScaler()
    data_scaled = scaler.fit_transform(data)

    # K-means 聚类
    kmeans = KMeans(n_clusters=n_clusters, random_state=42)
    clusters = kmeans.fit_predict(data_scaled)

    # 可视化 (2D)
    if data.shape[1] == 2:
        plt.figure(figsize=(10, 6))
        scatter = plt.scatter(data[:, 0], data[:, 1], c=clusters, cmap='viridis', alpha=0.7)
        plt.scatter(kmeans.cluster_centers_[:, 0], kmeans.cluster_centers_[:, 1],
                   c='red', marker='x', s=200, linewidths=3, label='聚类中心')
        plt.xlabel("特征 1")
        plt.ylabel("特征 2")
        plt.title("K-means 聚类结果")
        plt.legend()
        plt.colorbar(scatter)
        plt.grid(True, alpha=0.3)
        plt.savefig("cluster_analysis.png", dpi=300)
        plt.show()

    return clusters, kmeans.cluster_centers_

# 示例
import numpy as np

# Agent 性能数据
performance_data = np.array([
    [0.75, 1.2],  # [准确性, 响应时间]
    [0.82, 1.5],
    [0.78, 1.3],
    [0.65, 0.9],
    [0.88, 1.8],
    [0.72, 1.1],
    [0.85, 1.6],
    [0.80, 1.4],
])

clusters, centers = cluster_analysis(performance_data, n_clusters=3)
```

---

### 4.5.3 主成分分析 (PCA)

```python
from sklearn.decomposition import PCA

def pca_analysis(data, n_components=2):
    """主成分分析"""
    # 标准化
    scaler = StandardScaler()
    data_scaled = scaler.fit_transform(data)

    # PCA
    pca = PCA(n_components=n_components)
    principal_components = pca.fit_transform(data_scaled)

    # 解释方差比例
    print("主成分分析结果:")
    for i, var in enumerate(pca.explained_variance_ratio_):
        print(f"  PC{i+1} 解释方差: {var:.2%}")

    print(f"  累积解释方差: {sum(pca.explained_variance_ratio_):.2%}")

    # 可视化载荷
    if n_components == 2:
        plt.figure(figsize=(10, 6))
        plt.scatter(principal_components[:, 0], principal_components[:, 1], alpha=0.7)
        plt.xlabel(f"PC1 ({pca.explained_variance_ratio_[0]:.1%})")
        plt.ylabel(f"PC2 ({pca.explained_variance_ratio_[1]:.1%})")
        plt.title("主成分分析结果")
        plt.grid(True, alpha=0.3)
        plt.savefig("pca_analysis.png", dpi=300)
        plt.show()

    return principal_components, pca

# 示例
# 多维 Agent 性能数据
multi_dim_data = np.array([
    [0.75, 1.2, 0.85, 0.90],  # 准确性, 响应时间, 鲁棒性, 效率
    [0.82, 1.5, 0.78, 0.88],
    [0.65, 0.9, 0.92, 0.75],
    [0.88, 1.8, 0.75, 0.95],
    [0.72, 1.1, 0.88, 0.82],
])

pc, pca_model = pca_analysis(multi_dim_data, n_components=2)
```

---

## 4.6 完整分析工作流

### 4.6.1 端到端分析示例

```python
class ExperimentAnalyzer:
    """实验数据分析器"""

    def __init__(self, data_path):
        self.data = pd.read_csv(data_path)
        self.results = {}

    def analyze(self):
        """执行完整分析流程"""
        print("=" * 60)
        print("实验数据分析")
        print("=" * 60)

        # 1. 描述性统计
        print("\n1. 描述性统计")
        print("-" * 60)
        self.descriptive_statistics()

        # 2. 组间比较
        print("\n2. 组间比较")
        print("-" * 60)
        self.group_comparison()

        # 3. 相关性分析
        print("\n3. 相关性分析")
        print("-" * 60)
        self.correlation_analysis()

        # 4. 可视化
        print("\n4. 生成可视化")
        print("-" * 60)
        self.create_visualizations()

        # 5. 生成报告
        print("\n5. 生成分析报告")
        print("-" * 60)
        self.generate_report()

    def descriptive_statistics(self):
        """描述性统计"""
        numeric_cols = self.data.select_dtypes(include=[np.number]).columns

        for col in numeric_cols:
            print(f"\n{col}:")
            values = self.data[col].dropna()
            print(f"  均值: {np.mean(values):.4f}")
            print(f"  标准差: {np.std(values):.4f}")
            print(f"  最小值: {np.min(values):.4f}")
            print(f"  最大值: {np.max(values):.4f}")

    def group_comparison(self):
        """组间比较"""
        # 假设有 'group' 列
        groups = self.data['group'].unique()

        if len(groups) == 2:
            group1 = self.data[self.data['group'] == groups[0]]['value']
            group2 = self.data[self.data['group'] == groups[1]]['value']
            compare_two_groups(group1, group2)

    def correlation_analysis(self):
        """相关性分析"""
        numeric_cols = self.data.select_dtypes(include=[np.number]).columns

        if len(numeric_cols) >= 2:
            corr_matrix = self.data[numeric_cols].corr()
            print("\n相关性矩阵:")
            print(corr_matrix.to_string())

    def create_visualizations(self):
        """创建可视化"""
        output_dir = "analysis_plots"
        import os
        os.makedirs(output_dir, exist_ok=True)

        # 保存所有图表
        plt.savefig(f"{output_dir}/analysis_summary.png")

    def generate_report(self):
        """生成分析报告"""
        report = f"""
# 实验数据分析报告

## 分析概要

- 数据点数: {len(self.data)}
- 分析维度: {len(self.data.columns)}
- 分析时间: {pd.Timestamp.now()}

## 主要发现

1. 描述性统计完成
2. 组间比较完成
3. 相关性分析完成
4. 可视化完成

## 详细结果

见各分析章节和图表。

---
*本报告由 ExperimentAnalyzer 自动生成*
"""
        with open("analysis_report.md", "w") as f:
            f.write(report)

        print("报告已保存: analysis_report.md")

# 使用示例
# analyzer = ExperimentAnalyzer("experiment_results.csv")
# analyzer.analyze()
```

---

## 📚 本章小结

### 核心要点

1. **描述性统计**: 集中趋势、离散程度、分布形状
2. **推断统计**: 假设检验、方差分析、卡方检验
3. **数据可视化**: 分布图、对比图、时间序列、热图
4. **高级分析**: 回归、聚类、主成分分析
5. **完整工作流**: 端到端分析流程

### 实践成果

- ✅ 完整的 Python 数据分析工具链
- ✅ 统计检验方法 (t检验、ANOVA、卡方)
- ✅ 可视化函数库
- ✅ ExperimentAnalyzer 分析器

### 下一步

- 第5章: 报告撰写 - 将分析结果写成论文

---

<promise>CHAPTER_4_04_COMPLETE</promise>
