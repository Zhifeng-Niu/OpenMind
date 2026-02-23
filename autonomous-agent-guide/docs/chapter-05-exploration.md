# 第5章: 主动行为 - 探索与学习

> **本章目标**: 实现自主 Agent 的主动探索与学习机制

---

## 5.1 主动探索理论

### 5.1.1 探索的必要性

**为什么需要主动探索?**

```python
class ExplorationNecessityAnalyzer:
    """探索必要性分析器"""

    def __init__(self):
        self.knowledge_assessor = KnowledgeAssessment()
        self.opportunity_detector = OpportunityDetector()

    def analyze(self, agent_state):
        """分析是否需要探索"""
        reasons = []

        # 1. 知识不足
        knowledge_gaps = self.knowledge_assessor.identify_gaps(agent_state)
        if knowledge_gaps:
            reasons.append(ExplorationReason(
                type='knowledge_gap',
                description=f"存在{len(knowledge_gaps)}个知识缺口",
                priority=self.calculate_gap_priority(knowledge_gaps)
            ))

        # 2. 性能下降
        if agent_state.performance.is_degrading():
            reasons.append(ExplorationReason(
                type='performance_degradation',
                description="性能下降,需要探索新策略",
                priority=Priority.HIGH
            ))

        # 3. 机会发现
        opportunities = self.opportunity_detector.discover(agent_state)
        if opportunities:
            reasons.append(ExplorationReason(
                type='opportunity',
                description=f"发现{len(opportunities)}个探索机会",
                priority=Priority.MEDIUM
            ))

        # 4. 好奇心驱动
        curiosity_level = agent_state.motivation.curiosity.level
        if curiosity_level > 0.7:
            reasons.append(ExplorationReason(
                type='curiosity',
                description=f"好奇心水平高: {curiosity_level:.2f}",
                priority=Priority.MEDIUM
            ))

        return reasons
```

---

### 5.1.2 探索策略分类

**策略 1: 随机探索**
```python
class RandomExploration:
    """随机探索策略"""

    def explore(self, environment):
        """随机选择行动"""
        # 获取所有可能的行动
        possible_actions = environment.get_possible_actions()

        # 随机选择
        return random.choice(possible_actions)
```

**策略 2: ε-贪婪探索**
```python
class EpsilonGreedyExploration:
    """ε-贪婪探索策略"""

    def __init__(self, epsilon=0.1, decay_rate=0.995):
        self.epsilon = epsilon
        self.decay_rate = decay_rate

    def explore(self, environment, value_function):
        """ε-贪婪选择"""
        if random.random() < self.epsilon:
            # 探索: 随机选择
            return environment.get_random_action()
        else:
            # 利用: 选择价值最高的
            return self.get_best_action(environment, value_function)

    def decay_epsilon(self):
        """衰减探索率"""
        self.epsilon *= self.decay_rate
```

**策略 3: 优化不确定性 (Optimistic in the Face of Uncertainty)**
```python
class OFUExploration:
    """优化不确定性探索"""

    def explore(self, environment, value_estimates, uncertainty_estimates):
        """选择乐观估计的行动"""
        # 乐观估计 = 价值估计 + 不确定性
        optimistic_values = {
            action: value_estimates[action] + uncertainty_estimates[action]
            for action in environment.get_possible_actions()
        }

        # 选择乐观估计最高的
        return max(optimistic_values.items(), key=lambda x: x[1])[0]
```

**策略 4: 好奇心驱动探索**
```python
class CuriosityDrivenExploration:
    """好奇心驱动探索"""

    def __init__(self):
        self.predictive_model = PredictiveModel()
        self.information_theory = InformationTheory()

    def explore(self, environment):
        """基于好奇心探索"""
        possible_actions = environment.get_possible_actions()

        curiosity_scores = {}
        for action in possible_actions:
            # 预测执行行动后的结果
            prediction = self.predictive_model.predict(action)

            # 计算预测的不确定性 (好奇心)
            uncertainty = self.information_theory.entropy(prediction)

            # 估计信息增益
            information_gain = self.estimate_information_gain(action)

            # 好奇心 = 不确定性 + 信息增益
            curiosity_scores[action] = uncertainty + information_gain

        # 选择好奇心最高的行动
        return max(curiosity_scores.items(), key=lambda x: x[1])[0]

    def estimate_information_gain(self, action):
        """估计信息增益"""
        # 执行行动前后的知识差异
        prior_belief = self.current_belief()
        predicted_outcome = self.predictive_model.predict(action)
        posterior_belief = self.update_belief(prior_belief, predicted_outcome)

        # KL散度衡量信息增益
        return self.information_theory.kl_divergence(
            prior_belief,
            posterior_belief
        )
```

