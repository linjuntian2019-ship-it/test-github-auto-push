#!/usr/bin/env bash
set -euo pipefail

# 进入当前 git 项目根目录
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"

# 如果还不是 git 仓库，就初始化
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git init
  git branch -M main
fi

# 自动补一个基础 .gitignore，防止把本地垃圾/密钥传上去
touch .gitignore

for item in ".env" ".DS_Store" "__pycache__/" ".venv/" "venv/" "node_modules/" "logs/" "outputs/" "*.key" "*.pem"; do
  grep -qxF "$item" .gitignore || echo "$item" >> .gitignore
done

# 检查有没有远程仓库
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "没有检测到 GitHub 远程仓库 origin。"
  echo "你可以先运行："
  echo "gh repo create YOUR_REPO_NAME --private --source=. --remote=origin --push"
  exit 1
fi

# 如果没有文件变化，直接退出
if [ -z "$(git status --porcelain)" ]; then
  echo "没有新的文件变化，不需要 push。"
  exit 0
fi

# 提交并 push
git add .
git commit -m "update: $(date '+%Y-%m-%d %H:%M:%S')"

BRANCH="$(git branch --show-current)"
if [ -z "$BRANCH" ]; then
  BRANCH="main"
fi

git push -u origin "$BRANCH"

echo "完成：已经 push 到 GitHub。"


