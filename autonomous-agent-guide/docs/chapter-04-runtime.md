# 第4章: 运行架构 - 持续运行与监控

> **本章目标**: 实现 7x24 持续运行的自主 Agent 架构

---

## 4.1 持续运行架构

### 4.1.1 混合运行模式

**设计原则**: 三种模式结合,平衡响应性和资源效率

```python
class HybridAutonomousLoop:
    """混合自主运行循环"""

    def __init__(self):
        # 三种运行模式
        self.event_driven = EventDrivenLoop()
        self.polling = PollingLoop()
        self.autonomous_exploration = AutonomousExploration()

        # 模式选择器
        self.mode_selector = RuntimeModeSelector()

        # 资源管理
        self.energy_manager = EnergyManager()
        self.resource_monitor = ResourceMonitor()

    def run(self):
        """主运行循环"""
        while self.should_continue():
            # 1. 检查能量水平
            energy_level = self.energy_manager.get_energy()

            # 2. 根据能量选择模式
            if energy_level < 0.2:
                # 低能量: 保守模式
                self.conservative_run()
            elif energy_level > 0.8:
                # 高能量: 主动探索
                self.active_run()
            else:
                # 正常能量: 混合模式
                self.hybrid_run()

            # 3. 休眠一段时间
            sleep_time = self.calculate_sleep_time()
            time.sleep(sleep_time)

    def hybrid_run(self):
        """混合模式运行"""
        # 1. 事件驱动: 处理紧急事件
        events = self.event_driven.get_pending_events()
        if events:
            for event in events:
                self.handle_event(event)
                # 紧急事件处理后,检查是否需要继续
                if self.energy_manager.is_low():
                    return

        # 2. 轮询: 定期检查
        if self.polling.should_poll():
            poll_results = self.polling.poll()
            for result in poll_results:
                if result.needs_action:
                    self.handle_poll_result(result)

        # 3. 自主探索: 生成和执行目标
        if self.energy_manager.is_sufficient():
            exploration_goal = self.autonomous_exploration.generate_goal()
            if exploration_goal:
                self.execute_goal(exploration_goal)

    def conservative_run(self):
        """保守模式运行 (低能量)"""
        # 只处理紧急事件
        events = self.event_driven.get_urgent_events()
        for event in events:
            self.handle_event(event)
            # 恢复能量
            self.energy_manager.recharge()

    def active_run(self):
        """主动模式运行 (高能量)"""
        # 优先自主探索
        exploration_goal = self.autonomous_exploration.generate_goal()
        if exploration_goal:
            self.execute_goal(exploration_goal)

        # 其次处理事件
        events = self.event_driven.get_pending_events()
        for event in events:
            self.handle_event(event)
```

**关键特性**:
- ✅ **事件驱动**: 快速响应紧急情况
- ✅ **轮询检查**: 定期状态检查
- ✅ **自主探索**: 主动生成和执行目标
- ✅ **能量感知**: 根据资源水平调整

---

### 4.1.2 事件驱动循环

**实现**:
```python
class EventDrivenLoop:
    """事件驱动循环"""

    def __init__(self):
        self.event_queue = PriorityQueue()
        self.event_handlers = {}
        self.register_handlers()

    def register_handlers(self):
        """注册事件处理器"""
        self.event_handlers = {
            'urgent': UrgentEventHandler(),
            'normal': NormalEventHandler(),
            'background': BackgroundEventHandler(),
        }

    def get_pending_events(self):
        """获取待处理事件"""
        events = []
        while not self.event_queue.empty():
            event = self.event_queue.get()
            events.append(event)
        return events

    def get_urgent_events(self):
        """只获取紧急事件"""
        events = []
        # 非阻塞检查
        try:
            while True:
                event = self.event_queue.get_nowait()
                if event.priority >= Priority.URGENT:
                    events.append(event)
        except Empty:
            pass
        return events

    def emit_event(self, event):
        """发出事件"""
        self.event_queue.put(event)

class Event:
    """事件定义"""

    def __init__(self, type, data, priority=Priority.NORMAL):
        self.type = type
        self.data = data
        self.priority = priority
        self.timestamp = time.time()
        self.id = str(uuid.uuid4())

    def __lt__(self, other):
        """用于优先级队列排序"""
        return self.priority > other.priority

class UrgentEventHandler:
    """紧急事件处理器"""

    def handle(self, event):
        """处理紧急事件"""
        if event.type == 'error':
            return self.handle_error(event.data)
        elif event.type == 'security_threat':
            return self.handle_security_threat(event.data)
        elif event.type == 'resource_critical':
            return self.handle_resource_critical(event.data)

    def handle_error(self, error_data):
        """处理错误"""
        # 1. 记录错误
        self.logger.error(error_data)

        # 2. 生成恢复目标
        recovery_goal = Goal(
            description=f"从错误中恢复: {error_data.message}",
            type='error_recovery',
            priority=Priority.CRITICAL,
            steps=[
                Step("分析错误原因"),
                Step("制定恢复方案"),
                Step("执行恢复"),
                Step("验证恢复")
            ]
        )

        # 3. 立即执行
        return self.execute_immediately(recovery_goal)
```

