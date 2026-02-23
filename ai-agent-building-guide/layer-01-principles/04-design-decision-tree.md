# 设计决策树

> 系统化地设计你的 Agent

## 🎯 本章目标

使用决策树方法,系统化地设计 Agent。

1. 理解设计决策的完整流程
2. 掌握每个决策点的考量因素
3. 学会使用决策辅助工具
4. 避免常见的设计陷阱

## 4.1 完整决策树

```
你的 Agent 需要持续改进吗?
├─ 是 → 进入【演化系统】分支
│   ├─ 需要修改自身代码吗?
│   │   ├─ 是 → 代码自生成 + 沙箱测试
│   │   │   ├─ 需要多大改动?
│   │   │   │   ├─ 小改动 → 提示优化
│   │   │   │   ├─ 中等改动 → 函数级重构
│   │   │   │   └─ 大改动 → 架构演化
│   │   └─ 否 → 参数/策略优化
│   │       ├─ 基于什么优化?
│   │       │   ├─ 自身反馈 → RSI
│   │       │   ├─ 外部评价 → 强化学习
│   │       │   └─ 两者结合 → 混合优化
│   └─ 改进频率?
│       ├─ 实时 → 在线学习
│       ├─ 定期 → 批量优化
│       └─ 按需 → 触发式改进
└─ 否 → 进入【静态系统】分支
    └─ 任务类型?
        ├─ 单次响应 → 简单对话 Agent
        │   ├─ 需要多模态?
        │   │   ├─ 是 → 多模态 LLM
        │   │   └─ 否 → 文本 LLM
        │   └─ 需要工具?
        │       ├─ 是 → Tool Calling
        │       └─ 否 → 纯对话
        ├─ 多步任务 → 规划型 Agent
        │   ├─ 任务可预测?
        │   │   ├─ 是 → Workflow + LLM
        │   │   └─ 否 → ReAct Agent
        │   └─ 需要记忆?
        │       ├─ 是 → RAG + Agent
        │       └─ 否 → 无状态 Agent
        └─ 持续监控 → 守护进程 Agent
            ├─ 监控什么?
            │   ├─ 数据 → 数据监控
            │   ├─ 系统 → 系统监控
            │   └─ 业务 → 业务监控
            └─ 响应方式?
                ├─ 被动 → 定期检查
                ├─ 主动 → 事件驱动
                └─ 混合 → 两者结合
```

## 4.2 关键决策点详解

### 决策点 1: 是否需要持续改进?

**评估标准:**
- 任务是否会重复出现?
- 环境是否会变化?
- 是否有改进空间?

**案例分析:**
```
客服机器人:
- 重复: 是 (每天处理类似问题)
- 环境: 是 (产品更新、FAQ变化)
- 改进: 是 (可以优化回答质量)
→ 需要持续改进

一次性代码生成:
- 重复: 否 (每次任务不同)
- 环境: 否
- 改进: 否
→ 不需要持续改进
```

### 决策点 2: 是否需要修改自身代码?

**三种程度的改动:**

| 改动程度 | 技术 | 风险 | 示例 |
|---------|------|------|------|
| 提示优化 | Prompt Tuning | 低 | 优化回答质量 |
| 函数重构 | 代码生成 | 中 | 重写某个函数 |
| 架构演化 | 神经进化 | 高 | 完全重构系统 |

**实现示例:**
```python
class CodeSelfModifier:
    async def improve(self, feedback):
        complexity = self.assess_complexity(feedback)

        if complexity == "low":
            # 提示优化
            return await self.optimize_prompt(feedback)
        elif complexity == "medium":
            # 函数级重构
            return await self.refactor_function(feedback)
        else:
            # 架构演化
            return await self.evolve_architecture(feedback)
```

### 决策点 3: 改进基于什么?

**自身反馈 (RSI)**
```python
# 基于自己的输出质量
quality = self.evaluate(output)
if quality < threshold:
    output = self.improve(output)
```

**外部评价 (强化学习)**
```python
# 基于人类的评分
reward = human_feedback(output)
self.policy.update(reward)
```

**混合优化**
```python
# 结合两者
self_feedback = self.self_evaluate()
external_feedback = self.get_feedback()
combined = self.combine_feedbacks(
    self_feedback,
    external_feedback
)
```

### 决策点 4: 任务类型

**单次响应 vs 多步任务**

