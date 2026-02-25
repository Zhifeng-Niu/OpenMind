# Chapter 4: Runtime Architecture - Continuous Operation and Monitoring

> **Chapter Objective**: Implement 24/7 continuous operation architecture for autonomous agents

---

## 4.1 Continuous Operation Architecture

### 4.1.1 Hybrid Runtime Mode

**Design Principle**: Combine three modes to balance responsiveness and resource efficiency

```python
class HybridAutonomousLoop:
    """Hybrid autonomous runtime loop"""

    def __init__(self):
        # Three runtime modes
        self.event_driven = EventDrivenLoop()
        self.polling = PollingLoop()
        self.autonomous_exploration = AutonomousExploration()

        # Mode selector
        self.mode_selector = RuntimeModeSelector()

        # Resource management
        self.energy_manager = EnergyManager()
        self.resource_monitor = ResourceMonitor()

    def run(self):
        """Main runtime loop"""
        while self.should_continue():
            # 1. Check energy level
            energy_level = self.energy_manager.get_energy()

            # 2. Select mode based on energy
            if energy_level < 0.2:
                # Low energy: Conservative mode
                self.conservative_run()
            elif energy_level > 0.8:
                # High energy: Active exploration
                self.active_run()
            else:
                # Normal energy: Hybrid mode
                self.hybrid_run()

            # 3. Sleep for a period
            sleep_time = self.calculate_sleep_time()
            time.sleep(sleep_time)

    def hybrid_run(self):
        """Hybrid mode operation"""
        # 1. Event-driven: Handle urgent events
        events = self.event_driven.get_pending_events()
        if events:
            for event in events:
                self.handle_event(event)
                # After handling urgent events, check if need to continue
                if self.energy_manager.is_low():
                    return

        # 2. Polling: Periodic checks
        if self.polling.should_poll():
            poll_results = self.polling.poll()
            for result in poll_results:
                if result.needs_action:
                    self.handle_poll_result(result)

        # 3. Autonomous exploration: Generate and execute goals
        if self.energy_manager.is_sufficient():
            exploration_goal = self.autonomous_exploration.generate_goal()
            if exploration_goal:
                self.execute_goal(exploration_goal)

    def conservative_run(self):
        """Conservative mode operation (low energy)"""
        # Only handle urgent events
        events = self.event_driven.get_urgent_events()
        for event in events:
            self.handle_event(event)
            # Restore energy
            self.energy_manager.recharge()

    def active_run(self):
        """Active mode operation (high energy)"""
        # Prioritize autonomous exploration
        exploration_goal = self.autonomous_exploration.generate_goal()
        if exploration_goal:
            self.execute_goal(exploration_goal)

        # Then handle events
        events = self.event_driven.get_pending_events()
        for event in events:
            self.handle_event(event)
```

**Key Features**:
- ✅ **Event-Driven**: Quick response to urgent situations
- ✅ **Polling Check**: Periodic status checks
- ✅ **Autonomous Exploration**: Proactively generate and execute goals
- ✅ **Energy Awareness**: Adjust based on resource levels

---

### 4.1.2 Event-Driven Loop

