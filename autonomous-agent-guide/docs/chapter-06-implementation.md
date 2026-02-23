# 第6章: 工程实现 - 构建完全自主 Agent

> **本章目标**: 完整的工程实现与 OpenClaw 风格部署

---

## 6.1 系统架构设计

### 6.1.1 整体架构

```
┌─────────────────────────────────────────────┐
│               CLI 命令系统                    │
│  install / start / stop / status / logs    │
└─────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────┐
│           自主 Agent 核心系统                  │
│  ┌──────────────────────────────────────┐  │
│  │      反思层 (Reflection Layer)        │  │
│  │  自我认知 / 元认知 / 价值评估         │  │
│  └──────────────────────────────────────┘  │
│                ↕                            │
│  ┌──────────────────────────────────────┐  │
│  │      认知层 (Cognition Layer)         │  │
│  │  目标生成 / 决策 / 记忆 / 学习       │  │
│  └──────────────────────────────────────┘  │
│                ↕                            │
│  ┌──────────────────────────────────────┐  │
│  │   感知执行层 (Perception/Action)      │  │
│  │  多模态感知 / 工具使用 / 行动执行    │  │
│  └──────────────────────────────────────┘  │
│                ↕                            │
│  ┌──────────────────────────────────────┐  │
│  │   运行层 (Runtime & Monitor)          │  │
│  │  混合运行循环 / 资源管理 / 监控     │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────┐
│           基础设施层 (Infrastructure)          │
│  LLM / 向量存储 / 图数据库 / 缓存           │
│  Prometheus / Grafana / ELK                │
└─────────────────────────────────────────────┘
```

---

## 6.2 技术栈选择

### 6.2.1 核心依赖

```json
{
  "name": "autonomous-agent",
  "version": "0.1.0",
  "description": "Fully autonomous AI agent with intrinsic motivation",
  "main": "dist/index.js",
  "type": "module",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsup",
    "start": "node dist/index.js",
    "test": "vitest",
    "lint": "eslint src",
    "typecheck": "tsc --noEmit"
  },
  "dependencies": {
    "LLM": {
      "openai": "^4.0.0",
      "@anthropic-ai/sdk": "^0.30.0"
    },
    "multimodal": {
      "sharp": "^0.33.0",
      "@waywardai/whisper-node": "^1.0.0"
    },
    "memory": {
      "@pinecone-database/pinecone": "^3.0.0",
      "neo4j-driver": "^5.0.0",
      "redis": "^4.0.0"
    },
    "monitoring": {
      "prom-client": "^15.0.0",
      "pino": "^9.0.0"
    },
    "utilities": {
      "zod": "^3.22.0",
      "dotenv": "^16.3.0",
      "commander": "^12.0.0",
      "chalk": "^5.3.0",
      "ora": "^8.0.0"
    }
  },
  "devDependencies": {
    "typescript": "^5.3.0",
    "tsx": "^4.7.0",
    "tsup": "^8.0.0",
    "vitest": "^1.1.0",
    "eslint": "^8.56.0",
    "@types/node": "^20.11.0"
  }
}
```

---

### 6.2.2 项目结构

