#!/bin/bash

# OpenMind GitHub 上传脚本
# 使用方法: bash upload-to-github.sh YOUR_USERNAME

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# 检查参数
if [ -z "$1" ]; then
    log_warn "使用方法: $0 <GITHUB_USERNAME>"
    echo ""
    echo "示例:"
    echo "  $0 johndoe"
    echo ""
    echo "这将会创建仓库: https://github.com/johndoe/OpenMind"
    exit 1
fi

GITHUB_USERNAME=$1
REPO_NAME="OpenMind"
REPO_URL="https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git"

echo ""
echo "==================================="
echo "  OpenMind GitHub 上传助手"
echo "==================================="
echo ""
log_info "配置信息:"
echo "  GitHub 用户名: ${GITHUB_USERNAME}"
echo "  仓库名称: ${REPO_NAME}"
echo "  仓库 URL: ${REPO_URL}"
echo ""

# 1. 检查 Git 仓库
log_info "检查 Git 仓库..."
if [ ! -d ".git" ]; then
    log_warn "这不是一个 Git 仓库!"
    log_info "正在初始化..."
    git init
fi
log_success "Git 仓库检查完成"

# 2. 检查远程仓库
log_info "检查远程仓库配置..."
if git remote get-url origin &> /dev/null; then
    CURRENT_URL=$(git remote get-url origin)
    log_warn "远程仓库已存在: ${CURRENT_URL}"
    read -p "是否要更新远程仓库 URL? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote set-url origin "${REPO_URL}"
        log_success "远程仓库 URL 已更新"
    fi
else
    git remote add origin "${REPO_URL}"
    log_success "远程仓库已添加"
fi

# 3. 显示提交历史
log_info "提交历史:"
echo ""
git log --oneline -5
echo ""

# 4. 确认推送
log_warn "即将推送到 GitHub:"
echo "  ${REPO_URL}"
echo ""
read -p "确认推送? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    log_warn "取消推送"
    exit 0
fi

# 5. 推送到 GitHub
log_info "正在推送到 GitHub..."
echo ""

if git push -u origin main; then
    echo ""
    log_success "推送成功!"
    echo ""
    echo "==================================="
    echo "  🎉 OpenMind 已上传到 GitHub!"
    echo "==================================="
    echo ""
    echo "仓库地址:"
    echo "  ${REPO_URL}"
    echo ""
    echo "下一步:"
    echo "  1. 访问 ${REPO_URL}"
    echo "  2. 添加 Topics (标签)"
    echo "  3. 创建 v0.1.0 Release"
    echo "  4. 启用 GitHub Pages (可选)"
    echo "  5. 分享到社区"
    echo ""
    echo "详细指南请查看: GITHUB_UPLOAD_GUIDE.md"
    echo ""
else
    echo ""
    log_warn "推送失败!"
    echo ""
    echo "可能的原因:"
    echo "  1. GitHub 仓库尚未创建"
    echo "  2. 认证失败"
    echo "  3. 网络问题"
    echo ""
    echo "请检查:"
    echo "  1. 访问 https://github.com/new"
    echo "  2. 创建名为 '${REPO_NAME}' 的仓库"
    echo "  3. 设置为 Public"
    echo "  4. 不要初始化 README/.gitignore/LICENSE"
    echo "  5. 重新运行此脚本"
    echo ""
fi