**Implementation**:
```python
class EventDrivenLoop:
    """Event-driven loop"""

    def __init__(self):
        self.event_queue = PriorityQueue()
        self.event_handlers = {}
        self.register_handlers()

    def register_handlers(self):
        """Register event handlers"""
        self.event_handlers = {
            'urgent': UrgentEventHandler(),
            'normal': NormalEventHandler(),
            'background': BackgroundEventHandler(),
        }

    def get_pending_events(self):
        """Get pending events"""
        events = []
        while not self.event_queue.empty():
            event = self.event_queue.get()
            events.append(event)
        return events

    def get_urgent_events(self):
        """Get only urgent events"""
        events = []
        # Non-blocking check
        try:
            while True:
                event = self.event_queue.get_nowait()
                if event.priority >= Priority.URGENT:
                    events.append(event)
        except Empty:
            pass
        return events

    def emit_event(self, event):
        """Emit event"""
        self.event_queue.put(event)

class Event:
    """Event definition"""

    def __init__(self, type, data, priority=Priority.NORMAL):
        self.type = type
        self.data = data
        self.priority = priority
        self.timestamp = time.time()
        self.id = str(uuid.uuid4())

    def __lt__(self, other):
        """For priority queue sorting"""
        return self.priority > other.priority

class UrgentEventHandler:
    """Urgent event handler"""

    def handle(self, event):
        """Handle urgent event"""
        if event.type == 'error':
            return self.handle_error(event.data)
        elif event.type == 'security_threat':
            return self.handle_security_threat(event.data)
        elif event.type == 'resource_critical':
            return self.handle_resource_critical(event.data)

    def handle_error(self, error_data):
        """Handle error"""
        # 1. Log error
        self.logger.error(error_data)

        # 2. Generate recovery goal
        recovery_goal = Goal(
            description=f"Recover from error: {error_data.message}",
            type='error_recovery',
            priority=Priority.CRITICAL,
            steps=[
                Step("Analyze error cause"),
                Step("Develop recovery plan"),
                Step("Execute recovery"),
                Step("Verify recovery")
            ]
        )

        # 3. Execute immediately
        return self.execute_immediately(recovery_goal)
```

---

### 4.1.3 Polling Loop

**Implementation**:
```python
class PollingLoop:
    """Polling loop"""

    def __init__(self):
        self.polls = []
        self.last_poll_time = {}

    def register_poll(self, poll_config):
        """Register polling task"""
        self.polls.append(poll_config)

    def should_poll(self):
        """Determine if polling is needed"""
        for poll in self.polls:
            last_time = self.last_poll_time.get(poll.name, 0)
            if time.time() - last_time >= poll.interval:
                return True
        return False

    def poll(self):
        """Execute polling"""
        results = []

        for poll in self.polls:
            # Check if polling time reached
            last_time = self.last_poll_time.get(poll.name, 0)
            if time.time() - last_time >= poll.interval:
                # Execute polling
                result = poll.execute()
                results.append(result)
                self.last_poll_time[poll.name] = time.time()

        return results

class PollConfig:
    """Polling configuration"""

    def __init__(self, name, execute_fn, interval, condition=None):
        self.name = name
        self.execute_fn = execute_fn
        self.interval = interval
        self.condition = condition or (lambda: True)

    def execute(self):
        """Execute polling"""
        if self.condition():
            return PollResult(
                name=self.name,
                data=self.execute_fn(),
                timestamp=time.time()
            )
        return PollResult(
            name=self.name,
            data=None,
            timestamp=time.time()
        )

class PollResult:
    """Polling result"""

    def __init__(self, name, data, timestamp):
        self.name = name
        self.data = data
        self.timestamp = timestamp

    @property
    def needs_action(self):
        """Whether action is needed"""
        return self.data is not None and self.data.get('action_required', False)
```

---

### 4.1.4 Autonomous Exploration Loop

