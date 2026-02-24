#!/bin/bash

echo "🚀 最终尝试：使用GitHub Token创建仓库"
echo "======================================"

# 读取Token
if [ ! -f /root/.github_token ]; then
    echo "❌ 未找到GitHub Token"
    exit 1
fi

GITHUB_TOKEN=$(cat /root/.github_token)
echo "🔑 Token已加载（前10位）：${GITHUB_TOKEN:0:10}..."

# 方法1：尝试REST API（标准方法）
echo ""
echo "🔄 方法1：尝试REST API..."
response=$(curl -s -w "%{http_code}" -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user/repos \
  -d '{"name":"notebook-app","description":"一个简单易用的想法记录Web应用","private":false,"auto_init":false}' 2>/dev/null)

http_code=${response: -3}
response_body=${response:0:${#response}-3}

if [ "$http_code" = "201" ]; then
    echo "✅ REST API创建成功！"
    repo_name=$(echo "$response_body" | grep -o '"name":"[^"]*"' | head -1 | cut -d'"' -f4)
    ssh_url=$(echo "$response_body" | grep -o '"ssh_url":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "📦 仓库: $repo_name"
    echo "🔑 SSH URL: $ssh_url"
    
    # 立即推送代码
    echo ""
    echo "📤 推送代码到新仓库..."
    cd /home/notebook-app
    if git push -u origin main 2>&1; then
        echo "✅ 代码推送成功！"
        echo ""
        echo "🎉 完成！接下来："
        echo "1. 访问 https://github.com/gosunny2050/notebook-app/settings/pages"
        echo "2. 启用GitHub Pages"
        echo "3. 访问 https://gosunny2050.github.io/notebook-app/"
        exit 0
    else
        echo "❌ 推送失败，但仓库已创建"
        exit 1
    fi
else
    echo "❌ REST API失败 (HTTP $http_code)"
    error_msg=$(echo "$response_body" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "未知错误")
    echo "错误: $error_msg"
fi

# 方法2：尝试检查Token权限并给出建议
echo ""
echo "🔄 方法2：检查Token权限..."
user_info=$(curl -s -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user 2>/dev/null)
if echo "$user_info" | grep -q '"login"'; then
    username=$(echo "$user_info" | grep -o '"login":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "✅ Token有效，用户: $username"
    
    # 检查Token的scopes
    echo "🔍 检查Token权限范围..."
    # 通过尝试不同端点来推断权限
    can_read_repo=$(curl -s -o /dev/null -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
      https://api.github.com/repos/gosunny2050/calculator 2>/dev/null)
    
    if [ "$can_read_repo" = "200" ] || [ "$can_read_repo" = "404" ]; then
        echo "✅ Token有读取仓库权限"
    else
        echo "❌ Token可能没有仓库权限"
    fi
else
    echo "❌ Token无效"
fi

# 方法3：如果API都失败，使用备用方案
echo ""
echo "🔄 方法3：使用备用方案..."
echo ""
echo "📝 Token可能缺少 'repo' 权限。建议："
echo ""
echo "方案A：更新Token权限"
echo "----------------------------------------"
echo "1. 访问 https://github.com/settings/tokens"
echo "2. 找到当前Token，点击编辑"
echo "3. 确保选中 'repo' 权限"
echo "4. 保存并更新Token"
echo ""
echo "方案B：创建新Token"
echo "----------------------------------------"
echo "1. 访问 https://github.com/settings/tokens/new"
echo "2. 填写 Note: notebook-app-deploy"
echo "3. 选择权限:"
echo "   - ✅ repo (全部)"
echo "   - ✅ workflow (可选)"
echo "4. 生成Token并保存"
echo "5. 更新 /root/.github_token 文件"
echo ""
echo "方案C：手动创建仓库（最简单）"
echo "----------------------------------------"
echo "1. 访问 https://github.com/new?name=notebook-app&description=一个简单易用的想法记录Web应用"
echo "2. 点击创建（不要初始化文件）"
echo "3. 然后运行: cd /home/notebook-app && git push -u origin main"
echo ""
echo "🎯 推荐方案C，只需点击一次链接！"

exit 1