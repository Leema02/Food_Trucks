// lib/screens/truckOwner/orders/most_ordered_items_chart.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/core/services/order_service.dart';
import 'package:myapp/core/services/menu_service.dart';

import 'menu_item_info_dialog.dart';

class MostOrderedItemsChart extends StatefulWidget {
  final String truckId;

  const MostOrderedItemsChart({super.key, required this.truckId});

  @override
  State<MostOrderedItemsChart> createState() => _MostOrderedItemsChartState();
}

class _MostOrderedItemsChartState extends State<MostOrderedItemsChart> {
  // Now returns a tuple: the chart data AND the full menu list
  late Future<(List<MapEntry<String, int>>, List<dynamic>)> _processedDataFuture;

  @override
  void initState() {
    super.initState();
    _processedDataFuture = _fetchAndProcessData();
  }

  @override
  void didUpdateWidget(covariant MostOrderedItemsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.truckId != widget.truckId) {
      setState(() {
        _processedDataFuture = _fetchAndProcessData();
      });
    }
  }

  Future<(List<MapEntry<String, int>>, List<dynamic>)> _fetchAndProcessData() async {
    try {
      // Fetch both orders and the menu items list concurrently
      final responses = await Future.wait([
        OrderService.getOrdersByTruck(widget.truckId),
        MenuService.getMenuItems(widget.truckId),
      ]);

      final orderResponse = responses[0];
      final menuResponse = responses[1];

      if (orderResponse.statusCode != 200) {
        throw Exception('Failed to load orders: Status ${orderResponse.statusCode}');
      }
      if (menuResponse.statusCode != 200) {
        throw Exception('Failed to load menu items: Status ${menuResponse.statusCode}');
      }

      final List<dynamic> orders = jsonDecode(orderResponse.body);
      final List<dynamic> menuItems = jsonDecode(menuResponse.body);

      final Map<String, int> itemQuantities = {};
      for (var order in orders) {
        if (order['items'] is List) {
          for (var item in order['items']) {
            final String itemName = item['name'];
            final int quantity = (item['quantity'] as num).toInt();
            itemQuantities[itemName] = (itemQuantities[itemName] ?? 0) + quantity;
          }
        }
      }

      var sortedItems = itemQuantities.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topItems = sortedItems.take(5).toList();

      // Return both results
      return (topItems, menuItems);
    } catch (e) {
      rethrow;
    }
  }

  void _showMenuItemDialog(BuildContext context, Map<String, dynamic>? itemData) {
    if (itemData == null || itemData.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => MenuItemInfoDialog(menuItem: itemData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(List<MapEntry<String, int>>, List<dynamic>)>(
      future: _processedDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.$1.isEmpty) {
          return const Center(child: Text("No item data to display."));
        }

        final chartData = snapshot.data!.$1;
        final fullMenuList = snapshot.data!.$2;
        final maxValue = chartData.isEmpty ? 5.0 : chartData.first.value.toDouble() * 1.2;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFFFFF3E0),
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16).copyWith(top: 24),
            child: Column(
              children: [
                const Text(
                  'Most Ordered Items',
                  style: TextStyle(color: Color(0xFFBF360C), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                AspectRatio(
                  aspectRatio: 1.5,
                  child: BarChart(
                    BarChartData(
                      maxY: maxValue,
                      alignment: BarChartAlignment.spaceAround,
                      // UPDATED touch behavior
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.deepOrange.shade700,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                            '${rod.toY.toInt()} orders',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        touchCallback: (event, response) {
                          if (event is FlTapUpEvent && response?.spot != null) {
                            final int touchedIndex = response!.spot!.touchedBarGroupIndex;
                            if (touchedIndex < chartData.length) {
                              final String itemName = chartData[touchedIndex].key;
                              final selectedItem = fullMenuList.firstWhere(
                                      (item) => item['name'] == itemName,
                                  orElse: () => null
                              );
                              _showMenuItemDialog(context, selectedItem);
                            }
                          }
                        },
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => _getBottomTitles(value, meta, chartData),
                            reservedSize: 42,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) => _getLeftTitles(value, meta, maxValue),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(color: Colors.orange.shade100, strokeWidth: 1),
                      ),
                      barGroups: chartData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.value.toDouble(),
                              gradient: const LinearGradient(
                                  colors: [Color(0xFFFF7043), Color(0xFFFF5722)],
                                  begin: Alignment.bottomCenter, end: Alignment.topCenter),
                              width: 22,
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getLeftTitles(double value, TitleMeta meta, double maxValue) {
    final style = TextStyle(color: Color(0xFF6D4C41), fontWeight: FontWeight.bold, fontSize: 12);
    if (value == 0) return SideTitleWidget(axisSide: meta.axisSide, child: Text('0', style: style));
    if (value > maxValue || value % 1 != 0) return Container();
    return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(value.toInt().toString(), style: style));
  }

  Widget _getBottomTitles(double value, TitleMeta meta, List<MapEntry<String, int>> data) {
    final style = TextStyle(color: Colors.brown.shade800, fontWeight: FontWeight.bold, fontSize: 12);
    String text = '';
    if (value.toInt() < data.length) {
      String fullName = data[value.toInt()].key;
      text = fullName.length > 8 ? '${fullName.substring(0, 7)}…' : fullName;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide, space: 8,
      child: Transform.rotate(angle: -pi / 6, child: Text(text, style: style)),
    );
  }
}