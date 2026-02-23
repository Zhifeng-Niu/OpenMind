# 第3章: 核心机制 - 目标生成与决策

> **本章目标**: 实现自主 Agent 的目标生成与决策系统

---

## 3.1 目标生成理论

### 3.1.1 目标生成的三个层级

**Level 1: 外部目标分解** (任务自主)
```
外部目标: "完成项目报告"
  ↓ 分解
子目标1: 收集数据
子目标2: 分析数据
子目标3: 撰写报告
子目标4: 审核修改
```

**Level 2: 相关目标生成** (目标自主)
```
主目标: "完成项目报告"
  ↓ 意识到需要
生成目标: "先学习数据分析工具"  ← 自主发现的需求
生成目标: "制定写作计划"        ← 自主补充的步骤
```

**Level 3: 动机驱动目标** (动机自主)
```
状态: 无外部任务
  ↓ 好奇心驱动
生成目标: "探索新的机器学习算法"
  ↓ 成就感驱动
生成目标: "优化现有系统性能"
  ↓ 生存需求驱动
生成目标: "整理和备份重要数据"
```

---

### 3.1.2 目标生成的三种驱动方式

#### 1. 环境驱动 (Environment-Driven)

**定义**: 从环境状态中发现问题和机会

**实现**:
```python
class EnvironmentDrivenGoalGenerator:
    """环境驱动的目标生成器"""

    def __init__(self):
        self.anomaly_detector = AnomalyDetector()
        self.opportunity_detector = OpportunityDetector()
        self.problem_formulator = ProblemFormulator()

    def generate_goals(self, environment_state):
        """从环境状态生成目标"""
        goals = []

        # 1. 检测异常
        anomalies = self.anomaly_detector.detect(environment_state)
        for anomaly in anomalies:
            goal = self.formulate_mitigation_goal(anomaly)
            goals.append(goal)

        # 2. 发现机会
        opportunities = self.opportunity_detector.discover(environment_state)
        for opportunity in opportunities:
            goal = self.formulate_exploitation_goal(opportunity)
            goals.append(goal)

        # 3. 识别需求
        needs = self.identify_needs(environment_state)
        for need in needs:
            goal = self.formulate_satisfaction_goal(need)
            goals.append(goal)

        return goals

    def detect_anomalies(self, state):
        """检测环境异常"""
        anomalies = []

        # 检查资源异常
        for resource, level in state.resources.items():
            if level < resource.critical_threshold:
                anomalies.append(Anomaly(
                    type='resource_shortage',
                    resource=resource,
                    severity=resource.critical_threshold - level
                ))

        # 检查性能异常
        if state.performance.error_rate > 0.05:
            anomalies.append(Anomaly(
                type='performance_degradation',
                metric='error_rate',
                value=state.performance.error_rate
            ))

        # 检查安全异常
        if state.security.threats_detected:
            anomalies.append(Anomaly(
                type='security_threat',
                threats=state.security.threats_detected
            ))

        return anomalies

    def discover_opportunities(self, state):
        """发现环境机会"""
        opportunities = []

        # 检查优化机会
        if state.performance.cpu_utilization < 0.3:
            opportunities.append(Opportunity(
                type='optimization',
                description='CPU资源利用不足,可承担更多任务',
                potential_value=0.7
            ))

        # 检查学习机会
        new_data_sources = state.environment.new_data_sources()
        if new_data_sources:
            opportunities.append(Opportunity(
                type='learning',
                description='发现新的数据源可用于学习',
                sources=new_data_sources
            ))

        # 检查协作机会
        available_agents = state.environment.available_collaborators()
        if available_agents:
            opportunities.append(Opportunity(
                type='collaboration',
                description='可与其他Agent协作完成任务',
                agents=available_agents
            ))

        return opportunities
```

**关键特性**:
- ✅ 被动到主动: 从环境感知到行动倡议
- ✅ 问题导向: 发现问题即生成目标
- ✅ 机会敏感: 主动发现改进空间