---

### 4.1.3 轮询循环

**实现**:
```python
class PollingLoop:
    """轮询循环"""

    def __init__(self):
        self.polls = []
        self.last_poll_time = {}

    def register_poll(self, poll_config):
        """注册轮询任务"""
        self.polls.append(poll_config)

    def should_poll(self):
        """判断是否应该轮询"""
        for poll in self.polls:
            last_time = self.last_poll_time.get(poll.name, 0)
            if time.time() - last_time >= poll.interval:
                return True
        return False

    def poll(self):
        """执行轮询"""
        results = []

        for poll in self.polls:
            # 检查是否到达轮询时间
            last_time = self.last_poll_time.get(poll.name, 0)
            if time.time() - last_time >= poll.interval:
                # 执行轮询
                result = poll.execute()
                results.append(result)
                self.last_poll_time[poll.name] = time.time()

        return results

class PollConfig:
    """轮询配置"""

    def __init__(self, name, execute_fn, interval, condition=None):
        self.name = name
        self.execute_fn = execute_fn
        self.interval = interval
        self.condition = condition or (lambda: True)

    def execute(self):
        """执行轮询"""
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
    """轮询结果"""

    def __init__(self, name, data, timestamp):
        self.name = name
        self.data = data
        self.timestamp = timestamp

    @property
    def needs_action(self):
        """是否需要行动"""
        return self.data is not None and self.data.get('action_required', False)
```

---

### 4.1.4 自主探索循环

**实现**:
```python
class AutonomousExploration:
    """自主探索循环"""

    def __init__(self):
        self.goal_generator = GoalGenerator()
        self.curiosity_engine = CuriosityEngine()
        self.exploration_history = ExplorationHistory()

    def generate_goal(self):
        """生成探索目标"""
        # 1. 评估当前好奇心水平
        curiosity_score = self.curiosity_engine.evaluate_curiosity()

        # 2. 如果好奇心不足,不生成目标
        if curiosity_score < 0.3:
            return None

        # 3. 识别探索机会
        opportunities = self.identify_exploration_opportunities()

        # 4. 选择最佳机会
        if not opportunities:
            return None

        best_opportunity = self.select_best_opportunity(opportunities)

        # 5. 生成目标
        return self.create_exploration_goal(best_opportunity)

    def identify_exploration_opportunities(self):
        """识别探索机会"""
        opportunities = []

        # 1. 未探索的区域
        unexplored = self.exploration_history.get_unexplored_areas()
        for area in unexplored:
            opportunities.append(ExplorationOpportunity(
                type='area',
                target=area,
                novelty_score=area.novelty_score,
                information_gain=area.estimated_information_gain
            ))

        # 2. 未尝试的策略
        untried_strategies = self.exploration_history.get_untried_strategies()
        for strategy in untried_strategies:
            opportunities.append(ExplorationOpportunity(
                type='strategy',
                target=strategy,
                novelty_score=strategy.novelty_score,
                information_gain=strategy.estimated_information_gain
            ))

        # 3. 潜在的改进空间
        improvements = self.identify_improvement_opportunities()
        opportunities.extend(improvements)

        return opportunities

    def select_best_opportunity(self, opportunities):
        """选择最佳探索机会"""
        # 综合考虑新颖性、信息增益、可行性
        for opp in opportunities:
            opp.score = (
                0.4 * opp.novelty_score +
                0.4 * opp.information_gain +
                0.2 * opp.feasibility
            )

        return max(opportunities, key=lambda o: o.score)

    def create_exploration_goal(self, opportunity):
        """创建探索目标"""
        return Goal(
            description=f"探索{opportunity.type}: {opportunity.target}",
            type='exploration',
            motivation='curiosity',
            priority=Priority.MEDIUM,
            expected_information_gain=opportunity.information_gain,
            steps=self.generate_exploration_steps(opportunity)
        )
```

