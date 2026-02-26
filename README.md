# 想法记录本

一个简单易用的想法记录Web应用，让你随时记录灵感，随时查看想法。

## 🚀 快速开始

### 本地使用（最简单）
```bash
# 直接在浏览器中打开
open index.html
# 或双击 index.html 文件
```

### 在线访问
- **GitHub Pages**: https://gosunny2050.github.io/notebook-app/（部署后）
- **本地服务器**: http://localhost:8000（使用 `python3 -m http.server 8000`）

## ✨ 功能特性

### 核心功能
- 📝 **快速记录**：随时记录你的想法和灵感
- ✏️ **编辑功能**：随时修改和更新现有想法
- 🔍 **智能搜索**：通过标题、内容或标签搜索想法
- 🏷️ **标签分类**：为想法添加标签，方便分类管理
- 🌙 **暗色模式**：支持浅色/暗色主题切换，保护眼睛
- 📱 **响应式设计**：在手机、平板和电脑上都能完美使用

### 数据管理
- 💾 **本地存储**：使用浏览器localStorage保存数据，无需服务器
- 📤 **数据导出**：导出所有想法为JSON文件备份
- 📥 **数据导入**：从JSON文件恢复或合并想法
- 🔄 **自动保存**：每次操作自动保存到本地存储

### 用户体验
- 🎨 **美观界面**：现代化的UI设计，舒适的视觉体验
- ⚡ **快速保存**：支持 Ctrl+Enter 快捷键保存
- 🔔 **即时反馈**：操作成功/失败提示
- 🛡️ **安全防护**：输入转义防止XSS攻击

## 📖 使用方法

### 1. 添加想法
1. 在"添加新想法"区域填写：
   - **标题**（可选）
   - **内容**（必填）
   - **标签**（用逗号分隔，可选）
2. 点击"保存想法"按钮或按 **Ctrl+Enter**

### 2. 查看想法
- 所有想法按时间倒序显示
- 使用搜索框查找特定想法
- 使用标签过滤器按分类查看
- 显示想法总数统计

### 3. 管理想法
- 点击删除按钮移除单个想法
- 点击"清空所有记录"清空所有数据
- 所有操作都有确认提示

## 🛠️ 部署到GitHub Pages

### 步骤1：创建GitHub仓库
1. 访问 https://github.com/new
2. 创建名为 `notebook-app` 的仓库
3. **不要**初始化README、.gitignore或许可证

### 步骤2：推送代码
```bash
# 添加远程仓库
git remote add origin git@github.com:gosunny2050/notebook-app.git

# 推送代码
git push -u origin main
```

### 步骤3：启用GitHub Pages
1. 进入仓库 Settings → Pages
2. Source 选择 "Deploy from a branch"
3. Branch 选择 "main"，Folder 选择 "/ (root)"
4. 点击 Save

### 步骤4：等待部署
1-2分钟后访问：https://gosunny2050.github.io/notebook-app/

## 🗂️ 项目结构
```
notebook-app/
├── index.html          # 主应用页面
├── style.css          # 样式文件
├── script.js          # 核心逻辑
├── README.md          # 说明文档
├── test.html          # 功能测试页面
├── deploy.sh          # 一键部署脚本
├── push-to-github.sh  # GitHub推送脚本
└── PROJECT_SUMMARY.md # 详细项目总结
```

## 🔧 技术栈

- **HTML5** - 现代Web标准
- **CSS3** - Flexbox/Grid布局，响应式设计，CSS动画
- **JavaScript (ES6+)** - 面向对象编程，localStorage API
- **Font Awesome** - 图标库
- **Git** - 版本控制
- **GitHub Pages** - 静态网站托管

## 📱 浏览器兼容性

- Chrome 60+
- Firefox 55+
- Safari 11+
- Edge 79+
- 移动端浏览器

## 🔒 数据安全

- 所有数据存储在浏览器localStorage中
- 输入内容自动转义，防止XSS攻击
- 删除操作需要二次确认
- 数据不会上传到任何服务器

## 🚨 注意事项

1. **数据备份**：定期导出重要想法
2. **浏览器限制**：不同浏览器localStorage限制不同
3. **隐私模式**：隐私浏览模式下数据可能不持久
4. **存储空间**：localStorage通常有5-10MB限制

## 🤝 贡献

欢迎提交Issue和Pull Request！

## 📄 许可证

MIT License