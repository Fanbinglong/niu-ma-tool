# 牛马工具 - Flutter配送员本地管理工具

## 项目介绍

**牛马工具**是一款专为配送员打造的**本地离线Flutter工具**，聚焦配送场景核心需求，集成客户管理、订单管理、数据统计三大核心模块。无需联网、数据本地存储，帮助配送员高效管理日常配送任务，支持客户分类、智能排序、路线调整、数据可视化等实用功能。

---

## 核心功能

### 1. 客户管理模块
- 支持客户分类的**创建/重命名/删除**
- 客户信息**新增/编辑**全功能管理
- 三种配送地址录入方式：**当前定位获取、地图选点、手动输入**
- 快捷操作：**一键添加今日配送任务**

### 2. 订单管理模块
- 订单按日期**折叠展示**，查看更清晰
- 智能排序：**按当前位置距离排序**
- 路线规划：**按配送路线排序**，支持**手动拖拽调整**顺序

### 3. 数据统计模块
- 可视化图表：**近30日配送量柱状图**
- 明细数据：**配送记录表格化展示**
- 全维度统计日常配送数据

---

## 技术栈

| 分类 | 技术/依赖 | 用途 |
|------|-----------|------|
| 开发框架 | Flutter | 跨平台应用开发 |
| 开发语言 | Dart | Flutter 官方编程语言 |
| 本地存储 | sqflite (SQLite) | 本地数据持久化存储 |
| 定位服务 | geolocator | 获取设备实时地理位置 |
| 地图组件 | amap_flutter_map | 高德地图展示与选点功能 |
| 图表组件 | fl_chart | 配送数据柱状图绘制 |

---

## 项目结构

```
牛马工具/
├─ lib/                     # 核心代码目录
│  ├─ main.dart             # 应用入口文件
│  ├─ pages/                # 页面组件
│  │  ├─ customer_page.dart       # 客户管理主页面
│  │  ├─ customer_detail_page.dart # 客户详情页面
│  │  ├─ order_page.dart          # 订单管理页面
│  │  └─ statistics_page.dart      # 数据统计页面
│  └─ utils/                  # 工具类
│     └─ database_helper.dart  # SQLite数据库操作工具
├─ android/                  # Android平台配置文件
├─ pubspec.yaml              # 项目依赖配置文件
└─ README.md                 # 项目说明文档
```

---

## 运行与打包指南

### 一、环境准备
1. 安装Flutter开发环境
2. 启动安卓模拟器 / 连接安卓真机
3. 开启设备**USB调试模式**

### 二、运行项目
```bash
# 1. 克隆项目到本地
git clone [项目地址]

# 2. 安装项目依赖
flutter pub get

# 3. 运行项目
flutter run
```

### 三、打包APK（发布版）

#### 方法1：本地构建
```bash
# 执行打包命令
flutter build apk

# 打包后APK文件路径
build/app/outputs/flutter-apk/app-release.apk
```

#### 方法2：GitHub Actions自动构建（推荐）
项目已配置GitHub Actions自动构建流水线：

1. **推送代码到GitHub仓库**
2. **GitHub Actions自动构建APK**
3. **在Releases页面下载APK文件**

详细指南请查看：[GITHUB_ACTIONS_GUIDE.md](GITHUB_ACTIONS_GUIDE.md)

---

## 重要说明

1. **权限要求**：应用需要获取**定位权限**才能使用定位、地图选点、距离排序功能
2. **网络要求**：仅**地图选点**需要网络，其余所有功能（客户/订单/统计/存储）均支持**纯离线使用**
3. **数据安全**：所有数据存储在本地SQLite数据库，无云端上传，隐私安全
4. **关联删除**：删除客户时，会**自动删除该客户关联的所有订单数据**，操作前请确认

---

## 配置说明

### 高德地图API Key配置

#### 开发版配置
1. 在 `android/app/src/main/AndroidManifest.xml` 中替换 `YOUR_AMAP_API_KEY_HERE`
2. 在 `lib/pages/customer_detail_page.dart` 中替换 `YOUR_AMAP_API_KEY_HERE`

#### 发布版安全配置
高德地图需要配置发布版安全码以确保应用安全：

**PackageName**: `com.example.niu_ma_tool`

**SHA1安全码获取步骤**:
1. **生成发布密钥库**:
   ```bash
   keytool -genkey -v -keystore niu_ma_tool.jks -keyalg RSA -keysize 2048 -validity 10000 -alias niu_ma_tool
   ```

2. **查看SHA1指纹**:
   ```bash
   keytool -list -v -keystore niu_ma_tool.jks -alias niu_ma_tool
   ```

3. **高德平台配置**:
   - 访问 [高德开放平台](https://lbs.amap.com/)
   - 创建应用 → Android平台
   - PackageName: `com.example.niu_ma_tool`
   - SHA1: 填写生成的发布版SHA1安全码
   - 获取发布版API Key

**重要**: 发布版和调试版需要分别配置不同的API Key

### 权限配置
应用需要以下权限：
- `INTERNET` - 地图选点功能
- `ACCESS_FINE_LOCATION` - 精确定位
- `ACCESS_COARSE_LOCATION` - 粗略定位
- `ACCESS_NETWORK_STATE` - 网络状态检测
- `ACCESS_WIFI_STATE` - WiFi状态检测
- `CHANGE_WIFI_STATE` - WiFi状态修改
- `WRITE_EXTERNAL_STORAGE` - 外部存储写入
- `READ_EXTERNAL_STORAGE` - 外部存储读取

---

## 总结

1. 这是一款**离线优先、轻量高效**的配送员专用Flutter工具，核心解决配送场景的客户、订单、统计管理需求
2. 技术栈基于Flutter+SQLite，实现跨平台、本地数据持久化，搭配定位、地图、拖拽等实用能力
3. 操作简单、部署便捷，打包后可直接在安卓设备安装使用，完全适配配送员日常工作场景