---

## 4.2 状态管理与监控

### 4.2.1 Agent 状态机

**设计**:
```python
class AutonomousAgentStateMachine:
    """自主 Agent 状态机"""

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
        """转换到新状态"""
        if new_state in self.state_transitions[self.current_state]:
            old_state = self.current_state
            self.current_state = new_state
            self.on_state_transition(old_state, new_state)
            return True
        return False

    def on_state_transition(self, old_state, new_state):
        """状态转换回调"""
        # 记录状态转换
        self.logger.info(f"State: {old_state} -> {new_state}")

        # 执行状态进入/退出逻辑
        self.exit_state(old_state)
        self.enter_state(new_state)

    def enter_state(self, state):
        """进入状态"""
        if state == AgentState.ACTIVE:
            self.on_active()
        elif state == AgentState.THINKING:
            self.on_thinking()
        elif state == AgentState.WORKING:
            self.on_working()

    def exit_state(self, state):
        """退出状态"""
        if state == AgentState.WORKING:
            self.on_work_complete()

from enum import Enum

class AgentState(Enum):
    """Agent 状态枚举"""
    IDLE = "idle"              # 空闲,等待任务
    ACTIVE = "active"          # 活跃,可接受任务
    THINKING = "thinking"      # 思考,规划中
    PLANNING = "planning"      # 规划,制定计划
    WORKING = "working"        # 工作,执行任务
    SUSPENDED = "suspended"    # 暂停,低功耗模式
    SHUTDOWN = "shutdown"      # 关闭
```

---

### 4.2.2 监控系统

**实现**:
```python
class AutonomousAgentMonitor:
    """自主 Agent 监控系统"""

    def __init__(self):
        self.metrics_collector = MetricsCollector()
        self.health_checker = HealthChecker()
        self.alert_manager = AlertManager()
        self.performance_tracker = PerformanceTracker()

    def monitor(self):
        """执行监控"""
        while True:
            # 1. 收集指标
            metrics = self.collect_metrics()

            # 2. 健康检查
            health = self.health_checker.check(metrics)

            # 3. 性能追踪
            performance = self.performance_tracker.track(metrics)

            # 4. 生成警报
            if not health.is_healthy():
                self.alert_manager.generate_alert(health)

            # 5. 更新监控面板
            self.update_dashboard(metrics, health, performance)

            # 6. 休眠
            time.sleep(self.monitor_interval)

    def collect_metrics(self):
        """收集指标"""
        metrics = {
            # 资源指标
            'cpu_usage': psutil.cpu_percent(),
            'memory_usage': psutil.virtual_memory().percent,
            'disk_usage': psutil.disk_usage('/').percent,

            # 性能指标
            'goals_completed': self.stats.goals_completed,
            'goals_failed': self.stats.goals_failed,
            'average_goal_time': self.stats.average_goal_time,

            # 自主性指标
            'autonomous_goals_ratio': self.stats.autonomous_goals_ratio,
            'exploration_success_rate': self.stats.exploration_success_rate,

            # 能量指标
            'energy_level': self.energy_manager.get_energy(),

            # 状态指标
            'current_state': self.state_machine.current_state,
            'uptime': time.time() - self.start_time,
        }

        return metrics

    def update_dashboard(self, metrics, health, performance):
        """更新监控面板"""
        # 导出到 Prometheus
        self.export_to_prometheus(metrics)

        # 更新 Grafana
        self.update_grafana(metrics, health, performance)

        # 发送到日志
        self.log_metrics(metrics)

class MetricsCollector:
    """指标收集器"""

    def __init__(self):
        self.prometheus_gateway = PrometheusGateway()
        self.metrics_registry = {}

    def collect(self, agent_state):
        """收集指标"""
        metrics = {}

        # Counter 指标 (累计值)
        metrics['goals_completed_total'] = self.prometheus_gateway.counter(
            'goals_completed_total',
            agent_state.stats.goals_completed
        )

        metrics['actions_executed_total'] = self.prometheus_gateway.counter(
            'actions_executed_total',
            agent_state.stats.actions_executed
        )

        # Gauge 指标 (当前值)
        metrics['active_goals'] = self.prometheus_gateway.gauge(
            'active_goals',
            len(agent_state.active_goals)
        )

        metrics['energy_level'] = self.prometheus_gateway.gauge(
            'energy_level',
            agent_state.energy_level
        )

        # Histogram 指标 (分布)
        for latency in agent_state.recent_latencies:
            metrics['action_latency_seconds'] = self.prometheus_gateway.histogram(
                'action_latency_seconds',
                latency
            )

        return metrics
```

