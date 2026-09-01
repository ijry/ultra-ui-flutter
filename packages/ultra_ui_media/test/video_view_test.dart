import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultra_ui_media/ultra_ui_media.dart';

import 'fake_video_platform.dart';

void main() {
  late FakeVideoPlayerPlatform platform;

  setUp(() => platform = FakeVideoPlayerPlatform.install());

  // The loading state shows an indeterminate spinner, so pumpAndSettle never
  // returns. Pump a bounded number of frames to let async init microtasks run.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      // runAsync lets the controller's own async work (initialize, and the
      // awaited dispose chain) complete between frames.
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> pumpView(
    WidgetTester tester, {
    required bool playing,
    double rate = 1.0,
    String src = 'https://example.com/a.mp4',
    ValueChanged<double>? onProgress,
    VoidCallback? onEnded,
    ValueChanged<String>? onError,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: UPVideoView(
          src: src,
          playing: playing,
          playbackRate: rate,
          onProgress: onProgress,
          onEnded: onEnded,
          onError: onError,
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('a paused view initializes without starting playback',
      (tester) async {
    await pumpView(tester, playing: false);

    expect(platform.created, 1);
    expect(platform.playing, isFalse);
  });

  testWidgets('playing true starts playback once ready', (tester) async {
    await pumpView(tester, playing: true);

    expect(platform.playing, isTrue);
  });

  testWidgets('toggling playing drives play and pause', (tester) async {
    await pumpView(tester, playing: false);
    expect(platform.playing, isFalse);

    await tester.pumpWidget(
      const MaterialApp(
        home: UPVideoView(src: 'https://example.com/a.mp4', playing: true),
      ),
    );
    await settle(tester);
    expect(platform.playing, isTrue);

    await tester.pumpWidget(
      const MaterialApp(
        home: UPVideoView(src: 'https://example.com/a.mp4', playing: false),
      ),
    );
    await settle(tester);
    expect(platform.playing, isFalse);
  });

  testWidgets('playbackRate reaches the platform', (tester) async {
    await pumpView(tester, playing: true, rate: 1.5);

    expect(platform.speed, 1.5);
  });

  testWidgets('changing src rebuilds against a fresh controller',
      (tester) async {
    await pumpView(tester, playing: false);
    expect(platform.created, 1);

    await tester.pumpWidget(
      const MaterialApp(
        home: UPVideoView(src: 'https://example.com/b.mp4', playing: false),
      ),
    );
    await settle(tester);

    expect(platform.created, 2);
    expect(platform.disposed, 1);
  });

  testWidgets('progress is reported as a 0..1 fraction', (tester) async {
    final seen = <double>[];
    await pumpView(tester, playing: true, onProgress: seen.add);

    platform.emitPosition(const Duration(seconds: 5));
    // The controller polls the platform position every 500ms while playing.
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump();

    // The fake reports a 10s duration, so 5s is halfway.
    expect(seen.last, closeTo(0.5, 0.001));
  });

  testWidgets('a failed initialization surfaces the error', (tester) async {
    platform.failInitialize = true;
    final errors = <String>[];
    await pumpView(tester, playing: true, onError: errors.add);

    expect(errors, isNotEmpty);
  });

  testWidgets('the view disposes its controller on unmount', (tester) async {
    await pumpView(tester, playing: true);
    expect(platform.disposed, 0);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await settle(tester);

    expect(platform.disposed, 1);
  });
}