---

## 5.2 好奇心机制

### 5.2.1 惊讶度驱动

**实现**:
```python
class SurpriseDrivenCuriosity:
    """惊讶度驱动的好奇心"""

    def __init__(self):
        self.predictive_model = PredictiveModel()
        self.surprise_calculator = SurpriseCalculator()

    def calculate_curiosity(self, experience):
        """计算好奇心"""
        # 1. 预测
        prediction = self.predictive_model.predict(experience.situation)

        # 2. 计算惊讶度 (预测误差)
        surprise = self.surprise_calculator.calculate(
            prediction,
            experience.actual_outcome
        )

        # 3. 好奇心 = 惊讶度
        curiosity = surprise

        return curiosity

    def update_model(self, experience):
        """根据经验更新预测模型"""
        # 从错误中学习
        prediction_error = experience.actual_outcome - self.predictive_model.predict(experience.situation)
        self.predictive_model.learn(experience.situation, experience.actual_outcome)

class PredictiveModel:
    """预测模型"""

    def __init__(self):
        self.model = None  # 可以是神经网络、决策树等
        self.confidence_estimator = ConfidenceEstimator()

    def predict(self, situation):
        """预测结果"""
        prediction = self.model.predict(situation)
        confidence = self.confidence_estimator.estimate(situation)

        return Prediction(
            outcome=prediction,
            confidence=confidence
        )

    def learn(self, situation, actual_outcome):
        """从经验中学习"""
        # 更新模型
        self.model.update(situation, actual_outcome)

        # 调整置信度估计
        self.confidence_estimator.update(situation, actual_outcome)

class SurpriseCalculator:
    """惊讶度计算器"""

    def calculate(self, prediction, actual_outcome):
        """计算惊讶度"""
        # 1. 预测误差
        error = abs(prediction.outcome - actual_outcome)

        # 2. 考虑预测置信度
        # 置信度高的预测出错 → 更惊讶
        surprise = error * (1 + prediction.confidence)

        return surprise
```

---

### 5.2.2 信息增益驱动

**实现**:
```python
class InformationGainCuriosity:
    """信息增益驱动的好奇心"""

    def __init__(self):
        self.belief_model = BeliefModel()
        self.information_theory = InformationTheory()

    def calculate_curiosity(self, situation, potential_action):
        """计算好奇心"""
        # 1. 当前信念
        prior_belief = self.belief_model.get_belief(situation)

        # 2. 预测执行行动后的信念
        predicted_belief = self.predict_belief_update(
            situation,
            potential_action
        )

        # 3. 计算信息增益 (KL散度)
        information_gain = self.information_theory.kl_divergence(
            prior_belief,
            predicted_belief
        )

        return information_gain

    def predict_belief_update(self, situation, action):
        """预测信念更新"""
        # 模拟执行行动
        predicted_outcome = self.simulate_action(situation, action)

        # 更新信念
        updated_belief = self.belief_model.update(
            situation,
            action,
            predicted_outcome
        )

        return updated_belief

    def simulate_action(self, situation, action):
        """模拟执行行动"""
        # 可以使用世界模型模拟
        return self.world_model.predict(situation, action)
```

---

### 5.2.3 综合好奇心系统

