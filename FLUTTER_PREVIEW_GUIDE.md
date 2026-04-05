# Flutter 预览功能配置指南

Flutter 提供了类似 Jetpack Compose 的声明式 UI 预览功能，让您能够实时查看 UI 效果。

## 📱 Flutter 预览方式

### 1. Flutter DevTools（推荐）

Flutter DevTools 是官方的开发工具，提供 Widget 树查看器和实时预览。

**使用方法**：
```bash
# 运行应用
flutter run

# 打开 DevTools
# 在终端会显示 DevTools 的 URL，点击打开
# 或使用命令
flutter pub global activate devtools
flutter pub global run devtools
```

**功能**：
- ✅ Widget 树查看器
- ✅ 实时属性编辑
- ✅ 布局检查
- ✅ 性能分析

### 2. IDE 内置预览（VS Code / Android Studio）

#### VS Code 配置

1. **安装 Flutter 插件**
   - 插件名称：Flutter
   - 发布者：Dart Code

2. **启用预览功能**
   ```json
   // .vscode/settings.json
   {
     "dart.previewFlutterUiGuides": true,
     "dart.previewFlutterUiGuidesCustomTracking": true
   }
   ```

3. **使用热重载**
   - 保存文件时自动热重载
   - 按 `Ctrl+S` 保存即可看到更新

#### Android Studio 配置

1. **安装 Flutter 插件**
   - Settings → Plugins → Flutter

2. **启用预览**
   - Settings → Languages & Frameworks → Flutter
   - 勾选 "Enable hot reload on save"

3. **使用 DevTools**
   - 运行应用后，点击工具栏的 Flutter Inspector

### 3. 代码预览示例

Flutter 支持在代码中创建预览 Widget，类似于 Compose 的 `@Preview`。

**示例代码**：
```dart
// 在您的 Widget 文件中添加预览代码

// 主 Widget
class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('客户管理')),
      body: const Center(child: Text('客户列表')),
    );
  }
}

// 预览 Widget（仅用于开发时预览）
class CustomerPagePreview extends StatelessWidget {
  const CustomerPagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: CustomerPage(),
    );
  }
}

// 运行预览（在终端执行）
// flutter run -t lib/pages/customer_page.dart
```

### 4. 使用 flutter_run 预览

**创建独立的预览入口**：

```dart
// lib/preview.dart
import 'package:flutter/material.dart';
import 'pages/customer_page.dart';
import 'pages/order_page.dart';
import 'pages/statistics_page.dart';

void main() {
  runApp(const PreviewApp());
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '预览',
      home: Scaffold(
        appBar: AppBar(title: const Text('UI 预览')),
        body: ListView(
          children: [
            ListTile(
              title: const Text('客户页面预览'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CustomerPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('订单页面预览'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OrderPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('统计页面预览'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StatisticsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

**运行预览**：
```bash
flutter run -t lib/preview.dart
```

## 🔥 热重载（Hot Reload）

Flutter 的热重载功能让您无需重启应用即可看到代码更改的效果。

**使用方法**：
1. 运行应用：`flutter run`
2. 修改代码
3. 按 `r`（热重载）或 `R`（热重启）
4. 或在编辑器中保存文件（如果配置了自动热重载）

**优势**：
- ⚡ 毫秒级更新
- 💾 保持应用状态
- 🎨 实时 UI 调整

## 📊 Flutter Inspector

Flutter Inspector 是查看 Widget 树的强大工具。

**打开方式**：
1. 运行应用
2. 在终端找到 DevTools URL
3. 打开浏览器访问该 URL
4. 点击 "Flutter Inspector"

**功能**：
- 🌳 Widget 树可视化
- 🎯 布局边界显示
- 📏 尺寸检查
- 🎨 样式查看

## 💡 最佳实践

### 1. 创建预览友好的 Widget

```dart
// ✅ 好的做法：使用 const 构造函数
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('Hello');
  }
}

// ✅ 便于预览和测试
```

### 2. 分离业务逻辑和 UI

```dart
// ✅ UI 层 - 易于预览
class CustomerList extends StatelessWidget {
  final List<Customer> customers;
  
  const CustomerList({super.key, required this.customers});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(customers[index].name),
        );
      },
    );
  }
}

// ✅ 数据层 - 单独测试
class CustomerRepository {
  Future<List<Customer>> getCustomers() async {
    // 业务逻辑
  }
}
```

### 3. 使用示例数据预览

```dart
// 创建示例数据用于预览
class PreviewData {
  static final List<Customer> sampleCustomers = [
    Customer(name: '张三', phone: '13800138000'),
    Customer(name: '李四', phone: '13900139000'),
    Customer(name: '王五', phone: '13700137000'),
  ];
}

// 在预览中使用
class CustomerPagePreview extends StatelessWidget {
  const CustomerPagePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomerPage(customers: PreviewData.sampleCustomers);
  }
}
```

## 🚀 快速开始

**最简单的预览方式**：

```bash
# 1. 运行应用
flutter run

# 2. 打开 DevTools（终端会显示 URL）
# 点击终端中的 DevTools 链接

# 3. 使用 Flutter Inspector 查看 Widget 树

# 4. 修改代码并保存，自动热重载
```

## 📝 与 Jetpack Compose 预览对比

| 功能 | Jetpack Compose | Flutter |
|------|----------------|---------|
| 声明式 UI | ✅ @Composable | ✅ Widget |
| 实时预览 | ✅ @Preview | ✅ DevTools + 热重载 |
| 多配置预览 | ✅ 多个@Preview | ✅ 多个预览 Widget |
| 交互预览 | ✅ 有限支持 | ✅ 完整支持 |
| 主题预览 | ✅ 支持 | ✅ 支持（Theme 包裹） |

## 🎯 推荐工作流

1. **开发时**：使用热重载实时查看 UI 变化
2. **调试时**：使用 DevTools 检查 Widget 树
3. **测试时**：创建预览 Widget 快速验证 UI
4. **优化时**：使用 Flutter Inspector 分析布局

## 📦 项目配置

确保您的 `pubspec.yaml` 包含必要的依赖：

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

## 🔗 相关资源

- [Flutter DevTools 文档](https://docs.flutter.dev/development/tools/devtools/overview)
- [Flutter Inspector](https://docs.flutter.dev/development/tools/devtools/inspector)
- [热重载文档](https://docs.flutter.dev/development/tools/hot-reload)

---

**牛马工具 - Flutter 预览配置完成**
最后更新：2026-04-05