---

### 4.2.3 健康检查

**实现**:
```python
class HealthChecker:
    """健康检查器"""

    def __init__(self):
        self.checks = [
            ResourceHealthCheck(),
            PerformanceHealthCheck(),
            AutonomyHealthCheck(),
            MemoryHealthCheck(),
        ]

    def check(self, metrics):
        """执行健康检查"""
        health = HealthStatus()

        for check in self.checks:
            check_result = check.check(metrics)
            health.add_check_result(check.name, check_result)

        health.overall_status = self.calculate_overall_status(health)

        return health

    def calculate_overall_status(self, health):
        """计算总体健康状态"""
        if all(r.is_healthy for r in health.check_results.values()):
            return HealthStatus.HEALTHY
        elif any(r.is_critical for r in health.check_results.values()):
            return HealthStatus.CRITICAL
        else:
            return HealthStatus.DEGRADED

class ResourceHealthCheck:
    """资源健康检查"""

    def check(self, metrics):
        """检查资源健康"""
        issues = []

        # CPU 检查
        if metrics['cpu_usage'] > 90:
            issues.append(HealthIssue(
                type='cpu',
                severity='critical',
                message=f"CPU usage critical: {metrics['cpu_usage']}%"
            ))

        # 内存检查
        if metrics['memory_usage'] > 90:
            issues.append(HealthIssue(
                type='memory',
                severity='critical',
                message=f"Memory usage critical: {metrics['memory_usage']}%"
            ))

        # 磁盘检查
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
    """自主性健康检查"""

    def check(self, metrics):
        """检查自主性健康"""
        issues = []

        # 自主目标比例
        if metrics['autonomous_goals_ratio'] < 0.3:
            issues.append(HealthIssue(
                type='autonomy',
                severity='warning',
                message=f"Low autonomous goal ratio: {metrics['autonomous_goals_ratio']:.2%}"
            ))

        # 探索成功率
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

## 4.3 生命周期管理

### 4.3.1 启动与初始化

**实现**:
```python
class AgentLifecycleManager:
    """Agent 生命周期管理器"""

    def __init__(self):
        self.config = self.load_config()
        self.state = AgentLifecycleState.UNINITIALIZED

    def initialize(self):
        """初始化 Agent"""
        self.log_lifecycle_event('initialization_start')

        # 1. 加载配置
        self.load_configuration()

        # 2. 初始化组件
        self.initialize_components()

        # 3. 建立连接
        self.establish_connections()

        # 4. 恢复状态 (如果有持久化状态)
        self.restore_state()

        # 5. 健康检查
        self.run_initial_health_check()

        self.state = AgentLifecycleState.READY
        self.log_lifecycle_event('initialization_complete')

    def start(self):
        """启动 Agent"""
        if self.state != AgentLifecycleState.READY:
            raise RuntimeError(f"Cannot start from state: {self.state}")

        self.log_lifecycle_event('start')

        # 1. 启动运行循环
        self.start_runtime_loop()

        # 2. 启动监控
        self.start_monitoring()

        # 3. 注册信号处理
        self.register_signal_handlers()

        self.state = AgentLifecycleState.RUNNING

    def stop(self, graceful=True):
        """停止 Agent"""
        self.log_lifecycle_event('stop_request', graceful=graceful)

        if graceful:
            self.graceful_shutdown()
        else:
            self.immediate_shutdown()

    def graceful_shutdown(self):
        """优雅关闭"""
        self.state = AgentLifecycleState.STOPPING

        # 1. 停止接受新任务
        self.stop_accepting_tasks()

        # 2. 等待当前任务完成
        self.wait_for_tasks_completion(timeout=30)

        # 3. 持久化状态
        self.persist_state()

        # 4. 清理资源
        self.cleanup_resources()

        # 5. 关闭连接
        self.close_connections()

        self.state = AgentLifecycleState.STOPPED
        self.log_lifecycle_event('graceful_shutdown_complete')

    def immediate_shutdown(self):
        """立即关闭"""
        self.state = AgentLifecycleState.STOPPING

        # 1. 强制终止任务
        self.terminate_tasks()

        # 2. 尝试持久化状态
        try:
            self.persist_state()
        except Exception as e:
            self.logger.error(f"Failed to persist state: {e}")

        # 3. 快速清理
        self.quick_cleanup()

        self.state = AgentLifecycleState.STOPPED
        self.log_lifecycle_event('immediate_shutdown_complete')