**实现**:
```python
class CompositeCuriositySystem:
    """综合好奇心系统"""

    def __init__(self):
        self.surprise_curiosity = SurpriseDrivenCuriosity()
        self.information_gain_curiosity = InformationGainCuriosity()
        self.novelty_detector = NoveltyDetector()
        self.complexity_assessor = ComplexityAssessor()

    def calculate_curiosity(self, situation, action=None):
        """计算综合好奇心"""
        curiosity_components = {}

        # 1. 惊讶度
        if action:
            curiosity_components['surprise'] = (
                self.surprise_curiosity.calculate_curiosity(
                    Experience(situation, action)
                )
            )

        # 2. 信息增益
        if action:
            curiosity_components['information_gain'] = (
                self.information_gain_curiosity.calculate_curiosity(
                    situation,
                    action
                )
            )

        # 3. 新颖性
        curiosity_components['novelty'] = (
            self.novelty_detector.assess_novelty(situation)
        )

        # 4. 复杂性 (适度的复杂性引发好奇)
        complexity = self.complexity_assess.assess(situation)
        # 倒U型: 太简单或太复杂都不好奇
        curiosity_components['complexity'] = (
            1.0 - abs(complexity - 0.5) * 2
        )

        # 5. 加权综合
        weights = {
            'surprise': 0.3,
            'information_gain': 0.3,
            'novelty': 0.2,
            'complexity': 0.2,
        }

        overall_curiosity = sum(
            curiosity_components[k] * weights[k]
            for k in curiosity_components
        )

        return CuriosityScore(
            overall=overall_curiosity,
            components=curiosity_components
        )

class NoveltyDetector:
    """新颖性检测器"""

    def __init__(self):
        self.memory = EpisodicMemory()
        self.similarity_threshold = 0.8

    def assess_novelty(self, situation):
        """评估新颖性"""
        # 从记忆中检索相似情况
        similar_experiences = self.memory.retrieve_similar(
            situation,
            top_k=5
        )

        if not similar_experiences:
            # 完全新颖
            return 1.0

        # 计算最大相似度
        max_similarity = max(
            self.similarity(situation, exp)
            for exp in similar_experiences
        )

        # 新颖性 = 1 - 相似度
        novelty = 1.0 - max_similarity

        return novelty

    def similarity(self, situation1, situation2):
        """计算相似度"""
        # 使用嵌入向量的余弦相似度
        embedding1 = self.embed(situation1)
        embedding2 = self.embed(situation2)

        return cosine_similarity(embedding1, embedding2)

    def embed(self, situation):
        """将情境编码为向量"""
        return self.embedding_model.encode(situation)
```

---

## 5.3 主动视觉系统

### 5.3.1 注意力机制

**实现**:
```python
class VisualAttentionMechanism:
    """视觉注意力机制"""

    def __init__(self):
        self.saliency_map_generator = SaliencyMapGenerator()
        self.target_detector = TargetDetector()
        self.attention_history = AttentionHistory()

    def select_attention_region(self, image, goal):
        """选择注意区域"""
        # 1. 生成显著性图 (自底向上)
        bottom_up_saliency = self.saliency_map_generator.generate(image)

        # 2. 目标导向注意 (自顶向下)
        top_down_guidance = self.target_detector.generate_attention_map(
            image,
            goal
        )

        # 3. 融合两者
        combined_attention = self.combine_attentions(
            bottom_up_saliency,
            top_down_guidance
        )

        # 4. 考虑历史 (抑制已返回)
        attention_with_inhibition = self.apply_inhibition_of_return(
            combined_attention,
            self.attention_history
        )

        # 5. 选择注意力中心
        attention_region = self.select_region(attention_with_inhibition)

        # 6. 记录历史
        self.attention_history.add(attention_region)

        return attention_region

    def combine_attentions(self, bottom_up, top_down):
        """融合自底向上和自顶向下"""
        # 加权融合
        alpha = 0.6  # 自顶向下权重更高
        combined = alpha * top_down + (1 - alpha) * bottom_up
        return combined

    def apply_inhibition_of_return(self, attention_map, history):
        """应用返回抑制"""
        # 最近注意过的区域降低显著性
        for region in history.recent_regions(k=5):
            attention_map.suppress(region, factor=0.5)

        return attention_map

class SaliencyMapGenerator:
    """显著性图生成器"""

    def generate(self, image):
        """生成显著性图"""
        # 使用计算机视觉算法
        # 1. 颜色对比
        color_contrast = self.compute_color_contrast(image)

        # 2. 强度对比
        intensity_contrast = self.compute_intensity_contrast(image)

        # 3. 方向
        orientation = self.compute_orientation(image)

        # 融合
        saliency = (
            0.4 * color_contrast +
            0.4 * intensity_contrast +
            0.2 * orientation
        )

        return saliency
```

