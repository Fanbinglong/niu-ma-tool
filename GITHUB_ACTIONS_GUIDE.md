# GitHub Actions 自动构建APK指南

## 📋 概述

本指南将帮助您使用GitHub Actions自动构建"牛马工具"Flutter应用的APK文件。GitHub Actions是GitHub提供的免费CI/CD服务，可以自动构建、测试和部署您的应用。

## 🚀 快速开始

### 步骤1：创建GitHub仓库

1. **登录GitHub** (https://github.com)
2. **创建新仓库**：
   - 仓库名称：`niu-ma-tool` (或其他名称)
   - 描述："牛马工具 - Flutter配送员本地管理工具"
   - 选择公开或私有
   - 不初始化README（项目已有文件）

3. **上传代码到GitHub**：
   ```bash
   # 在项目根目录执行
   git init
   git add .
   git commit -m "初始提交：牛马工具Flutter应用"
   git branch -M main
   git remote add origin https://github.com/你的用户名/niu-ma-tool.git
   git push -u origin main
   ```

### 步骤2：启用GitHub Actions

1. **进入仓库设置**：
   - 点击仓库顶部的"Settings"标签
   - 左侧菜单选择"Actions" → "General"
   - 确保"Allow all actions and reusable workflows"被选中

2. **查看工作流**：
   - 点击"Actions"标签
   - 您将看到自动检测到的Flutter工作流

### 步骤3：触发构建

**自动触发**：
- 每次推送到`main`或`master`分支时自动构建
- 创建Pull Request时自动构建

**手动触发**：
- 进入"Actions"标签
- 选择"Build APK"工作流
- 点击"Run workflow"按钮

## 🔧 工作流配置详解

### 构建流程

GitHub Actions将执行以下步骤：

1. **环境准备**
   - 使用Ubuntu最新版本
   - 安装Java 11
   - 安装Flutter 3.41.5（与本地环境一致）

2. **代码检查**
   - 检出代码
   - 安装依赖 (`flutter pub get`)
   - 代码分析 (`flutter analyze`)

3. **构建APK**
   - 发布版构建 (`flutter build apk --release`)
   - 生成APK文件

4. **文件发布**
   - 上传构建产物到Artifacts
   - 创建GitHub Release
   - 上传APK到Release

### 配置文件位置

工作流配置文件位于：
```
.github/workflows/build-apk.yml
```

## 📱 APK文件获取

构建完成后，您可以通过以下方式获取APK文件：

### 方式1：GitHub Artifacts（推荐）
1. 进入"Actions"标签
2. 点击最新的构建运行
3. 在"Artifacts"部分下载`niu-ma-tool-apk`
4. 文件保留30天

### 方式2：GitHub Release
1. 进入仓库的"Releases"页面
2. 下载最新版本的APK文件
3. 文件永久保存

### 方式3：直接链接
构建成功后，APK文件位于：
```
https://github.com/你的用户名/niu-ma-tool/releases/latest/download/niu-ma-tool-v{版本号}.apk
```

## ⚙️ 自定义配置

### 修改Flutter版本

在`.github/workflows/build-apk.yml`中修改：
```yaml
env:
  FLUTTER_VERSION: '3.41.5'  # 改为您需要的版本
```

### 添加构建参数

可以添加额外的构建参数：
```yaml
- name: Build APK with parameters
  run: |
    flutter build apk --release \
      --build-name=1.0.0 \
      --build-number=${{ github.run_number }}
```

### 添加测试步骤

在构建前添加测试：
```yaml
- name: Run tests
  run: flutter test
```

## 🔒 安全配置

### 高德地图API Key保护

为了保护您的API Key，请使用GitHub Secrets：

1. **进入仓库设置** → "Secrets and variables" → "Actions"
2. **点击"New repository secret"**
3. **添加以下Secrets**：
   - `AMAP_API_KEY`: `ac67cb6f3eb549c90e3ea9e6f5a97962`

4. **修改工作流使用Secrets**：
```yaml
- name: Replace API Keys
  run: |
    sed -i 's/ac67cb6f3eb549c90e3ea9e6f5a97962/${{ secrets.AMAP_API_KEY }}/g' android/app/src/main/AndroidManifest.xml
    sed -i 's/ac67cb6f3eb549c90e3ea9e6f5a97962/${{ secrets.AMAP_API_KEY }}/g' lib/pages/customer_detail_page.dart
```

## 🐛 常见问题解决

### 构建失败排查

1. **检查日志**：查看GitHub Actions的详细构建日志
2. **依赖问题**：确保`pubspec.yaml`中的依赖版本兼容
3. **权限问题**：检查Android权限配置

### 网络问题

如果遇到网络超时：
- GitHub Actions使用国际网络，高德地图服务应该可以正常访问
- 如果仍有问题，可以配置代理或使用镜像源

### 构建时间优化

- 使用缓存加速构建：
```yaml
- name: Cache Flutter dependencies
  uses: actions/cache@v3
  with:
    path: /home/runner/.pub-cache
    key: ${{ runner.os }}-flutter-${{ hashFiles('**/pubspec.lock') }}
    restore-keys: |
      ${{ runner.os }}-flutter-
```

## 📊 构建状态监控

### 状态徽章

在README中添加构建状态徽章：
```markdown
![Build Status](https://github.com/你的用户名/niu-ma-tool/actions/workflows/build-apk.yml/badge.svg)
```

### 通知设置

1. **邮件通知**：GitHub默认发送构建结果邮件
2. **Slack/Discord集成**：可以配置Webhook通知
3. **移动端通知**：通过GitHub Mobile应用接收通知

## 🎯 最佳实践

### 分支策略

- `main`分支：稳定版本，自动构建发布版APK
- `develop`分支：开发版本，构建测试版APK
- 功能分支：不自动构建，手动触发测试

### 版本管理

- 使用语义化版本号：`1.0.0`
- 构建号使用GitHub运行号：`v123`
- 在APK文件名中包含版本信息

### 安全建议

- 定期更新Flutter版本
- 监控依赖安全漏洞
- 使用代码扫描工具
- 保护敏感信息（API Keys）

## 📞 技术支持

如果遇到问题：

1. **查看GitHub Actions文档**：https://docs.github.com/actions
2. **Flutter构建问题**：查看Flutter官方文档
3. **创建Issue**：在GitHub仓库中报告问题

## ✅ 成功标志

当您看到以下标志时，表示配置成功：

- ✅ GitHub Actions工作流运行成功（绿色对勾）
- ✅ APK文件可在Artifacts中下载
- ✅ Release页面包含最新APK版本
- ✅ 应用可以正常安装和使用

---

**恭喜！** 您现在拥有了一个完整的自动化构建流水线，每次代码更新都会自动生成最新的APK文件。