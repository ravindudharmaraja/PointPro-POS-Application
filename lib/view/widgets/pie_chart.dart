import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> dataMap;
  final Map<String, Color>? colorMap;

  const PieChartWidget({
    super.key,
    required this.dataMap,
    this.colorMap, required List categories,
  });

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  final List<Color> _defaultColors = const [
    promiscuousPink,
    darkYellow,
    royalFuchsia,
    blue,
    Colors.teal,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    final Color borderColor = Theme.of(context).dividerColor;
    final Color fallbackTextColor =
        Theme.of(context).colorScheme.onPrimary; // for contrast

    return AspectRatio(
      aspectRatio: 1.0,
      child: PieChart(
        PieChartData(
          pieTouchData: PieTouchData(
            touchCallback: (event, pieTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    pieTouchResponse?.touchedSection == null) {
                  touchedIndex = -1;
                } else {
                  touchedIndex =
                      pieTouchResponse!.touchedSection!.touchedSectionIndex;
                }
              });
            },
          ),
          borderData: FlBorderData(show: false),
          sectionsSpace: 4,
          centerSpaceRadius: 60,
          sections: _buildChartSections(borderColor, fallbackTextColor),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildChartSections(
      Color borderColor, Color textColor) {
    if (widget.dataMap.isEmpty) {
      return [
        PieChartSectionData(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          value: 100,
          radius: 15.0,
          showTitle: false,
        ),
      ];
    }

    return List.generate(widget.dataMap.length, (i) {
      final entry = widget.dataMap.entries.elementAt(i);
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 30.0 : 20.0;
      final fontSize = isTouched ? 16.0 : 12.0;
      final color =
          widget.colorMap?[entry.key] ?? _defaultColors[i % _defaultColors.length];

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.value.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: textColor,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 2,
            ),
          ],
        ),
        borderSide: BorderSide(width: 2, color: borderColor),
      );
    });
  }
}