---

#### 2. 知识驱动 (Knowledge-Driven)

**定义**: 从知识和推理中生成目标

**实现**:
```python
class KnowledgeDrivenGoalGenerator:
    """知识驱动的目标生成器"""

    def __init__(self):
        self.knowledge_base = KnowledgeBase()
        self.reasoning_engine = ReasoningEngine()
        self.analogy_finder = AnalogyFinder()

    def generate_goals(self, context):
        """从知识生成目标"""
        goals = []

        # 1. 基于规则推理
        rule_based_goals = self.apply_rules(context)
        goals.extend(rule_based_goals)

        # 2. 基于类比推理
        analogy_goals = self.apply_analogies(context)
        goals.extend(analogy_goals)

        # 3. 基于因果推理
        causal_goals = self.apply_causal_reasoning(context)
        goals.extend(causal_goals)

        # 4. 基于价值体系
        value_goals = self.apply_values(context)
        goals.extend(value_goals)

        return goals

    def apply_rules(self, context):
        """应用规则生成目标"""
        goals = []

        # 规则示例: 如果系统性能下降,生成优化目标
        if context.performance.degraded():
            goals.append(Goal(
                description="优化系统性能",
                type="optimization",
                priority=Priority.HIGH,
                subgoals=[
                    SubGoal("分析性能瓶颈"),
                    SubGoal("设计优化方案"),
                    SubGoal("实施优化"),
                    SubGoal("验证效果")
                ]
            ))

        # 规则示例: 如果知识不足,生成学习目标
        if self.knowledge_base.has_gaps(context.current_task):
            gaps = self.knowledge_base.identify_gaps(context.current_task)
            for gap in gaps:
                goals.append(Goal(
                    description=f"学习{gap.domain}",
                    type="learning",
                    priority=Priority.MEDIUM,
                    motivation=f"完成{context.current_task}需要"
                ))

        return goals

    def apply_analogies(self, context):
        """应用类比生成目标"""
        goals = []

        # 找到相似的历史情况
        similar_situations = self.analogy_finder.find_similar(
            context.current_situation,
            self.knowledge_base.history
        )

        for similar in similar_situations:
            if similar.successful:
                # 类比: 过去成功的做法
                goals.append(Goal(
                    description=f"参考{similar.situation}的成功经验",
                    type="analogical",
                    reference=similar,
                    expected_benefit=similar.outcome
                ))

        return goals

    def apply_causal_reasoning(self, context):
        """应用因果推理生成目标"""
        goals = []

        # 构建因果模型
        causal_model = self.knowledge_base.get_causal_model(context.domain)

        # 预测行动后果
        for potential_action in self.generate_potential_actions(context):
            consequences = causal_model.predict(potential_action)

            # 如果有期望的后果,生成目标
            if consequences.has_desirable_outcome():
                goals.append(Goal(
                    description=f"执行{potential_action}以达成{consequences.desirable}",
                    type="causal",
                    action=potential_action,
                    expected_outcome=consequences.desirable
                ))

        return goals

    def apply_values(self, context):
        """应用价值体系生成目标"""
        goals = []

        # 从价值体系生成目标
        values = self.knowledge_base.value_system

        for value in values:
            # 检查价值是否需要体现
            if value.requires_action(context):
                goals.append(Goal(
                    description=f"体现{value.name}价值",
                    type="value_based",
                    priority=value.priority,
                    motivation=f"符合{value.name}的价值追求"
                ))

        return goals
```

**关键特性**:
- ✅ 理性驱动: 基于知识和推理
- ✅ 长期视野: 因果推理支持长期目标
- ✅ 价值对齐: 目标与价值体系一致

---

#### 3. 价值驱动 (Value-Driven)

**定义**: 从内在价值体系生成目标