```
autonomous-agent/
├── src/
│   ├── core/
│   │   ├── agent.ts                 # 核心Agent类
│   │   ├── motivation/
│   │   │   ├── curiosity.ts         # 好奇心驱动
│   │   │   ├── achievement.ts       # 成就感驱动
│   │   │   ├── survival.ts          # 生存需求
│   │   │   └── index.ts             # 动机系统整合
│   │   ├── goal/
│   │   │   ├── generators.ts        # 目标生成器
│   │   │   ├── evaluator.ts         # 目标评估
│   │   │   └── manager.ts           # 目标管理
│   │   ├── decision/
│   │   │   ├── deliberative.ts      # 慎思式决策
│   │   │   ├── reactive.ts          # 反应式决策
│   │   │   ├── autonomous.ts        # 自主式决策
│   │   │   └── hybrid.ts            # 混合决策
│   │   ├── memory/
│   │   │   ├── working.ts           # 工作记忆
│   │   │   ├── episodic.ts          # 情景记忆
│   │   │   ├── semantic.ts          # 语义记忆
│   │   │   └── consolidation.ts     # 记忆巩固
│   │   ├── learning/
│   │   │   ├── experience.ts        # 经验学习
│   │   │   ├── meta.ts              # 元学习
│   │   │   └── transfer.ts          # 知识迁移
│   │   └── runtime/
│   │       ├── loop.ts              # 运行循环
│   │       ├── state-machine.ts     # 状态机
│   │       ├── lifecycle.ts         # 生命周期
│   │       └── monitor.ts           # 监控
│   ├── perception/
│   │   ├── vision/
│   │   │   ├── active-vision.ts     # 主动视觉
│   │   │   ├── attention.ts         # 注意力机制
│   │   │   └── saccade.ts           # 扫视控制
│   │   ├── audio/
│   │   │   ├── continuous.ts        # 持续监听
│   │   │   ├── wake-word.ts         # 唤醒词检测
│   │   │   └── speech.ts            # 语音识别
│   │   └── fusion.ts                # 多模态融合
│   ├── action/
│   │   ├── executor.ts              # 行动执行器
│   │   ├── tools.ts                 # 工具使用
│   │   └── planning.ts              # 行动规划
│   ├── infrastructure/
│   │   ├── llm/
│   │   │   ├── openai.ts
│   │   │   ├── anthropic.ts
│   │   │   └── router.ts            # 多模型路由
│   │   ├── storage/
│   │   │   ├── vector.ts            # 向量存储
│   │   │   ├── graph.ts             # 图存储
│   │   │   └── cache.ts             # 缓存
│   │   └── monitoring/
│   │       ├── metrics.ts           # Prometheus指标
│   │       ├── logging.ts           # 日志
│   │       └── tracing.ts           # 追踪
│   ├── cli/
│   │   ├── index.ts                 # CLI入口
│   │   ├── commands/
│   │   │   ├── install.ts           # 安装命令
│   │   │   ├── start.ts             # 启动命令
│   │   │   ├── stop.ts              # 停止命令
│   │   │   ├── status.ts            # 状态命令
│   │   │   └── logs.ts              # 日志命令
│   │   └── wizards/
│   │       ├── onboarding.ts        # 入职向导
│   │       ├── configuration.ts     # 配置向导
│   │       └── api-key.ts           # API密钥向导
│   ├── config/
│   │   ├── default.ts               # 默认配置
│   │   ├── schema.ts                # 配置Schema
│   │   └── loader.ts                # 配置加载器
│   ├── types/
│   │   ├── agent.ts                 # Agent类型
│   │   ├── goal.ts                  # 目标类型
│   │   ├── memory.ts                # 记忆类型
│   │   └── perception.ts            # 感知类型
│   └── utils/
│       ├── logger.ts                # 日志工具
│       ├── errors.ts                # 错误处理
│       └── validation.ts            # 验证工具
├── tests/
│   ├── unit/                        # 单元测试
│   ├── integration/                 # 集成测试
│   └── e2e/                         # 端到端测试
├── docker/
│   ├── Dockerfile
│   └── docker-compose.yml
├── scripts/
│   ├── install.sh                   # 一键安装脚本
│   └── setup.sh                     # 初始化脚本
├── package.json
├── tsconfig.json
├── vitest.config.ts
└── README.md
```

---

## 6.3 核心实现

### 6.3.1 Agent 核心类