---

### 5.3.2 扫视控制

**实现**:
```python
class SaccadeController:
    """扫视控制器"""

    def __init__(self):
        self.current_fixation = None
        self.fixation_duration = 200  # ms

    def move_to(self, target_region):
        """移动到目标区域"""
        # 1. 计算扫视参数
        saccade = self.plan_saccade(self.current_fixation, target_region)

        # 2. 执行扫视
        self.execute_saccade(saccade)

        # 3. 更新当前注视点
        self.current_fixation = target_region

        # 4. 注视一段时间
        time.sleep(self.fixation_duration / 1000.0)

    def plan_saccade(self, from_region, to_region):
        """规划扫视"""
        # 计算扫视向量
        vector = to_region.center - from_region.center

        # 计算扫视幅度
        amplitude = np.linalg.norm(vector)

        # 估算扫视持续时间
        duration = self.estimate_saccade_duration(amplitude)

        return Saccade(
            from_region=from_region,
            to_region=to_region,
            vector=vector,
            amplitude=amplitude,
            duration=duration
        )

    def estimate_saccade_duration(self, amplitude):
        """估算扫视持续时间"""
        # 基于经验的公式
        # duration (ms) = 20 + 2.2 * amplitude (degrees)
        return 20 + 2.2 * amplitude

class FoveaVision:
    """中央凹视觉 (高分辨率)"""

    def analyze(self, region, image):
        """精细分析区域"""
        # 提取区域
        roi = image.extract_region(region)

        # 高分辨率分析
        details = {
            'objects': self.detect_objects(roi),
            'text': self.read_text(roi),
            'faces': self.recognize_faces(roi),
            'colors': self.analyze_colors(roi),
            'textures': self.analyze_textures(roi),
        }

        return details

class PeripheralVision:
    """外周视觉 (低分辨率)"""

    def scan(self, image):
        """扫描整个场景"""
        # 低分辨率概览
        overview = {
            'layout': self.estimate_layout(image),
            'major_objects': self.detect_major_objects(image),
            'motion': self.detect_motion(image),
            'lighting': self.estimate_lighting(image),
        }

        return overview
```

---

## 5.4 自主学习循环

### 5.4.1 从经验中学习

**实现**:
```python
class ExperientialLearning:
    """经验学习"""

    def __init__(self):
        self.experience_buffer = ExperienceBuffer(capacity=10000)
        self.learning_algorithm = LearningAlgorithm()
        self.performance_monitor = PerformanceMonitor()

    def learn_from_experience(self):
        """从经验中学习"""
        # 1. 从缓冲区采样经验
        experiences = self.experience_buffer.sample(batch_size=32)

        # 2. 学习更新
        for experience in experiences:
            # 预测
            prediction = self.learning_algorithm.predict(experience.situation)

            # 计算误差
            error = self.calculate_error(prediction, experience.outcome)

            # 更新
            self.learning_algorithm.update(
                experience.situation,
                experience.outcome,
                error
            )

        # 3. 评估学习效果
        performance = self.performance_monitor.assess()

        return performance

    def add_experience(self, experience):
        """添加经验到缓冲区"""
        self.experience_buffer.add(experience)

    def calculate_error(self, prediction, actual):
        """计算误差"""
        return actual - prediction

class ExperienceBuffer:
    """经验缓冲区"""

    def __init__(self, capacity):
        self.capacity = capacity
        self.buffer = []
        self.priorities = []  # 用于优先经验回放

    def add(self, experience):
        """添加经验"""
        # 计算优先级
        priority = self.calculate_priority(experience)

        # 如果满了,移除优先级最低的
        if len(self.buffer) >= self.capacity:
            min_idx = np.argmin(self.priorities)
            self.buffer.pop(min_idx)
            self.priorities.pop(min_idx)

        self.buffer.append(experience)
        self.priorities.append(priority)

    def sample(self, batch_size):
        """采样经验"""
        # 基于优先级采样
        probabilities = np.array(self.priorities) / sum(self.priorities)
        indices = np.random.choice(
            len(self.buffer),
            size=min(batch_size, len(self.buffer)),
            replace=False,
            p=probabilities
        )

        return [self.buffer[i] for i in indices]

    def calculate_priority(self, experience):
        """计算优先级"""
        # 优先级 = TD误差 + 新颖性
        td_error = abs(experience.td_error)
        novelty = experience.novelty

        return td_error * (1 + novelty)
```

