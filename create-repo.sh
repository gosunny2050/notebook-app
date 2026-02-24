#!/bin/bash

echo "🚀 自动创建GitHub仓库"
echo "======================"

# 检查SSH认证
echo "🔑 检查SSH认证..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✅ SSH认证成功"
else
    echo "❌ SSH认证失败"
    exit 1
fi

# 检查是否在项目目录
if [ ! -f "index.html" ]; then
    echo "❌ 错误：请在项目根目录运行"
    exit 1
fi

echo ""
echo "🔄 尝试自动创建GitHub仓库..."
echo ""

# 方法1：检查是否有GitHub Token
echo "🔍 检查GitHub Token..."
if [ -f ~/.github_token ]; then
    GITHUB_TOKEN=$(cat ~/.github_token)
    echo "✅ 找到GitHub Token"
    
    echo "🔄 使用GitHub API创建仓库..."
    response=$(curl -s -X POST \
      -H "Accept: application/vnd.github.v3+json" \
      -H "Authorization: token $GITHUB_TOKEN" \
      https://api.github.com/user/repos \
      -d '{"name":"notebook-app","description":"一个简单易用的想法记录Web应用","private":false,"auto_init":false}' 2>/dev/null)
    
    if echo "$response" | grep -q '"name":"notebook-app"'; then
        echo "✅ GitHub仓库创建成功！"
        echo ""
        echo "📤 推送代码到新仓库..."
        if git push -u origin main 2>&1; then
            echo "✅ 代码推送成功！"
            echo ""
            echo "🌐 接下来："
            echo "1. 访问 https://github.com/gosunny2050/notebook-app/settings/pages"
            echo "2. 启用GitHub Pages"
            echo "3. 访问 https://gosunny2050.github.io/notebook-app/"
            exit 0
        fi
    else
        echo "❌ API创建失败: $response"
    fi
else
    echo "ℹ️ 未找到GitHub Token"
fi

echo ""
echo "🔄 方法2：尝试使用git的push-to-create功能..."
echo ""

# 有些Git服务器支持通过推送自动创建仓库
# 我们先配置正确的远程URL
echo "🔧 配置远程仓库..."
git remote remove origin 2>/dev/null
git remote add origin git@github.com:gosunny2050/notebook-app.git

echo "📤 尝试推送（如果服务器支持，可能会自动创建仓库）..."
push_output=$(git push -u origin main 2>&1)
push_status=$?

if [ $push_status -eq 0 ]; then
    echo "✅ 推送成功！仓库可能已自动创建"
    echo ""
    echo "🌐 访问地址："
    echo "https://github.com/gosunny2050/notebook-app"
    echo ""
    echo "📱 GitHub Pages："
    echo "https://gosunny2050.github.io/notebook-app/"
    exit 0
else
    echo "❌ 推送失败，需要手动创建仓库"
    echo "错误信息：$push_output"
fi

echo ""
echo "🔄 方法3：使用GitHub CLI（如果可用）..."
echo ""

if which gh >/dev/null 2>&1; then
    echo "✅ 找到GitHub CLI"
    echo "🔄 使用gh创建仓库..."
    
    if gh repo create notebook-app --public --description "一个简单易用的想法记录Web应用" --push --source=. --remote=origin 2>&1; then
        echo "✅ GitHub CLI创建成功！"
        exit 0
    else
        echo "❌ GitHub CLI创建失败"
    fi
else
    echo "ℹ️ GitHub CLI未安装"
fi

echo ""
echo "="*60
echo "📝 需要手动创建GitHub仓库"
echo "="*60
echo ""
echo "由于自动创建需要GitHub Token或特殊配置，请手动创建："
echo ""
echo "1. 访问: https://github.com/new"
echo "2. 填写:"
echo "   - Repository name: notebook-app"
echo "   - Description: 一个简单易用的想法记录Web应用"
echo "   - Public (公开)"
echo "   - 不要初始化任何文件"
echo "3. 点击 'Create repository'"
echo ""
echo "创建后，运行以下命令推送代码："
echo "cd /home/notebook-app"
echo "git push -u origin main"
echo ""
echo "然后启用GitHub Pages："
echo "1. 访问仓库 Settings → Pages"
echo "2. 选择 main 分支，/ (root) 文件夹"
echo "3. 点击 Save"
echo ""
echo "🌐 访问地址：https://gosunny2050.github.io/notebook-app/"