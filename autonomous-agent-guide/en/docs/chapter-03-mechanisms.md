# Chapter 3: Core Mechanisms - Goal Generation and Decision Making

> **Chapter Objective**: Implement goal generation and decision systems for autonomous agents

---

## 3.1 Goal Generation Theory

### 3.1.1 Three Levels of Goal Generation

**Level 1: External Goal Decomposition** (Task Autonomy)
```
External Goal: "Complete project report"
  ↓ Decomposition
Sub-goal 1: Collect data
Sub-goal 2: Analyze data
Sub-goal 3: Write report
Sub-goal 4: Review and revise
```

**Level 2: Related Goal Generation** (Goal Autonomy)
```
Main Goal: "Complete project report"
  ↓ Realize need for
Generated Goal: "First learn data analysis tools"  ← Self-discovered need
Generated Goal: "Create writing plan"              ← Self-supplemented step
```

**Level 3: Motivation-Driven Goals** (Motivation Autonomy)
```
State: No external task
  ↓ Curiosity driven
Generated Goal: "Explore new machine learning algorithms"
  ↓ Achievement driven
Generated Goal: "Optimize existing system performance"
  ↓ Survival driven
Generated Goal: "Organize and backup important data"
```

---

### 3.1.2 Three Drivers of Goal Generation

#### 1. Environment-Driven

**Definition**: Discovering problems and opportunities from environmental state

**Implementation**:
```python
class EnvironmentDrivenGoalGenerator:
    """Environment-driven goal generator"""

    def __init__(self):
        self.anomaly_detector = AnomalyDetector()
        self.opportunity_detector = OpportunityDetector()
        self.problem_formulator = ProblemFormulator()

    def generate_goals(self, environment_state):
        """Generate goals from environmental state"""
        goals = []

        # 1. Detect anomalies
        anomalies = self.anomaly_detector.detect(environment_state)
        for anomaly in anomalies:
            goal = self.formulate_mitigation_goal(anomaly)
            goals.append(goal)

        # 2. Discover opportunities
        opportunities = self.opportunity_detector.discover(environment_state)
        for opportunity in opportunities:
            goal = self.formulate_exploitation_goal(opportunity)
            goals.append(goal)

        # 3. Identify needs
        needs = self.identify_needs(environment_state)
        for need in needs:
            goal = self.formulate_satisfaction_goal(need)
            goals.append(goal)

        return goals

    def detect_anomalies(self, state):
        """Detect environmental anomalies"""
        anomalies = []

        # Check resource anomalies
        for resource, level in state.resources.items():
            if level < resource.critical_threshold:
                anomalies.append(Anomaly(
                    type='resource_shortage',
                    resource=resource,
                    severity=resource.critical_threshold - level
                ))

        # Check performance anomalies
        if state.performance.error_rate > 0.05:
            anomalies.append(Anomaly(
                type='performance_degradation',
                metric='error_rate',
                value=state.performance.error_rate
            ))

        # Check security anomalies
        if state.security.threats_detected:
            anomalies.append(Anomaly(
                type='security_threat',
                threats=state.security.threats_detected
            ))

        return anomalies

    def discover_opportunities(self, state):
        """Discover environmental opportunities"""
        opportunities = []

        # Check optimization opportunities
        if state.performance.cpu_utilization < 0.3:
            opportunities.append(Opportunity(
                type='optimization',
                description='CPU resources underutilized, can handle more tasks',
                potential_value=0.7
            ))

        # Check learning opportunities
        new_data_sources = state.environment.new_data_sources()
        if new_data_sources:
            opportunities.append(Opportunity(
                type='learning',
                description='New data sources discovered for learning',
                sources=new_data_sources
            ))

        # Check collaboration opportunities
        available_agents = state.environment.available_collaborators()
        if available_agents:
            opportunities.append(Opportunity(
                type='collaboration',
                description='Can collaborate with other agents to complete tasks',
                agents=available_agents
            ))

        return opportunities
```

**Key Features**:
- ✅ Reactive to Proactive: From environmental sensing to action initiative
- ✅ Problem-Oriented: Discovering problems generates goals
- ✅ Opportunity-Sensitive: Proactively discover improvement spaces

---

#### 2. Knowledge-Driven

**Definition**: Generating goals from knowledge and reasoning

