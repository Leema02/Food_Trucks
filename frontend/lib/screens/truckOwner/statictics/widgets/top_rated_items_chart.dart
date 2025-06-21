// lib/screens/truckOwner/orders/top_rated_items_chart.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/core/services/menu_service.dart';
import 'package:myapp/core/services/review_service.dart';

import 'menu_item_info_dialog.dart';


class TopRatedItemsChart extends StatefulWidget {
  final String truckId;

  const TopRatedItemsChart({super.key, required this.truckId});

  @override
  State<TopRatedItemsChart> createState() => _TopRatedItemsChartState();
}

class _TopRatedItemsChartState extends State<TopRatedItemsChart> {
  // Returns chart data AND the full menu list
  late Future<(List<MapEntry<String, double>>, List<dynamic>)> _processedDataFuture;

  @override
  void initState() {
    super.initState();
    _processedDataFuture = _fetchAndProcessData();
  }

  @override
  void didUpdateWidget(covariant TopRatedItemsChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.truckId != widget.truckId) {
      setState(() {
        _processedDataFuture = _fetchAndProcessData();
      });
    }
  }

  Future<(List<MapEntry<String, double>>, List<dynamic>)> _fetchAndProcessData() async {
    try {
      final menuResponse = await MenuService.getMenuItems(widget.truckId);
      if (menuResponse.statusCode != 200) throw Exception('Failed to load menu items');
      final List<dynamic> menuItems = jsonDecode(menuResponse.body);

      final ratingFutures = menuItems.map((item) async {
        final reviews = await ReviewService.fetchMenuItemReviews2(item['_id']);
        if (reviews.isEmpty) return {'name': item['name'], 'avg_rating': 0.0};

        double totalRating = reviews.map<num>((r) => r['rating'] ?? 0).fold(0, (p, e) => p + e);
        return {'name': item['name'], 'avg_rating': totalRating / reviews.length};
      }).toList();

      final results = await Future.wait(ratingFutures);
      final Map<String, double> averageRatings = {
        for (var result in results) if (result['avg_rating'] > 0) result['name']: result['avg_rating']
      };

      var sortedItems = averageRatings.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topRatedItems = sortedItems.take(5).toList();

      // Return both results
      return (topRatedItems, menuItems);
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
    return FutureBuilder<(List<MapEntry<String, double>>, List<dynamic>)>(
      future: _processedDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.$1.isEmpty) {
          return const Center(child: Text("No rated items to display."));
        }

        final chartData = snapshot.data!.$1;
        final fullMenuList = snapshot.data!.$2;

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFFF1F8E9),
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16).copyWith(top: 24),
            child: Column(
              children: [
                const Text(
                  'Top Rated Items (Avg. Rating)',
                  style: TextStyle(color: Color(0xFF2E7D32), fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                AspectRatio(
                  aspectRatio: 1.5,
                  child: BarChart(
                    BarChartData(
                      maxY: 5,
                      alignment: BarChartAlignment.spaceAround,
                      // UPDATED touch behavior
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => Colors.green.shade700,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
                            'Avg: ${rod.toY.toStringAsFixed(1)} ★',
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
                            interval: 1,
                            getTitlesWidget: (value, meta) => _getLeftTitles(value, meta),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(color: Colors.green.shade100, strokeWidth: 1),
                      ),
                      barGroups: chartData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.value,
                              gradient: const LinearGradient(
                                  colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
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

  Widget _getLeftTitles(double value, TitleMeta meta) {
    final style = TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.bold, fontSize: 12);
    if (value > 5 || value < 0 || value % 1 != 0) return Container();
    return SideTitleWidget(axisSide: meta.axisSide, space: 4, child: Text(value.toInt().toString(), style: style));
  }

  Widget _getBottomTitles(double value, TitleMeta meta, List<MapEntry<String, double>> data) {
    final style = TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 12);
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