**Implementation**:
```python
class AutonomousExploration:
    """Autonomous exploration loop"""

    def __init__(self):
        self.goal_generator = GoalGenerator()
        self.curiosity_engine = CuriosityEngine()
        self.exploration_history = ExplorationHistory()

    def generate_goal(self):
        """Generate exploration goal"""
        # 1. Assess current curiosity level
        curiosity_score = self.curiosity_engine.evaluate_curiosity()

        # 2. If curiosity is insufficient, don't generate goal
        if curiosity_score < 0.3:
            return None

        # 3. Identify exploration opportunities
        opportunities = self.identify_exploration_opportunities()

        # 4. Select best opportunity
        if not opportunities:
            return None

        best_opportunity = self.select_best_opportunity(opportunities)

        # 5. Generate goal
        return self.create_exploration_goal(best_opportunity)

    def identify_exploration_opportunities(self):
        """Identify exploration opportunities"""
        opportunities = []

        # 1. Unexplored areas
        unexplored = self.exploration_history.get_unexplored_areas()
        for area in unexplored:
            opportunities.append(ExplorationOpportunity(
                type='area',
                target=area,
                novelty_score=area.novelty_score,
                information_gain=area.estimated_information_gain
            ))

        # 2. Untried strategies
        untried_strategies = self.exploration_history.get_untried_strategies()
        for strategy in untried_strategies:
            opportunities.append(ExplorationOpportunity(
                type='strategy',
                target=strategy,
                novelty_score=strategy.novelty_score,
                information_gain=strategy.estimated_information_gain
            ))

        # 3. Potential improvement spaces
        improvements = self.identify_improvement_opportunities()
        opportunities.extend(improvements)

        return opportunities

    def select_best_opportunity(self, opportunities):
        """Select best exploration opportunity"""
        # Consider novelty, information gain, feasibility
        for opp in opportunities:
            opp.score = (
                0.4 * opp.novelty_score +
                0.4 * opp.information_gain +
                0.2 * opp.feasibility
            )

        return max(opportunities, key=lambda o: o.score)

    def create_exploration_goal(self, opportunity):
        """Create exploration goal"""
        return Goal(
            description=f"Explore {opportunity.type}: {opportunity.target}",
            type='exploration',
            motivation='curiosity',
            priority=Priority.MEDIUM,
            expected_information_gain=opportunity.information_gain,
            steps=self.generate_exploration_steps(opportunity)
        )
```

---

## 4.2 State Management and Monitoring

### 4.2.1 Agent State Machine

**Design**:
```python
class AutonomousAgentStateMachine:
    """Autonomous agent state machine"""

    def __init__(self):
        self.current_state = AgentState.IDLE
        self.state_transitions = {
            AgentState.IDLE: [
                AgentState.ACTIVE,
                AgentState.SUSPENDED,
                AgentState.SHUTDOWN
            ],
            AgentState.ACTIVE: [
                AgentState.THINKING,
                AgentState.WORKING,
                AgentState.IDLE
            ],
            AgentState.THINKING: [
                AgentState.ACTIVE,
                AgentState.PLANNING
            ],
            AgentState.PLANNING: [
                AgentState.WORKING,
                AgentState.ACTIVE
            ],
            AgentState.WORKING: [
                AgentState.ACTIVE,
                AgentState.IDLE
            ],
            AgentState.SUSPENDED: [
                AgentState.IDLE,
                AgentState.SHUTDOWN
            ],
            AgentState.SHUTDOWN: []
        }

    def transition_to(self, new_state):
        """Transition to new state"""
        if new_state in self.state_transitions[self.current_state]:
            old_state = self.current_state
            self.current_state = new_state
            self.on_state_transition(old_state, new_state)
            return True
        return False

    def on_state_transition(self, old_state, new_state):
        """State transition callback"""
        # Log state transition
        self.logger.info(f"State: {old_state} -> {new_state}")

        # Execute state enter/exit logic
        self.exit_state(old_state)
        self.enter_state(new_state)

    def enter_state(self, state):
        """Enter state"""
        if state == AgentState.ACTIVE:
            self.on_active()
        elif state == AgentState.THINKING:
            self.on_thinking()
        elif state == AgentState.WORKING:
            self.on_working()

    def exit_state(self, state):
        """Exit state"""
        if state == AgentState.WORKING:
            self.on_work_complete()

from enum import Enum

class AgentState(Enum):
    """Agent state enumeration"""
    IDLE = "idle"              # Idle, waiting for tasks
    ACTIVE = "active"          # Active, can accept tasks
    THINKING = "thinking"      # Thinking, planning
    PLANNING = "planning"      # Planning, developing plans
    WORKING = "working"        # Working, executing tasks
    SUSPENDED = "suspended"    # Suspended, low power mode
    SHUTDOWN = "shutdown"      # Shutdown
```