| 特征 | 单次 | 多步 |
|------|------|------|
| 输入 | 独立 | 连续 |
| 输出 | 一次性 | 渐进式 |
| 规划 | 不需要 | 需要 |
| 示例 | 问答 | 任务执行 |

**判断方法:**
```python
def classify_task(task_description):
    if "步骤" in task_description or "然后" in task_description:
        return "multi_step"
    elif "完成" in task_description or "实现" in task_description:
        return "multi_step"
    else:
        return "single_shot"
```

## 4.3 决策辅助工具

### 工具 1: 问题诊断清单

```python
class DiagnosticChecklist:
    """帮助诊断 Agent 需求"""

    QUESTIONS = [
        "任务是否重复出现?",
        "环境是否会变化?",
        "是否需要长期规划?",
        "是否需要工具?",
        "是否需要记忆?",
        "是否需要多 Agent 协作?",
        "安全性要求如何?",
        "是否需要解释决策?"
    ]

    def diagnose(self, requirements):
        answers = {}
        for question in self.QUESTIONS:
            answers[question] = self.ask_user(question)

        # 分析答案模式
        return self.analyze(answers)

    def ask_user(self, question):
        return input(f"{question} (y/n): ").lower() == 'y'

    def analyze(self, answers):
        if answers["任务是否重复出现?"] and answers["环境是否会变化?"]:
            return "需要演化能力"

        if answers["是否需要多 Agent 协作?"]:
            return "需要多 Agent 系统"

        # ... 更多分析逻辑
```

### 工具 2: 架构推荐器

```python
class ArchitectureRecommender:
    """根据需求推荐架构"""

    def recommend(self, requirements):
        # 基于决策树的推荐逻辑
        if requirements.needs_improvement:
            return self.recommend_evolutionary(requirements)
        else:
            return self.recommend_static(requirements)

    def recommend_evolutionary(self, req):
        if req.can_modify_code:
            return {
                "pattern": "代码自增强",
                "components": [
                    "LLM",
                    "代码解释器",
                    "测试框架",
                    "版本控制"
                ]
            }
        else:
            return {
                "pattern": "参数优化",
                "components": [
                    "LLM",
                    "优化器",
                    "评估器",
                    "参数存储"
                ]
            }
```

## 4.4 常见设计路径

### 路径 1: 简单 RAG Agent

```
需求: 问答系统
→ 单次响应
→ 需要记忆
→ 不需要改进
→ 静态系统

架构:
- LLM
- 向量数据库
- 简单 Loop
```

### 路径 2: 规划型 Agent

```
需求: 任务执行
→ 多步任务
→ 任务可预测
→ 不需要改进
→ 静态系统

架构:
- LLM + ReAct
- 工具调用
- 短期记忆
```

### 路径 3: 自我演化 Agent

```
需求: 持续改进
→ 需要改进
→ 可以修改代码
→ 中等改动
→ 演化系统

架构:
- LLM
- 代码自生成
- 沙箱测试
- RSI 模块
```

## 4.5 设计陷阱

### 陷阱 1: 过度设计

**症状:**
- 为简单任务选择复杂架构
- 引入不必要的模式

**避免方法:**
- 从最简单开始
- 只在需要时增加复杂度
- 定期审视设计决策

### 陷阱 2: 过早优化

**症状:**
- 在验证假设前优化架构
- 引入高级模式但不确定是否需要

**避免方法:**
- 先用最简单方案验证
- 收集数据后再优化
- YAGNI (You Aren't Gonna Need It)

### 陷阱 3: 忽视演化路径

**症状:**
- 设计难以扩展的架构
- 没有考虑未来需求

**避免方法:**
- 模块化设计
- 预留扩展点
- 设计可替换组件

## 4.6 练习

### 练习 1: 使用决策树

使用决策树为以下场景设计 Agent:
1. 自动化代码审查
2. 个人知识管理
3. 社交媒体分析

### 练习 2: 诊断需求

给定一个 Agent 想法,使用诊断清单分析需求。

### 练习 3: 推荐架构

基于需求推荐合适的架构组合。

## 4.7 总结

### 关键要点

1. **系统化设计**: 使用决策树避免遗漏
2. **逐步细化**: 从高层决策到具体实现
3. **工具辅助**: 使用诊断和推荐工具
4. **避免陷阱**: 过度设计、过早优化、忽视演化

### 下一步

- [Claude Code 作为工具](05-claude-code-as-tool.md) - 如何实现设计
- [Layer 2: 案例解析](../layer-02-case-studies/) - 真实项目的设计
