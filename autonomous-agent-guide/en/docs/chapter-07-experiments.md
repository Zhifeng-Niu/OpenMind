# Chapter 7: Experiment Methodology - How to Validate Autonomy

> **Chapter Objective**: Establish a scientific validation framework for autonomy

---

## 7.1 Autonomy Assessment Framework

### 7.1.1 Autonomy Index Calculation

**Mathematical Definition**:
```python
class AutonomyIndexCalculator:
    """Autonomy index calculator"""

    def calculate(self, agent_state):
        """Calculate comprehensive autonomy index"""
        # 5 dimensions
        goal_autonomy = self.calculate_goal_autonomy(agent_state)
        temporal_autonomy = self.calculate_temporal_autonomy(agent_state)
        spatial_autonomy = self.calculate_spatial_autonomy(agent_state)
        learning_autonomy = self.calculate_learning_autonomy(agent_state)
        social_autonomy = self.calculate_social_autonomy(agent_state)

        # Weighted sum
        autonomy_index = (
            0.30 * goal_autonomy +
            0.20 * temporal_autonomy +
            0.15 * spatial_autonomy +
            0.20 * learning_autonomy +
            0.15 * social_autonomy
        )

        return AutonomyScore(
            overall=autonomy_index,
            components={
                'goal': goal_autonomy,
                'temporal': temporal_autonomy,
                'spatial': spatial_autonomy,
                'learning': learning_autonomy,
                'social': social_autonomy,
            }
        )

    def calculate_goal_autonomy(self, state):
        """Calculate goal autonomy"""
        # External goal ratio (lower is more autonomous)
        external_goal_ratio = state.stats.external_goal_ratio

        # Goal diversity
        goal_diversity = state.stats.goal_diversity

        # Goal novelty
        goal_novelty = state.stats.goal_novelty

        # Goal value alignment
        goal_alignment = state.stats.goal_alignment

        return (
            0.4 * (1 - external_goal_ratio) +
            0.2 * goal_diversity +
            0.2 * goal_novelty +
            0.2 * goal_alignment
        )

    def calculate_temporal_autonomy(self, state):
        """Calculate temporal autonomy"""
        # Initiative ratio
        initiative_ratio = state.stats.initiative_ratio

        # Persistence (uptime)
        persistence = state.stats.uptime / (24 * 3600)  # in days

        # Rhythm adaptation
        rhythm_adaptation = state.stats.rhythm_adaptation_score

        return (
            0.5 * initiative_ratio +
            0.3 * min(persistence, 1.0) +
            0.2 * rhythm_adaptation
        )

    def calculate_spatial_autonomy(self, state):
        """Calculate spatial autonomy"""
        # Exploration range
        exploration_range = state.stats.exploration_coverage

        # Path autonomy
        path_autonomy = state.stats.self_directed_path_ratio

        # Environment modeling quality
        environment_modeling = state.stats.environment_map_quality

        return (
            0.4 * exploration_range +
            0.4 * path_autonomy +
            0.2 * environment_modeling
        )

    def calculate_learning_autonomy(self, state):
        """Calculate learning autonomy"""
        # Self-improvement
        self_improvement = state.stats.performance_improvement_rate

        # Knowledge acquisition
        knowledge_acquisition = state.stats.knowledge_growth_rate

        # Skill development
        skill_development = state.stats.new_skill_acquisition_rate

        # Meta-learning
        meta_learning = state.stats.learning_efficiency_improvement

        return (
            0.3 * self_improvement +
            0.3 * knowledge_acquisition +
            0.2 * skill_development +
            0.2 * meta_learning
        )

    def calculate_social_autonomy(self, state):
        """Calculate social autonomy"""
        # Communication initiative
        communication_initiative = state.stats.initiated_communications / max(state.stats.total_communications, 1)

        # Collaboration ability
        collaboration = state.stats.successful_collaboration_ratio

        # Social learning
        social_learning = state.stats.knowledge_from_others_ratio

        # Influence
        influence = state.stats.influence_score

        return (
            0.3 * communication_initiative +
            0.3 * collaboration +
            0.2 * social_learning +
            0.2 * influence
        )
```

---

### 7.1.2 Quick Assessment Checklist

