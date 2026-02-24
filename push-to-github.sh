#!/bin/bash

echo "🚀 GitHub代码推送脚本"
echo "======================"

# 检查是否在正确的目录
if [ ! -f "index.html" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

echo "📊 当前Git状态："
git status

echo ""
echo "📦 准备推送代码到GitHub..."
echo ""

# 检查远程仓库配置
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -z "$REMOTE_URL" ]; then
    echo "❌ 未配置远程仓库"
    echo ""
    echo "请先在GitHub上创建仓库，然后运行以下命令："
    echo "git remote add origin git@github.com:gosunny2050/notebook-app.git"
    exit 1
fi

echo "✅ 远程仓库已配置：$REMOTE_URL"
echo ""

# 确认推送
read -p "是否推送代码到GitHub？(y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 用户取消操作"
    exit 0
fi

echo "📤 推送代码到GitHub..."
echo ""

# 推送代码
if git push -u origin main; then
    echo ""
    echo "✅ 代码推送成功！"
    echo ""
    echo "🌐 接下来需要："
    echo "1. 访问 https://github.com/gosunny2050/notebook-app"
    echo "2. 点击 Settings → Pages"
    echo "3. 设置 Source 为 'Deploy from a branch'"
    echo "4. 选择分支 'main' 和文件夹 '/'"
    echo "5. 点击 Save"
    echo ""
    echo "📱 访问地址（部署后）："
    echo "https://gosunny2050.github.io/notebook-app/"
    echo ""
    echo "🔄 本地测试地址："
    echo "file://$(pwd)/index.html"
    echo "或"
    echo "http://localhost:8000 (使用 python3 -m http.server 8000)"
else
    echo ""
    echo "❌ 推送失败！可能的原因："
    echo "1. GitHub仓库不存在"
    echo "2. 网络连接问题"
    echo "3. SSH密钥未配置"
    echo ""
    echo "🔧 解决方案："
    echo "1. 确保在GitHub上创建了 notebook-app 仓库"
    echo "2. 检查SSH密钥：ssh -T git@github.com"
    echo "3. 确认仓库URL：git remote -v"
fi