# 完整工作流

> **从实验想法到学术发表的端到端流程**

---

## 6.1 实验生命周期

### 6.1.1 五阶段模型

```
想法 → 假设 → 设计 → 实验 → 分析 → 发表
  ↓      ↓      ↓      ↓      ↓      ↓
记录  文献  方案  执行  数据   投稿
```

**时间估算**:
- 快速项目: 2-3 月
- 标准项目: 6-12 月
- 大型项目: 1-2 年

---

## 6.2 阶段 1: 想法与假设

### 6.2.1 研究想法的来源

**阅读文献**:
- 关注当前研究热点
- 识别研究空白
- 思考改进方案

**实践观察**:
- 实际项目中的问题
- 工具的局限性
- 用户的痛点

**跨学科启发**:
- 认知科学 → Agent 架构
- 神经科学 → 学习机制
- 经济学 → 激励设计

**想法记录模板**:
```markdown
## 研究想法

**日期**: 2026-02-23
**标题**: [简短描述]

**问题陈述**
当前存在什么问题?

**解决方案概述**
我的想法是什么?

**创新点**
与现有方法有何不同?

**预期效果**
如果成功,会有什么影响?

**初步评估**
可行性 (1-5):
影响力 (1-5):
难度 (1-5):
```

---

### 6.2.2 文献调研

**调研步骤**:

1. **关键词搜索**
   ```
   Google Scholar, arXiv, Semantic Scholar
   关键词: "autonomous agents", "intrinsic motivation", "LLM"
   ```

2. **快速筛选**
   - 标题相关性
   - 摘要质量
   - 引用数量
   - 发表时间

3. **深度阅读**
   - 选择 10-20 篇核心论文
   - 详细阅读方法部分
   - 记录关键发现

4. **文献矩阵**
   ```python
   # 使用文献管理工具 (Zotero, Mendeley)
   # 创建文献矩阵
   import pandas as pd

   papers = [
       {
           "title": "Intrinsic Motivation for Artificial Agents",
           "authors": "Singh et al.",
           "year": 2010,
           "methods": "Curiosity-driven exploration",
           "findings": "Improves sample efficiency",
           "limitations": "Only tested in games",
           "relevance": "High",
       },
       # ... 更多论文
   ]

   df = pd.DataFrame(papers)
   df.to_csv("literature_matrix.csv")
   ```

---

### 6.2.3 假设形成

**好的假设** (SMART 原则):
- **S**pecific: 具体明确
- **M**easurable: 可测量
- **A**chievable: 可实现
- **R**elevant: 相关性强
- **T**ime-bound: 有时间限制

**示例**:
```markdown
## 研究假设

H1: 合成动机系统将显著提升 AI Agent 的目标生成质量

**操作化定义**:
- 合成动机系统: 包含好奇心、成就感、生存需求三维
- 目标生成质量: 可行性×价值×一致性×新颖性×具体性 (0-1)
- 显著提升: Cohen's d > 0.5, p < 0.05

H2: 好奇心驱动的探索在新颖环境中比随机探索效率高 30% 以上

**操作化定义**:
- 探索效率: 单位时间内的发现数 / 总步数
- 新颖环境: Agent 未见过的环境配置
- 效率高: (好奇心_发现数 - 随机_发现数) / 随机_发现数 > 0.3
```

---

## 6.3 阶段 2: 实验设计

### 6.3.1 实验设计清单

```python
class ExperimentDesignChecklist:
    """实验设计检查清单"""

    def __init__(self):
        self.checklist = {
            "研究问题": False,
            "研究假设": False,
            "变量定义": False,
            "实验类型": False,
            "被试安排": False,
            "材料准备": False,
            "数据分析计划": False,
            "伦理审查": False,
        }

    def review(self):
        """审查实验设计"""
        for item, status in self.checklist.items():
            symbol = "✅" if status else "❌"
            print(f"{symbol} {item}")

        completed = sum(self.checklist.values())
        total = len(self.checklist)
        print(f"\n完成度: {completed}/{total} ({completed/total*100:.1f}%)")

        if completed == total:
            print("\n✅ 实验设计已就绪!")
        else:
            print("\n⚠️  还有项目未完成,请继续完善")

# 使用示例
checklist = ExperimentDesignChecklist()
checklist.review()
```