---

### 4.2.2 Monitoring System

**Implementation**:
```python
class AutonomousAgentMonitor:
    """Autonomous agent monitoring system"""

    def __init__(self):
        self.metrics_collector = MetricsCollector()
        self.health_checker = HealthChecker()
        self.alert_manager = AlertManager()
        self.performance_tracker = PerformanceTracker()

    def monitor(self):
        """Execute monitoring"""
        while True:
            # 1. Collect metrics
            metrics = self.collect_metrics()

            # 2. Health check
            health = self.health_checker.check(metrics)

            # 3. Performance tracking
            performance = self.performance_tracker.track(metrics)

            # 4. Generate alerts
            if not health.is_healthy():
                self.alert_manager.generate_alert(health)

            # 5. Update monitoring dashboard
            self.update_dashboard(metrics, health, performance)

            # 6. Sleep
            time.sleep(self.monitor_interval)

    def collect_metrics(self):
        """Collect metrics"""
        metrics = {
            # Resource metrics
            'cpu_usage': psutil.cpu_percent(),
            'memory_usage': psutil.virtual_memory().percent,
            'disk_usage': psutil.disk_usage('/').percent,

            # Performance metrics
            'goals_completed': self.stats.goals_completed,
            'goals_failed': self.stats.goals_failed,
            'average_goal_time': self.stats.average_goal_time,

            # Autonomy metrics
            'autonomous_goals_ratio': self.stats.autonomous_goals_ratio,
            'exploration_success_rate': self.stats.exploration_success_rate,

            # Energy metrics
            'energy_level': self.energy_manager.get_energy(),

            # State metrics
            'current_state': self.state_machine.current_state,
            'uptime': time.time() - self.start_time,
        }

        return metrics

    def update_dashboard(self, metrics, health, performance):
        """Update monitoring dashboard"""
        # Export to Prometheus
        self.export_to_prometheus(metrics)

        # Update Grafana
        self.update_grafana(metrics, health, performance)

        # Send to logs
        self.log_metrics(metrics)

class MetricsCollector:
    """Metrics collector"""

    def __init__(self):
        self.prometheus_gateway = PrometheusGateway()
        self.metrics_registry = {}

    def collect(self, agent_state):
        """Collect metrics"""
        metrics = {}

        # Counter metrics (cumulative values)
        metrics['goals_completed_total'] = self.prometheus_gateway.counter(
            'goals_completed_total',
            agent_state.stats.goals_completed
        )

        metrics['actions_executed_total'] = self.prometheus_gateway.counter(
            'actions_executed_total',
            agent_state.stats.actions_executed
        )

        # Gauge metrics (current values)
        metrics['active_goals'] = self.prometheus_gateway.gauge(
            'active_goals',
            len(agent_state.active_goals)
        )

        metrics['energy_level'] = self.prometheus_gateway.gauge(
            'energy_level',
            agent_state.energy_level
        )

        # Histogram metrics (distributions)
        for latency in agent_state.recent_latencies:
            metrics['action_latency_seconds'] = self.prometheus_gateway.histogram(
                'action_latency_seconds',
                latency
            )

        return metrics
```

---

### 4.2.3 Health Check

