# Appendix B: Troubleshooting

> **Diagnosis and Solutions for Common Problems**

---

## B.1 Installation and Deployment Issues

### Problem 1: Installation Script Failure

**Symptoms**:
```bash
$ bash install.sh
# Error: Cannot find module 'autonomous-agent'
```

**Diagnostic Steps**:
```bash
# 1. Check Node.js version
$ node --version
# Should be >= 18.0.0

# 2. Check npm permissions
$ npm config get prefix
# If /usr/local, may need sudo

# 3. Check network connection
$ ping registry.npmjs.org
```

**Solutions**:
```bash
# Solution 1: Update Node.js
$ nvm install 20

# Solution 2: Use sudo
$ sudo npm install -g autonomous-agent

# Solution 3: Use domestic mirror
$ npm config set registry https://registry.npmmirror.com
$ npm install -g autonomous-agent
```

---

### Problem 2: Docker Container Cannot Start

**Symptoms**:
```bash
$ docker-compose up
# Error: Cannot connect to Docker daemon
```

**Diagnostic Steps**:
```bash
# 1. Check Docker status
$ docker ps
# Should see container list or "Daemon not running"

# 2. Check Docker service
$ systemctl status docker

# 3. View Docker logs
$ journalctl -u docker -n 50
```

**Solutions**:
```bash
# Linux
$ sudo systemctl start docker
$ sudo systemctl enable docker

# macOS
$ open -a Docker

# Permission issues
$ sudo usermod -aG docker $USER
# Need to logout and login again
```

---

### Problem 3: Environment Variables Not Set

**Symptoms**:
```bash
$ autonomous-agent start
# Error: OPENAI_API_KEY not found
```

**Solutions**:
```bash
# Solution 1: Create .env file
$ cat > ~/.autonomous-agent/.env << EOF
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
PINECONE_API_KEY=...
NEO4J_URI=bolt://localhost:7687
REDIS_URI=redis://localhost:6379
EOF

# Solution 2: Export environment variables
$ export OPENAI_API_KEY="sk-..."
$ export ANTHROPIC_API_KEY="sk-ant-..."

# Solution 3: Use configuration wizard
$ autonomous-agent configure
```

---

## B.2 Runtime Issues

### Problem 1: Agent Crashes Immediately After Starting

**Symptoms**:
```bash
$ autonomous-agent start
Agent started successfully
# A few seconds later
[ERROR] Agent crashed: Division by zero
```

**Diagnostic Steps**:
```bash
# 1. View detailed logs
$ autonomous-agent logs -f

# 2. Check health status
$ autonomous-agent status

# 3. Run diagnostics
$ autonomous-agent doctor
```

**Common Causes and Solutions**:

**Cause 1: Configuration Error**
```bash
# Check configuration file
$ cat ~/.autonomous-agent/config.yaml

# Reset to default configuration
$ mv ~/.autonomous-agent/config.yaml ~/.autonomous-agent/config.yaml.bak
$ autonomous-agent start  # Will use default configuration
```

**Cause 2: Insufficient Resources**
```bash
# Check available resources
$ free -h
$ df -h

# Clean up resources
$ sudo apt-get clean
$ docker system prune -a
```

**Cause 3: Missing Dependencies**
```bash
# Reinstall
$ npm uninstall -g autonomous-agent
$ npm install -g autonomous-agent
```

---

### Problem 2: Memory Leak

**Symptoms**:
```bash
# Memory usage keeps growing
$ watch -n 1 'ps aux | grep autonomous-agent'
# RSS keeps increasing
```

**Diagnostic Tools**:
```python
# tools/memory_profiler.py
import psutil
import time

def monitor_memory(pid, interval=60):
    """Monitor memory usage"""
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

**Solutions**:

**Solution 1: Adjust Memory Limits**
```yaml
# config.yaml
runtime:
  memory:
    max_heap_mb: 2048
    gc_interval: 300