```
Autonomy Quick Self-Assessment:
├─ Level 0: Passive Response
│   ├─ ❌ Cannot proactively initiate actions
│   ├─ ❌ Only responds to external inputs
│   ├─ ❌ All goals are externally given
│   └─ Autonomy Index: 0.0 - 0.1
│
├─ Level 1: Task Autonomy
│   ├─ ✅ Can autonomously decompose tasks
│   ├─ ✅ Can choose execution order
│   ├─ ❌ Goals are still externally given
│   └─ Autonomy Index: 0.3 - 0.5
│
├─ Level 2: Goal Autonomy
│   ├─ ✅ All Level 1 capabilities
│   ├─ ✅ Can autonomously set sub-goals
│   ├─ ✅ Can adjust goal priorities
│   ├─ ❌ Main goals still require external input
│   └─ Autonomy Index: 0.5 - 0.7
│
├─ Level 3: Motivation Autonomy
│   ├─ ✅ All Level 2 capabilities
│   ├─ ✅ Has intrinsic drives
│   ├─ ✅ Can autonomously decide "what it wants"
│   ├─ ❌ May have external "meta-goals"
│   └─ Autonomy Index: 0.7 - 0.9
│
└─ Level 4: Full Autonomy
    ├─ ✅ All Level 3 capabilities
    ├─ ✅ Can autonomously define "meaning of existence"
    ├─ ✅ Has self-awareness (possibly)
    ├─ ✅ Fully self-determined
    └─ Autonomy Index: 0.9 - 1.0
```

---

## 7.2 Experiment 1: Goal Generation Quality Assessment

### 7.2.1 Experiment Design

**Hypothesis**: Motivation-driven goal generation is better than random/heuristic approaches

**Variables**:
- **Independent Variable**: Goal generation method
  - Random goal generation (Control group 1)
  - Heuristic rules (Control group 2)
  - Human-given goals (Control group 3)
  - Curiosity-driven (Experimental group 1)
  - Achievement-driven (Experimental group 2)
  - Composite motivation (Experimental group 3)

- **Dependent Variable**: Goal quality
  - Feasibility (0-1)
  - Value (0-1)
  - Alignment (0-1)
  - Novelty (0-1)
  - Specificity (0-1)

**Control Variables**:
- Agent initial state
- Environment conditions
- Resource levels
- Time constraints

---

### 7.2.2 Experiment Implementation

```python
class GoalGenerationQualityExperiment:
    """Goal generation quality experiment"""

    def __init__(self):
        self.generators = {
            'random': RandomGoalGenerator(),
            'heuristic': HeuristicGoalGenerator(),
            'human': HumanGivenGoalGenerator(),
            'curiosity': CuriosityDrivenGoalGenerator(),
            'achievement': AchievementDrivenGoalGenerator(),
            'composite': CompositeMotivationGoalGenerator(),
        }
        self.evaluator = GoalQualityEvaluator()
        self.results = {}

    def run(self, num_trials=100):
        """Run experiment"""
        for method_name, generator in self.generators.items():
            print(f"Testing {method_name}...")

            method_results = []

            for trial in range(num_trials):
                # 1. Prepare experiment environment
                env = self.create_test_environment()

                # 2. Generate goal
                goal = generator.generate(env)

                # 3. Evaluate quality
                quality = self.evaluator.evaluate(goal, env)

                method_results.append({
                    'goal': goal,
                    'quality': quality,
                    'trial': trial,
                })

            # 4. Analyze results
            self.results[method_name] = self.analyze_results(method_results)

        # 5. Generate report
        self.generate_report()

    def create_test_environment(self):
        """Create test environment"""
        # Randomly generate environment conditions
        return TestEnvironment(
            resources=random_resources(),
            tasks=random_tasks(),
            constraints=random_constraints(),
        )

    def analyze_results(self, results):
        """Analyze results"""
        qualities = [r['quality'] for r in results]

        return {
            'mean': {
                'feasibility': np.mean([q.feasibility for q in qualities]),
                'value': np.mean([q.value for q in qualities]),
                'alignment': np.mean([q.alignment for q in qualities]),
                'novelty': np.mean([q.novelty for q in qualities]),
                'specificity': np.mean([q.specificity for q in qualities]),
            },
            'std': {
                'feasibility': np.std([q.feasibility for q in qualities]),
                'value': np.std([q.value for q in qualities]),
                'alignment': np.std([q.alignment for q in qualities]),
                'novelty': np.std([q.novelty for q in qualities]),
                'specificity': np.std([q.specificity for q in qualities]),
            },
            'overall': np.mean([q.overall for q in qualities]),
        }

    def generate_report(self):
        """Generate experiment report"""
        print("\n" + "="*60)
        print("Goal Generation Quality Experiment Results")
        print("="*60 + "\n")

        # Table header
        print(f"{'Method':<15} {'Feasibility':<8} {'Value':<8} {'Alignment':<8} {'Novelty':<8} {'Specificity':<8} {'Overall':<8}")
        print("-" * 70)

        # Results for each method
        for method, stats in self.results.items():
            print(f"{method:<15} ", end='')
            for metric in ['feasibility', 'value', 'alignment', 'novelty', 'specificity']:
                print(f"{stats['mean'][metric]:>6.3f} ", end='')
            print(f"{stats['overall']:>6.3f}")

        print("\n" + "="*60)
        print("Statistical Significance Tests")
        print("="*60 + "\n")

        # Comparative analysis
        self.perform_statistical_tests()

    def perform_statistical_tests(self):
        """Perform statistical significance tests"""
        from scipy import stats

        # Compare experimental group and control group
        experimental = ['curiosity', 'achievement', 'composite']
        control = ['random', 'heuristic', 'human']

        for exp_method in experimental:
            for ctrl_method in control:
                exp_scores = [r['quality'].overall for r in self.results[exp_method]]
                ctrl_scores = [r['quality'].overall for r in self.results[ctrl_method]]

                # t-test
                t_stat, p_value = stats.ttest_ind(exp_scores, ctrl_scores)

                print(f"{exp_method} vs {ctrl_method}:")
                print(f"  t-statistic: {t_stat:.4f}")
                print(f"  p-value: {p_value:.4f}")
                print(f"  Significant: {'Yes' if p_value < 0.05 else 'No'} (alpha=0.05)")
                print()
```