---

### 5.4.2 元学习 (学会学习)

**实现**:
```python
class MetaLearning:
    """元学习"""

    def __init__(self):
        self.task_distribution = TaskDistribution()
        self.learner = Learner()
        self.meta_optimizer = MetaOptimizer()

    def meta_learn(self, num_tasks=10):
        """元学习过程"""
        meta_gradients = []

        for _ in range(num_tasks):
            # 1. 采样任务
            task = self.task_distribution.sample()

            # 2. 快速适应 (内循环)
            adapted_params = self.fast_adapt(task)

            # 3. 计算元梯度 (外循环)
            meta_gradient = self.compute_meta_gradient(task, adapted_params)
            meta_gradients.append(meta_gradient)

        # 4. 元更新
        self.meta_optimizer.update(meta_gradients)

    def fast_adapt(self, task, num_steps=5):
        """快速适应新任务"""
        # 复制当前参数
        params = self.learner.get_params().copy()

        for _ in range(num_steps):
            # 在任务上采样
            batch = task.sample_batch()

            # 计算梯度
            gradient = self.learner.compute_gradient(batch, params)

            # 更新
            params = params - 0.01 * gradient

        return params

    def compute_meta_gradient(self, task, adapted_params):
        """计算元梯度"""
        # 在适应后的参数上,计算测试集的梯度
        test_batch = task.sample_test_batch()
        meta_gradient = self.learner.compute_gradient(test_batch, adapted_params)

        return meta_gradient
```

---

## 5.5 知识整合与迁移

### 5.5.1 知识整合

**实现**:
```python
class KnowledgeIntegrator:
    """知识整合器"""

    def __init__(self):
        self.semantic_memory = SemanticMemory()
        self.episodic_memory = EpisodicMemory()
        self.generalization_engine = GeneralizationEngine()

    def integrate(self, new_experiences):
        """整合新经验"""
        for experience in new_experiences:
            # 1. 存储情景记忆
            self.episodic_memory.store(experience)

            # 2. 提取语义知识
            semantic_knowledge = self.extract_semantic_knowledge(experience)

            # 3. 整合到语义记忆
            if semantic_knowledge:
                self.integrate_semantic_knowledge(semantic_knowledge)

    def extract_semantic_knowledge(self, experience):
        """提取语义知识"""
        # 1. 识别模式
        patterns = self.identify_patterns(experience)

        # 2. 泛化
        generalized = self.generalization_engine.generalize(patterns)

        # 3. 验证
        if self.validate_generalization(generalized):
            return generalized

        return None

    def identify_patterns(self, experience):
        """识别模式"""
        # 从经验中识别:
        # 1. 因果关系
        causal_patterns = self.identify_causal_patterns(experience)

        # 2. 规则
        rule_patterns = self.identify_rule_patterns(experience)

        # 3. 概念
        concept_patterns = self.identify_concept_patterns(experience)

        return {
            'causal': causal_patterns,
            'rules': rule_patterns,
            'concepts': concept_patterns,
        }

    def integrate_semantic_knowledge(self, knowledge):
        """整合语义知识"""
        # 检查是否与现有知识冲突
        conflicts = self.semantic_memory.check_conflicts(knowledge)

        if conflicts:
            # 解决冲突
            resolved = self.resolve_conflicts(knowledge, conflicts)
            self.semantic_memory.update(resolved)
        else:
            # 直接添加
            self.semantic_memory.add(knowledge)
```