**Implementation**:
```python
class KnowledgeDrivenGoalGenerator:
    """Knowledge-driven goal generator"""

    def __init__(self):
        self.knowledge_base = KnowledgeBase()
        self.reasoning_engine = ReasoningEngine()
        self.analogy_finder = AnalogyFinder()

    def generate_goals(self, context):
        """Generate goals from knowledge"""
        goals = []

        # 1. Rule-based reasoning
        rule_based_goals = self.apply_rules(context)
        goals.extend(rule_based_goals)

        # 2. Analogy-based reasoning
        analogy_goals = self.apply_analogies(context)
        goals.extend(analogy_goals)

        # 3. Causal reasoning
        causal_goals = self.apply_causal_reasoning(context)
        goals.extend(causal_goals)

        # 4. Value-based system
        value_goals = self.apply_values(context)
        goals.extend(value_goals)

        return goals

    def apply_rules(self, context):
        """Apply rules to generate goals"""
        goals = []

        # Rule example: If system performance degrades, generate optimization goal
        if context.performance.degraded():
            goals.append(Goal(
                description="Optimize system performance",
                type="optimization",
                priority=Priority.HIGH,
                subgoals=[
                    SubGoal("Analyze performance bottlenecks"),
                    SubGoal("Design optimization plan"),
                    SubGoal("Implement optimization"),
                    SubGoal("Verify results")
                ]
            ))

        # Rule example: If knowledge is insufficient, generate learning goal
        if self.knowledge_base.has_gaps(context.current_task):
            gaps = self.knowledge_base.identify_gaps(context.current_task)
            for gap in gaps:
                goals.append(Goal(
                    description=f"Learn {gap.domain}",
                    type="learning",
                    priority=Priority.MEDIUM,
                    motivation=f"Required to complete {context.current_task}"
                ))

        return goals

    def apply_analogies(self, context):
        """Apply analogies to generate goals"""
        goals = []

        # Find similar historical situations
        similar_situations = self.analogy_finder.find_similar(
            context.current_situation,
            self.knowledge_base.history
        )

        for similar in similar_situations:
            if similar.successful:
                # Analogy: What worked in the past
                goals.append(Goal(
                    description=f"Reference successful experience from {similar.situation}",
                    type="analogical",
                    reference=similar,
                    expected_benefit=similar.outcome
                ))

        return goals

    def apply_causal_reasoning(self, context):
        """Apply causal reasoning to generate goals"""
        goals = []

        # Build causal model
        causal_model = self.knowledge_base.get_causal_model(context.domain)

        # Predict action consequences
        for potential_action in self.generate_potential_actions(context):
            consequences = causal_model.predict(potential_action)

            # If desirable consequences exist, generate goal
            if consequences.has_desirable_outcome():
                goals.append(Goal(
                    description=f"Execute {potential_action} to achieve {consequences.desirable}",
                    type="causal",
                    action=potential_action,
                    expected_outcome=consequences.desirable
                ))

        return goals

    def apply_values(self, context):
        """Apply value system to generate goals"""
        goals = []

        # Generate goals from value system
        values = self.knowledge_base.value_system

        for value in values:
            # Check if value requires action
            if value.requires_action(context):
                goals.append(Goal(
                    description=f"Embody {value.name} value",
                    type="value_based",
                    priority=value.priority,
                    motivation=f"Aligns with {value.name} value pursuit"
                ))

        return goals
```

**Key Features**:
- ✅ Rationality-Driven: Based on knowledge and reasoning
- ✅ Long-term Perspective: Causal reasoning supports long-term goals
- ✅ Value Alignment: Goals consistent with value system

---

#### 3. Value-Driven

**Definition**: Generating goals from intrinsic value system