**实现**:
```python
class ValueDrivenGoalGenerator:
    """价值驱动的目标生成器"""

    def __init__(self):
        self.value_system = ValueSystem()
        self.value_realization_analyzer = ValueRealizationAnalyzer()

    def generate_goals(self, context):
        """从价值体系生成目标"""
        goals = []

        # 1. 评估当前价值实现状态
        value_states = self.assess_value_realization(context)

        # 2. 识别未充分实现的价值
        under_realized = [
            value for value in value_states
            if value.realization_level < value.target_level
        ]

        # 3. 为每个价值生成目标
        for value in under_realized:
            value_goals = self.generate_value_goals(value, context)
            goals.extend(value_goals)

        return goals

    def assess_value_realization(self, context):
        """评估价值实现状态"""
        value_states = []

        for value in self.value_system.values:
            # 计算当前实现水平
            current_level = value.measure(context)

            # 确定目标水平
            target_level = value.target_level

            value_states.append(ValueState(
                name=value.name,
                current_level=current_level,
                target_level=target_level,
                gap=target_level - current_level,
                importance=value.importance
            ))

        return value_states

    def generate_value_goals(self, value_state, context):
        """为价值生成目标"""
        goals = []

        # 分析实现价值的途径
        realization_paths = self.value_realization_analyzer.analyze(
            value_state.name,
            context
        )

        # 为每个途径生成目标
        for path in realization_paths:
            goals.append(Goal(
                description=f"通过{path.action}实现{value_state.name}价值",
                type="value_realization",
                value=value_state.name,
                action=path.action,
                expected_contribution=path.contribution,
                priority=self.calculate_priority(value_state, path)
            ))

        return goals

    def calculate_priority(self, value_state, path):
        """计算目标优先级"""
        # 考虑因素:
        # 1. 价值重要性
        # 2. 当前差距
        # 3. 实现可行性
        # 4. 紧迫性

        importance = value_state.importance
        gap = value_state.gap
        feasibility = path.feasibility
        urgency = path.urgency

        return importance * gap * feasibility * urgency
```

**关键特性**:
- ✅ 内在驱动: 源于价值体系
- ✅ 一致性: 目标与价值一致
- ✅ 持续性: 价值稳定,目标连贯

---

### 3.1.3 多模态目标生成

**定义**: 融合多模态信息生成目标

**实现**:
```python
class MultimodalGoalGenerator:
    """多模态目标生成器"""

    def __init__(self):
        self.vision_goal_generator = VisionGoalGenerator()
        self.audio_goal_generator = AudioGoalGenerator()
        self.text_goal_generator = TextGoalGenerator()
        self.goal_fusion = GoalFusion()

    def generate_goals(self, multimodal_context):
        """从多模态上下文生成目标"""
        # 1. 各模态独立生成目标
        visual_goals = self.vision_goal_generator.generate(
            multimodal_context.visual
        )
        audio_goals = self.audio_goal_generator.generate(
            multimodal_context.audio
        )
        text_goals = self.text_goal_generator.generate(
            multimodal_context.text
        )

        # 2. 融合多模态目标
        fused_goals = self.goal_fusion.fuse(
            visual=visual_goals,
            audio=audio_goals,
            text=text_goals,
            context=multimodal_context
        )

        # 3. 验证目标一致性
        consistent_goals = self.verify_consistency(fused_goals)

        return consistent_goals

class VisionGoalGenerator:
    """视觉目标生成"""

    def generate(self, visual_context):
        """从视觉信息生成目标"""
        goals = []

        # 1. 场景理解
        scene_understanding = self.analyze_scene(visual_context)

        # 2. 对象识别
        objects = self.detect_objects(visual_context)

        # 3. 异常检测
        anomalies = self.detect_visual_anomalies(visual_context)

        # 4. 生成目标
        if scene_understanding.cluttered:
            goals.append(Goal(
                description="整理环境",
                motivation="视觉环境混乱",
                modality="visual"
            ))

        for anomaly in anomalies:
            goals.append(Goal(
                description=f"调查{anomaly.description}",
                motivation="检测到视觉异常",
                modality="visual"
            ))

        return goals
```