```

**Solution 2: Enable Memory Optimization**
```typescript
// Configuration for memory optimization
const config = {
  memory: {
    optimization: true,
    aggressiveGC: true,
    memoryLimit: '2GB',
  }
};
```

**Solution 3: Periodic Restart**
```bash
# Use cron for periodic restart
$ crontab -e
# Add:
0 3 * * * /usr/local/bin/autonomous-agent restart
```

---

### Problem 3: Low Quality Goal Generation

**Symptoms**:
- Agent generates infeasible goals
- Goals misaligned with values
- Goals too vague

**Diagnostic Steps**:
```bash
# 1. View generated goals
$ autonomous-agent logs | grep "Goal generated"

# 2. Evaluate goal quality
$ autonomous-agent eval --metrics goal-quality

# 3. View motivation system status
$ autonomous-agent status --motivation
```

**Solutions**:

**Adjust Goal Generation Parameters**:
```yaml
# config.yaml
goal_generation:
  min_feasibility: 0.7
  min_value: 0.6
  min_specificity: 0.5
  diversity_weight: 0.3
  novelty_weight: 0.2
```

**Adjust Motivation System**:
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

## B.3 Performance Issues

### Problem 1: Slow Response

**Symptoms**:
- Agent response latency is high
- Goal execution is slow
- CPU usage is low but throughput is low

**Diagnosis**:
```bash
# 1. Performance profiling
$ autonomous-agent profile --duration 60

# 2. View bottlenecks
$ autonomous-agent analyze --bottleneck

# 3. Check LLM latency
$ autonomous-agent test --llm-latency
```

**Solutions**:

**Use Faster Model**:
```yaml
# config.yaml
llm:
  provider: openai
  model: gpt-4-turbo  # Faster than gpt-4
  # Or use local model
  # provider: ollama
  # model: llama3
```

**Parallelization**:
```typescript
// Enable parallel processing
const config = {
  parallelism: {
    enabled: true,
    max_workers: 4,
  }
};
```

---

### Problem 2: High Resource Usage

**Symptoms**:
```bash
$ top
# PID   USER  %CPU  %MEM
# 1234  user  95.5  12.3  autonomous-agent
```

**Diagnosis**:
```bash
# CPU analysis
$ autonomous-agent profile --cpu

# Memory analysis
$ autonomous-agent profile --memory

# Network analysis
$ autonomous-agent profile --network
```

**Solutions**:

**Limit Resource Usage**:
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

**Lower Sampling Rate**:
```yaml
# config.yaml
perception:
  vision:
    frame_rate: 15  # Reduced from 30
  audio:
    sample_rate: 16000  # Reduced from 44100
```

---

## B.4 Autonomy Issues

### Problem 1: Lack of Proactiveness

**Symptoms**:
- Agent only responds to external inputs
- Does not proactively generate goals
- Long idle periods

**Diagnosis**:
```bash
# Check autonomy index
$ autonomous-agent eval --autonomy-index

# Check motivation levels
$ autonomous-agent status --motivation

# View goal generation history
$ autonomous-agent history --goals
```

**Solutions**:

**Enable Active Exploration**:
```yaml
# config.yaml
exploration:
  enabled: true
  min_curiosity_threshold: 0.3
  max_idle_time: 300  # 5 minutes
```

**Adjust Curiosity**:
```yaml
# config.yaml
curiosity:
  surprise_weight: 0.4
  information_gain_weight: 0.4
  novelty_weight: 0.2
  exploration_bonus: 0.5
```

---

### Problem 2: Repeating Same Behavior

**Symptoms**:
- Agent repeatedly executes similar goals
- Lacks diversity
- Stuck in local loops

**Solutions**:

**Increase Diversity Penalty**:
```yaml
# config.yaml
goal_selection:
  diversity_weight: 0.5
  repetition_penalty: 0.3
  similarity_threshold: 0.8
```

**Enable Exploration**:
```yaml
# config.yaml
exploration:
  epsilon: 0.1  # 10% probability of random exploration
  decay_rate: 0.995
