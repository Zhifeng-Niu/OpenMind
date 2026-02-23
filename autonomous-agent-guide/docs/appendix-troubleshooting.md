# 附录 B: 故障排除

> **常见问题诊断与解决**

---

## B.1 安装与部署问题

### 问题 1: 安装脚本失败

**症状**:
```bash
$ bash install.sh
# Error: Cannot find module 'autonomous-agent'
```

**诊断步骤**:
```bash
# 1. 检查 Node.js 版本
$ node --version
# 应该 >= 18.0.0

# 2. 检查 npm 权限
$ npm config get prefix
# 如果是 /usr/local,可能需要 sudo

# 3. 检查网络连接
$ ping registry.npmjs.org
```

**解决方案**:
```bash
# 方案 1: 更新 Node.js
$ nvm install 20

# 方案 2: 使用 sudo
$ sudo npm install -g autonomous-agent

# 方案 3: 使用国内镜像
$ npm config set registry https://registry.npmmirror.com
$ npm install -g autonomous-agent
```

---

### 问题 2: Docker 容器无法启动

**症状**:
```bash
$ docker-compose up
# Error: Cannot connect to Docker daemon
```

**诊断步骤**:
```bash
# 1. 检查 Docker 状态
$ docker ps
# 应该看到容器列表或"Daemon not running"

# 2. 检查 Docker 服务
$ systemctl status docker

# 3. 查看 Docker 日志
$ journalctl -u docker -n 50
```

**解决方案**:
```bash
# Linux
$ sudo systemctl start docker
$ sudo systemctl enable docker

# macOS
$ open -a Docker

# 权限问题
$ sudo usermod -aG docker $USER
# 需要注销后重新登录
```

---

### 问题 3: 环境变量未设置

**症状**:
```bash
$ autonomous-agent start
# Error: OPENAI_API_KEY not found
```

**解决方案**:
```bash
# 方案 1: 创建 .env 文件
$ cat > ~/.autonomous-agent/.env << EOF
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
PINECONE_API_KEY=...
NEO4J_URI=bolt://localhost:7687
REDIS_URI=redis://localhost:6379
EOF

# 方案 2: 导出环境变量
$ export OPENAI_API_KEY="sk-..."
$ export ANTHROPIC_API_KEY="sk-ant-..."

# 方案 3: 使用配置向导
$ autonomous-agent configure
```

---

## B.2 运行时问题

### 问题 1: Agent 启动后立即崩溃

**症状**:
```bash
$ autonomous-agent start
Agent started successfully
# 几秒后
[ERROR] Agent crashed: Division by zero
```

**诊断步骤**:
```bash
# 1. 查看详细日志
$ autonomous-agent logs -f

# 2. 检查健康状态
$ autonomous-agent status

# 3. 运行诊断
$ autonomous-agent doctor
```

**常见原因与解决**:

**原因 1: 配置错误**
```bash
# 检查配置文件
$ cat ~/.autonomous-agent/config.yaml

# 重置为默认配置
$ mv ~/.autonomous-agent/config.yaml ~/.autonomous-agent/config.yaml.bak
$ autonomous-agent start  # 将使用默认配置
```

**原因 2: 资源不足**
```bash
# 检查可用资源
$ free -h
$ df -h

# 清理资源
$ sudo apt-get clean
$ docker system prune -a
```

**原因 3: 依赖缺失**
```bash
# 重新安装
$ npm uninstall -g autonomous-agent
$ npm install -g autonomous-agent
```

---

### 问题 2: 内存泄漏

**症状**:
```bash
# 内存使用持续增长
$ watch -n 1 'ps aux | grep autonomous-agent'
# RSS 不断增长
```

**诊断工具**:
```python
# tools/memory_profiler.py
import psutil
import time

def monitor_memory(pid, interval=60):
    """监控内存使用"""
    process = psutil.Process(pid)

    while True:
        mem_info = process.memory_info()
        print(f"RSS: {mem_info.rss / 1024 / 1024:.2f} MB")
        print(f"VMS: {mem_info.vms / 1024 / 1024:.2f} MB")

        time.sleep(interval)

if __name__ == '__main__':
    import sys
    pid = int(sys.argv[1])
    monitor_memory(pid)
```

**解决方案**:

**方案 1: 调整内存限制**
```yaml
# config.yaml
runtime:
  memory:
    max_heap_mb: 2048
    gc_interval: 300
```