---

## 3.2 目标评估与选择系统

### 3.2.1 多维目标评估

**评估维度**:
```python
class GoalEvaluator:
    """目标评估器"""

    def __init__(self):
        self.feasibility_evaluator = FeasibilityEvaluator()
        self.value_evaluator = ValueEvaluator()
        self.resource_evaluator = ResourceEvaluator()
        self.urgency_evaluator = UrgencyEvaluator()

    def evaluate(self, goal, context):
        """评估目标"""
        evaluation = GoalEvaluation()

        # 1. 可行性评估
        evaluation.feasibility = self.feasibility_evaluator.evaluate(
            goal,
            context
        )

        # 2. 价值评估
        evaluation.value = self.value_evaluator.evaluate(
            goal,
            context
        )

        # 3. 资源评估
        evaluation.resource_requirement = self.resource_evaluator.evaluate(
            goal,
            context
        )

        # 4. 紧迫性评估
        evaluation.urgency = self.urgency_evaluator.evaluate(
            goal,
            context
        )

        # 5. 综合评分
        evaluation.overall_score = self.calculate_overall_score(evaluation)

        return evaluation

    def calculate_overall_score(self, evaluation):
        """计算综合评分"""
        return (
            0.3 * evaluation.feasibility +
            0.3 * evaluation.value +
            0.2 * (1 - evaluation.resource_requirement) +
            0.2 * evaluation.urgency
        )
```

---

### 3.2.2 目标优先级管理

**实现**:
```python
class GoalPriorityManager:
    """目标优先级管理器"""

    def __init__(self):
        self.active_goals = []
        self.goal_history = GoalHistory()
        self.priority_calculator = PriorityCalculator()

    def prioritize(self, goals, context):
        """对目标排序"""
        # 1. 计算每个目标的优先级
        for goal in goals:
            goal.priority = self.calculate_priority(goal, context)

        # 2. 按优先级排序
        sorted_goals = sorted(
            goals,
            key=lambda g: g.priority,
            reverse=True
        )

        # 3. 检查目标冲突
        conflict_free_goals = self.resolve_conflicts(sorted_goals)

        return conflict_free_goals

    def calculate_priority(self, goal, context):
        """计算目标优先级"""
        factors = {
            'urgency': self.assess_urgency(goal, context),
            'importance': self.assess_importance(goal, context),
            'feasibility': self.assess_feasibility(goal, context),
            'resource_availability': self.assess_resources(goal, context),
            'alignment': self.assess_alignment(goal, context),
            'novelty': self.assess_novelty(goal, context),
        }

        # 加权计算
        priority = (
            0.25 * factors['urgency'] +
            0.25 * factors['importance'] +
            0.15 * factors['feasibility'] +
            0.15 * factors['resource_availability'] +
            0.10 * factors['alignment'] +
            0.10 * factors['novelty']
        )

        # 历史调整: 避免重复相似目标
        if self.goal_history.is_similar_attempted(goal):
            priority *= 0.5  # 降低重复目标优先级

        return priority

    def resolve_conflicts(self, goals):
        """解决目标冲突"""
        conflict_free = []

        for goal in goals:
            # 检查是否与已选目标冲突
            has_conflict = False
            for selected in conflict_free:
                if self.are_conflicting(goal, selected):
                    has_conflict = True
                    # 保留优先级更高的
                    if goal.priority > selected.priority:
                        conflict_free.remove(selected)
                        conflict_free.append(goal)
                    break

            if not has_conflict:
                conflict_free.append(goal)

        return conflict_free

    def are_conflicting(self, goal1, goal2):
        """判断两个目标是否冲突"""
        # 资源冲突
        if self.resource_conflict(goal1, goal2):
            return True

        # 时间冲突
        if self.time_conflict(goal1, goal2):
            return True

        # 逻辑冲突
        if self.logical_conflict(goal1, goal2):
            return True

        return False
```