**Implementation**:
```python
class ValueDrivenGoalGenerator:
    """Value-driven goal generator"""

    def __init__(self):
        self.value_system = ValueSystem()
        self.value_realization_analyzer = ValueRealizationAnalyzer()

    def generate_goals(self, context):
        """Generate goals from value system"""
        goals = []

        # 1. Assess current value realization state
        value_states = self.assess_value_realization(context)

        # 2. Identify under-realized values
        under_realized = [
            value for value in value_states
            if value.realization_level < value.target_level
        ]

        # 3. Generate goals for each value
        for value in under_realized:
            value_goals = self.generate_value_goals(value, context)
            goals.extend(value_goals)

        return goals

    def assess_value_realization(self, context):
        """Assess value realization state"""
        value_states = []

        for value in self.value_system.values:
            # Calculate current realization level
            current_level = value.measure(context)

            # Determine target level
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
        """Generate goals for a value"""
        goals = []

        # Analyze paths to realize value
        realization_paths = self.value_realization_analyzer.analyze(
            value_state.name,
            context
        )

        # Generate goal for each path
        for path in realization_paths:
            goals.append(Goal(
                description=f"Realize {value_state.name} value through {path.action}",
                type="value_realization",
                value=value_state.name,
                action=path.action,
                expected_contribution=path.contribution,
                priority=self.calculate_priority(value_state, path)
            ))

        return goals

    def calculate_priority(self, value_state, path):
        """Calculate goal priority"""
        # Consider factors:
        # 1. Value importance
        # 2. Current gap
        # 3. Realization feasibility
        # 4. Urgency

        importance = value_state.importance
        gap = value_state.gap
        feasibility = path.feasibility
        urgency = path.urgency

        return importance * gap * feasibility * urgency
```

**Key Features**:
- ✅ Intrinsic Drive: Source from value system
- ✅ Consistency: Goals aligned with values
- ✅ Continuity: Values are stable, goals are coherent

---

### 3.1.3 Multimodal Goal Generation

**Definition**: Fusing multimodal information to generate goals

**Implementation**:
```python
class MultimodalGoalGenerator:
    """Multimodal goal generator"""

    def __init__(self):
        self.vision_goal_generator = VisionGoalGenerator()
        self.audio_goal_generator = AudioGoalGenerator()
        self.text_goal_generator = TextGoalGenerator()
        self.goal_fusion = GoalFusion()

    def generate_goals(self, multimodal_context):
        """Generate goals from multimodal context"""
        # 1. Generate goals independently from each modality
        visual_goals = self.vision_goal_generator.generate(
            multimodal_context.visual
        )
        audio_goals = self.audio_goal_generator.generate(
            multimodal_context.audio
        )
        text_goals = self.text_goal_generator.generate(
            multimodal_context.text
        )

        # 2. Fuse multimodal goals
        fused_goals = self.goal_fusion.fuse(
            visual=visual_goals,
            audio=audio_goals,
            text=text_goals,
            context=multimodal_context
        )

        # 3. Verify goal consistency
        consistent_goals = self.verify_consistency(fused_goals)

        return consistent_goals

class VisionGoalGenerator:
    """Visual goal generator"""

    def generate(self, visual_context):
        """Generate goals from visual information"""
        goals = []

        # 1. Scene understanding
        scene_understanding = self.analyze_scene(visual_context)

        # 2. Object recognition
        objects = self.detect_objects(visual_context)

        # 3. Anomaly detection
        anomalies = self.detect_visual_anomalies(visual_context)

        # 4. Generate goals
        if scene_understanding.cluttered:
            goals.append(Goal(
                description="Organize environment",
                motivation="Visual environment is cluttered",
                modality="visual"
            ))

        for anomaly in anomalies:
            goals.append(Goal(
                description=f"Investigate {anomaly.description}",
                motivation="Visual anomaly detected",
                modality="visual"
            ))

        return goals
```

---

## 3.2 Goal Evaluation and Selection System

### 3.2.1 Multi-dimensional Goal Evaluation

**Evaluation Dimensions**:
```python
class GoalEvaluator:
    """Goal evaluator"""

    def __init__(self):
        self.feasibility_evaluator = FeasibilityEvaluator()
        self.value_evaluator = ValueEvaluator()
        self.resource_evaluator = ResourceEvaluator()
        self.urgency_evaluator = UrgencyEvaluator()

    def evaluate(self, goal, context):
        """Evaluate goal"""
        evaluation = GoalEvaluation()

        # 1. Feasibility evaluation
        evaluation.feasibility = self.feasibility_evaluator.evaluate(
            goal,
            context
        )

        # 2. Value evaluation
        evaluation.value = self.value_evaluator.evaluate(
            goal,
            context
        )

        # 3. Resource evaluation
        evaluation.resource_requirement = self.resource_evaluator.evaluate(
            goal,
            context
        )

        # 4. Urgency evaluation
        evaluation.urgency = self.urgency_evaluator.evaluate(
            goal,
            context
        )

        # 5. Overall score
        evaluation.overall_score = self.calculate_overall_score(evaluation)

        return evaluation

    def calculate_overall_score(self, evaluation):
        """Calculate overall score"""
        return (
            0.3 * evaluation.feasibility +
            0.3 * evaluation.value +
            0.2 * (1 - evaluation.resource_requirement) +
            0.2 * evaluation.urgency
        )
```