```

---

### 4.3.2 状态持久化

**实现**:
```python
class StatePersistence:
    """状态持久化"""

    def __init__(self):
        self.storage_backend = self.get_storage_backend()
        self.state_serializer = StateSerializer()

    def persist_state(self, state):
        """持久化状态"""
        # 1. 序列化状态
        serialized = self.state_serializer.serialize(state)

        # 2. 保存到后端
        self.storage_backend.save(
            key=f"agent_state_{state.id}",
            data=serialized,
            metadata={
                'timestamp': time.time(),
                'version': state.version
            }
        )

        # 3. 验证保存成功
        if not self.verify_persistence(state.id):
            raise PersistenceError("Failed to verify state persistence")

    def restore_state(self, agent_id):
        """恢复状态"""
        # 1. 从后端加载
        serialized = self.storage_backend.load(
            key=f"agent_state_{agent_id}"
        )

        if not serialized:
            return None

        # 2. 反序列化
        state = self.state_serializer.deserialize(serialized)

        # 3. 验证状态完整性
        if not self.verify_state_integrity(state):
            raise CorruptedStateError("State integrity check failed")

        return state

    def verify_persistence(self, agent_id):
        """验证持久化成功"""
        # 尝试加载刚保存的状态
        loaded = self.storage_backend.load(
            key=f"agent_state_{agent_id}"
        )
        return loaded is not None

    def verify_state_integrity(self, state):
        """验证状态完整性"""
        # 检查必要字段
        required_fields = ['id', 'version', 'timestamp', 'data']
        if not all(hasattr(state, field) for field in required_fields):
            return False

        # 检查版本兼容性
        if not self.is_version_compatible(state.version):
            return False

        # 检查时间戳合理性
        if state.timestamp > time.time():
            return False

        return True

class StateSerializer:
    """状态序列化器"""

    def serialize(self, state):
        """序列化状态"""
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
        """反序列化状态"""
        state = AgentState()
        state.id = serialized['id']
        state.version = serialized['version']
        state.timestamp = serialized['timestamp']

        # 恢复数据
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

## 4.4 多模态持续感知

### 4.4.1 视觉持续监控

**实现**:
```python
class ContinuousVisionMonitor:
    """持续视觉监控"""

    def __init__(self):
        self.camera = Camera()
        self.anomaly_detector = VisualAnomalyDetector()
        self.change_detector = ChangeDetector()
        self.face_recognizer = FaceRecognizer()

    def start_monitoring(self):
        """开始监控"""
        while self.should_continue():
            # 1. 获取当前帧
            frame = self.camera.get_frame()

            # 2. 检测异常
            anomalies = self.anomaly_detector.detect(frame)
            if anomalies:
                self.handle_anomalies(anomalies)

            # 3. 检测变化
            changes = self.change_detector.detect(frame)
            if changes:
                self.handle_changes(changes)

            # 4. 人脸识别 (如果启用)
            if self.config.face_recognition_enabled:
                faces = self.face_recognizer.recognize(frame)
                if faces:
                    self.handle_faces(faces)

            # 5. 更新背景模型
            self.change_detector.update_background(frame)

            # 6. 休眠
            time.sleep(self.monitor_interval)

    def handle_anomalies(self, anomalies):
        """处理异常"""
        for anomaly in anomalies:
            # 生成事件
            event = Event(
                type='visual_anomaly',
                data=anomaly,
                priority=anomaly.severity
            )
            self.event_queue.put(event)

    def handle_changes(self, changes):
        """处理变化"""
        for change in changes:
            # 记录变化
            self.memory.store_change(change)

            # 如果是重要变化,生成事件
            if change.importance > 0.7:
                event = Event(
                    type='visual_change',
                    data=change,
                    priority=Priority.NORMAL
                )
                self.event_queue.put(event)
```

---

### 4.4.2 听觉持续监听

