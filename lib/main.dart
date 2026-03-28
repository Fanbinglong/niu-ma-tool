import 'package:flutter/material.dart';
import 'pages/customer_page.dart';
import 'pages/order_page.dart';
import 'pages/statistics_page.dart';

void main() {
  runApp(const NiuMaTool());
}

class NiuMaTool extends StatelessWidget {
  const NiuMaTool({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '牛马工具',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    CustomerPage(),
    OrderPage(),
    StatisticsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('牛马工具'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '客户管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: '订单管理',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '数据统计',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}