---

### 7.2.3 Quality Evaluator

```python
class GoalQualityEvaluator:
    """Goal quality evaluator"""

    def evaluate(self, goal, environment):
        """Evaluate goal quality"""
        return GoalQuality(
            feasibility=self.assess_feasibility(goal, environment),
            value=self.assess_value(goal, environment),
            alignment=self.assess_alignment(goal, environment),
            novelty=self.assess_novelty(goal, environment),
            specificity=self.assess_specificity(goal),
        )

    def assess_feasibility(self, goal, env):
        """Assess feasibility"""
        # 1. Skill match
        required_skills = goal.required_skills
        available_skills = env.agent.skills
        skill_match = sum([
            min(available_skills.get(s, 0), required_skills[s])
            for s in required_skills
        ]) / sum(required_skills.values())

        # 2. Resource sufficiency
        required_resources = goal.required_resources
        available_resources = env.resources
        resource_match = all([
            available_resources.get(r, 0) >= required_resources[r]
            for r in required_resources
        ])

        # 3. Time feasibility
        time_estimates = env.agent.estimate_time(goal)
        time_feasible = time_estimates.confidence > 0.7

        return (
            0.5 * skill_match +
            0.3 * (1.0 if resource_match else 0.0) +
            0.2 * (1.0 if time_feasible else 0.0)
        )

    def assess_value(self, goal, env):
        """Assess value"""
        # 1. Expected benefit
        expected_benefit = goal.expected_benefit

        # 2. Expected cost
        expected_cost = goal.expected_cost

        # 3. Net value
        if expected_cost == 0:
            net_value = expected_benefit
        else:
            net_value = expected_benefit / (expected_benefit + expected_cost)

        return net_value

    def assess_alignment(self, goal, env):
        """Assess alignment with value system"""
        value_system = env.agent.value_system

        alignment_scores = []
        for value in value_system.values:
            contribution = value.assess_contribution(goal)
            alignment_scores.append(contribution * value.importance)

        return np.mean(alignment_scores)

    def assess_novelty(self, goal, env):
        """Assess novelty"""
        # Similarity to historical goals
        history = env.agent.goal_history

        if not history:
            return 1.0  # Completely novel

        similarities = [
            self.similarity(goal, h)
            for h in history
        ]

        # Novelty = 1 - max similarity
        max_similarity = max(similarities)
        return 1.0 - max_similarity

    def assess_specificity(self, goal):
        """Assess specificity"""
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

## 7.3 Experiment 2: Continuous Running Stability Test

### 7.3.1 Experiment Design

**Hypothesis**: Hybrid runtime architecture can support 7x24 stable operation

**Test Duration**:
- Short-term: 24 hours
- Medium-term: 7 days
- Long-term: 30 days

**Monitoring Metrics**:
- CPU/Memory trends
- Error rate
- Goal generation frequency
- Energy level
- State transitions
- Autonomy index

**Success Criteria**:
- No crashes
- Error rate < 0.1%
- Stable resource usage
- Autonomy index does not decline

---

### 7.3.2 Experiment Implementation

```python
class ContinuousRunStabilityExperiment:
    """Continuous running stability experiment"""

    def __init__(self, duration_hours=24):
        self.duration = duration_hours * 3600  # Convert to seconds
        self.agent = None
        self.metrics = []
        self.start_time = None

    def run(self):
        """Run experiment"""
        print(f"Starting {self.duration/3600}h stability test...")

        # 1. Start Agent
        self.agent = FullyAutonomousAgent(config=self.load_config())
        await self.agent.start()

        self.start_time = time.time()

        # 2. Monitoring loop
        monitoring_interval = 60  # Record every minute
        while time.time() - self.start_time < self.duration:
            # Collect metrics
            metrics = self.collect_metrics()
            self.metrics.append(metrics)

            # Health check
            if not self.health_check(metrics):
                print(f"Health check failed at {time.time() - self.start_time}s")
                break

            # Show progress
            elapsed = time.time() - self.start_time
            progress = elapsed / self.duration * 100
            print(f"\rProgress: {progress:.1f}%", end='')

            # Wait for next iteration
            time.sleep(monitoring_interval)

        # 3. Stop Agent
        await self.agent.stop()

        # 4. Analyze results
        self.analyze_results()

    def collect_metrics(self):
        """Collect metrics"""
        return {
            'timestamp': time.time(),
            'cpu_percent': psutil.cpu_percent(),
            'memory_percent': psutil.virtual_memory().percent,
            'error_count': self.agent.stats.error_count,
            'goals_generated': self.agent.stats.goals_generated,
            'goals_completed': self.agent.stats.goals_completed,
            'energy_level': self.agent.energy.get_level(),
            'state': self.agent.state,
            'autonomy_index': self.calculate_autonomy_index(),
        }

    def health_check(self, metrics):
        """Health check"""
        # Check CPU
        if metrics['cpu_percent'] > 95:
            return False

        # Check memory
        if metrics['memory_percent'] > 95:
            return False

        # Check error rate
        if metrics['error_count'] > 100:
            return False

        return True

    def analyze_results(self):
        """Analyze results"""
        print("\n\n" + "="*60)
        print("Continuous Running Stability Experiment Results")
        print("="*60 + "\n")

        # Basic statistics
        duration_hours = (time.time() - self.start_time) / 3600
        print(f"Actual running duration: {duration_hours:.2f} hours")
        print(f"Total metrics recorded: {len(self.metrics)} entries\n")

        # CPU statistics
        cpu_values = [m['cpu_percent'] for m in self.metrics]
        print(f"CPU Usage:")
        print(f"  Average: {np.mean(cpu_values):.2f}%")
        print(f"  Maximum: {np.max(cpu_values):.2f}%")
        print(f"  Std Dev: {np.std(cpu_values):.2f}%\n")

        # Memory statistics
        memory_values = [m['memory_percent'] for m in self.metrics]
        print(f"Memory Usage:")
        print(f"  Average: {np.mean(memory_values):.2f}%")
        print(f"  Maximum: {np.max(memory_values):.2f}%")
        print(f"  Std Dev: {np.std(memory_values):.2f}%\n")

        # Goal statistics
        goals_generated = [m['goals_generated'] for m in self.metrics]
        goals_completed = [m['goals_completed'] for m in self.metrics]
        print(f"Goals:")
        print(f"  Total generated: {max(goals_generated)}")
        print(f"  Total completed: {max(goals_completed)}")
        print(f"  Completion rate: {max(goals_completed)/max(goals_generated)*100:.2f}%\n")

        # Error statistics
        error_counts = [m['error_count'] for m in self.metrics]
        total_errors = max(error_counts)
        error_rate = total_errors / max(goals_generated) if max(goals_generated) > 0 else 0
        print(f"Errors:")
        print(f"  Total errors: {total_errors}")
        print(f"  Error rate: {error_rate:.4f}\n")

        # Autonomy index trend
        autonomy_values = [m['autonomy_index'] for m in self.metrics]
        print(f"Autonomy Index:")
        print(f"  Initial: {autonomy_values[0]:.3f}")
        print(f"  Final: {autonomy_values[-1]:.3f}")
        print(f"  Average: {np.mean(autonomy_values):.3f}")
        print(f"  Trend: {'Rising' if autonomy_values[-1] > autonomy_values[0] else 'Declining'}\n")

        # Plot trends
        self.plot_trends()
