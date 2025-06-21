// lib/screens/truckOwner/orders/daily_orders_chart.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:myapp/core/services/order_service.dart';

// Renamed widget
class DailyOrdersChart extends StatefulWidget {
  final String truckId;

  const DailyOrdersChart({super.key, required this.truckId});

  @override
  State<DailyOrdersChart> createState() => _DailyOrdersChartState();
}

class _DailyOrdersChartState extends State<DailyOrdersChart> {
  late Future<Map<int, int>> _processedDataFuture;

  @override
  void initState() {
    super.initState();
    _processedDataFuture = _fetchAndProcessOrders();
  }

  @override
  void didUpdateWidget(covariant DailyOrdersChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.truckId != widget.truckId) {
      setState(() {
        _processedDataFuture = _fetchAndProcessOrders();
      });
    }
  }

  Future<Map<int, int>> _fetchAndProcessOrders() async {
    try {
      final response = await OrderService.getOrdersByTruck(widget.truckId);
      if (response.statusCode == 200) {
        final List<dynamic> orders = jsonDecode(response.body);
        final Map<int, int> weeklyOrderCounts = {
          1: 0,
          2: 0,
          3: 0,
          4: 0,
          5: 0,
          6: 0,
          7: 0
        };
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

        for (var order in orders) {
          if (order['createdAt'] == null) continue;
          final orderDate = DateTime.parse(order['createdAt']);
          if (orderDate.isAfter(thirtyDaysAgo)) {
            final weekday = orderDate.weekday;
            weeklyOrderCounts[weekday] = (weeklyOrderCounts[weekday] ?? 0) + 1;
          }
        }
        return weeklyOrderCounts;
      } else {
        throw Exception(
            'Failed to load orders: Status Code ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<int, int>>(
      future: _processedDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading chart data:\n${snapshot.error}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red.shade700),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.values.every((v) => v == 0)) {
          return const Center(
            child: Text("No order activity in the last 30 days."),
          );
        }

        final weeklyData = snapshot.data!;
        final maxOrderCount = weeklyData.values.reduce(max);
        final maxY = (maxOrderCount < 5 ? 5.0 : (maxOrderCount * 1.2));

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: const Color(0xFFFFE0B2),
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)
                .copyWith(top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Orders Per WeekDays (Last 30 Days)',
                  style: TextStyle(
                    color: Color(0xFFBF360C),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                AspectRatio(
                  aspectRatio: 1.5,
                  child: BarChart(
                    BarChartData(
                      maxY: maxY,
                      barTouchData: _buildBarTouchData(),
                      titlesData: FlTitlesData(
                        show: true,
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: _getBottomTitles,
                            reservedSize: 36,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) =>
                                _getLeftTitles(value, meta, maxY),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: max(1, (maxY / 4).floorToDouble()),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.orange.shade100,
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: weeklyData.entries.map((entry) {
                        return BarChartGroupData(
                          x: entry.key,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: const Color(0xFFFF600A),
                              width: 16,
                              borderRadius: BorderRadius.circular(6),
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

  // --- Helper methods remain the same ---
  BarTouchData _buildBarTouchData() {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipColor: (_) => const Color(0xFFFF600A),
        tooltipPadding: const EdgeInsets.all(8),
        tooltipRoundedRadius: 10,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
          String weekDay = weekDays[group.x.toInt() - 1];

          return BarTooltipItem(
            '$weekDay\n',
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            children: [
              TextSpan(
                text: '${rod.toY.toInt()} orders',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xFF4E342E),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    const weekDayChars = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final text = Text(weekDayChars[value.toInt() - 1], style: style);

    return SideTitleWidget(axisSide: meta.axisSide, space: 12, child: text);
  }

  Widget _getLeftTitles(double value, TitleMeta meta, double maxY) {
    if (value == 0 || value >= maxY) return Container();
    if (value % max(1, (maxY / 4).floorToDouble()) != 0) return Container();
    const style = TextStyle(
      color: Color(0xFF6D4C41),
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(
        value.toInt().toString(),
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }
}