```typescript
// src/core/agent.ts
import { EventEmitter } from 'events';
import { MotivationSystem } from './motivation';
import { GoalManager } from './goal';
import { DecisionSystem } from './decision';
import { MemorySystem } from './memory';
import { RuntimeLoop } from './runtime';
import { PerceptionSystem } from '../perception';
import { ActionSystem } from '../action';
import { AgentConfig, AgentState } from '../types';

export class FullyAutonomousAgent extends EventEmitter {
  private config: AgentConfig;
  private state: AgentState;
  private motivation: MotivationSystem;
  private goals: GoalManager;
  private decision: DecisionSystem;
  private memory: MemorySystem;
  private runtime: RuntimeLoop;
  private perception: PerceptionSystem;
  private action: ActionSystem;

  constructor(config: AgentConfig) {
    super();
    this.config = config;
    this.state = AgentState.IDLE;

    // 初始化各子系统
    this.motivation = new MotivationSystem(config.motivation);
    this.goals = new GoalManager(config.goals);
    this.decision = new DecisionSystem(config.decision);
    this.memory = new MemorySystem(config.memory);
    this.runtime = new RuntimeLoop(config.runtime);
    this.perception = new PerceptionSystem(config.perception);
    this.action = new ActionSystem(config.action);

    // 监听子系统事件
    this.setupEventHandlers();
  }

  async start(): Promise<void> {
    this.log('info', 'Starting autonomous agent...');

    // 1. 初始化
    await this.initialize();

    // 2. 启动运行循环
    await this.runtime.start();

    // 3. 更新状态
    this.state = AgentState.RUNNING;
    this.emit('started');

    this.log('info', 'Agent started successfully');
  }

  async stop(graceful: boolean = true): Promise<void> {
    this.log('info', `Stopping agent (graceful: ${graceful})...`);

    this.state = AgentState.STOPPING;

    if (graceful) {
      await this.gracefulShutdown();
    } else {
      await this.immediateShutdown();
    }

    this.state = AgentState.STOPPED;
    this.emit('stopped');

    this.log('info', 'Agent stopped');
  }

  private async initialize(): Promise<void> {
    // 初始化各子系统
    await this.memory.initialize();
    await this.perception.initialize();
    await this.action.initialize();

    // 恢复持久化状态
    await this.restoreState();

    // 初始健康检查
    await this.healthCheck();
  }

  private async gracefulShutdown(): Promise<void> {
    this.log('info', 'Initiating graceful shutdown...');

    // 1. 停止接受新任务
    this.runtime.stopAcceptingTasks();

    // 2. 等待当前任务完成
    await this.runtime.waitForTasksCompletion(30000);

    // 3. 持久化状态
    await this.persistState();

    // 4. 清理资源
    await this.cleanup();
  }

  private async immediateShutdown(): Promise<void> {
    this.log('warn', 'Initiating immediate shutdown...');

    // 1. 强制终止任务
    this.runtime.terminateTasks();

    // 2. 尝试持久化
    try {
      await this.persistState();
    } catch (error) {
      this.log('error', 'Failed to persist state during immediate shutdown');
    }

    // 3. 快速清理
    await this.quickCleanup();
  }

  private setupEventHandlers(): void {
    // 监听目标事件
    this.goals.on('goal_generated', (goal) => {
      this.emit('goal_generated', goal);
    });

    this.goals.on('goal_completed', (goal) => {
      this.emit('goal_completed', goal);
      this.motivation.onGoalCompletion(goal);
    });

    // 监听决策事件
    this.decision.on('decision_made', (decision) => {
      this.emit('decision_made', decision);
    });

    // 监听感知事件
    this.perception.on('anomaly_detected', (anomaly) => {
      this.emit('anomaly_detected', anomaly);
    });

    this.perception.on('opportunity_discovered', (opportunity) => {
      this.emit('opportunity_discovered', opportunity);
    });

    // 监听运行时事件
    this.runtime.on('error', (error) => {
      this.emit('error', error);
    });

    this.runtime.on('low_energy', (level) => {
      this.emit('low_energy', level);
    });
  }

  private async restoreState(): Promise<void> {
    const persisted = await this.memory.loadPersistedState();
    if (persisted) {
      this.log('info', 'Restoring persisted state...');
      this.state = persisted.state;
      this.goals.restoreState(persisted.goals);
      this.motivation.restoreState(persisted.motivation);
    }
  }

  private async persistState(): Promise<void> {
    const state = {
      state: this.state,
      goals: this.goals.getState(),
      motivation: this.motivation.getState(),
      timestamp: Date.now(),
    };

    await this.memory.persistState(state);
  }

  private async healthCheck(): Promise<void> {
    // 检查各子系统健康状态
    const checks = [
      this.memory.healthCheck(),
      this.perception.healthCheck(),
      this.action.healthCheck(),
    ];

    const results = await Promise.allSettled(checks);

    const failed = results.filter(r => r.status === 'rejected');
    if (failed.length > 0) {
      throw new Error(`Health check failed: ${failed.length} subsystems unhealthy`);
    }
  }

  private log(level: string, message: string): void {
    this.emit('log', { level, message, timestamp: Date.now() });
  }
}
```

---

### 6.3.2 运行循环实现

