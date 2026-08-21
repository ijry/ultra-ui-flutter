// UPCanvas 2D context tests for the methods added to close the source gap.
//
// These verify geometry rather than pixels. Rasterizing to a byte array hangs
// under this repo's test binding — Picture.toImage resolves, but the following
// toByteData never completes — so each path-building operation is applied and
// its resulting bounds asserted instead. Bounds still prove the operation did
// something specific and correct: a no-op or a wrong transform changes them.
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

const double _size = 40;

/// Mounts a canvas and returns its controller.
Future<UPCanvasController> _mount(
  WidgetTester tester, {
  double size = _size,
}) async {
  final controller = UPCanvasController();
  await tester.pumpWidget(
    MaterialApp(
      theme: UP.themeData(),
      home: Scaffold(
        body: UPCanvas(
          width: size,
          height: size,
          bgColor: '#ffffff',
          controller: controller,
        ),
      ),
    ),
  );
  await tester.pump();
  return controller;
}

/// Applies [draw] to a fresh path and returns the resulting bounds.
Future<Rect> _pathBounds(
  WidgetTester tester,
  void Function(UPCanvasController c) draw,
) async {
  final controller = await _mount(tester);
  controller.beginPath();
  draw(controller);
  return controller.currentPathBounds;
}

void main() {
  group('path geometry', () {
    testWidgets('ellipse spans its radii', (tester) async {
      final bounds = await _pathBounds(tester, (c) {
        c.ellipse(20, 20, 18, 8, 0, 0, 6.2832);
      });
      // Wide and short: 36 across, 16 tall, centred at 20,20.
      expect(bounds.width, closeTo(36, 0.5));
      expect(bounds.height, closeTo(16, 0.5));
      expect(bounds.center.dx, closeTo(20, 0.5));
      expect(bounds.center.dy, closeTo(20, 0.5));
    });

    testWidgets('a rotated ellipse turns about its own centre', (tester) async {
      final bounds = await _pathBounds(tester, (c) {
        // The same ellipse a quarter turn round.
        c.ellipse(20, 20, 18, 8, 1.5708, 0, 6.2832);
      });
      // Now tall and narrow, still centred on the same point.
      expect(bounds.width, closeTo(16, 0.5));
      expect(bounds.height, closeTo(36, 0.5));
      expect(bounds.center.dx, closeTo(20, 0.5),
          reason: 'rotation must be about the ellipse centre, not the origin');
      expect(bounds.center.dy, closeTo(20, 0.5));
    });

    testWidgets('arcTo extends the path toward the corner', (tester) async {
      final bounds = await _pathBounds(tester, (c) {
        c.moveTo(5, 5);
        c.arcTo(35, 5, 35, 35, 10);
      });
      // Starts at 5,5 and curves out toward the 35,35 side.
      expect(bounds.left, closeTo(5, 0.5));
      expect(bounds.top, closeTo(5, 0.5));
      expect(bounds.right, greaterThan(30));
    });
  });

  group('transforms', () {
    testWidgets('the transform operations reach a live canvas', (tester) async {
      final controller = await _mount(tester);
      // The matrix itself is owned by Flutter's Canvas, so the observable
      // contract here is that each call reaches it without throwing.
      expect(controller.canvas, isNotNull);
      expect(() {
        controller.translate(10, 10);
        controller.transform(1, 0, 0, 1, 5, 5);
        controller.setTransform(1, 0, 0, 1, 2, 2);
        controller.resetTransform();
        controller.scale(2, 1);
        controller.rotate(0.5);
      }, returnsNormally);
    });

    testWidgets('callContext routes the transform operations', (tester) async {
      final controller = await _mount(tester);
      expect(() {
        controller.callContext('translate', <dynamic>[10, 10]);
        controller.callContext('transform', <dynamic>[1, 0, 0, 1, 5, 5]);
        controller.callContext('setTransform', <dynamic>[1, 0, 0, 1, 2, 2]);
        controller.callContext('resetTransform');
        controller.callContext('scale', <dynamic>[2, 1]);
      }, returnsNormally);
    });

    testWidgets('callContext builds paths through the same dispatch',
        (tester) async {
      final controller = await _mount(tester);
      controller.beginPath();
      controller.callContext('moveTo', <dynamic>[5, 5]);
      controller.callContext('lineTo', <dynamic>[25, 25]);
      final line = controller.currentPathBounds;
      expect(line.left, closeTo(5, 0.5));
      expect(line.right, closeTo(25, 0.5));

      controller.beginPath();
      controller.callContext('rect', <dynamic>[0, 0, 10, 20]);
      final rect = controller.currentPathBounds;
      expect(rect.width, closeTo(10, 0.5));
      expect(rect.height, closeTo(20, 0.5));

      controller.beginPath();
      controller.callContext('ellipse', <dynamic>[20, 20, 18, 8, 0, 0, 6.2832]);
      expect(controller.currentPathBounds.width, closeTo(36, 0.5));
    });
  });

  group('line dash and stroke state', () {
    testWidgets('setLineDash and getLineDash round-trip', (tester) async {
      final controller = await _mount(tester);
      expect(controller.getLineDash(), isEmpty);

      controller.setLineDash(<dynamic>[4, '2', 6.5]);
      expect(controller.getLineDash(), <double>[4, 2, 6.5],
          reason: 'string entries coerce like the source');

      controller.setLineDash();
      expect(controller.getLineDash(), isEmpty);
    });

    testWidgets('setLineDash routes through callContext', (tester) async {
      final controller = await _mount(tester);
      controller.callContext('setLineDash', <dynamic>[
        <dynamic>[3, 4]
      ]);
      expect(controller.callContext('getLineDash'), <double>[3, 4]);
    });

    testWidgets('setMiterLimit is accepted and stroking still runs',
        (tester) async {
      final controller = await _mount(tester);
      expect(() {
        controller.setMiterLimit(2);
        controller.setStrokeStyle('#ff0000');
        controller.setLineWidth(4);
        controller.beginPath();
        controller.moveTo(5, 20);
        controller.lineTo(35, 20);
        controller.stroke();
        controller.draw();
      }, returnsNormally);
      expect(controller.recordedPicture, isNotNull);
    });

    testWidgets('setGlobalCompositeOperation is retained', (tester) async {
      final controller = await _mount(tester);
      expect(controller.globalCompositeOperation, 'source-over');
      controller.setGlobalCompositeOperation('multiply');
      expect(controller.globalCompositeOperation, 'multiply');
      controller
          .callContext('setGlobalCompositeOperation', <dynamic>['screen']);
      expect(controller.globalCompositeOperation, 'screen');
    });
  });

  group('text measurement', () {
    testWidgets('estimateTextWidth measures without changing the font',
        (tester) async {
      final controller = await _mount(tester, size: 200);
      controller.setFontSize(10);
      final atTen = controller.estimateTextWidth('hello');
      final atThirty = controller.estimateTextWidth('hello', 30);

      expect(atTen, greaterThan(0));
      expect(atThirty, greaterThan(atTen));
      // The override must not leak into the context's own font size.
      expect(controller.estimateTextWidth('hello'), closeTo(atTen, 0.001));
    });

    testWidgets('measureTextAsync agrees with the synchronous estimate',
        (tester) async {
      final controller = await _mount(tester, size: 200);
      final measured = await controller.measureTextAsync('hello', 20);
      expect(measured['width'], controller.estimateTextWidth('hello', 20));
    });
  });

  group('host bridge shims', () {
    testWidgets('createPattern returns a shader only for a real image',
        (tester) async {
      final controller = await _mount(tester);
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 4, 4),
        Paint()..color = const Color(0xFFFF0000),
      );
      final image = await recorder.endRecording().toImage(4, 4);

      expect(controller.createPattern(image), isNotNull);
      expect(controller.createPattern(image, 'no-repeat'), isNotNull);
      // A map payload mirrors what getImageData returns.
      expect(controller.createPattern(<String, dynamic>{'image': image}),
          isNotNull);
      // Nothing usable in, nothing out — rather than a bogus shader.
      expect(controller.createPattern(null), isNull);
      expect(controller.createPattern('not an image'), isNull);
    });

    testWidgets('the webview bridge hooks record their payloads',
        (tester) async {
      final controller = await _mount(tester);
      // Flutter draws directly, so these have no bridge to serve; they retain
      // the payload for host inspection and API compatibility.
      controller.onWebViewMessage(<String, dynamic>{'type': 'ready'});
      expect(controller.lastWebViewMessage, <String, dynamic>{'type': 'ready'});
      controller.onWebViewTouch(<String, dynamic>{'x': 1});
      expect(controller.lastWebViewTouch, <String, dynamic>{'x': 1});
      // No nvue file layer on Flutter, so this resolves null rather than
      // faking a data URL.
      expect(await controller.readNvueFileAsDataURL('/tmp/a.png'), isNull);
    });
  });
}
