#!/bin/bash
# 自动拉取所有子目录中的Git仓库更新
# 作者：chenlei
# 用法：./auto_pull.sh [-f] [路径]
#  -f : 强制更新模式（忽略本地修改）
#  路径: 指定扫描目录（默认为当前目录）

# 颜色定义
RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
NC='\033[0m' # 恢复默认

# 初始化参数
FORCE_UPDATE=false
TARGET_DIR="."

# 解析参数
while getopts "f" opt; do
  case $opt in
    f) FORCE_UPDATE=true ;;
    *) echo "用法: $0 [-f] [路径]"; exit 1 ;;
  esac
done
shift $((OPTIND-1))
[ "$1" ] && TARGET_DIR="$1"

# 日志文件路径
LOG_FILE="$TARGET_DIR/git_pull.log"

# 主函数：处理单个仓库
process_repo() {
  local repo_dir="$1"
  echo -e "${YELLOW}▶ 处理仓库: $repo_dir${NC}"
  
  cd "$repo_dir" || { echo -e "${RED}✗ 无法进入目录${NC}"; return 1; }
  
  # 检测是否为Git仓库
  if [ ! -d .git ]; then
    echo -e "${RED}✗ 非Git仓库${NC}"
    return 1
  fi

  # 获取当前分支
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  
  # 强制更新模式
  if $FORCE_UPDATE; then
    echo -e "${YELLOW}⚡ 强制重置到远程版本...${NC}"
    git fetch --all
    git reset --hard "origin/$CURRENT_BRANCH"
    git clean -fd
    return $?
  fi

  # 常规拉取
  echo -e "${YELLOW}🔄 拉取更新...${NC}"
  git_output=$(git pull 2>&1)
  pull_status=$?

  # 处理冲突
  if [ $pull_status -ne 0 ]; then
    echo -e "${RED}‼️ 检测到冲突或错误：${NC}"
    echo "$git_output"
    return 1
  fi

  # 记录成功日志
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $repo_dir 更新成功" >> "$LOG_FILE"
}

# 递归查找.git目录并处理
find "$TARGET_DIR" -type d -name .git | while read git_dir; do
  repo_dir=$(dirname "$git_dir")
  process_repo "$repo_dir"
  echo "--------------------------------------"
done

echo -e "${GREEN}✅ 所有仓库处理完成，日志见: $LOG_FILE${NC}"
