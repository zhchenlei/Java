#!/bin/bash
# 本脚本请在git bash中运行
# 作者：chenlei 2025/03/15
# 更新时间：2025/03/15
# 在终端输入 ./push.sh 即可打开脚本
# 博客：https://blog.hellolei.xin

# 新增：读取用户输入的 commit 消息 [5,7](@ref)
read -e -p $'\033[32m请输入本次提交的内容描述：\033[0m' commit_message

# 若未输入内容则使用默认值
if [ -z "$commit_message" ]; then
    commit_message="update"
fi

echo -e "\033[32m正在为你备份博客中.........\033[0m"
git add .

echo -e "\033[32m正在提交变更.........\033[0m"
git commit -m "$commit_message"  # 使用变量替换固定内容 [5,6](@ref)

echo -e "\033[32m正在推送至远程仓库.........\033[0m"
git push origin main --force

if [ $? -ne 0 ]; then
    echo -e "\033[31m 备份失败！请检查网络情况！ \033[0m"
else
    echo -e "\033[32m恭喜！已成功备份到 GitHub 仓库 backup \033[0m"
fi