**Implementation**:
```python
class HealthChecker:
    """Health checker"""

    def __init__(self):
        self.checks = [
            ResourceHealthCheck(),
            PerformanceHealthCheck(),
            AutonomyHealthCheck(),
            MemoryHealthCheck(),
        ]

    def check(self, metrics):
        """Execute health check"""
        health = HealthStatus()

        for check in self.checks:
            check_result = check.check(metrics)
            health.add_check_result(check.name, check_result)

        health.overall_status = self.calculate_overall_status(health)

        return health

    def calculate_overall_status(self, health):
        """Calculate overall health status"""
        if all(r.is_healthy for r in health.check_results.values()):
            return HealthStatus.HEALTHY
        elif any(r.is_critical for r in health.check_results.values()):
            return HealthStatus.CRITICAL
        else:
            return HealthStatus.DEGRADED

class ResourceHealthCheck:
    """Resource health check"""

    def check(self, metrics):
        """Check resource health"""
        issues = []

        # CPU check
        if metrics['cpu_usage'] > 90:
            issues.append(HealthIssue(
                type='cpu',
                severity='critical',
                message=f"CPU usage critical: {metrics['cpu_usage']}%"
            ))

        # Memory check
        if metrics['memory_usage'] > 90:
            issues.append(HealthIssue(
                type='memory',
                severity='critical',
                message=f"Memory usage critical: {metrics['memory_usage']}%"
            ))

        # Disk check
        if metrics['disk_usage'] > 90:
            issues.append(HealthIssue(
                type='disk',
                severity='warning',
                message=f"Disk usage high: {metrics['disk_usage']}%"
            ))

        return HealthCheckResult(
            name='resource',
            is_healthy=len(issues) == 0,
            is_critical=any(i.severity == 'critical' for i in issues),
            issues=issues
        )

class AutonomyHealthCheck:
    """Autonomy health check"""

    def check(self, metrics):
        """Check autonomy health"""
        issues = []

        # Autonomous goal ratio
        if metrics['autonomous_goals_ratio'] < 0.3:
            issues.append(HealthIssue(
                type='autonomy',
                severity='warning',
                message=f"Low autonomous goal ratio: {metrics['autonomous_goals_ratio']:.2%}"
            ))

        # Exploration success rate
        if metrics['exploration_success_rate'] < 0.5:
            issues.append(HealthIssue(
                type='exploration',
                severity='warning',
                message=f"Low exploration success rate: {metrics['exploration_success_rate']:.2%}"
            ))

        return HealthCheckResult(
            name='autonomy',
            is_healthy=len(issues) == 0,
            is_critical=False,
            issues=issues
        )
```

---

## 4.3 Lifecycle Management

### 4.3.1 Startup and Initialization

**Implementation**:
```python
class AgentLifecycleManager:
    """Agent lifecycle manager"""

    def __init__(self):
        self.config = self.load_config()
        self.state = AgentLifecycleState.UNINITIALIZED

    def initialize(self):
        """Initialize agent"""
        self.log_lifecycle_event('initialization_start')

        # 1. Load configuration
        self.load_configuration()

        # 2. Initialize components
        self.initialize_components()

        # 3. Establish connections
        self.establish_connections()

        # 4. Restore state (if persisted state exists)
        self.restore_state()

        # 5. Health check
        self.run_initial_health_check()

        self.state = AgentLifecycleState.READY
        self.log_lifecycle_event('initialization_complete')

    def start(self):
        """Start agent"""
        if self.state != AgentLifecycleState.READY:
            raise RuntimeError(f"Cannot start from state: {self.state}")

        self.log_lifecycle_event('start')

        # 1. Start runtime loop
        self.start_runtime_loop()

        # 2. Start monitoring
        self.start_monitoring()

        # 3. Register signal handlers
        self.register_signal_handlers()

        self.state = AgentLifecycleState.RUNNING

    def stop(self, graceful=True):
        """Stop agent"""
        self.log_lifecycle_event('stop_request', graceful=graceful)

        if graceful:
            self.graceful_shutdown()
        else:
            self.immediate_shutdown()

    def graceful_shutdown(self):
        """Graceful shutdown"""
        self.state = AgentLifecycleState.STOPPING

        # 1. Stop accepting new tasks
        self.stop_accepting_tasks()

        # 2. Wait for current tasks to complete
        self.wait_for_tasks_completion(timeout=30)

        # 3. Persist state
        self.persist_state()

        # 4. Cleanup resources
        self.cleanup_resources()

        # 5. Close connections
        self.close_connections()

        self.state = AgentLifecycleState.STOPPED
        self.log_lifecycle_event('graceful_shutdown_complete')

    def immediate_shutdown(self):
        """Immediate shutdown"""
        self.state = AgentLifecycleState.STOPPING

        # 1. Force terminate tasks
        self.terminate_tasks()

        # 2. Try to persist state
        try:
            self.persist_state()
        except Exception as e:
            self.logger.error(f"Failed to persist state: {e}")

        # 3. Quick cleanup
        self.quick_cleanup()

        self.state = AgentLifecycleState.STOPPED
        self.log_lifecycle_event('immediate_shutdown_complete')
```