```typescript
// src/core/runtime/loop.ts
import { EventEmitter } from 'events';
import { EnergyManager } from './energy';
import { EventDrivenLoop } from './event-driven';
import { PollingLoop } from './polling';
import { AutonomousExploration } from './exploration';

export interface RuntimeConfig {
  energy?: {
    initialLevel?: number;
    decayRate?: number;
    rechargeRate?: number;
  };
  eventDriven?: {
    maxQueueSize?: number;
  };
  polling?: {
    interval?: number;
  };
  exploration?: {
    minCuriosity?: number;
  };
}

export class RuntimeLoop extends EventEmitter {
  private energy: EnergyManager;
  private eventDriven: EventDrivenLoop;
  private polling: PollingLoop;
  private exploration: AutonomousExploration;
  private running: boolean = false;
  private acceptingTasks: boolean = true;

  constructor(config: RuntimeConfig = {}) {
    super();

    this.energy = new EnergyManager(config.energy);
    this.eventDriven = new EventDrivenLoop(config.eventDriven);
    this.polling = new PollingLoop(config.polling);
    this.exploration = new AutonomousExploration(config.exploration);

    this.setupEventHandlers();
  }

  async start(): Promise<void> {
    if (this.running) {
      throw new Error('Runtime already running');
    }

    this.running = true;
    this.emit('started');

    // 启动主循环
    this.mainLoop();
  }

  stop(): void {
    this.running = false;
    this.emit('stopped');
  }

  stopAcceptingTasks(): void {
    this.acceptingTasks = false;
  }

  waitForTasksCompletion(timeout: number): Promise<void> {
    return new Promise((resolve) => {
      const checkInterval = setInterval(() => {
        if (this.eventDriven.queueEmpty && !this.exploration.isActive) {
          clearInterval(checkInterval);
          resolve();
        }
      }, 100);

      setTimeout(() => {
        clearInterval(checkInterval);
        resolve();
      }, timeout);
    });
  }

  terminateTasks(): void {
    this.eventDriven.clearQueue();
    this.exploration.terminate();
  }

  private async mainLoop(): Promise<void> {
    while (this.running) {
      try {
        // 获取当前能量水平
        const energyLevel = this.energy.getLevel();

        // 根据能量选择运行模式
        if (energyLevel < 0.2) {
          await this.conservativeRun();
        } else if (energyLevel > 0.8) {
          await this.activeRun();
        } else {
          await this.hybridRun();
        }

        // 能量衰减
        this.energy.decay();

        // 休眠
        const sleepTime = this.calculateSleepTime();
        await this.sleep(sleepTime);

      } catch (error) {
        this.emit('error', error);
        // 错误后短暂休眠
        await this.sleep(5000);
      }
    }
  }

  private async conservativeRun(): Promise<void> {
    // 低能量: 只处理紧急事件
    const urgentEvents = await this.eventDriven.getUrgentEvents();
    for (const event of urgentEvents) {
      await this.handleEvent(event);
      await this.energy.recharge();
    }
  }

  private async hybridRun(): Promise<void> {
    // 正常能量: 混合模式

    // 1. 事件驱动
    const events = await this.eventDriven.getPendingEvents();
    for (const event of events) {
      await this.handleEvent(event);
      if (this.energy.isLow()) {
        return;
      }
    }

    // 2. 轮询
    if (this.polling.shouldPoll()) {
      const pollResults = await this.polling.poll();
      for (const result of pollResults) {
        if (result.needsAction) {
          await this.handlePollResult(result);
        }
      }
    }

    // 3. 自主探索
    if (this.energy.isSufficient() && this.acceptingTasks) {
      const explorationGoal = await this.exploration.generateGoal();
      if (explorationGoal) {
        await this.executeGoal(explorationGoal);
      }
    }
  }

  private async activeRun(): Promise<void> {
    // 高能量: 优先自主探索

    const explorationGoal = await this.exploration.generateGoal();
    if (explorationGoal) {
      await this.executeGoal(explorationGoal);
    }

    const events = await this.eventDriven.getPendingEvents();
    for (const event of events) {
      await this.handleEvent(event);
    }
  }

  private async handleEvent(event: Event): Promise<void> {
    this.emit('event_handling', event);
    // 事件处理逻辑
  }

  private async handlePollResult(result: PollResult): Promise<void> {
    this.emit('poll_handling', result);
    // 轮询结果处理逻辑
  }

  private async executeGoal(goal: Goal): Promise<void> {
    this.emit('goal_execution', goal);
    // 目标执行逻辑
  }

  private calculateSleepTime(): number {
    const energyLevel = this.energy.getLevel();
    // 能量越低,休眠越长
    return Math.max(100, (1 - energyLevel) * 5000);
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  private setupEventHandlers(): void {
    this.energy.on('low', (level) => {
      this.emit('low_energy', level);
    });

    this.eventDriven.on('error', (error) => {
      this.emit('error', error);
    });

    this.exploration.on('goal_generated', (goal) => {
      this.emit('exploration_goal', goal);
    });
  }
}
```