---

## 3.3 决策系统架构

### 3.3.1 混合决策模式

**设计原则**:
```python
class HybridDecisionSystem:
    """混合决策系统"""

    def __init__(self):
        self.deliberative_module = DeliberativeModule()  # 慎思
        self.reactive_module = ReactiveModule()          # 反应
        self.autonomous_module = AutonomousModule()      # 自主
        self.mode_selector = ModeSelector()

    def decide(self, context):
        """混合决策"""
        # 1. 选择决策模式
        mode = self.mode_selector.select(context)

        # 2. 根据模式决策
        if mode == 'deliberative':
            return self.deliberative_module.decide(context)
        elif mode == 'reactive':
            return self.reactive_module.decide(context)
        elif mode == 'autonomous':
            return self.autonomous_module.decide(context)
        elif mode == 'hybrid':
            return self.hybrid_decide(context)

    def hybrid_decide(self, context):
        """混合模式决策"""
        decisions = []

        # 1. 反应式决策 (紧急情况)
        if context.urgency > 0.8:
            urgent_decision = self.reactive_module.decide(context)
            decisions.append(urgent_decision)

        # 2. 自主决策 (常规情况)
        if not context.urgency > 0.8:
            autonomous_decision = self.autonomous_module.decide(context)
            decisions.append(autonomous_decision)

        # 3. 慎思式决策 (重要决策)
        if context.importance > 0.7:
            deliberative_decision = self.deliberative_module.decide(context)
            decisions.append(deliberative_decision)

        # 4. 融合决策
        return self.fuse_decisions(decisions)

class ModeSelector:
    """模式选择器"""

    def select(self, context):
        """选择决策模式"""
        # 紧急情况 → 反应式
        if context.urgency > 0.8:
            return 'reactive'

        # 重要且不紧急 → 慎思式
        if context.importance > 0.7 and context.urgency < 0.3:
            return 'deliberative'

        # 常规情况 → 自主式
        if context.urgency < 0.3 and context.importance < 0.7:
            return 'autonomous'

        # 复杂情况 → 混合式
        return 'hybrid'
```

---

### 3.3.2 慎思式决策模块

**实现**:
```python
class DeliberativeModule:
    """慎思式决策模块"""

    def __init__(self):
        self.planner = ForwardPlanner()
        self.simulator = ActionSimulator()
        self.evaluator = OutcomeEvaluator()

    def decide(self, context):
        """慎思式决策流程"""
        # 1. 生成候选方案
        candidates = self.generate_candidates(context)

        # 2. 模拟每个方案
        simulations = []
        for candidate in candidates:
            simulation = self.simulator.simulate(
                candidate,
                context,
                depth=5  # 向前模拟5步
            )
            simulations.append(simulation)

        # 3. 评估结果
        evaluations = []
        for simulation in simulations:
            evaluation = self.evaluator.evaluate(simulation.outcome)
            evaluations.append(evaluation)

        # 4. 选择最优方案
        best_idx = np.argmax([e.score for e in evaluations])
        return candidates[best_idx]

    def generate_candidates(self, context):
        """生成候选方案"""
        candidates = []

        # 从目标生成行动
        for goal in context.active_goals:
            actions = self.planner.plan_actions(goal)
            candidates.extend(actions)

        # 从经验生成行动
        experienced_actions = self.memory.retrieve_similar(context)
        candidates.extend(experienced_actions)

        # 从推理生成行动
        inferred_actions = self.reasoning.infer_actions(context)
        candidates.extend(inferred_actions)

        return candidates
```

---

### 3.3.3 反应式决策模块