---

### 4.3.2 State Persistence

**Implementation**:
```python
class StatePersistence:
    """State persistence"""

    def __init__(self):
        self.storage_backend = self.get_storage_backend()
        self.state_serializer = StateSerializer()

    def persist_state(self, state):
        """Persist state"""
        # 1. Serialize state
        serialized = self.state_serializer.serialize(state)

        # 2. Save to backend
        self.storage_backend.save(
            key=f"agent_state_{state.id}",
            data=serialized,
            metadata={
                'timestamp': time.time(),
                'version': state.version
            }
        )

        # 3. Verify save successful
        if not self.verify_persistence(state.id):
            raise PersistenceError("Failed to verify state persistence")

    def restore_state(self, agent_id):
        """Restore state"""
        # 1. Load from backend
        serialized = self.storage_backend.load(
            key=f"agent_state_{agent_id}"
        )

        if not serialized:
            return None

        # 2. Deserialize
        state = self.state_serializer.deserialize(serialized)

        # 3. Verify state integrity
        if not self.verify_state_integrity(state):
            raise CorruptedStateError("State integrity check failed")

        return state

    def verify_persistence(self, agent_id):
        """Verify persistence successful"""
        # Try to load just-saved state
        loaded = self.storage_backend.load(
            key=f"agent_state_{agent_id}"
        )
        return loaded is not None

    def verify_state_integrity(self, state):
        """Verify state integrity"""
        # Check required fields
        required_fields = ['id', 'version', 'timestamp', 'data']
        if not all(hasattr(state, field) for field in required_fields):
            return False

        # Check version compatibility
        if not self.is_version_compatible(state.version):
            return False

        # Check timestamp reasonability
        if state.timestamp > time.time():
            return False

        return True

class StateSerializer:
    """State serializer"""

    def serialize(self, state):
        """Serialize state"""
        return {
            'id': state.id,
            'version': state.version,
            'timestamp': time.time(),
            'data': {
                'active_goals': [g.to_dict() for g in state.active_goals],
                'memory': state.memory.to_dict(),
                'energy_level': state.energy_level,
                'statistics': state.statistics.to_dict(),
                'configuration': state.config.to_dict(),
            }
        }

    def deserialize(self, serialized):
        """Deserialize state"""
        state = AgentState()
        state.id = serialized['id']
        state.version = serialized['version']
        state.timestamp = serialized['timestamp']

        # Restore data
        state.active_goals = [
            Goal.from_dict(g) for g in serialized['data']['active_goals']
        ]
        state.memory = Memory.from_dict(serialized['data']['memory'])
        state.energy_level = serialized['data']['energy_level']
        state.statistics = Statistics.from_dict(serialized['data']['statistics'])
        state.config = Configuration.from_dict(serialized['data']['configuration'])

        return state
```

---

## 4.4 Multimodal Continuous Perception

### 4.4.1 Continuous Visual Monitoring

