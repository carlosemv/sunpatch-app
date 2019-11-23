import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:circular_chart/src/animated_circular_chart.dart';
import 'package:circular_chart/src/circular_chart.dart';
import 'package:circular_chart/src/stack.dart';

class AnimatedCircularChartPainter extends CustomPainter {
  AnimatedCircularChartPainter(this.animation, this.labelPainters)
      : super(repaint: animation);

  final Animation<CircularChart> animation;
  final List<TextPainter> labelPainters;

  @override
  void paint(Canvas canvas, Size size) {
    _paintLabel(canvas, size, labelPainters);
    _paintChart(canvas, size, animation.value);
  }

  @override
  bool shouldRepaint(AnimatedCircularChartPainter old) => false;
}

class CircularChartPainter extends CustomPainter {
  CircularChartPainter(this.chart, this.labelPainters);

  final CircularChart chart;
  final List<TextPainter> labelPainters;

  @override
  void paint(Canvas canvas, Size size) {
    _paintLabel(canvas, size, labelPainters);
    _paintChart(canvas, size, chart);
  }

  @override
  bool shouldRepaint(CircularChartPainter old) => false;
}

const double _kRadiansPerDegree = Math.pi / 180;

void _paintLabel(Canvas canvas, Size size, List<TextPainter> labelPainters) {
  if (labelPainters != null) {
    num lineOffset = 0;
    for (var p in labelPainters) {
      p.layout();
      p.paint(
        canvas,
        new Offset(
          size.width / 2 - p.width / 2,
          size.height / 2 - p.height / 2 + lineOffset,
        ),
      );
      lineOffset += p.height;
    }
  }
}

void _paintChart(Canvas canvas, Size size, CircularChart chart) {
  final Paint segmentPaint = new Paint()
    ..style = chart.chartType == CircularChartType.Radial
        ? PaintingStyle.stroke
        : PaintingStyle.fill
    ..strokeCap = chart.edgeStyle == SegmentEdgeStyle.round
        ? StrokeCap.round
        : StrokeCap.butt;

  for (final CircularChartStack stack in chart.stacks) {
    for (final segment in stack.segments) {
      segmentPaint.color = segment.color;
      segmentPaint.strokeWidth = stack.width;

      canvas.drawArc(
        new Rect.fromCircle(
          center: new Offset(size.width / 2, size.height / 2),
          radius: stack.radius,
        ),
        stack.startAngle * _kRadiansPerDegree,
        segment.sweepAngle * _kRadiansPerDegree,
        chart.chartType == CircularChartType.Pie,
        segmentPaint,
      );
    }
  }
}
