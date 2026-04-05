import 'package:flutter/material.dart';
import 'pages/customer_page.dart';
import 'pages/order_page.dart';
import 'pages/statistics_page.dart';

/// Flutter 预览应用入口
/// 类似 Jetpack Compose 的 @Preview 功能
/// 
/// 运行方式：
/// ```bash
/// flutter run -t lib/preview.dart
/// ```
void main() {
  runApp(const PreviewApp());
}

/// 预览应用主界面
class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '牛马工具 - UI 预览',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PreviewScreen(),
    );
  }
}

/// 预览选择界面
class PreviewScreen extends StatelessWidget {
  const PreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔍 UI 预览'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPreviewCard(
            context,
            title: '客户管理页面',
            description: '预览客户列表和客户管理功能',
            icon: Icons.people,
            color: Colors.blue,
            page: const CustomerPage(),
          ),
          const SizedBox(height: 16),
          _buildPreviewCard(
            context,
            title: '订单管理页面',
            description: '预览订单列表和订单管理功能',
            icon: Icons.receipt_long,
            color: Colors.green,
            page: const OrderPage(),
          ),
          const SizedBox(height: 16),
          _buildPreviewCard(
            context,
            title: '数据统计页面',
            description: '预览统计图表和数据分析',
            icon: Icons.bar_chart,
            color: Colors.orange,
            page: const StatisticsPage(),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  '预览说明',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '• 点击卡片预览对应页面\n'
              '• 使用热重载实时更新 (按 r 键)\n'
              '• 使用 DevTools 检查 Widget 树\n'
              '• 按返回键回到预览菜单',
              style: TextStyle(fontSize: 14, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