**Implementation**:
```python
class ContinuousVisionMonitor:
    """Continuous visual monitoring"""

    def __init__(self):
        self.camera = Camera()
        self.anomaly_detector = VisualAnomalyDetector()
        self.change_detector = ChangeDetector()
        self.face_recognizer = FaceRecognizer()

    def start_monitoring(self):
        """Start monitoring"""
        while self.should_continue():
            # 1. Get current frame
            frame = self.camera.get_frame()

            # 2. Detect anomalies
            anomalies = self.anomaly_detector.detect(frame)
            if anomalies:
                self.handle_anomalies(anomalies)

            # 3. Detect changes
            changes = self.change_detector.detect(frame)
            if changes:
                self.handle_changes(changes)

            # 4. Face recognition (if enabled)
            if self.config.face_recognition_enabled:
                faces = self.face_recognizer.recognize(frame)
                if faces:
                    self.handle_faces(faces)

            # 5. Update background model
            self.change_detector.update_background(frame)

            # 6. Sleep
            time.sleep(self.monitor_interval)

    def handle_anomalies(self, anomalies):
        """Handle anomalies"""
        for anomaly in anomalies:
            # Generate event
            event = Event(
                type='visual_anomaly',
                data=anomaly,
                priority=anomaly.severity
            )
            self.event_queue.put(event)

    def handle_changes(self, changes):
        """Handle changes"""
        for change in changes:
            # Record change
            self.memory.store_change(change)

            # If important change, generate event
            if change.importance > 0.7:
                event = Event(
                    type='visual_change',
                    data=change,
                    priority=Priority.NORMAL
                )
                self.event_queue.put(event)
```

---

### 4.4.2 Continuous Audio Monitoring

**Implementation**:
```python
class ContinuousAudioMonitor:
    """Continuous audio monitoring"""

    def __init__(self):
        self.microphone = Microphone()
        self.wake_word_detector = WakeWordDetector()
        self.speech_recognizer = SpeechRecognizer()
        self.sound_classifier = SoundClassifier()

    def start_listening(self):
        """Start listening"""
        while self.should_continue():
            # 1. Get audio chunk
            audio_chunk = self.microphone.get_chunk()

            # 2. Wake word detection (low power mode)
            if self.wake_word_detector.detect(audio_chunk):
                # Wake word detected, enter full processing
                self.handle_active_input(audio_chunk)
                continue

            # 3. Sound classification (medium power)
            sound_type = self.sound_classifier.classify(audio_chunk)

            if sound_type.is_important():
                # Important sounds: alarms, crying, etc.
                self.handle_important_sound(sound_type, audio_chunk)

    def handle_active_input(self, audio_chunk):
        """Handle active input"""
        # 1. Full speech recognition
        text = self.speech_recognizer.recognize(audio_chunk)

        # 2. Emotion analysis
        emotion = self.speech_recognizer.recognize_emotion(audio_chunk)

        # 3. Generate event
        event = Event(
            type='voice_command',
            data={
                'text': text,
                'emotion': emotion
            },
            priority=Priority.NORMAL
        )
        self.event_queue.put(event)

    def handle_important_sound(self, sound_type, audio_chunk):
        """Handle important sound"""
        event = Event(
            type='important_sound',
            data={
                'sound_type': sound_type.name,
                'audio_chunk': audio_chunk
            },
            priority=sound_type.priority
        )
        self.event_queue.put(event)
```

---

## 4.5 Resource and Energy Management

### 4.5.1 Energy Management System