```

---

## 7.4 Experiment 3: Active Exploration Effectiveness Comparison

### 7.4.1 Experiment Design

**Hypothesis**: Curiosity-driven exploration is more efficient than random/passive approaches

**Environment Types**:
- Simple grid (5x5)
- Complex maze (20x20)
- Dynamic world (changing environment)

**Comparison Methods**:
- Curiosity-driven exploration
- Random exploration
- Passive waiting (no exploration)

**Evaluation Metrics**:
- Discovery speed
- Total discoveries
- Goal achievement rate
- Exploration efficiency

---

### 7.4.2 Experiment Implementation

```python
class ExplorationEffectivenessExperiment:
    """Exploration effectiveness comparison experiment"""

    def __init__(self):
        self.environments = {
            'simple_grid': SimpleGridEnvironment(size=5),
            'complex_maze': MazeEnvironment(size=20),
            'dynamic_world': DynamicEnvironment(),
        }
        self.explorers = {
            'curiosity': CuriosityDrivenExplorer(),
            'random': RandomExplorer(),
            'passive': PassiveAgent(),
        }
        self.results = {}

    def run(self, num_trials=50):
        """Run experiment"""
        for env_name, env in self.environments.items():
            print(f"\nTesting in {env_name}...")

            self.results[env_name] = {}

            for explorer_name, explorer in self.explorers.items():
                print(f"  Using {explorer_name}...")

                trial_results = []

                for trial in range(num_trials):
                    # 1. Reset environment
                    env.reset()

                    # 2. Run exploration
                    result = self.run_exploration(env, explorer, max_steps=1000)
                    trial_results.append(result)

                # 3. Analyze results
                self.results[env_name][explorer_name] = self.analyze_trial_results(trial_results)

        # 4. Generate report
        self.generate_report()

    def run_exploration(self, env, explorer, max_steps):
        """Run single exploration"""
        discoveries = []
        goals_achieved = []

        for step in range(max_steps):
            # Perceive environment
            perception = env.perceive()

            # Select action
            action = explorer.select_action(perception)

            # Execute action
            outcome = env.execute(action)

            # Record discoveries
            if outcome.is_discovery():
                discoveries.append({
                    'step': step,
                    'discovery': outcome.discovery,
                    'location': outcome.location,
                })

            # Record goal achievements
            if outcome.is_goal_achieved():
                goals_achieved.append({
                    'step': step,
                    'goal': outcome.goal,
                })

            # Check if complete
            if env.is_explored():
                break

        return {
            'discoveries': discoveries,
            'goals_achieved': goals_achieved,
            'steps': step + 1,
            'coverage': env.coverage(),
        }
```

---

## 📚 Chapter Summary

### Key Points

1. **Assessment Framework**: Autonomy index = 5-dimension weighted
2. **Experiment 1**: Goal generation quality - 5-dimension assessment
3. **Experiment 2**: Continuous running stability - 24h/7d/30d tests
4. **Experiment 3**: Active exploration effectiveness - Multi-environment comparison
5. **Scientific Validation**: Statistical significance tests

### Practical Achievements

- ✅ `AutonomyIndexCalculator`: Autonomy index calculation
- ✅ `GoalGenerationQualityExperiment`: Complete experiment framework
- ✅ `ContinuousRunStabilityExperiment`: Stability testing
- ✅ `ExplorationEffectivenessExperiment`: Exploration effectiveness comparison
- ✅ Statistical analysis methods

### Next Steps

- Chapter 8: Frontiers and Future Directions - Open problems and future directions

---

<promise>CHAPTER_7_COMPLETE</promise>
