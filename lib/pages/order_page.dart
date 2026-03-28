import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:niu_ma_tool/utils/database_helper.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, List<Map<String, dynamic>>> _groupedOrders = {};
  List<String> _expandedDates = [];

  Position? _currentPosition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _getCurrentLocation();
  }

  Future<void> _loadOrders() async {
    final orders = await _dbHelper
        .getOrdersByDate(DateTime.now().toIso8601String().split('T')[0]);

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var order in orders) {
      final date = order['delivery_date'];
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }

      final customer = await _dbHelper.getCustomer(order['customer_id']);
      if (customer != null) {
        grouped[date]!.add({
          ...order,
          'customer': customer,
        });
      }
    }

    setState(() {
      _groupedOrders = grouped;
      if (_groupedOrders.isNotEmpty && _expandedDates.isEmpty) {
        _expandedDates = [DateTime.now().toIso8601String().split('T')[0]];
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('获取位置失败: $e');
    }
  }

  Future<void> _sortByDistance() async {
    if (_currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法获取当前位置，请检查定位权限')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      for (var date in _groupedOrders.keys) {
        final orders = _groupedOrders[date]!;

        final ordersWithDistance = await Future.wait(orders.map((order) async {
          final customer = order['customer'];
          if (customer['latitude'] != null && customer['longitude'] != null) {
            final distance = await Geolocator.distanceBetween(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
              customer['latitude'],
              customer['longitude'],
            );
            return {...order, 'distance': distance};
          }
          return {...order, 'distance': double.infinity};
        }));

        ordersWithDistance.sort((a, b) =>
            (a['distance'] as double).compareTo(b['distance'] as double));

        for (int i = 0; i < ordersWithDistance.length; i++) {
          await _dbHelper.updateOrderSortOrder(ordersWithDistance[i]['id'], i);
        }
      }

      await _loadOrders();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已按距离排序')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('排序失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sortByRoute() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('按路线排序功能开发中')),
    );
  }

  void _toggleDateExpansion(String date) {
    setState(() {
      if (_expandedDates.contains(date)) {
        _expandedDates.remove(date);
      } else {
        _expandedDates.add(date);
      }
    });
  }

  // Note: Drag and drop reordering functionality has been replaced with swipe actions
  // for better mobile usability. Orders can be swiped left to delete or right to mark as delivered.

  void _showDeleteOrderDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除订单'),
        content: Text('确定要删除"${order['customer']['name']}"的配送订单吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteOrder(order['id']);
              Navigator.pop(context);
              _loadOrders();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _markAsDelivered(Map<String, dynamic> order) async {
    await _dbHelper.insertDeliveryRecord({
      'customer_id': order['customer_id'],
      'delivery_date': order['delivery_date'],
    });

    await _dbHelper.deleteOrder(order['id']);
    _loadOrders();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('标记为已送达')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Sorting Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.near_me),
                    label: const Text('按距离排序'),
                    onPressed: _isLoading ? null : _sortByDistance,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.route),
                    label: const Text('按路线排序'),
                    onPressed: _sortByRoute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _groupedOrders.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list_alt, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('暂无配送订单',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _groupedOrders.keys.length,
                        itemBuilder: (context, index) {
                          final date = _groupedOrders.keys.elementAt(index);
                          final orders = _groupedOrders[date]!;
                          final isExpanded = _expandedDates.contains(date);

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Column(
                              children: [
                                // Date Header
                                ListTile(
                                  leading: const Icon(Icons.calendar_today),
                                  title: Text(
                                    _formatDate(date),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Icon(
                                    isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                  onTap: () => _toggleDateExpansion(date),
                                ),

                                // Orders List (Collapsible)
                                if (isExpanded)
                                  Column(
                                    children: orders.map((order) {
                                      return Dismissible(
                                        key: Key(order['id'].toString()),
                                        direction: DismissDirection.horizontal,
                                        background: Container(
                                          color: Colors.red,
                                          alignment: Alignment.centerRight,
                                          padding:
                                              const EdgeInsets.only(right: 20),
                                          child: const Icon(Icons.delete,
                                              color: Colors.white),
                                        ),
                                        secondaryBackground: Container(
                                          color: Colors.green,
                                          alignment: Alignment.centerLeft,
                                          padding:
                                              const EdgeInsets.only(left: 20),
                                          child: const Icon(Icons.check,
                                              color: Colors.white),
                                        ),
                                        onDismissed: (direction) {
                                          if (direction ==
                                              DismissDirection.endToStart) {
                                            _showDeleteOrderDialog(order);
                                          } else if (direction ==
                                              DismissDirection.startToEnd) {
                                            _markAsDelivered(order);
                                          }
                                        },
                                        child: _buildOrderItem(order),
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final customer = order['customer'];
    final status = order['status'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(status),
          child: Icon(
            _getStatusIcon(status),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(customer['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer['address']),
            if (customer['phone'] != null) Text('电话: ${customer['phone']}'),
            Text('排序: ${order['sort_order'] + 1}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == 'pending')
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => _markAsDelivered(order),
                tooltip: '标记为已送达',
              ),
            PopupMenuButton<String>(
              itemBuilder: (context) => [
                if (status == 'pending')
                  const PopupMenuItem(
                    value: 'complete',
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green),
                      title: Text('标记送达'),
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('删除订单', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'complete') {
                  _markAsDelivered(order);
                } else if (value == 'delete') {
                  _showDeleteOrderDialog(order);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    if (target == today) {
      return '今天 ($dateString)';
    } else if (target == today.subtract(const Duration(days: 1))) {
      return '昨天 ($dateString)';
    } else if (target == today.add(const Duration(days: 1))) {
      return '明天 ($dateString)';
    } else {
      return '${date.month}月${date.day}日 ($dateString)';
    }
  }
}