---

### 5.5.2 知识迁移

**实现**:
```python
class KnowledgeTransfer:
    """知识迁移"""

    def __init__(self):
        self.source_knowledge = SourceKnowledgeBase()
        self.target_task = None
        self.transfer_evaluator = TransferEvaluator()

    def transfer(self, target_task):
        """迁移知识到目标任务"""
        self.target_task = target_task

        # 1. 识别相关源知识
        relevant_knowledge = self.identify_relevant_knowledge(target_task)

        # 2. 评估可迁移性
        transferable = []
        for knowledge in relevant_knowledge:
            if self.assess_transferability(knowledge, target_task):
                transferable.append(knowledge)

        # 3. 迁移知识
        transferred = []
        for knowledge in transferable:
            adapted = self.adapt_knowledge(knowledge, target_task)
            if self.validate_transfer(adapted, target_task):
                transferred.append(adapted)

        return transferred

    def identify_relevant_knowledge(self, target_task):
        """识别相关知识"""
        relevant = []

        for knowledge in self.source_knowledge.all_knowledge():
            # 计算相似度
            similarity = self.compute_similarity(knowledge, target_task)

            if similarity > 0.5:
                relevant.append((knowledge, similarity))

        # 按相似度排序
        relevant.sort(key=lambda x: x[1], reverse=True)

        return [k for k, s in relevant]

    def adapt_knowledge(self, knowledge, target_task):
        """调整知识以适应目标任务"""
        # 1. 分析差异
        differences = self.analyze_differences(knowledge, target_task)

        # 2. 调整知识
        adapted = knowledge.copy()
        for difference in differences:
            adapted = self.adjust_for_difference(adapted, difference)

        return adapted
```

---

## 5.6 实践示例

### 5.6.1 完整好奇心驱动探索系统

```python
class CuriosityDrivenExplorationSystem:
    """好奇心驱动探索系统"""

    def __init__(self):
        self.curiosity_system = CompositeCuriositySystem()
        self.exploration_strategy = CuriosityDrivenExploration()
        self.learning_system = ExperientialLearning()
        self.knowledge_integrator = KnowledgeIntegrator()

    def run(self, environment, max_steps=1000):
        """运行探索"""
        for step in range(max_steps):
            # 1. 感知环境
            current_state = environment perceive()

            # 2. 评估好奇心
            curiosity_scores = {}
            for action in environment.get_possible_actions():
                score = self.curiosity_system.calculate_curiosity(
                    current_state,
                    action
                )
                curiosity_scores[action] = score

            # 3. 选择最好奇的行动
            best_action = max(
                curiosity_scores.items(),
                key=lambda x: x[1].overall
            )[0]

            # 4. 执行行动
            outcome = environment.execute(best_action)

            # 5. 记录经验
            experience = Experience(
                situation=current_state,
                action=best_action,
                outcome=outcome,
                curiosity=curiosity_scores[best_action]
            )
            self.learning_system.add_experience(experience)

            # 6. 学习
            if step % 10 == 0:
                self.learning_system.learn_from_experience()

            # 7. 整合知识
            if step % 100 == 0:
                self.knowledge_integrator.integrate([experience])

            # 8. 检查终止条件
            if self.should_stop(current_state):
                break
```

---

## 📚 本章小结

### 核心要点

1. **探索策略**: 随机/ε-贪婪/OFU/好奇心驱动
2. **好奇心机制**: 惊讶度+信息增益+新颖性
3. **主动视觉**: 注意力机制+扫视控制+中央凹/外周
4. **自主学习**: 经验学习+元学习
5. **知识迁移**: 整合+迁移+适应

### 实践成果

- ✅ `CompositeCuriositySystem`: 综合好奇心系统
- ✅ `VisualAttentionMechanism`: 视觉注意力
- ✅ `ExperientialLearning`: 经验学习
- ✅ `MetaLearning`: 元学习框架
- ✅ `CuriosityDrivenExplorationSystem`: 完整探索系统

### 下一步

- 第6章: 工程实现 - 完整系统部署

---

<promise>CHAPTER_5_COMPLETE</promise>
