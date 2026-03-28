# GitHub上传指南 - 牛马工具

## 📋 概述

本指南将帮助您将"牛马工具"Flutter应用上传到GitHub仓库，并启用自动构建功能。

## 🚀 快速开始

### 方法1：使用批处理脚本（推荐）

**最简单的方法**：双击运行 `upload_to_github.bat` 文件

### 方法2：使用PowerShell脚本

1. **以管理员身份运行PowerShell**
2. **执行脚本**：
   ```powershell
   .\upload_to_github.ps1
   ```

### 方法3：手动执行命令

如果您更喜欢手动操作，可以按照以下步骤执行：

## 📝 手动上传步骤

### 步骤1：创建GitHub仓库

1. **访问GitHub**：https://github.com/new
2. **填写仓库信息**：
   - Repository name: `niu-ma-tool`（或其他名称）
   - Description: "牛马工具 - Flutter配送员本地管理工具"
   - Public 或 Private（根据需求选择）
   - **重要**：不要勾选"Add a README file"、"Add .gitignore"、"Choose a license"
3. **创建仓库**：点击"Create repository"

### 步骤2：初始化Git仓库

在项目根目录执行：

```bash
# 初始化Git仓库
git init

# 添加所有文件
git add .

# 创建初始提交
git commit -m "Initial commit: Niu Ma Tool - Flutter delivery management app"
```

### 步骤3：连接到GitHub仓库

```bash
# 添加远程仓库（替换为您的实际URL）
git remote add origin https://github.com/您的用户名/niu-ma-tool.git

# 重命名主分支
git branch -M main

# 推送到GitHub
git push -u origin main
```

## 🔧 脚本功能说明

### upload_to_github.bat（批处理版本）

**功能**：
- 检查Git安装状态
- 初始化Git仓库
- 添加所有文件到暂存区
- 创建初始提交
- 配置GitHub远程仓库
- 推送代码到GitHub

**使用方法**：双击运行或命令行执行

### upload_to_github.ps1（PowerShell版本）

**功能**：与批处理版本相同，但使用PowerShell语法

**优势**：更好的错误处理和颜色显示

## 📱 上传后的自动构建

### GitHub Actions自动构建

上传成功后，GitHub Actions将自动：

1. **检测代码推送**：每次推送到main分支时自动构建
2. **构建APK**：使用Flutter环境构建发布版APK
3. **创建Release**：自动生成GitHub Release
4. **上传APK**：将APK文件上传到Release页面

### APK文件获取

构建完成后，您可以通过以下方式获取APK：

1. **GitHub Releases页面**：
   ```
   https://github.com/您的用户名/niu-ma-tool/releases
   ```

2. **直接下载链接**：
   ```
   https://github.com/您的用户名/niu-ma-tool/releases/latest/download/niu-ma-tool-v{版本号}.apk
   ```

## 🐛 常见问题解决

### 问题1：Git未安装

**症状**：脚本提示"Git is not installed"

**解决方案**：
1. 下载并安装Git：https://git-scm.com/downloads
2. 安装时选择"Add to PATH"选项
3. 重启命令行工具

### 问题2：权限错误

**症状**：推送时出现权限错误

**解决方案**：
1. 确保GitHub仓库存在且您有写入权限
2. 检查GitHub URL是否正确
3. 如果需要，配置SSH密钥或使用Personal Access Token

### 问题3：网络连接问题

**症状**：推送超时或失败

**解决方案**：
1. 检查网络连接
2. 尝试使用SSH代替HTTPS
3. 配置Git代理（如果需要）

## ⚙️ 高级配置

### 使用SSH密钥（可选）

如果您希望使用SSH连接GitHub：

1. **生成SSH密钥**：
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. **添加公钥到GitHub**：
   - 复制 `~/.ssh/id_ed25519.pub` 内容
   - 添加到GitHub Settings → SSH and GPG keys

3. **修改远程URL**：
   ```bash
   git remote set-url origin git@github.com:您的用户名/niu-ma-tool.git
   ```

### 配置Git用户信息

如果首次使用Git，请配置用户信息：

```bash
git config --global user.name "您的姓名"
git config --global user.email "您的邮箱"
```

## 📊 上传状态监控

### 检查上传状态

上传完成后，您可以：

1. **查看GitHub仓库**：确认所有文件已上传
2. **检查Actions标签**：查看构建状态
3. **查看Releases页面**：下载APK文件

### 构建状态徽章

在README中添加构建状态徽章：

```markdown
![Build Status](https://github.com/您的用户名/niu-ma-tool/actions/workflows/build-apk.yml/badge.svg)
```

## 🔄 后续更新

### 推送代码更新

当您修改代码后，使用以下命令更新GitHub：

```bash
# 添加修改的文件
git add .

# 创建提交
git commit -m "描述您的修改"

# 推送到GitHub
git push origin main
```

### 自动构建触发

每次推送后，GitHub Actions将自动：
- 构建新的APK版本
- 更新Release页面
- 保留构建历史记录

## 🎯 成功标志

当您看到以下标志时，表示上传成功：

- ✅ 脚本显示"SUCCESS: Project uploaded to GitHub!"
- ✅ GitHub仓库显示所有项目文件
- ✅ GitHub Actions开始自动构建
- ✅ Releases页面出现APK下载链接

## 📞 技术支持

如果遇到问题：

1. **查看Git文档**：https://git-scm.com/doc
2. **查看GitHub文档**：https://docs.github.com
3. **检查脚本错误信息**：根据具体错误信息搜索解决方案

---

**恭喜！** 您现在拥有了一个完整的自动化构建流水线，每次代码更新都会自动生成最新的APK文件。