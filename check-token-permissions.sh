#!/bin/bash

echo "🔍 检查GitHub Token权限"
echo "======================"

if [ ! -f /root/.github_token ]; then
    echo "❌ 未找到Token文件"
    exit 1
fi

GITHUB_TOKEN=$(cat /root/.github_token)
echo "🔑 Token: ${GITHUB_TOKEN:0:15}..."

# 检查Token基本信息
echo ""
echo "📊 检查Token基本信息..."
user_response=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user 2>/dev/null)

if echo "$user_response" | grep -q '"login"'; then
    username=$(echo "$user_response" | grep -o '"login":"[^"]*"' | cut -d'"' -f4)
    echo "✅ Token有效，用户: $username"
else
    echo "❌ Token无效或已过期"
    exit 1
fi

# 检查仓库创建权限
echo ""
echo "🔄 检查仓库创建权限..."
test_response=$(curl -s -w "%{http_code}" -X POST \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/user/repos \
  -d '{"name":"test-repo-permission-check","description":"测试权限","private":false,"auto_init":false}' 2>/dev/null)

http_code=${test_response: -3}

if [ "$http_code" = "201" ]; then
    echo "✅ 有仓库创建权限"
    # 删除测试仓库
    echo "🧹 清理测试仓库..."
    curl -s -X DELETE -H "Authorization: token $GITHUB_TOKEN" \
      https://api.github.com/repos/$username/test-repo-permission-check >/dev/null 2>&1
elif [ "$http_code" = "403" ]; then
    echo "❌ 没有仓库创建权限"
    echo "错误信息:"
    echo "${test_response:0:${#test_response}-3}" | grep -o '"message":"[^"]*"' | cut -d'"' -f4
else
    echo "⚠️  未知权限状态 (HTTP $http_code)"
fi

# 检查现有仓库访问权限
echo ""
echo "🔍 检查现有仓库访问权限..."
repo_response=$(curl -s -w "%{http_code}" -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/gosunny2050/calculator 2>/dev/null)

repo_http_code=${repo_response: -3}
if [ "$repo_http_code" = "200" ]; then
    echo "✅ 可以访问现有仓库"
elif [ "$repo_http_code" = "404" ]; then
    echo "⚠️  仓库不存在或无法访问"
else
    echo "❌ 仓库访问被拒绝 (HTTP $repo_http_code)"
fi

# 总结
echo ""
echo "📋 权限总结："
echo "----------------------------------------"
echo "用户认证: ✅ $username"
echo "仓库创建: $( [ "$http_code" = "201" ] && echo "✅ 有权限" || echo "❌ 无权限" )"
echo "仓库访问: $( [ "$repo_http_code" = "200" ] && echo "✅ 有权限" || echo "⚠️  受限" )"
echo ""
echo "🔧 建议："
if [ "$http_code" = "201" ]; then
    echo "✅ Token权限足够，可以自动创建仓库"
else
    echo "📝 需要更新Token权限："
    echo "1. 访问 https://github.com/settings/tokens"
    echo "2. 确保Token有 'repo' 或 'public_repo' 权限"
    echo "3. 或者创建新Token"
fi