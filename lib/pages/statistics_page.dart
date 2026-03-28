import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:niu_ma_tool/utils/database_helper.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _deliveryRecords = [];
  Map<String, int> _dailyCounts = {};
  int _totalDeliveries = 0;
  int _last30DaysCount = 0;
  int _last7DaysCount = 0;
  int _mostActiveDayCount = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    final records = await _dbHelper.getDeliveryRecords();

    final dailyCounts = <String, int>{};
    int total = 0;
    int last30Days = 0;
    int last7Days = 0;

    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

    for (var record in records) {
      final date = record['delivery_date'];
      dailyCounts[date] = (dailyCounts[date] ?? 0) + 1;
      total++;

      final recordDate = DateTime.parse(date);
      if (recordDate.isAfter(thirtyDaysAgo)) {
        last30Days++;
      }
      if (recordDate.isAfter(sevenDaysAgo)) {
        last7Days++;
      }
    }

    int mostActiveCount = 0;
    dailyCounts.forEach((date, count) {
      if (count > mostActiveCount) {
        mostActiveCount = count;
      }
    });

    setState(() {
      _deliveryRecords = records;
      _dailyCounts = dailyCounts;
      _totalDeliveries = total;
      _last30DaysCount = last30Days;
      _last7DaysCount = last7Days;
      _mostActiveDayCount = mostActiveCount;
    });
  }

  List<BarChartGroupData> _getChartData() {
    final now = DateTime.now();
    final data = <BarChartGroupData>[];

    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final count = _dailyCounts[dateString] ?? 0;

      data.add(
        BarChartGroupData(
          x: 29 - i,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: Colors.blue,
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return data;
  }

  Widget _buildStatisticsCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statistics Overview
            const Text(
              '数据概览',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatisticsCard(
                  '总配送量',
                  _totalDeliveries.toString(),
                  Icons.local_shipping,
                  Colors.blue,
                ),
                _buildStatisticsCard(
                  '近30天',
                  _last30DaysCount.toString(),
                  Icons.calendar_month,
                  Colors.green,
                ),
                _buildStatisticsCard(
                  '近7天',
                  _last7DaysCount.toString(),
                  Icons.trending_up,
                  Colors.orange,
                ),
                _buildStatisticsCard(
                  '最忙日',
                  _mostActiveDayCount.toString(),
                  Icons.emoji_events,
                  Colors.red,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Chart Section
            const Text(
              '近30日配送量趋势',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (_dailyCounts.values.isNotEmpty
                          ? _dailyCounts.values
                              .reduce((a, b) => a > b ? a : b)
                              .toDouble()
                          : 10) +
                      2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.blue.withAlpha(204),
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final date = DateTime.now()
                            .subtract(Duration(days: 29 - groupIndex));
                        return BarTooltipItem(
                          '${DateFormat('MM-dd').format(date)}\n${rod.toY.toInt()}单',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % 5 == 0) {
                            final date = DateTime.now()
                                .subtract(Duration(days: 29 - value.toInt()));
                            return Text(DateFormat('MM-dd').format(date));
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.min || value == meta.max) {
                            return Text(value.toInt().toString());
                          }
                          return const Text('');
                        },
                        reservedSize: 40,
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  barGroups: _getChartData(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Delivery Records Table
            const Text(
              '配送记录明细',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (_deliveryRecords.isEmpty)
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.bar_chart, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('暂无配送记录', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              Card(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('日期')),
                      DataColumn(label: Text('客户姓名')),
                      DataColumn(label: Text('配送地址')),
                      DataColumn(label: Text('创建时间')),
                    ],
                    rows: _deliveryRecords.take(50).map((record) {
                      return DataRow(
                        cells: [
                          DataCell(Text(record['delivery_date'])),
                          DataCell(FutureBuilder<Map<String, dynamic>?>(
                            future:
                                _dbHelper.getCustomer(record['customer_id']),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Text(snapshot.data!['name']);
                              }
                              return const Text('加载中...');
                            },
                          )),
                          DataCell(FutureBuilder<Map<String, dynamic>?>(
                            future:
                                _dbHelper.getCustomer(record['customer_id']),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Text(
                                  snapshot.data!['address'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }
                              return const Text('加载中...');
                            },
                          )),
                          DataCell(Text(
                            DateFormat('HH:mm')
                                .format(DateTime.parse(record['created_at'])),
                          )),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),

            if (_deliveryRecords.length > 50)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '显示前50条记录，共${_deliveryRecords.length}条记录',
                  style: const TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadStatistics,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
