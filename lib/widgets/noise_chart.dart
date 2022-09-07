import 'dart:async';
import 'dart:math' as math;

/// Package imports
import 'package:flutter/material.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/charts.dart';

import '../noise_log.dart';

class ChartData {
  final int count;
  final double value;
  ChartData(this.count, this.value);
}

class NoiseChart extends StatefulWidget {
  final List<ChartData> values;
  final double maxValue;
  final double xInterval;
  const NoiseChart({Key? key,
    required this.maxValue, required this.values, required this.xInterval}): super(key: key);
  @override
  _NoiseChart createState() => _NoiseChart();
}

class _NoiseChart extends State<NoiseChart> {
  _NoiseChart();
  ChartSeriesController? _chartSeriesController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(child: _chartBody()),
      ),
    );
  }

  SfCartesianChart _chartBody() {
    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      primaryXAxis: NumericAxis(
        interval: widget.xInterval,
        majorGridLines: const MajorGridLines(width: 0),
        edgeLabelPlacement: EdgeLabelPlacement.shift
      ),
      primaryYAxis: NumericAxis(
        maximum: widget.maxValue + 10,
        minimum: 30,
        interval: 5,
        axisLine: const AxisLine(width: 0),
        majorTickLines: const MajorTickLines(size: 0),
      ),
      series: _getSeries(),
    );
  }

  List<LineSeries<ChartData, num>> _getSeries() {
    return <LineSeries<ChartData, num>>[
      LineSeries<ChartData, num>(
        onRendererCreated: (ChartSeriesController ctrl) {
          _chartSeriesController = ctrl;
        },
        animationDuration: 0,
        dataSource: widget.values!,
        xValueMapper: (ChartData noises, _) => noises.count - 1 as num,
        yValueMapper: (ChartData noises, _) => noises.value,
        width: 2
      )
    ];
  }

  @override
  void dispose() {
    _chartSeriesController = null;
    super.dispose();
  }
}