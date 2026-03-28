import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:amap_flutter_map/amap_flutter_map.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:niu_ma_tool/utils/database_helper.dart';

class CustomerDetailPage extends StatefulWidget {
  final Map<String, dynamic>? customer;
  final int? categoryId;

  const CustomerDetailPage({
    super.key,
    this.customer,
    this.categoryId,
  });

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;
  double? _latitude;
  double? _longitude;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _initializeForm();
  }

  Future<void> _loadCategories() async {
    final categories = await _dbHelper.getCustomerCategories();
    setState(() {
      _categories = categories;
    });
  }

  void _initializeForm() {
    if (widget.customer != null) {
      _nameController.text = widget.customer!['name'] ?? '';
      _phoneController.text = widget.customer!['phone'] ?? '';
      _addressController.text = widget.customer!['address'] ?? '';
      _selectedCategoryId = widget.customer!['category_id'];
      _latitude = widget.customer!['latitude'];
      _longitude = widget.customer!['longitude'];
    } else {
      _selectedCategoryId = widget.categoryId;
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('请先开启定位服务')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('定位权限被拒绝')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('定位权限被永久拒绝，请在设置中开启')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _addressController.text =
            '纬度: ${position.latitude}, 经度: ${position.longitude}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('获取位置失败: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openMapPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('地图选点'),
        content: const Text('地图选点功能需要网络连接，请确保设备已联网。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showMapSelectionDialog();
            },
            child: const Text('继续'),
          ),
        ],
      ),
    );
  }

  void _showMapSelectionDialog() {
    LatLng initialPosition = const LatLng(39.9042, 116.4074); // 北京
    if (_latitude != null && _longitude != null) {
      initialPosition = LatLng(_latitude!, _longitude!);
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              AppBar(
                title: const Text('选择位置'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      Navigator.pop(context);
                      _addressController.text = '地图选点位置';
                    },
                  ),
                ],
              ),
              Expanded(
                child: AMapWidget(
                  apiKey: const AMapApiKey(
                    androidKey: 'ac67cb6f3eb549c90e3ea9e6f5a97962',
                    iosKey: 'ac67cb6f3eb549c90e3ea9e6f5a97962',
                  ),
                  initialCameraPosition: CameraPosition(
                    target: initialPosition,
                    zoom: 14.0,
                  ),
                  onMapCreated: (AMapController controller) {
                    // 地图创建完成后的回调
                  },
                  onTap: (LatLng position) {
                    setState(() {
                      _latitude = position.latitude;
                      _longitude = position.longitude;
                    });
                  },
                  markers: _latitude != null && _longitude != null
                      ? {
                          Marker(
                            position: LatLng(_latitude!, _longitude!),
                          ),
                        }
                      : {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final customerData = {
      'category_id': _selectedCategoryId,
      'name': _nameController.text,
      'phone': _phoneController.text.isNotEmpty ? _phoneController.text : null,
      'address': _addressController.text,
      'latitude': _latitude,
      'longitude': _longitude,
    };

    try {
      if (widget.customer != null) {
        await _dbHelper.updateCustomer(widget.customer!['id'], customerData);
      } else {
        await _dbHelper.insertCustomer(customerData);
      }

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('保存失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.customer != null ? '编辑客户' : '添加客户'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveCustomer,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Selection
                    DropdownButtonFormField<int?>(
                      initialValue: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: '客户分类',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('未分类'),
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
                      },
                    ),
                    const SizedBox(height: 16),

                    // Name Field
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: '客户姓名 *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入客户姓名';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone Field
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: '联系电话',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Address Section
                    const Text('配送地址 *',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // Address Input Methods
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.location_on),
                            label: const Text('当前定位'),
                            onPressed: _getCurrentLocation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.map),
                            label: const Text('地图选点'),
                            onPressed: _openMapPicker,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Address Text Field
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: '配送地址',
                        border: OutlineInputBorder(),
                        hintText: '请选择地址输入方式或手动输入地址',
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入配送地址';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Coordinates Display
                    if (_latitude != null && _longitude != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('坐标信息',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('纬度: $_latitude'),
                              Text('经度: $_longitude'),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
