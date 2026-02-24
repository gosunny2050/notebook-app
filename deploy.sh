#!/bin/bash

echo "🚀 部署想法记录本应用到GitHub Pages"

# 检查是否在正确的目录
if [ ! -f "index.html" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

# 添加所有更改
git add .

# 提交更改
if [ -n "$1" ]; then
    commit_msg="$1"
else
    commit_msg="更新：$(date '+%Y-%m-%d %H:%M:%S')"
fi

git commit -m "$commit_msg"

# 推送到GitHub
echo "📤 推送到GitHub..."
git push origin main

echo "✅ 部署完成！"
echo "🌐 访问地址：https://gosunny2050.github.io/notebook-app/"