---

### 3.2.2 Goal Priority Management

**Implementation**:
```python
class GoalPriorityManager:
    """Goal priority manager"""

    def __init__(self):
        self.active_goals = []
        self.goal_history = GoalHistory()
        self.priority_calculator = PriorityCalculator()

    def prioritize(self, goals, context):
        """Prioritize goals"""
        # 1. Calculate priority for each goal
        for goal in goals:
            goal.priority = self.calculate_priority(goal, context)

        # 2. Sort by priority
        sorted_goals = sorted(
            goals,
            key=lambda g: g.priority,
            reverse=True
        )

        # 3. Check goal conflicts
        conflict_free_goals = self.resolve_conflicts(sorted_goals)

        return conflict_free_goals

    def calculate_priority(self, goal, context):
        """Calculate goal priority"""
        factors = {
            'urgency': self.assess_urgency(goal, context),
            'importance': self.assess_importance(goal, context),
            'feasibility': self.assess_feasibility(goal, context),
            'resource_availability': self.assess_resources(goal, context),
            'alignment': self.assess_alignment(goal, context),
            'novelty': self.assess_novelty(goal, context),
        }

        # Weighted calculation
        priority = (
            0.25 * factors['urgency'] +
            0.25 * factors['importance'] +
            0.15 * factors['feasibility'] +
            0.15 * factors['resource_availability'] +
            0.10 * factors['alignment'] +
            0.10 * factors['novelty']
        )

        # Historical adjustment: Avoid repeating similar goals
        if self.goal_history.is_similar_attempted(goal):
            priority *= 0.5  # Lower priority for repeated goals

        return priority

    def resolve_conflicts(self, goals):
        """Resolve goal conflicts"""
        conflict_free = []

        for goal in goals:
            # Check if conflicts with already selected goals
            has_conflict = False
            for selected in conflict_free:
                if self.are_conflicting(goal, selected):
                    has_conflict = True
                    # Keep the higher priority one
                    if goal.priority > selected.priority:
                        conflict_free.remove(selected)
                        conflict_free.append(goal)
                    break

            if not has_conflict:
                conflict_free.append(goal)

        return conflict_free

    def are_conflicting(self, goal1, goal2):
        """Determine if two goals conflict"""
        # Resource conflict
        if self.resource_conflict(goal1, goal2):
            return True

        # Time conflict
        if self.time_conflict(goal1, goal2):
            return True

        # Logical conflict
        if self.logical_conflict(goal1, goal2):
            return True

        return False
```

---

## 3.3 Decision System Architecture

### 3.3.1 Hybrid Decision Mode

**Design Principles**:
```python
class HybridDecisionSystem:
    """Hybrid decision system"""

    def __init__(self):
        self.deliberative_module = DeliberativeModule()  # Deliberative
        self.reactive_module = ReactiveModule()          # Reactive
        self.autonomous_module = AutonomousModule()      # Autonomous
        self.mode_selector = ModeSelector()

    def decide(self, context):
        """Hybrid decision"""
        # 1. Select decision mode
        mode = self.mode_selector.select(context)

        # 2. Decision based on mode
        if mode == 'deliberative':
            return self.deliberative_module.decide(context)
        elif mode == 'reactive':
            return self.reactive_module.decide(context)
        elif mode == 'autonomous':
            return self.autonomous_module.decide(context)
        elif mode == 'hybrid':
            return self.hybrid_decide(context)

    def hybrid_decide(self, context):
        """Hybrid mode decision"""
        decisions = []

        # 1. Reactive decision (urgent situations)
        if context.urgency > 0.8:
            urgent_decision = self.reactive_module.decide(context)
            decisions.append(urgent_decision)

        # 2. Autonomous decision (routine situations)
        if not context.urgency > 0.8:
            autonomous_decision = self.autonomous_module.decide(context)
            decisions.append(autonomous_decision)

        # 3. Deliberative decision (important decisions)
        if context.importance > 0.7:
            deliberative_decision = self.deliberative_module.decide(context)
            decisions.append(deliberative_decision)

        # 4. Fuse decisions
        return self.fuse_decisions(decisions)

class ModeSelector:
    """Mode selector"""

    def select(self, context):
        """Select decision mode"""
        # Urgent situation → Reactive
        if context.urgency > 0.8:
            return 'reactive'

        # Important but not urgent → Deliberative
        if context.importance > 0.7 and context.urgency < 0.3:
            return 'deliberative'

        # Routine situation → Autonomous
        if context.urgency < 0.3 and context.importance < 0.7:
            return 'autonomous'

        # Complex situation → Hybrid
        return 'hybrid'
```