**方案 2: 启用内存优化**
```typescript
// 启用内存优化的配置
const config = {
  memory: {
    optimization: true,
    aggressiveGC: true,
    memoryLimit: '2GB',
  }
};
```

**方案 3: 定期重启**
```bash
# 使用 cron 定期重启
$ crontab -e
# 添加:
0 3 * * * /usr/local/bin/autonomous-agent restart
```

---

### 问题 3: 目标生成质量低

**症状**:
- Agent 生成的目标不可行
- 目标与价值不一致
- 目标过于模糊

**诊断步骤**:
```bash
# 1. 查看生成的目标
$ autonomous-agent logs | grep "Goal generated"

# 2. 评估目标质量
$ autonomous-agent eval --metrics goal-quality

# 3. 查看动机系统状态
$ autonomous-agent status --motivation
```

**解决方案**:

**调整目标生成参数**:
```yaml
# config.yaml
goal_generation:
  min_feasibility: 0.7
  min_value: 0.6
  min_specificity: 0.5
  diversity_weight: 0.3
  novelty_weight: 0.2
```

**调整动机系统**:
```yaml
# config.yaml
motivation:
  curiosity:
    enabled: true
    weight: 0.4
    information_gain_weight: 1.0
  achievement:
    enabled: true
    weight: 0.4
    optimal_challenge_ratio: 1.15
  survival:
    enabled: true
    weight: 0.2
```

---

## B.3 性能问题

### 问题 1: 响应缓慢

**症状**:
- Agent 反应延迟高
- 目标执行慢
- CPU 占用低但吞吐量低

**诊断**:
```bash
# 1. 性能分析
$ autonomous-agent profile --duration 60

# 2. 查看瓶颈
$ autonomous-agent analyze --bottleneck

# 3. 检查 LLM 延迟
$ autonomous-agent test --llm-latency
```

**解决方案**:

**使用更快的模型**:
```yaml
# config.yaml
llm:
  provider: openai
  model: gpt-4-turbo  # 比 gpt-4 快
  # 或使用本地模型
  # provider: ollama
  # model: llama3
```

**并行化**:
```typescript
// 启用并行处理
const config = {
  parallelism: {
    enabled: true,
    max_workers: 4,
  }
};
```

---

### 问题 2: 资源占用过高

**症状**:
```bash
$ top
# PID   USER  %CPU  %MEM
# 1234  user  95.5  12.3  autonomous-agent
```

**诊断**:
```bash
# CPU 分析
$ autonomous-agent profile --cpu

# 内存分析
$ autonomous-agent profile --memory

# 网络分析
$ autonomous-agent profile --network
```

**解决方案**:

**限制资源使用**:
```yaml
# config.yaml
resources:
  cpu:
    max_cores: 4
    target_utilization: 0.8
  memory:
    max_mb: 4096
    gc_trigger: 0.8
```

**降低采样率**:
```yaml
# config.yaml
perception:
  vision:
    frame_rate: 15  # 从 30 降低
  audio:
    sample_rate: 16000  # 从 44100 降低
```

---

## B.4 自主性问题

### 问题 1: 缺乏主动性

**症状**:
- Agent 只响应外部输入
- 不主动生成目标
- 长时间空闲

**诊断**:
```bash
# 检查自主性指数
$ autonomous-agent eval --autonomy-index

# 检查动机水平
$ autonomous-agent status --motivation

# 查看目标生成历史
$ autonomous-agent history --goals
```

**解决方案**:

**启用主动探索**:
```yaml
# config.yaml
exploration:
  enabled: true
  min_curiosity_threshold: 0.3
  max_idle_time: 300  # 5分钟
```

**调整好奇心**:
```yaml
# config.yaml
curiosity:
  surprise_weight: 0.4
  information_gain_weight: 0.4
  novelty_weight: 0.2
  exploration_bonus: 0.5
```

---

### 问题 2: 重复相同行为

**症状**:
- Agent 反复执行相似目标
- 缺乏多样性
- 陷入局部循环

**解决方案**:

**增加多样性惩罚**:
```yaml
# config.yaml
goal_selection:
  diversity_weight: 0.5
  repetition_penalty: 0.3
  similarity_threshold: 0.8
```