---

### 6.3.2 实验方案文档

**模板**:
```markdown
# 实验方案文档

## 1. 研究概述

### 1.1 研究问题
### 1.2 研究假设
### 1.3 预期贡献

## 2. 实验设计

### 2.1 实验类型
- [ ] 对照实验
- [ ] 参数调优
- [ ] 消融研究
- [ ] 案例研究

### 2.2 被试安排
- 被试数量
- 分组方式
- 随机化方法

### 2.3 变量操作
- 自变量定义
- 因变量测量
- 控制变量

## 3. 实施流程

### 3.1 准备阶段
- 环境搭建
- 工具安装
- 数据收集

### 3.2 执行阶段
- 实验运行
- 数据记录
- 质量控制

### 3.3 收尾阶段
- 数据整理
- 清理工作

## 4. 数据分析计划

### 4.1 统计方法
- 描述性统计
- 推断性统计
- 效应量计算

### 4.2 可视化计划
- 图表类型
- 绘图工具
- 样式要求

## 5. 时间规划

| 阶段 | 任务 | 时间 | 负责人 |
|------|------|------|--------|
| 准备 | 环境搭建 | 1周 | XXX |
| 执行 | 数据收集 | 2周 | XXX |
| 分析 | 数据处理 | 1周 | XXX |
| 撰写 | 报告撰写 | 1周 | XXX |

## 6. 资源需求

- 计算资源
- 软件工具
- 人力投入

## 7. 风险评估

### 7.1 潜在风险
- 技术风险
- 时间风险
- 资源风险

### 7.2 应对措施
- 备选方案
- 缓冲时间
- 资源预留
```

---

## 6.4 阶段 3: 实验执行

### 6.4.1 实验执行工具链

**自动化脚本**:
```bash
#!/bin/bash
# run_experiment.sh

echo "开始实验..."

# 1. 准备环境
python prepare_environment.py

# 2. 运行实验
for i in {1..100}; do
    echo "运行实验 $i..."
    python run_experiment.py --seed $i >> "logs/experiment_$i.log"
done

# 3. 收集结果
python collect_results.py

# 4. 分析数据
python analyze_results.py

echo "实验完成!"
```

**实验监控**:
```python
class ExperimentMonitor:
    """实验监控器"""

    def __init__(self):
        self.metrics = []

    def log_progress(self, current, total, message=""):
        """记录进度"""
        progress = current / total * 100
        print(f"[{progress:.1f}%] {message}")
        self.metrics.append({
            "timestamp": time.time(),
            "progress": progress,
            "message": message
        })

    def check_health(self):
        """健康检查"""
        # CPU/内存使用
        cpu = psutil.cpu_percent()
        memory = psutil.virtual_memory().percent

        if cpu > 90:
            print(f"⚠️ CPU 使用率过高: {cpu}%")

        if memory > 90:
            print(f"⚠️ 内存使用率过高: {memory}%")

        return cpu < 90 and memory < 90
```

---

### 6.4.2 数据管理

**数据存储**:
```python
import pandas as pd
import json
from datetime import datetime

class DataManager:
    """数据管理器"""

    def __init__(self, base_dir="experiment_data"):
        self.base_dir = Path(base_dir)
        self.base_dir.mkdir(exist_ok=True)

    def save_run(self, data, experiment_id):
        """保存单次实验数据"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = self.base_dir / f"{experiment_id}_{timestamp}.json"

        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)

        return filename

    def load_all(self, experiment_id):
        """加载所有实验数据"""
        files = self.base_dir.glob(f"{experiment_id}_*.json")
        data = []
        for file in files:
            with open(file, 'r') as f:
                data.append(json.load(f))
        return data

    def create_summary(self, experiment_id):
        """创建数据摘要"""
        data = self.load_all(experiment_id)
        df = pd.DataFrame(data)

        summary = {
            "total_runs": len(data),
            "mean": df.mean().to_dict(),
            "std": df.std().to_dict(),
            "min": df.min().to_dict(),
            "max": df.max().to_dict(),
        }

        summary_file = self.base_dir / f"{experiment_id}_summary.json"
        with open(summary_file, 'w') as f:
            json.dump(summary, f, indent=2)

        return summary
```

