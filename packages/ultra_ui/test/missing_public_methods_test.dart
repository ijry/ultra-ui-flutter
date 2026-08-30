import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui/ultra_ui.dart';

Future<ui.Image> _solidImage() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 16, 16),
    Paint()..color = const Color(0xff2e7d32),
  );
  return recorder.endRecording().toImage(16, 16);
}

class _SyncPosterCanvas {
  int calls = 0;

  void draw(bool reserve, VoidCallback done) {
    expect(reserve, isFalse);
    calls += 1;
    done();
  }
}

void main() {
  testWidgets(
      'datetime reInitColumns keeps the pending value and emits only a correction',
      (tester) async {
    final key = GlobalKey<UPDatetimePickerState>();
    final changes = <dynamic>[];

    Widget build({required int minMinute}) {
      return MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPDatetimePicker(
            key: key,
            mode: 'time',
            modelValue: '15:30',
            minMinute: minMinute,
            onChange: (value) {
              changes
                  .add(value is Map ? Map<String, dynamic>.from(value) : value);
            },
          ),
        ),
      );
    }

    await tester.pumpWidget(build(minMinute: 0));
    key.currentState!.setValue('15:40');
    await tester.pump();
    changes.clear();

    await tester.pumpWidget(build(minMinute: 50));
    await tester.pump();

    expect(key.currentState!.getInputValue(), '15:50');
    expect(changes, [
      {'value': '15:50', 'mode': 'time'},
    ]);

    // A second bounds update that leaves the value valid must not duplicate
    // the synthetic change event.
    await tester.pumpWidget(build(minMinute: 50));
    await tester.pump();
    expect(key.currentState!.getInputValue(), '15:50');
    expect(changes, [
      {'value': '15:50', 'mode': 'time'},
    ]);
  });

  testWidgets('cropper loadImage uses the requested path loader',
      (tester) async {
    final image = await _solidImage();
    final key = GlobalKey<UPCropperState>();
    String? requestedPath;

    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPCropper(
            key: key,
            areaWidth: 40,
            areaHeight: 40,
            exportWidth: 24,
            exportHeight: 24,
            imageLoader: (path) async {
              requestedPath = path;
              return image;
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await key.currentState!.loadImage('picked://green');
    final exported = await key.currentState!.exportImage();

    expect(requestedPath, 'picked://green');
    expect(key.currentState!.imagePath, 'picked://green');
    expect(exported, isNotNull);
    expect(exported!.width, 24);
    expect(exported.height, 24);
  });

  testWidgets('popup close event is not duplicated by the show watcher',
      (tester) async {
    final key = GlobalKey<UPPopupState>();
    var show = true;
    var closes = 0;
    late StateSetter hostSetState;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            hostSetState = setState;
            return Scaffold(
              body: UPPopup(
                key: key,
                show: show,
                duration: 0,
                onClose: () => closes += 1,
                onUpdateShow: (value) => setState(() => show = value),
                child: const Text('popup'),
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    key.currentState!.close();
    await tester.pump();
    expect(closes, 1);

    hostSetState(() => show = true);
    await tester.pump();
    hostSetState(() => show = false);
    await tester.pump();
    expect(closes, 2);
  });

  testWidgets('nested popup can leave close ownership to its wrapper',
      (tester) async {
    var show = true;
    var closes = 0;

    Widget build() => MaterialApp(
          home: Scaffold(
            body: UPPopup(
              show: show,
              duration: 0,
              emitCloseOnExternalShowChange: false,
              onClose: () => closes += 1,
              child: const Text('nested popup'),
            ),
          ),
        );

    await tester.pumpWidget(build());
    show = false;
    await tester.pumpWidget(build());
    await tester.pump();

    expect(closes, 0);
  });

  testWidgets('poster flushPosterCanvas waits for the draw callback',
      (tester) async {
    final key = GlobalKey<UPPosterState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(body: UPPoster(key: key)),
      ),
    );
    await tester.pump();

    // A missing host canvas is a supported no-op in the Flutter port.
    await key.currentState!.flushPosterCanvas();

    final canvas = _SyncPosterCanvas();
    await key.currentState!.flushPosterCanvas(canvas);
    expect(canvas.calls, 1);
  });

  testWidgets('drag sort exposes current item indexes and handler presence',
      (tester) async {
    final key = GlobalKey<UPDragSortState>();
    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPDragSort(
            key: key,
            initialList: const [
              {'id': 'a', 'label': 'A'},
              {'id': 'b', 'label': 'B'},
            ],
            handlerBuilder: (context, item, index) =>
                const Icon(Icons.drag_handle),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(key.currentState!.hasHandler, isTrue);
    expect(key.currentState!.getItemIndex('b'), 1);
    key.currentState!.move(1, 0, emit: false);
    expect(key.currentState!.getItemIndex('b'), 0);
    expect(key.currentState!.getItemIndex('missing'), -1);
  });

  testWidgets('list item resize stores the measured rectangle', (tester) async {
    final item = UPListItem(child: const SizedBox());
    final measured = <String, dynamic>{
      'width': 120.0,
      'height': 44.0,
      'left': 8.0,
      'top': 16.0,
    };

    final result = await item.resize(measured);

    expect(result, measured);
    expect(item.rect, measured);
    expect(item.show, isTrue);
  });

  testWidgets('swipe action parentData reflects autoClose', (tester) async {
    final key = GlobalKey<UPSwipeActionState>();

    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPSwipeAction(key: key, autoClose: true, children: const []),
        ),
      ),
    );
    await tester.pump();
    expect(key.currentState!.parentData, [true]);

    await tester.pumpWidget(
      MaterialApp(
        theme: UP.themeData(),
        home: Scaffold(
          body: UPSwipeAction(key: key, autoClose: false, children: const []),
        ),
      ),
    );
    await tester.pump();
    expect(key.currentState!.parentData, [false]);
  });
}