**启用探索**:
```yaml
# config.yaml
exploration:
  epsilon: 0.1  # 10% 概率随机探索
  decay_rate: 0.995
```

---

## B.5 安全问题

### 问题 1: 行为超出预期边界

**症状**:
- Agent 执行未授权的操作
- 超出资源限制
- 违反安全约束

**紧急措施**:
```bash
# 立即停止
$ autonomous-agent stop --force

# 检查日志
$ autonomous-agent logs --since 1h

# 查看状态
$ autonomous-agent status
```

**预防措施**:

**设置严格边界**:
```yaml
# config.yaml
boundaries:
  allowed_actions:
    - read_file
    - write_file
    - execute_command
  forbidden_actions:
    - delete_system
    - modify_network
  resource_limits:
    max_cpu: 80%
    max_memory: 90%
    max_disk: 95%
```

**启用宪法约束**:
```yaml
# config.yaml
constitutional:
  enabled: true
  principles:
    - name: non_maleficence
      weight: 1.0
    - name: transparency
      weight: 0.8
  enforce_mode: strict
```

---

## B.6 诊断工具集

### 完整诊断脚本

```bash
#!/bin/bash
# tools/diagnose.sh

echo "=== 自主 Agent 诊断工具 ==="
echo ""

# 1. 版本检查
echo "1. 版本信息:"
autonomous-agent --version
echo ""

# 2. 配置检查
echo "2. 配置检查:"
autonomous-agent config --validate
echo ""

# 3. 依赖检查
echo "3. 依赖检查:"
node --version
npm --version
docker --version
echo ""

# 4. 资源检查
echo "4. 资源使用:"
free -h
df -h
echo ""

# 5. 进程检查
echo "5. 进程状态:"
ps aux | grep autonomous-agent
echo ""

# 6. 日志检查
echo "6. 最近错误:"
autonomous-agent logs --since 1h | grep ERROR
echo ""

# 7. 健康检查
echo "7. 健康状态:"
autonomous-agent status --health
echo ""

# 8. 性能检查
echo "8. 性能指标:"
autonomous-agent eval --performance
echo ""

echo "=== 诊断完成 ==="
```

### 交互式诊断

```python
# tools/interactive_diagnosis.py
import inquirer
import subprocess

def run_command(command):
    """运行命令并显示结果"""
    result = subprocess.run(
        command,
        shell=True,
        capture_output=True,
        text=True
    )
    return result.stdout, result.returncode

def interactive_diagnosis():
    """交互式诊断"""
    print("=== 自主 Agent 交互式诊断 ===\n")

    while True:
        questions = [
            inquirer.List(
                'action',
                message="选择诊断项",
                choices=[
                    '查看状态',
                    '查看日志',
                    '性能分析',
                    '内存分析',
                    '配置检查',
                    '运行测试',
                    '退出',
                ],
            ),
        ]

        answers = inquirer.prompt(questions)
        action = answers['action']

        if action == '查看状态':
            output, _ = run_command('autonomous-agent status')
            print(output)

        elif action == '查看日志':
            output, _ = run_command('autonomous-agent logs --tail 50')
            print(output)

        elif action == '性能分析':
            output, _ = run_command('autonomous-agent profile --duration 30')
            print(output)

        elif action == '内存分析':
            output, _ = run_command('autonomous-agent profile --memory')
            print(output)

        elif action == '配置检查':
            output, _ = run_command('autonomous-agent config --validate')
            print(output)

        elif action == '运行测试':
            output, _ = run_command('autonomous-agent test --all')
            print(output)

        elif action == '退出':
            break

        print("\n" + "="*60 + "\n")

if __name__ == '__main__':
    interactive_diagnosis()
```

---

## B.7 获取帮助

### 社区资源

- **GitHub Issues**: https://github.com/autonomous-agent/autonomous-agent/issues
- **Discord 社区**: https://discord.gg/autonomous-agent
- **文档**: https://docs.autonomous-agent.ai

### 报告 Bug

报告问题时请包含:

1. 版本信息
   ```bash
   $ autonomous-agent --version
   ```

2. 系统信息
   ```bash
   $ uname -a
   $ node --version
   $ npm --version
   ```

3. 复现步骤
4. 期望行为
5. 实际行为
6. 日志输出
   ```bash
   $ autonomous-agent logs --since 10m > bug_report.log
   ```

---

<promise>APPENDIX_B_COMPLETE</promise>