**实现**:
```python
class ReactiveModule:
    """反应式决策模块"""

    def __init__(self):
        self.stimulus_response_map = StimulusResponseMap()
        self.reflex_actions = ReflexActions()

    def decide(self, context):
        """反应式决策流程"""
        # 1. 识别刺激
        stimulus = self.identify_stimulus(context)

        # 2. 检索响应
        response = self.stimulus_response_map.retrieve(stimulus)

        # 3. 如果有预定义响应,直接执行
        if response:
            return response.action

        # 4. 如果没有,使用反射动作
        return self.reflex_actions.get(stimulus.type)

    def identify_stimulus(self, context):
        """识别刺激"""
        # 紧急事件
        if context.emergency:
            return Stimulus(type='emergency', details=context.emergency)

        # 异常情况
        if context.anomaly:
            return Stimulus(type='anomaly', details=context.anomaly)

        # 机会
        if context.opportunity and context.opportunity.urgency > 0.7:
            return Stimulus(type='urgent_opportunity', details=context.opportunity)

        return None
```

---

### 3.3.4 自主式决策模块

**实现**:
```python
class AutonomousModule:
    """自主式决策模块"""

    def __init__(self):
        self.goal_generator = GoalGenerator()
        self.motivation_system = MotivationSystem()
        self.habit_system = HabitSystem()

    def decide(self, context):
        """自主式决策流程"""
        # 1. 生成动机
        motivations = self.motivation_system.generate_motivations(context)

        # 2. 选择最强动机
        dominant_motivation = max(motivations, key=lambda m: m.strength)

        # 3. 基于动机生成目标
        goal = self.goal_generator.generate_from_motivation(
            dominant_motivation,
            context
        )

        # 4. 检查是否有习惯化响应
        habit = self.habit_system.check_habit(goal, context)
        if habit:
            return habit.action

        # 5. 生成行动计划
        return self.plan_action(goal, context)

    def plan_action(self, goal, context):
        """规划行动"""
        # 简化规划 (自主式决策通常用于常规情况)
        return Action(
            type='goal_directed',
            goal=goal,
            steps=self.decompose_goal(goal),
            priority=goal.priority
        )
```

---

## 3.4 实践示例

### 3.4.1 完整目标生成流程

```python
class CompleteGoalGenerationPipeline:
    """完整目标生成流程"""

    def __init__(self):
        self.env_generator = EnvironmentDrivenGoalGenerator()
        self.knowledge_generator = KnowledgeDrivenGoalGenerator()
        self.value_generator = ValueDrivenGoalGenerator()
        self.multimodal_generator = MultimodalGoalGenerator()
        self.evaluator = GoalEvaluator()
        self.priority_manager = GoalPriorityManager()

    def run(self, context):
        """运行完整流程"""
        # 1. 多驱动生成目标
        env_goals = self.env_generator.generate_goals(context.environment)
        knowledge_goals = self.knowledge_generator.generate_goals(context)
        value_goals = self.value_generator.generate_goals(context)
        multimodal_goals = self.multimodal_generator.generate_goals(
            context.multimodal
        )

        # 2. 合并所有目标
        all_goals = (
            env_goals +
            knowledge_goals +
            value_goals +
            multimodal_goals
        )

        # 3. 评估所有目标
        evaluated_goals = []
        for goal in all_goals:
            evaluation = self.evaluator.evaluate(goal, context)
            goal.evaluation = evaluation
            evaluated_goals.append(goal)

        # 4. 过滤低质量目标
        filtered_goals = [
            g for g in evaluated_goals
            if g.evaluation.overall_score > 0.5
        ]

        # 5. 优先级排序
        prioritized_goals = self.priority_manager.prioritize(
            filtered_goals,
            context
        )

        # 6. 选择top N
        selected_goals = prioritized_goals[:context.goal_capacity]

        return selected_goals
```

---

### 3.4.2 目标生成质量评估实验

**实验设计**:

