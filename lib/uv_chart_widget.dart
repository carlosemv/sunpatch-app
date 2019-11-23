import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:circular_chart/circular_chart.dart';

class UVChartWidget extends StatelessWidget {
  final _chartKey = new GlobalKey<AnimatedCircularChartState>();
  int percentage;

  UVChartWidget(this.percentage);

  @override
  Widget build(BuildContext context) {
    return new AnimatedCircularChart(
      key: _chartKey,
      duration: Duration.zero,
      size: Size(300, 300),
      initialChartData: _buildGraph(),
      chartType: CircularChartType.Radial,
      percentageValues: true,
      holeTextPainters: <TextPainter> [
        TextPainter(
          text: new TextSpan(style: Theme.of(context).textTheme.display1,
            text: percentage.toString()+"%"),
        ),
        TextPainter(
          text: new TextSpan(style: Theme.of(context).textTheme.subhead,
            text: "of max exposure"),
        ),
      ],
    );
  }

  Color getWheelColor() {
    if (percentage >= 100)
      return Colors.red;
    else if (percentage >= 75)
      return Colors.deepOrange;
    else if (percentage >= 50)
      return Colors.amber;
    else
      return Colors.green;
  }

  List<CircularStackEntry> _buildGraph() {
    List<CircularStackEntry> circles = [];
    var wheelColor = getWheelColor();

    for (var x = 0; x < percentage ~/ 100; x++) {
      circles.add(new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
            100.0,
            wheelColor,
          )
        ]
      ));
    }

    var rem = percentage % 100;
    if (rem != 0) {
      circles.add(new CircularStackEntry(
        <CircularSegmentEntry>[
          new CircularSegmentEntry(
            rem.toDouble(),
            wheelColor,
          ),
        ]
      ));
    }

    return circles;
  }
}