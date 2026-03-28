import 'package:flutter/material.dart';
import 'package:niu_ma_tool/utils/database_helper.dart';
import 'customer_detail_page.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _customers = [];
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final categories = await _dbHelper.getCustomerCategories();
    final customers =
        await _dbHelper.getCustomers(categoryId: _selectedCategoryId);

    setState(() {
      _categories = categories;
      _customers = customers;
    });
  }

  void _showAddCategoryDialog() {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加客户分类'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入分类名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _dbHelper
                    .insertCustomerCategory({'name': controller.text});
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(Map<String, dynamic> category) {
    TextEditingController controller =
        TextEditingController(text: category['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑分类'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '请输入分类名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _dbHelper.updateCustomerCategory(
                  category['id'],
                  {'name': controller.text},
                );
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(Map<String, dynamic> category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定要删除分类"${category['name']}"吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteCustomerCategory(category['id']);
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToCustomerDetail([Map<String, dynamic>? customer]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CustomerDetailPage(
          customer: customer,
          categoryId: _selectedCategoryId,
        ),
      ),
    ).then((_) => _loadData());
  }

  void _showDeleteCustomerDialog(Map<String, dynamic> customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除客户'),
        content: Text('确定要删除客户"${customer['name']}"吗？此操作将同时删除相关订单数据。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteCustomer(customer['id']);
              Navigator.pop(context);
              _loadData();
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addToTodayOrders(int customerId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final existingOrders = await _dbHelper.getOrdersByDate(today);

    await _dbHelper.insertOrder({
      'customer_id': customerId,
      'delivery_date': today,
      'status': 'pending',
      'sort_order': existingOrders.length,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已添加到今日配送任务')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Category Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int?>(
                    initialValue: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: '客户分类',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('全部客户'),
                      ),
                      ..._categories.map((category) {
                        return DropdownMenuItem<int?>(
                          value: category['id'],
                          child: Text(category['name']),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                      _loadData();
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _showAddCategoryDialog,
                  tooltip: '添加分类',
                ),
              ],
            ),
          ),

          // Category Management Section
          if (_categories.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text(category['name']),
                      deleteIcon: const Icon(Icons.more_vert, size: 16),
                      onDeleted: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('编辑分类'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showEditCategoryDialog(category);
                                },
                              ),
                              ListTile(
                                leading:
                                    const Icon(Icons.delete, color: Colors.red),
                                title: const Text('删除分类',
                                    style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showDeleteCategoryDialog(category);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),

          // Customer List Section
          Expanded(
            child: _customers.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('暂无客户数据', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _customers.length,
                    itemBuilder: (context, index) {
                      final customer = _customers[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),
                          title: Text(customer['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (customer['phone'] != null)
                                Text('电话: ${customer['phone']}'),
                              Text('地址: ${customer['address']}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.add_task),
                                onPressed: () =>
                                    _addToTodayOrders(customer['id']),
                                tooltip: '添加到今日配送',
                              ),
                              PopupMenuButton<String>(
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit),
                                      title: Text('编辑'),
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      leading:
                                          Icon(Icons.delete, color: Colors.red),
                                      title: Text('删除',
                                          style: TextStyle(color: Colors.red)),
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _navigateToCustomerDetail(customer);
                                  } else if (value == 'delete') {
                                    _showDeleteCustomerDialog(customer);
                                  }
                                },
                              ),
                            ],
                          ),
                          onTap: () => _navigateToCustomerDetail(customer),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToCustomerDetail(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