---

## 6.5 阶段 4: 数据分析与可视化

### 6.5.1 分析脚本模板

```python
#!/usr/bin/env python3
"""
完整数据分析流程
"""

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy import stats

class CompleteAnalyzer:
    """完整数据分析器"""

    def __init__(self, data_dir):
        self.data_dir = Path(data_dir)
        self.results = {}

    def load_data(self, experiment_id):
        """加载数据"""
        manager = DataManager(self.data_dir)
        data = manager.load_all(experiment_id)
        self.df = pd.DataFrame(data)
        print(f"✅ 已加载 {len(self.df)} 条数据")

    def descriptive_stats(self):
        """描述性统计"""
        print("\n" + "="*60)
        print("描述性统计")
        print("="*60)

        stats = self.df.describe()
        print(stats)

        # 保存统计
        stats.to_csv(f"{self.data_dir}/descriptive_stats.csv")

        return stats

    def hypothesis_tests(self):
        """假设检验"""
        print("\n" + "="*60)
        print("假设检验")
        print("="*60)

        groups = self.df['group'].unique()

        if len(groups) == 2:
            group1 = self.df[self.df['group'] == groups[0]]['value']
            group2 = self.df[self.df['group'] == groups[1]]['value']

            # t 检验
            t_stat, p_value = stats.ttest_ind(group1, group2)
            cohens_d = (np.mean(group1) - np.mean(group2)) / np.sqrt(
                ((len(group1) - 1) * np.var(group1) +
                 (len(group2) - 1) * np.var(group2)) /
                (len(group1) + len(group2) - 2)
            )

            print(f"t 检验: t = {t_stat:.4f}, p = {p_value:.4f}")
            print(f"Cohen's d: {cohens_d:.4f}")

            self.results['t_test'] = {
                't_statistic': t_stat,
                'p_value': p_value,
                'cohens_d': cohens_d
            }

    def create_visualizations(self):
        """创建可视化"""
        print("\n" + "="*60)
        print("创建可视化")
        print("="*60)

        output_dir = self.data_dir / "plots"
        output_dir.mkdir(exist_ok=True)

        # 1. 组间对比箱线图
        plt.figure(figsize=(10, 6))
        sns.boxplot(data=self.df, x='group', y='value')
        plt.title('组间对比')
        plt.savefig(output_dir / 'group_comparison.png', dpi=300)
        plt.close()

        # 2. 分布直方图
        plt.figure(figsize=(12, 6))
        for group in self.df['group'].unique():
            data = self.df[self.df['group'] == group]['value']
            plt.hist(data, alpha=0.7, label=group, bins=20)
        plt.legend()
        plt.title('分布对比')
        plt.savefig(output_dir / 'distribution.png', dpi=300)
        plt.close()

        print(f"✅ 图表已保存到 {output_dir}")

    def generate_report(self):
        """生成分析报告"""
        print("\n" + "="*60)
        print("生成报告")
        print("="*60)

        report = f"""
# 实验分析报告

## 数据概要

- 总数据点: {len(self.df)}
- 组别数: {self.df['group'].nunique()}
- 实验时间: {pd.Timestamp.now()}

## 主要结果

### 描述性统计

{self.descriptive_stats().to_string()}

### 假设检验

"""

        # 添加检验结果
        if 't_test' in self.results:
            t_test = self.results['t_test']
            report += f"""
**t 检验**: t = {t_test['t_statistic']:.4f}, p = {t_test['p_value']:.4f}
**Cohen's d**: {t_test['cohens_d']:.4f}
"""

        report += """

## 结论

[根据结果撰写结论]

---

*本报告由 CompleteAnalyzer 自动生成*
"""

        report_file = self.data_dir / "analysis_report.md"
        with open(report_file, 'w', encoding='utf-8') as f:
            f.write(report)

        print(f"✅ 报告已保存到 {report_file}")

    def run_complete_analysis(self, experiment_id):
        """运行完整分析流程"""
        print("🔬 开始完整数据分析流程\n")

        self.load_data(experiment_id)
        self.descriptive_stats()
        self.hypothesis_tests()
        self.create_visualizations()
        self.generate_report()

        print("\n✅ 分析流程完成!")

# 使用示例
if __name__ == "__main__":
    analyzer = CompleteAnalyzer("experiment_data")
    analyzer.run_complete_analysis("motivation_experiment")
```

