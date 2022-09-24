import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:io' as io;

/// Package imports
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Chart import
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:ui' as ui;

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
  final int levelValue;
  const NoiseChart({Key? key,
    required this.maxValue, required this.values, required this.xInterval, required this.levelValue}): super(key: key);
  @override
  NoiseChartState createState() => NoiseChartState();
}

class NoiseChartState extends State<NoiseChart> {
  NoiseChartState();
  ChartSeriesController? _chartSeriesController;
  late GlobalKey<SfCartesianChartState> _cartesianChartKey = GlobalKey();

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
      key: _cartesianChartKey,
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
        plotBands: [
          PlotBand(
            start: widget.levelValue,
            end: widget.levelValue,
            borderColor: Colors.red,
            borderWidth: 2,
            associatedAxisStart: 0,
          )
        ],
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
        xValueMapper: (ChartData noises, _) => noises.count as num,
        yValueMapper: (ChartData noises, _) => noises.value >= 0 && noises.value <= 200 ? noises.value : 0,
        width: 2
      )
    ];
  }

  Future<void> saveAsImage(int id) async {
    final ui.Image data = await _cartesianChartKey.currentState!.toImage(pixelRatio: 1.0);
    final ByteData? bytes = await data.toByteData(format : ui.ImageByteFormat.png);
    final Uint8List imageBytes = bytes!.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    if (imageBytes != null) {
      final io.Directory extDir = await getApplicationDocumentsDirectory();
      final String filename = extDir.path + "/noise_out_" + id.toString() +
          ".png";
      await File(filename).writeAsBytes(imageBytes);
    }
  }

  @override
  void dispose() {
    _chartSeriesController = null;
    super.dispose();
  }
}