---

### 3.3.2 Deliberative Decision Module

**Implementation**:
```python
class DeliberativeModule:
    """Deliberative decision module"""

    def __init__(self):
        self.planner = ForwardPlanner()
        self.simulator = ActionSimulator()
        self.evaluator = OutcomeEvaluator()

    def decide(self, context):
        """Deliberative decision process"""
        # 1. Generate candidates
        candidates = self.generate_candidates(context)

        # 2. Simulate each candidate
        simulations = []
        for candidate in candidates:
            simulation = self.simulator.simulate(
                candidate,
                context,
                depth=5  # Simulate 5 steps forward
            )
            simulations.append(simulation)

        # 3. Evaluate results
        evaluations = []
        for simulation in simulations:
            evaluation = self.evaluator.evaluate(simulation.outcome)
            evaluations.append(evaluation)

        # 4. Select best option
        best_idx = np.argmax([e.score for e in evaluations])
        return candidates[best_idx]

    def generate_candidates(self, context):
        """Generate candidate actions"""
        candidates = []

        # Generate actions from goals
        for goal in context.active_goals:
            actions = self.planner.plan_actions(goal)
            candidates.extend(actions)

        # Generate actions from experience
        experienced_actions = self.memory.retrieve_similar(context)
        candidates.extend(experienced_actions)

        # Generate actions from reasoning
        inferred_actions = self.reasoning.infer_actions(context)
        candidates.extend(inferred_actions)

        return candidates
```

---

### 3.3.3 Reactive Decision Module

**Implementation**:
```python
class ReactiveModule:
    """Reactive decision module"""

    def __init__(self):
        self.stimulus_response_map = StimulusResponseMap()
        self.reflex_actions = ReflexActions()

    def decide(self, context):
        """Reactive decision process"""
        # 1. Identify stimulus
        stimulus = self.identify_stimulus(context)

        # 2. Retrieve response
        response = self.stimulus_response_map.retrieve(stimulus)

        # 3. If predefined response exists, execute directly
        if response:
            return response.action

        # 4. If not, use reflex action
        return self.reflex_actions.get(stimulus.type)

    def identify_stimulus(self, context):
        """Identify stimulus"""
        # Emergency
        if context.emergency:
            return Stimulus(type='emergency', details=context.emergency)

        # Anomaly
        if context.anomaly:
            return Stimulus(type='anomaly', details=context.anomaly)

        # Opportunity
        if context.opportunity and context.opportunity.urgency > 0.7:
            return Stimulus(type='urgent_opportunity', details=context.opportunity)

        return None
```

---

### 3.3.4 Autonomous Decision Module

**Implementation**:
```python
class AutonomousModule:
    """Autonomous decision module"""

    def __init__(self):
        self.goal_generator = GoalGenerator()
        self.motivation_system = MotivationSystem()
        self.habit_system = HabitSystem()

    def decide(self, context):
        """Autonomous decision process"""
        # 1. Generate motivations
        motivations = self.motivation_system.generate_motivations(context)

        # 2. Select dominant motivation
        dominant_motivation = max(motivations, key=lambda m: m.strength)

        # 3. Generate goal based on motivation
        goal = self.goal_generator.generate_from_motivation(
            dominant_motivation,
            context
        )

        # 4. Check if habituated response exists
        habit = self.habit_system.check_habit(goal, context)
        if habit:
            return habit.action

        # 5. Generate action plan
        return self.plan_action(goal, context)

    def plan_action(self, goal, context):
        """Plan action"""
        # Simplified planning (autonomous decision typically for routine situations)
        return Action(
            type='goal_directed',
            goal=goal,
            steps=self.decompose_goal(goal),
            priority=goal.priority
        )
```

---

## 3.4 Practical Examples

### 3.4.1 Complete Goal Generation Pipeline

