#!/bin/bash

echo "🚀 GitHub仓库创建脚本"
echo "======================"

# 检查是否在正确的目录
if [ ! -f "index.html" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

echo "📊 检查Git配置..."
echo ""

# 检查SSH认证
echo "🔑 检查SSH认证..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ SSH认证成功"
else
    echo "❌ SSH认证失败"
    echo "请确保："
    echo "1. SSH密钥已添加到GitHub"
    echo "2. 运行：ssh -T git@github.com"
    exit 1
fi

echo ""
echo "📦 检查当前Git状态..."
git status

echo ""
echo "🏗️ 尝试创建GitHub仓库..."
echo ""

# 方法1：尝试直接推送（GitHub可能会自动创建）
echo "🔄 方法1：尝试直接推送到GitHub..."
echo "如果仓库不存在，GitHub可能会自动创建（取决于配置）"
echo ""

read -p "是否尝试直接推送？(y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ 用户取消操作"
    echo ""
    echo "📝 请手动创建仓库："
    echo "1. 访问 https://github.com/new"
    echo "2. 创建名为 'notebook-app' 的仓库"
    echo "3. 不要初始化任何文件"
    echo "4. 然后运行：./push-to-github.sh"
    exit 0
fi

echo "📤 尝试推送代码到GitHub..."
echo ""

# 尝试推送
if git push -u origin main 2>&1; then
    echo ""
    echo "🎉 成功！代码已推送到GitHub"
    echo ""
    echo "🌐 接下来："
    echo "1. 访问 https://github.com/gosunny2050/notebook-app"
    echo "2. 点击 Settings → Pages"
    echo "3. 启用GitHub Pages"
    echo ""
    echo "📱 访问地址："
    echo "https://gosunny2050.github.io/notebook-app/"
else
    echo ""
    echo "⚠️ 推送失败，可能原因："
    echo "1. GitHub仓库不存在"
    echo "2. 需要手动创建仓库"
    echo ""
    echo "📝 手动创建步骤："
    echo ""
    echo "步骤1：创建GitHub仓库"
    echo "----------------------------------------"
    echo "1. 访问 https://github.com/new"
    echo "2. 填写："
    echo "   - Repository name: notebook-app"
    echo "   - Description: 一个简单易用的想法记录Web应用"
    echo "   - Public (公开)"
    echo "   - 不要初始化README、.gitignore、许可证"
    echo "3. 点击 'Create repository'"
    echo ""
    echo "步骤2：获取仓库URL"
    echo "----------------------------------------"
    echo "创建后，复制SSH地址："
    echo "git@github.com:gosunny2050/notebook-app.git"
    echo ""
    echo "步骤3：配置远程仓库"
    echo "----------------------------------------"
    echo "运行以下命令："
    echo "git remote set-url origin git@github.com:gosunny2050/notebook-app.git"
    echo ""
    echo "步骤4：推送代码"
    echo "----------------------------------------"
    echo "运行：./push-to-github.sh"
    echo ""
    echo "步骤5：启用GitHub Pages"
    echo "----------------------------------------"
    echo "1. 仓库 Settings → Pages"
    echo "2. Source: Deploy from a branch"
    echo "3. Branch: main, Folder: / (root)"
    echo "4. 点击 Save"
    echo ""
    echo "⏱️ 等待1-2分钟部署完成"
fi