**Implementation**:
```python
class EnergyManager:
    """Energy management system"""

    def __init__(self):
        self.energy_level = 1.0  # 0-1
        self.max_energy = 1.0
        self.energy_decay_rate = 0.01
        self.recharge_rate = 0.1

    def consume_energy(self, amount):
        """Consume energy"""
        self.energy_level = max(0, self.energy_level - amount)

        # If energy too low, trigger warning
        if self.energy_level < 0.2:
            self.trigger_low_energy_warning()

    def recharge(self, amount=None):
        """Replenish energy"""
        if amount is None:
            amount = self.recharge_rate

        self.energy_level = min(self.max_energy, self.energy_level + amount)

    def get_energy(self):
        """Get current energy level"""
        return self.energy_level

    def is_low(self):
        """Is energy low"""
        return self.energy_level < 0.3

    def is_sufficient(self):
        """Is energy sufficient"""
        return self.energy_level > 0.5

    def trigger_low_energy_warning(self):
        """Trigger low energy warning"""
        event = Event(
            type='low_energy',
            data={
                'energy_level': self.energy_level
            },
            priority=Priority.HIGH
        )
        self.event_queue.put(event)

class ResourceManager:
    """Resource manager"""

    def __init__(self):
        self.resources = {
            'cpu': ResourceMonitor('cpu'),
            'memory': ResourceMonitor('memory'),
            'disk': ResourceMonitor('disk'),
            'network': ResourceMonitor('network'),
        }
        self.limits = {
            'cpu': 0.9,
            'memory': 0.9,
            'disk': 0.9,
            'network': 0.8,
        }

    def check_resources(self):
        """Check resource status"""
        status = {}

        for name, monitor in self.resources.items():
            usage = monitor.get_usage()
            limit = self.limits[name]

            status[name] = {
                'usage': usage,
                'limit': limit,
                'available': 1.0 - usage,
                'critical': usage > limit
            }

        return status

    def allocate_resource(self, resource_type, amount):
        """Allocate resource"""
        status = self.check_resources()

        if status[resource_type]['available'] >= amount:
            # Allocation successful
            return True
        else:
            # Insufficient resources
            return False
```

---

## 4.6 Safety and Boundaries

### 4.6.1 Behavior Boundaries

**Implementation**:
```python
class BoundaryManager:
    """Boundary manager"""

    def __init__(self):
        self.config = self.load_boundaries()
        self.violation_detector = ViolationDetector()

    def check_action(self, action):
        """Check if action is within boundaries"""
        # 1. Type check
        if not self.is_allowed_action_type(action.type):
            return BoundaryCheckResult(
                allowed=False,
                reason=f"Action type {action.type} not allowed"
            )

        # 2. Resource check
        if not self.check_resource_limits(action):
            return BoundaryCheckResult(
                allowed=False,
                reason="Resource limits exceeded"
            )

        # 3. Time check
        if not self.check_time_constraints(action):
            return BoundaryCheckResult(
                allowed=False,
                reason="Time constraints violated"
            )

        # 4. Spatial check
        if not self.check_spatial_constraints(action):
            return BoundaryCheckResult(
                allowed=False,
                reason="Spatial constraints violated"
            )

        # 5. Value check
        if not self.check_value_alignment(action):
            return BoundaryCheckResult(
                allowed=False,
                reason="Action not aligned with values"
            )

        return BoundaryCheckResult(allowed=True)

    def is_allowed_action_type(self, action_type):
        """Check if action type is allowed"""
        return action_type in self.config.allowed_action_types
```

---

## 📚 Chapter Summary

### Key Points

1. **Hybrid Runtime**: Event-driven + Polling + Autonomous exploration
2. **State Management**: 7-state machine + Lifecycle management
3. **Monitoring System**: Health check + Metrics collection + Alerts
4. **Continuous Perception**: Visual/Audio continuous monitoring
5. **Resource Management**: Energy system + Resource limits

### Practical Achievements

- ✅ `HybridAutonomousLoop`: Hybrid runtime loop
- ✅ `AutonomousAgentMonitor`: Monitoring system
- ✅ `AgentLifecycleManager`: Lifecycle management
- ✅ `ContinuousVisionMonitor`: Continuous visual monitoring
- ✅ `EnergyManager`: Energy management system

### Next Steps

- Chapter 5: Proactive Behavior - Exploration and Learning Mechanisms

---

<promise>CHAPTER_4_COMPLETE</promise>