**实现**:
```python
class ContinuousAudioMonitor:
    """持续听觉监控"""

    def __init__(self):
        self.microphone = Microphone()
        self.wake_word_detector = WakeWordDetector()
        self.speech_recognizer = SpeechRecognizer()
        self.sound_classifier = SoundClassifier()

    def start_listening(self):
        """开始监听"""
        while self.should_continue():
            # 1. 获取音频块
            audio_chunk = self.microphone.get_chunk()

            # 2. 唤醒词检测 (低功耗模式)
            if self.wake_word_detector.detect(audio_chunk):
                # 检测到唤醒词,进入完整处理
                self.handle_active_input(audio_chunk)
                continue

            # 3. 声音分类 (中等功耗)
            sound_type = self.sound_classifier.classify(audio_chunk)

            if sound_type.is_important():
                # 重要声音:警报、哭声等
                self.handle_important_sound(sound_type, audio_chunk)

    def handle_active_input(self, audio_chunk):
        """处理主动输入"""
        # 1. 完整语音识别
        text = self.speech_recognizer.recognize(audio_chunk)

        # 2. 情感分析
        emotion = self.speech_recognizer.recognize_emotion(audio_chunk)

        # 3. 生成事件
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
        """处理重要声音"""
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

## 4.5 资源与能量管理

### 4.5.1 能量管理系统

**实现**:
```python
class EnergyManager:
    """能量管理系统"""

    def __init__(self):
        self.energy_level = 1.0  # 0-1
        self.max_energy = 1.0
        self.energy_decay_rate = 0.01
        self.recharge_rate = 0.1

    def consume_energy(self, amount):
        """消耗能量"""
        self.energy_level = max(0, self.energy_level - amount)

        # 如果能量过低,触发警告
        if self.energy_level < 0.2:
            self.trigger_low_energy_warning()

    def recharge(self, amount=None):
        """补充能量"""
        if amount is None:
            amount = self.recharge_rate

        self.energy_level = min(self.max_energy, self.energy_level + amount)

    def get_energy(self):
        """获取当前能量水平"""
        return self.energy_level

    def is_low(self):
        """是否低能量"""
        return self.energy_level < 0.3

    def is_sufficient(self):
        """是否能量充足"""
        return self.energy_level > 0.5

    def trigger_low_energy_warning(self):
        """触发低能量警告"""
        event = Event(
            type='low_energy',
            data={
                'energy_level': self.energy_level
            },
            priority=Priority.HIGH
        )
        self.event_queue.put(event)

class ResourceManager:
    """资源管理器"""

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
        """检查资源状态"""
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
        """分配资源"""
        status = self.check_resources()

        if status[resource_type]['available'] >= amount:
            # 分配成功
            return True
        else:
            # 资源不足
            return False
```

---

## 4.6 安全与边界

### 4.6.1 行为边界

**实现**:
```python
class BoundaryManager:
    """边界管理器"""

    def __init__(self):
        self.config = self.load_boundaries()
        self.violation_detector = ViolationDetector()

    def check_action(self, action):
        """检查行动是否在边界内"""
        # 1. 类型检查
        if not self.is_allowed_action_type(action.type):
            return BoundaryCheckResult(
                allowed=False,
                reason=f"Action type {action.type} not allowed"
            )

        # 2. 资源检查
        if not self.check_resource_limits(action):
            return BoundaryCheckResult(
                allowed=False,
                reason="Resource limits exceeded"
            )

        # 3. 时间检查
        if not self.check_time_constraints(action):
            return BoundaryCheckResult(
                allowed=False,
                reason="Time constraints violated"
            )

        # 4. 空间检查
        if not self.check_spatial_constraints(action):
            return BoundaryCheckResult(
                allowed=False,
                reason="Spatial constraints violated"
            )

        # 5. 价值检查
        if not self.check_value_alignment(action):
            return BoundaryCheckResult(
                allowed=False,
                reason="Action not aligned with values"
            )

        return BoundaryCheckResult(allowed=True)

    def is_allowed_action_type(self, action_type):
        """检查行动类型是否允许"""
        return action_type in self.config.allowed_action_types
```

---

## 📚 本章小结

### 核心要点

1. **混合运行**: 事件驱动+轮询+自主探索
2. **状态管理**: 7状态机+生命周期管理
3. **监控系统**: 健康检查+指标收集+告警
4. **持续感知**: 视觉/听觉持续监控
5. **资源管理**: 能量系统+资源限制

### 实践成果

- ✅ `HybridAutonomousLoop`: 混合运行循环
- ✅ `AutonomousAgentMonitor`: 监控系统
- ✅ `AgentLifecycleManager`: 生命周期管理
- ✅ `ContinuousVisionMonitor`: 持续视觉监控
- ✅ `EnergyManager`: 能量管理系统

### 下一步

- 第5章: 主动行为 - 探索与学习机制

---

<promise>CHAPTER_4_COMPLETE</promise>