---

## 6.4 OpenClaw 风格部署

### 6.4.1 一键安装脚本

```bash
#!/bin/bash
# scripts/install.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖..."

    if ! command -v node &> /dev/null; then
        log_error "Node.js 未安装。请先安装 Node.js >= 18"
        exit 1
    fi

    if ! command -v docker &> /dev/null; then
        log_warn "Docker 未安装。可选,用于容器化部署"
    fi

    log_info "依赖检查完成"
}

# 安装 Agent
install_agent() {
    log_info "开始安装自主 Agent..."

    # 全局安装
    npm install -g autonomous-agent

    log_info "安装完成"
}

# 初始化配置
init_config() {
    log_info "初始化配置..."

    # 创建配置目录
    CONFIG_DIR="$HOME/.autonomous-agent"
    mkdir -p "$CONFIG_DIR"

    # 复制默认配置
    cp /usr/local/lib/node_modules/autonomous-agent/config/default.yaml "$CONFIG_DIR/config.yaml"

    log_info "配置目录: $CONFIG_DIR"
}

# 启动向导
run_wizard() {
    log_info "启动配置向导..."

    autonomous-agent configure
}

# 启动服务
start_service() {
    log_info "启动 Agent 服务..."

    # 检查是否已安装服务
    if systemctl list-units --full -all | grep -q "autonomous-agent.service"; then
        log_warn "服务已存在"
    else
        # 创建 systemd 服务
        sudo tee /etc/systemd/system/autonomous-agent.service > /dev/null <<EOF
[Unit]
Description=Autonomous AI Agent
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/.autonomous-agent
ExecStart=/usr/local/bin/autonomous-agent start
Restart=unless-stopped
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

        sudo systemctl daemon-reload
        sudo systemctl enable autonomous-agent
    fi

    # 启动服务
    sudo systemctl start autonomous-agent

    log_info "服务已启动"
}

# 主流程
main() {
    echo ""
    echo "==================================="
    echo "  自主 Agent 安装程序"
    echo "==================================="
    echo ""

    check_dependencies
    install_agent
    init_config
    run_wizard

    # 询问是否启动服务
    echo ""
    read -p "是否立即启动服务? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        start_service
    fi

    echo ""
    log_info "安装完成!"
    echo ""
    echo "常用命令:"
    echo "  autonomous-agent start    # 启动 Agent"
    echo "  autonomous-agent stop     # 停止 Agent"
    echo "  autonomous-agent status   # 查看状态"
    echo "  autonomous-agent logs     # 查看日志"
    echo ""
}

main "$@"
```

---

### 6.4.2 Docker Compose 配置

```yaml
# docker/docker-compose.yml
version: '3.8'

services:
  autonomous-agent:
    build:
      context: ..
      dockerfile: docker/Dockerfile
    image: autonomous-agent:latest
    container_name: autonomous-agent
    restart: unless-stopped

    environment:
      - NODE_ENV=production
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
      - PINECONE_API_KEY=${PINECONE_API_KEY}
      - NEO4J_URI=bolt://neo4j:7687
      - REDIS_URI=redis://redis:6379

    volumes:
      - ${CONFIG_DIR:-./config}:/home/agent/.autonomous-agent
      - agent-memory:/home/agent/memory
      - agent-logs:/home/agent/logs

    ports:
      - "8080:8080"  # Web UI
      - "9090:9090"  # Prometheus metrics

    depends_on:
      - neo4j
      - redis
      - prometheus

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  neo4j:
    image: neo4j:5.15-community
    container_name: autonomous-agent-neo4j
    restart: unless-stopped
    environment:
      - NEO4J_AUTH=neo4j/password
      - NEO4J_PLUGINS=["apoc"]
    volumes:
      - neo4j-data:/data
    ports:
      - "7474:7474"  # HTTP
      - "7687:7687"  # Bolt

  redis:
    image: redis:7-alpine
    container_name: autonomous-agent-redis
    restart: unless-stopped
    command: redis-server --appendonly yes
    volumes:
      - redis-data:/data

  prometheus:
    image: prom/prometheus:latest
    container_name: autonomous-agent-prometheus
    restart: unless-stopped
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus-data:/prometheus
    ports:
      - "9091:9090"

  grafana:
    image: grafana/grafana:latest
    container_name: autonomous-agent-grafana
    restart: unless-stopped
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana-data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    ports:
      - "3000:3000"

volumes:
  agent-memory:
  agent-logs:
  neo4j-data:
  redis-data:
  prometheus-data:
  grafana-data:
```

