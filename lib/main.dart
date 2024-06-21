// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

const double kMax = 1.25098;
const double kMin = -0.752941;

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Wide Gamut')),
        body: const ExampleAnimation(),
      ),
    ),
  );
}

class ExampleAnimation extends StatefulWidget {
  const ExampleAnimation({super.key});

  @override
  State<ExampleAnimation> createState() => _ExampleAnimationState();
}

class _ExampleAnimationState extends State<ExampleAnimation> {
  ui.FragmentProgram? program;

  @override
  void initState() {
    ui.FragmentProgram.fromAsset('shaders/color.frag').then((ui.FragmentProgram program) {
      setState(() {
        this.program = program;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (program == null) {
      return const Placeholder();
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'On iOS devices that support wide gamut, Flutter can output colors '
            'with a range of -0.752941 to 1.25098 instead of just 0 to 1. For the '
            'brightest possible red, green, blue the maximum value is used for the '
            'enabled channel and the minimum is used for the disabled channel. For white, '
            'all color channels are set to the maximum. '
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomPaint(
              painter: ColorPainter((kMax, kMin, kMin, 1), program!),
              size: const Size(50, 200),
            ),
            CustomPaint(
              painter: ColorPainter((kMin, kMax, kMin, 1), program!),
              size: const Size(50, 200),
            ),
            CustomPaint(
              painter: ColorPainter((kMin, kMin, kMax, 1), program!),
              size: const Size(50, 200),
            ),
            CustomPaint(
              painter: ColorPainter((kMax, kMax, kMax, 1), program!),
              size: const Size(50, 200),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomPaint(
              painter: ColorPainter((1, 0, 0, 1), program!),
              size: const Size(50, 200),
            ),
            CustomPaint(
              painter: ColorPainter((0, 1, 0, 1), program!),
              size: const Size(50, 200),
            ),
            CustomPaint(
              painter: ColorPainter((0, 0, 1, 1), program!),
              size: const Size(50, 200),
            ),
            CustomPaint(
              painter: ColorPainter((1, 1, 1, 1), program!),
              size: const Size(50, 200),
            )
          ],
        ),
      ],
    );
  }
}

class ColorPainter extends CustomPainter {
  ColorPainter(this.color, this.program);

  final (double, double, double, double) color;
  final ui.FragmentProgram program;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    final ui.FragmentShader shader = program.fragmentShader();
    shader.setFloat(0, color.$1);
    shader.setFloat(1, color.$2);
    shader.setFloat(2, color.$3);
    shader.setFloat(3, color.$4);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
