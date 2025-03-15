#!/bin/bash

# 文件名: sync_repo.sh
# 作者：chenlei 2025/03/15
# 更新时间：2025/03/15
# 用途：强制同步本地分支与远程仓库，解决分叉问题
# 使用方法：./sync_repo.sh [分支名] 
# 设置默认分支（如果未指定参数，默认为 main）
TARGET_BRANCH="${1:-main}"

# 终止脚本执行（如果任何命令失败）
set -e

# 步骤1：检查当前分支
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "$TARGET_BRANCH" ]; then
  echo -e "\033[31m错误：当前分支为 $CURRENT_BRANCH，请先切换到目标分支 $TARGET_BRANCH\033[0m"
  exit 1
fi

# 步骤2：拉取远程最新代码（不自动合并）
echo -e "\033[34m[1/3] 拉取远程最新代码...\033[0m"
git fetch origin

# 步骤3：强制同步本地分支（丢弃所有本地修改）
echo -e "\033[34m[2/3] 强制同步分支 $TARGET_BRANCH...\033[0m"
git reset --hard "origin/$TARGET_BRANCH"

# 步骤4：验证同步结果
echo -e "\033[34m[3/3] 验证提交历史（最近3条）:\033[0m"
git log --oneline -n 3

# 步骤5：二次确认同步（可选）
echo -e "\n\033[32m同步完成！本地分支 $TARGET_BRANCH 已强制指向 origin/$TARGET_BRANCH\033[0m"