---

### 6.4.3 CLI 命令系统

```typescript
// src/cli/index.ts
import { Command } from 'commander';
import chalk from 'chalk';
import ora from 'ora';
import { InstallCommand } from './commands/install';
import { StartCommand } from './commands/start';
import { StopCommand } from './commands/stop';
import { StatusCommand } from './commands/status';
import { LogsCommand } from './commands/logs';

const program = new Command();

program
  .name('autonomous-agent')
  .description('完全自主的 AI Agent')
  .version('0.1.0');

// 安装命令
program
  .command('install')
  .description('安装并配置 Agent')
  .option('-d, --dev', '开发模式安装')
  .action(async (options) => {
    const spinner = ora('安装中...').start();
    try {
      await InstallCommand.run(options);
      spinner.succeed(chalk.green('安装完成'));
    } catch (error) {
      spinner.fail(chalk.red('安装失败'));
      console.error(error);
      process.exit(1);
    }
  });

// 启动命令
program
  .command('start')
  .description('启动 Agent')
  .option('-d, --daemon', '作为守护进程运行')
  .option('-v, --verbose', '详细输出')
  .action(async (options) => {
    const spinner = ora('启动中...').start();
    try {
      await StartCommand.run(options);
      spinner.succeed(chalk.green('Agent 已启动'));
      console.log(chalk.gray('使用 "autonomous-agent logs" 查看日志'));
    } catch (error) {
      spinner.fail(chalk.red('启动失败'));
      console.error(error);
      process.exit(1);
    }
  });

// 停止命令
program
  .command('stop')
  .description('停止 Agent')
  .option('-f, --force', '强制停止')
  .action(async (options) => {
    const spinner = ora('停止中...').start();
    try {
      await StopCommand.run(options);
      spinner.succeed(chalk.green('Agent 已停止'));
    } catch (error) {
      spinner.fail(chalk.red('停止失败'));
      console.error(error);
      process.exit(1);
    }
  });

// 状态命令
program
  .command('status')
  .description('查看 Agent 状态')
  .action(async () => {
    try {
      await StatusCommand.run();
    } catch (error) {
      console.error(chalk.red('获取状态失败:'), error);
      process.exit(1);
    }
  });

// 日志命令
program
  .command('logs')
  .description('查看 Agent 日志')
  .option('-f, --follow', '持续跟踪日志')
  .option('-n, --lines <number>', '显示最近N行', '100')
  .action(async (options) => {
    try {
      await LogsCommand.run(options);
    } catch (error) {
      console.error(chalk.red('获取日志失败:'), error);
      process.exit(1);
    }
  });

// 配置向导
program
  .command('configure')
  .description('运行配置向导')
  .action(async () => {
    try {
      await ConfigurationWizard.run();
    } catch (error) {
      console.error(chalk.red('配置失败:'), error);
      process.exit(1);
    }
  });

program.parse();
```

---

## 6.5 监控与可观测性

### 6.5.1 Prometheus 指标