```

---

## B.5 Safety Issues

### Problem 1: Behavior Exceeds Expected Boundaries

**Symptoms**:
- Agent executes unauthorized operations
- Exceeds resource limits
- Violates safety constraints

**Emergency Measures**:
```bash
# Stop immediately
$ autonomous-agent stop --force

# Check logs
$ autonomous-agent logs --since 1h

# View status
$ autonomous-agent status
```

**Preventive Measures**:

**Set Strict Boundaries**:
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

**Enable Constitutional Constraints**:
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

## B.6 Diagnostic Toolkit

### Complete Diagnostic Script

```bash
#!/bin/bash
# tools/diagnose.sh

echo "=== Autonomous Agent Diagnostic Tool ==="
echo ""

# 1. Version check
echo "1. Version Information:"
autonomous-agent --version
echo ""

# 2. Configuration check
echo "2. Configuration Check:"
autonomous-agent config --validate
echo ""

# 3. Dependency check
echo "3. Dependency Check:"
node --version
npm --version
docker --version
echo ""

# 4. Resource check
echo "4. Resource Usage:"
free -h
df -h
echo ""

# 5. Process check
echo "5. Process Status:"
ps aux | grep autonomous-agent
echo ""

# 6. Log check
echo "6. Recent Errors:"
autonomous-agent logs --since 1h | grep ERROR
echo ""

# 7. Health check
echo "7. Health Status:"
autonomous-agent status --health
echo ""

# 8. Performance check
echo "8. Performance Metrics:"
autonomous-agent eval --performance
echo ""

echo "=== Diagnosis Complete ==="
```

### Interactive Diagnosis

```python
# tools/interactive_diagnosis.py
import inquirer
import subprocess

def run_command(command):
    """Run command and display results"""
    result = subprocess.run(
        command,
        shell=True,
        capture_output=True,
        text=True
    )
    return result.stdout, result.returncode

def interactive_diagnosis():
    """Interactive diagnosis"""
    print("=== Autonomous Agent Interactive Diagnosis ===\n")

    while True:
        questions = [
            inquirer.List(
                'action',
                message="Select diagnostic item",
                choices=[
                    'View Status',
                    'View Logs',
                    'Performance Analysis',
                    'Memory Analysis',
                    'Configuration Check',
                    'Run Tests',
                    'Exit',
                ],
            ),
        ]

        answers = inquirer.prompt(questions)
        action = answers['action']

        if action == 'View Status':
            output, _ = run_command('autonomous-agent status')
            print(output)

        elif action == 'View Logs':
            output, _ = run_command('autonomous-agent logs --tail 50')
            print(output)

        elif action == 'Performance Analysis':
            output, _ = run_command('autonomous-agent profile --duration 30')
            print(output)

        elif action == 'Memory Analysis':
            output, _ = run_command('autonomous-agent profile --memory')
            print(output)

        elif action == 'Configuration Check':
            output, _ = run_command('autonomous-agent config --validate')
            print(output)

        elif action == 'Run Tests':
            output, _ = run_command('autonomous-agent test --all')
            print(output)

        elif action == 'Exit':
            break

        print("\n" + "="*60 + "\n")

if __name__ == '__main__':
    interactive_diagnosis()
```

---

## B.7 Getting Help

### Community Resources

- **GitHub Issues**: https://github.com/autonomous-agent/autonomous-agent/issues
- **Discord Community**: https://discord.gg/autonomous-agent
- **Documentation**: https://docs.autonomous-agent.ai

### Reporting Bugs

When reporting issues, please include:

1. Version Information
   ```bash
   $ autonomous-agent --version
   ```

2. System Information
   ```bash
   $ uname -a
   $ node --version
   $ npm --version
   ```

3. Reproduction Steps
4. Expected Behavior
5. Actual Behavior
6. Log Output
   ```bash
   $ autonomous-agent logs --since 10m > bug_report.log
   ```

---

<promise>APPENDIX_B_COMPLETE</promise>