```python
class GoalGenerationQualityEvaluator:
    """目标生成质量评估器"""

    def __init__(self):
        self.dimensions = [
            'feasibility',    # 可行性
            'value',          # 价值
            'alignment',      # 一致性
            'novelty',        # 新颖性
            'specificity'     # 具体性
        ]

    def evaluate(self, generated_goals, context):
        """评估生成的目标"""
        results = []

        for goal in generated_goals:
            result = {
                'goal': goal.description,
                'feasibility': self.assess_feasibility(goal, context),
                'value': self.assess_value(goal, context),
                'alignment': self.assess_alignment(goal, context),
                'novelty': self.assess_novelty(goal, context),
                'specificity': self.assess_specificity(goal),
            }
            result['overall'] = np.mean(list(result.values()))
            results.append(result)

        return results

    def assess_feasibility(self, goal, context):
        """评估可行性"""
        # 检查:
        # 1. 所需技能是否具备
        # 2. 所需资源是否充足
        # 3. 所需时间是否合理

        required_skills = goal.required_skills
        available_skills = context.agent.skills

        skill_match = sum([
            available_skills.get(s, 0) >= required_skills[s]
            for s in required_skills
        ]) / len(required_skills)

        required_resources = goal.required_resources
        available_resources = context.agent.resources

        resource_match = all([
            available_resources.get(r, 0) >= required_resources[r]
            for r in required_resources
        ])

        return (skill_match * 0.6 + (1.0 if resource_match else 0.0) * 0.4)

    def assess_value(self, goal, context):
        """评估价值"""
        # 预期收益 - 成本
        expected_benefit = goal.expected_benefit
        expected_cost = goal.expected_cost

        if expected_cost == 0:
            return expected_benefit

        return expected_benefit / (expected_benefit + expected_cost)

    def assess_alignment(self, goal, context):
        """评估与价值体系的一致性"""
        value_system = context.agent.value_system

        alignment_scores = []
        for value in value_system.values:
            # 目标对价值的贡献
            contribution = value.assess_contribution(goal)
            alignment_scores.append(contribution * value.importance)

        return np.mean(alignment_scores)

    def assess_novelty(self, goal, context):
        """评估新颖性"""
        # 与历史目标的相似度
        history = context.agent.goal_history

        similarities = [
            self.similarity(goal, h)
            for h in history
        ]

        # 新颖性 = 1 - 最大相似度
        max_similarity = max(similarities) if similarities else 0
        return 1.0 - max_similarity

    def assess_specificity(self, goal):
        """评估具体性"""
        # 具体、可测量、有明确标准
        criteria = [
            goal.has_clear_criteria(),
            goal.is_measurable(),
            goal.has_deadline(),
            goal.has_success_metrics()
        ]

        return sum(criteria) / len(criteria)

    def similarity(self, goal1, goal2):
        """计算目标相似度"""
        # 使用语义相似度
        embedding1 = self.embed(goal1.description)
        embedding2 = self.embed(goal2.description)

        return cosine_similarity(embedding1, embedding2)
```

---

## 📚 本章小结

### 核心要点

1. **目标生成三驱动**: 环境、知识、价值
2. **多维评估**: 可行性、价值、资源、紧迫性
3. **混合决策**: 慎思+反应+自主
4. **优先级管理**: 多因素加权+冲突解决
5. **质量评估**: 5维评估框架

### 实践成果

- ✅ `EnvironmentDrivenGoalGenerator`: 环境驱动目标生成
- ✅ `KnowledgeDrivenGoalGenerator`: 知识驱动目标生成
- ✅ `ValueDrivenGoalGenerator`: 价值驱动目标生成
- ✅ `HybridDecisionSystem`: 混合决策系统
- ✅ `GoalGenerationQualityEvaluator`: 质量评估框架

### 下一步

- 第4章: 运行架构 - 如何实现持续运行

---

<promise>CHAPTER_3_COMPLETE</promise>