```typescript
// src/infrastructure/monitoring/metrics.ts
import { Counter, Histogram, Gauge, Registry } from 'prom-client';

export class AgentMetrics {
  private registry: Registry;

  // 目标相关指标
  public goalsGenerated: Counter;
  public goalsCompleted: Counter;
  public goalsFailed: Counter;
  public activeGoals: Gauge;
  public goalDuration: Histogram;

  // 决策相关指标
  public decisionsMade: Counter;
  public decisionLatency: Histogram;

  // 动机相关指标
  public curiosityLevel: Gauge;
  public achievementLevel: Gauge;
  public survivalLevel: Gauge;

  // 资源相关指标
  public energyLevel: Gauge;
  public memoryUsage: Gauge;
  public cpuUsage: Gauge;

  // 自主性相关指标
  public autonomousGoalsRatio: Gauge;
  public explorationSuccessRate: Gauge;

  constructor() {
    this.registry = new Registry();

    this.goalsGenerated = new Counter({
      name: 'agent_goals_generated_total',
      help: 'Total number of goals generated',
      registers: [this.registry],
    });

    this.goalsCompleted = new Counter({
      name: 'agent_goals_completed_total',
      help: 'Total number of goals completed',
      registers: [this.registry],
    });

    this.activeGoals = new Gauge({
      name: 'agent_active_goals',
      help: 'Number of currently active goals',
      registers: [this.registry],
    });

    this.goalDuration = new Histogram({
      name: 'agent_goal_duration_seconds',
      help: 'Duration of goal execution in seconds',
      buckets: [1, 5, 10, 30, 60, 300, 600],
      registers: [this.registry],
    });

    this.autonomousGoalsRatio = new Gauge({
      name: 'agent_autonomous_goals_ratio',
      help: 'Ratio of autonomous vs external goals',
      registers: [this.registry],
    });

    this.energyLevel = new Gauge({
      name: 'agent_energy_level',
      help: 'Current energy level (0-1)',
      registers: [this.registry],
    });
  }

  getMetrics(): string {
    return this.registry.metrics();
  }
}
```

---

## 6.6 向导系统

### 6.6.1 入职向导

```typescript
// src/cli/wizards/onboarding.ts
import inquirer from 'inquirer';
import chalk from 'chalk';

export class OnboardingWizard {
  static async run(): Promise<void> {
    console.log(chalk.cyan.bold('\n欢迎使用自主 Agent!\n'));

    const answers = await inquirer.prompt([
      {
        type: 'confirm',
        name: 'firstTime',
        message: '这是第一次使用自主 Agent 吗?',
        default: true,
      },
      {
        type: 'list',
        name: 'experience',
        message: '您对 AI Agent 的了解程度?',
        choices: [
          '新手 - 刚接触',
          '中级 - 有一些经验',
          '专家 - 很有经验',
        ],
        when: (answers) => answers.firstTime,
      },
      {
        type: 'checkbox',
        name: 'features',
        message: '您想启用哪些功能?',
        choices: [
          { name: '主动视觉', value: 'vision', checked: false },
          { name: '持续监听', value: 'audio', checked: false },
          { name: '主动探索', value: 'exploration', checked: true },
          { name: '自主学习', value: 'learning', checked: true },
        ],
      },
      {
        type: 'input',
        name: 'openaiKey',
        message: '请输入 OpenAI API Key:',
        validate: (input) => input.startsWith('sk-') || '无效的 API Key',
        when: () => !process.env.OPENAI_API_KEY,
      },
      {
        type: 'confirm',
        name: 'startNow',
        message: '是否立即启动 Agent?',
        default: false,
      },
    ]);

    // 保存配置
    await this.saveConfig(answers);

    console.log(chalk.green('\n配置完成!\n'));

    if (answers.startNow) {
      console.log(chalk.cyan('启动 Agent...\n'));
      await StartCommand.run({});
    }
  }

  private static async saveConfig(answers: any): Promise<void> {
    // 保存配置逻辑
  }
}
```

---

## 📚 本章小结

### 核心要点

1. **完整架构**: 4层设计(反思/认知/感知执行/运行)
2. **技术栈**: TypeScript + OpenAI/Anthropic + Pinecone/Neo4j/Redis
3. **核心实现**: Agent类+运行循环+各子系统
4. **OpenClaw风格**: 一键安装+Docker Compose+CLI命令
5. **监控可观测**: Prometheus指标+Grafana面板+日志

### 实践成果

- ✅ 完整项目结构
- ✅ `FullyAutonomousAgent` 核心类
- ✅ `RuntimeLoop` 运行循环
- ✅ 一键安装脚本
- ✅ Docker Compose 配置
- ✅ CLI 命令系统
- ✅ Prometheus 指标
- ✅ 向导系统

### 下一步

- 第7章: 实验方法论 - 如何验证自主性

---

<promise>CHAPTER_6_COMPLETE</promise>
