import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SentimentPieChart extends StatelessWidget {
  final int positiveCount;
  final int neutralCount;
  final int negativeCount;

  const SentimentPieChart({
    super.key,
    required this.positiveCount,
    required this.neutralCount,
    required this.negativeCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = positiveCount + neutralCount + negativeCount;
    if (total == 0) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: _buildChartSections(total),
              ),
            ),
          ),
          const SizedBox(width: 4),
          _buildLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(int total) {
    return [
      if (positiveCount > 0)
        PieChartSectionData(
          color: Colors.green.shade400,
          value: positiveCount.toDouble(),
          title: '${(positiveCount / total * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (neutralCount > 0)
        PieChartSectionData(
          color: Colors.orange.shade400,
          value: neutralCount.toDouble(),
          title: '${(neutralCount / total * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      if (negativeCount > 0)
        PieChartSectionData(
          color: Colors.red.shade400,
          value: negativeCount.toDouble(),
          title: '${(negativeCount / total * 100).toStringAsFixed(0)}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
    ];
  }

  Widget _buildLegend() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Indicator(
          color: Colors.green.shade400,
          text: 'Positive [$positiveCount]',
          isSquare: true,
          size: 14,
        ),
        const SizedBox(height: 4),
        _Indicator(
          color: Colors.orange.shade400,
          text: 'Neutral [$neutralCount]',
          isSquare: true,
          size: 14,
        ),
        const SizedBox(height: 4),
        _Indicator(
          color: Colors.red.shade400,
          text: 'Negative [$negativeCount]',
          isSquare: true,
          size: 14,
        ),
      ],
    );
  }
}

class _Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const _Indicator({
    required this.color,
    required this.text,
    this.isSquare = false,
    this.size = 16,
    // ignore: unused_element_parameter
    this.textColor = const Color(0xff505050),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        )
      ],
    );
  }
}