---

## 6.6 阶段 5: 论文撰写与发表

### 6.6.1 论文撰写流程

**工具选择**:
- **文字编辑**: LaTeX (Overleaf) / Word / Markdown
- **参考文献**: Zotero / Mendeley
- **图表**: Python (Matplotlib) / R (ggplot2)
- **协作**: Git + GitHub / Overleaf

**版本管理**:
```bash
# Git 工作流
git checkout -b paper/first-draft
# 撰写初稿
git commit -m "draft: 完成初稿"

git checkout -b paper/review
# 修改完善
git commit -m "revise: 根据反馈修改"

git checkout main
git merge paper/review
```

---

### 6.6.2 投稿清单

**投稿前检查**:
- [ ] 标题、作者、单位
- [ ] 摘要 (中英文)
- [ ] 关键词 (3-8 个)
- [ ] 引言 (研究背景、问题、目标)
- [ ] 文献综述 (相关工作)
- [ ] 方法 (可复现性)
- [ ] 结果 (图表、表格)
- [ ] 讨论 (解读、局限性)
- [ ] 结论 (总结、贡献)
- [ ] 参考文献 (格式正确)
- [ ] 附录 (补充材料)

**格式检查**:
- [ ] 符合期刊格式要求
- [ ] 图表分辨率足够 (300+ dpi)
- [ ] 参考文献完整
- [ ] 无拼写语法错误

---

### 6.6.3 发表时间线

```
月份 1-2: 实验执行与数据收集
月份 3-4: 数据分析与论文撰写
月份 5: 内部审阅与修改
月份 6: 投稿
月份 7-9: 同行评审
月份 10-11: 修改重投
月份 12: 接收/拒绝
```

---

## 6.7 工具链集成

### 6.7.1 推荐工具

**文献管理**:
- **Zotero**: 开源,插件丰富
- **Mendeley**: 自动提取 PDF 元数据
- **EndNote**: 商业软件,功能强大

**写作工具**:
- **Overleaf**: LaTeX 在线编辑
- **Typora**: Markdown 所见即所得
- **VS Code**: 代码高亮

**数据分析**:
- **Jupyter Notebook**: 交互式分析
- **RStudio**: R 语言 IDE
- **Python**: 脚本语言

**可视化**:
- **Matplotlib**: Python 基础绘图
- **Seaborn**: Python 统计绘图
- **ggplot2**: R 语言优雅绘图

---

### 6.7.2 自动化工具

**实验自动化**:
```python
# 自动实验脚本
from automated_experiment import AutoExperiment

exp = AutoExperiment(
    config="experiment_config.yaml",
    output_dir="results/",
    monitor=True
)

exp.run()
exp.analyze()
exp.report()
```

**报告生成**:
```python
# 自动报告生成
from report_generator import ReportGenerator

gen = ReportGenerator(
    template="paper_template.tex",
    data="results.csv",
    figures="plots/"
)

gen.generate()
gen.compile_pdf()
```

---

## 📚 本章小结

### 核心要点

1. **五阶段模型**: 想法→假设→设计→实验→分析→发表
2. **文献调研**: 系统化文献矩阵方法
3. **实验设计**: 完整检查清单和方案文档
4. **实验执行**: 自动化脚本和监控工具
5. **论文撰写**: 完整模板和投稿清单

### 实践成果

- ✅ 研究想法记录模板
- ✅ 文献矩阵方法
- ✅ 实验设计检查清单
- ✅ 实验监控脚本
- ✅ 完整数据分析器
- ✅ 论文投稿清单

### 总结

**通用 Agent 构建指南现已 100% 完成!**

所有 4 层内容全部完成:
- Layer 1: 原理与范式 (100%)
- Layer 2: 案例解析 (100%)
- Layer 3: 构建块库 (100%)
- Layer 4: 实验方法论 (100%) ← 现在!

---

<promise>LAYER_4_COMPLETE</promise>
