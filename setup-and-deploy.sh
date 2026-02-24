#!/bin/bash

echo "🎯 想法记录本 - 完整部署脚本"
echo "=============================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函数：打印带颜色的消息
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查目录
if [ ! -f "index.html" ]; then
    print_error "请在项目根目录运行此脚本"
    exit 1
fi

print_info "步骤1：检查Git配置"
echo "----------------------------------------"

# 检查Git配置
USERNAME=$(git config --global user.name 2>/dev/null || echo "未设置")
EMAIL=$(git config --global user.email 2>/dev/null || echo "未设置")

echo "Git用户: $USERNAME"
echo "Git邮箱: $EMAIL"

if [ "$USERNAME" = "未设置" ] || [ "$EMAIL" = "未设置" ]; then
    print_warning "Git用户信息未完整配置"
    read -p "是否配置Git用户信息？(y/n): " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "请输入Git用户名: " git_user
        read -p "请输入Git邮箱: " git_email
        git config --global user.name "$git_user"
        git config --global user.email "$git_email"
        print_success "Git用户信息已配置"
    fi
fi

print_info "步骤2：检查SSH认证"
echo "----------------------------------------"

# 测试SSH连接
ssh_test=$(ssh -T git@github.com 2>&1)
if echo "$ssh_test" | grep -q "successfully authenticated"; then
    print_success "SSH认证成功"
    echo "认证信息: $(echo "$ssh_test" | head -1)"
else
    print_error "SSH认证失败"
    echo "错误信息: $ssh_test"
    echo ""
    print_warning "请确保："
    echo "1. SSH密钥已生成：ssh-keygen -t ed25519 -C \"your_email@example.com\""
    echo "2. 公钥已添加到GitHub：cat ~/.ssh/id_ed25519.pub"
    echo "3. 测试连接：ssh -T git@github.com"
    exit 1
fi

print_info "步骤3：检查Git状态"
echo "----------------------------------------"

git status --short

print_info "步骤4：创建GitHub仓库"
echo "----------------------------------------"

echo "由于GitHub API需要Token认证，需要手动创建仓库"
echo ""
echo "📝 请按照以下步骤操作："
echo ""
echo "1. 打开浏览器，访问："
echo "   ${BLUE}https://github.com/new${NC}"
echo ""
echo "2. 填写仓库信息："
echo "   - ${YELLOW}Repository name${NC}: notebook-app"
echo "   - ${YELLOW}Description${NC}: 一个简单易用的想法记录Web应用"
echo "   - ${YELLOW}Visibility${NC}: Public (公开)"
echo "   - ${RED}重要${NC}: 不要初始化README、.gitignore、许可证"
echo ""
echo "3. 点击 'Create repository'"
echo ""
echo "4. 创建后，复制SSH地址："
echo "   ${BLUE}git@github.com:gosunny2050/notebook-app.git${NC}"
echo ""

read -p "是否已完成仓库创建？(y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "请先创建GitHub仓库，然后重新运行此脚本"
    exit 0
fi

print_info "步骤5：验证远程仓库"
echo "----------------------------------------"

# 检查远程仓库
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -n "$REMOTE_URL" ]; then
    echo "当前远程仓库: $REMOTE_URL"
    read -p "是否使用此远程仓库？(y/n): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        read -p "请输入新的远程仓库URL: " new_url
        git remote set-url origin "$new_url"
        print_success "远程仓库已更新"
    fi
else
    git remote add origin git@github.com:gosunny2050/notebook-app.git
    print_success "远程仓库已添加"
fi

print_info "步骤6：推送代码到GitHub"
echo "----------------------------------------"

echo "准备推送代码..."
echo ""

# 显示将要推送的内容
echo "📊 提交记录："
git log --oneline -5

echo ""
read -p "是否推送代码到GitHub？(y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "推送已取消"
    exit 0
fi

echo "📤 推送代码中..."
if git push -u origin main; then
    print_success "代码推送成功！"
else
    print_error "推送失败"
    echo "可能原因："
    echo "1. 仓库URL不正确"
    echo "2. 网络问题"
    echo "3. 权限问题"
    echo ""
    echo "请检查："
    echo "1. 仓库URL：git remote -v"
    echo "2. 网络连接"
    echo "3. SSH密钥权限"
    exit 1
fi

print_info "步骤7：启用GitHub Pages"
echo "----------------------------------------"

echo "🎨 接下来需要启用GitHub Pages："
echo ""
echo "1. 访问仓库页面："
echo "   ${BLUE}https://github.com/gosunny2050/notebook-app${NC}"
echo ""
echo "2. 点击 'Settings' → 'Pages'"
echo ""
echo "3. 配置："
echo "   - ${YELLOW}Source${NC}: Deploy from a branch"
echo "   - ${YELLOW}Branch${NC}: main"
echo "   - ${YELLOW}Folder${NC}: / (root)"
echo ""
echo "4. 点击 'Save'"
echo ""
echo "5. 等待1-2分钟部署完成"
echo ""

print_success "🎉 部署流程完成！"
echo ""
echo "🌐 访问地址："
echo "   ${BLUE}https://gosunny2050.github.io/notebook-app/${NC}"
echo ""
echo "📱 本地测试："
echo "   直接打开：file://$(pwd)/index.html"
echo "   或使用：python3 -m http.server 8000"
echo ""
echo "🔧 后续维护："
echo "   修改代码后，运行：./deploy.sh"
echo ""
echo "📝 项目文档："
echo "   查看 README.md 获取详细使用说明"