```python
class CompleteGoalGenerationPipeline:
    """Complete goal generation pipeline"""

    def __init__(self):
        self.env_generator = EnvironmentDrivenGoalGenerator()
        self.knowledge_generator = KnowledgeDrivenGoalGenerator()
        self.value_generator = ValueDrivenGoalGenerator()
        self.multimodal_generator = MultimodalGoalGenerator()
        self.evaluator = GoalEvaluator()
        self.priority_manager = GoalPriorityManager()

    def run(self, context):
        """Run complete pipeline"""
        # 1. Multi-driver goal generation
        env_goals = self.env_generator.generate_goals(context.environment)
        knowledge_goals = self.knowledge_generator.generate_goals(context)
        value_goals = self.value_generator.generate_goals(context)
        multimodal_goals = self.multimodal_generator.generate_goals(
            context.multimodal
        )

        # 2. Merge all goals
        all_goals = (
            env_goals +
            knowledge_goals +
            value_goals +
            multimodal_goals
        )

        # 3. Evaluate all goals
        evaluated_goals = []
        for goal in all_goals:
            evaluation = self.evaluator.evaluate(goal, context)
            goal.evaluation = evaluation
            evaluated_goals.append(goal)

        # 4. Filter low-quality goals
        filtered_goals = [
            g for g in evaluated_goals
            if g.evaluation.overall_score > 0.5
        ]

        # 5. Priority sorting
        prioritized_goals = self.priority_manager.prioritize(
            filtered_goals,
            context
        )

        # 6. Select top N
        selected_goals = prioritized_goals[:context.goal_capacity]

        return selected_goals
```

---

### 3.4.2 Goal Generation Quality Evaluation Experiment

**Experiment Design**:

```python
class GoalGenerationQualityEvaluator:
    """Goal generation quality evaluator"""

    def __init__(self):
        self.dimensions = [
            'feasibility',    # Feasibility
            'value',          # Value
            'alignment',      # Alignment
            'novelty',        # Novelty
            'specificity'     # Specificity
        ]

    def evaluate(self, generated_goals, context):
        """Evaluate generated goals"""
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
        """Assess feasibility"""
        # Check:
        # 1. Required skills available
        # 2. Required resources sufficient
        # 3. Required time reasonable

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
        """Assess value"""
        # Expected benefit - cost
        expected_benefit = goal.expected_benefit
        expected_cost = goal.expected_cost

        if expected_cost == 0:
            return expected_benefit

        return expected_benefit / (expected_benefit + expected_cost)

    def assess_alignment(self, goal, context):
        """Assess alignment with value system"""
        value_system = context.agent.value_system

        alignment_scores = []
        for value in value_system.values:
            # Goal's contribution to value
            contribution = value.assess_contribution(goal)
            alignment_scores.append(contribution * value.importance)

        return np.mean(alignment_scores)

    def assess_novelty(self, goal, context):
        """Assess novelty"""
        # Similarity to historical goals
        history = context.agent.goal_history

        similarities = [
            self.similarity(goal, h)
            for h in history
        ]

        # Novelty = 1 - max similarity
        max_similarity = max(similarities) if similarities else 0
        return 1.0 - max_similarity

    def assess_specificity(self, goal):
        """Assess specificity"""
        # Concrete, measurable, clear criteria
        criteria = [
            goal.has_clear_criteria(),
            goal.is_measurable(),
            goal.has_deadline(),
            goal.has_success_metrics()
        ]

        return sum(criteria) / len(criteria)

    def similarity(self, goal1, goal2):
        """Calculate goal similarity"""
        # Use semantic similarity
        embedding1 = self.embed(goal1.description)
        embedding2 = self.embed(goal2.description)

        return cosine_similarity(embedding1, embedding2)
```

---

## 📚 Chapter Summary

### Key Points

1. **Goal Generation Three Drivers**: Environment, Knowledge, Value
2. **Multi-dimensional Evaluation**: Feasibility, Value, Resource, Urgency
3. **Hybrid Decision**: Deliberative + Reactive + Autonomous
4. **Priority Management**: Multi-factor weighting + Conflict resolution
5. **Quality Evaluation**: 5-dimension evaluation framework

### Practical Achievements

- ✅ `EnvironmentDrivenGoalGenerator`: Environment-driven goal generation
- ✅ `KnowledgeDrivenGoalGenerator`: Knowledge-driven goal generation
- ✅ `ValueDrivenGoalGenerator`: Value-driven goal generation
- ✅ `HybridDecisionSystem`: Hybrid decision system
- ✅ `GoalGenerationQualityEvaluator`: Quality evaluation framework

### Next Steps

- Chapter 4: Runtime Architecture - How to achieve continuous operation

---

<promise>CHAPTER_3_COMPLETE</promise>
