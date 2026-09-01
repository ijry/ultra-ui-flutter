import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// In-memory stand-in for the video_player platform channel, so tests exercise
/// UPVideoView's own state machine without decoding real media.
class FakeVideoPlayerPlatform extends VideoPlayerPlatform {
  FakeVideoPlayerPlatform._();

  static FakeVideoPlayerPlatform install() {
    TestWidgetsFlutterBinding.ensureInitialized();
    final platform = FakeVideoPlayerPlatform._();
    VideoPlayerPlatform.instance = platform;
    return platform;
  }

  static const duration = Duration(seconds: 10);

  int created = 0;
  int disposed = 0;
  bool playing = false;
  double speed = 1.0;
  bool looping = false;
  bool failInitialize = false;

  int _nextId = 1;
  final _events = <int, StreamController<VideoEvent>>{};
  int? _activeId;

  /// Moves the active player's clock. The controller polls [getPosition] on a
  /// timer, so tests advance time after calling this to let the value land.
  void emitPosition(Duration position) {
    final id = _activeId;
    if (id == null) return;
    _positions[id] = position;
  }

  final _positions = <int, Duration>{};

  @override
  Future<void> init() async {}

  @override
  Future<int?> create(DataSource dataSource) =>
      createWithOptions(VideoCreationOptions(
        dataSource: dataSource,
        viewType: VideoViewType.textureView,
      ));

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    if (failInitialize) throw PlatformVideoError('cannot open source');
    created += 1;
    final id = _nextId++;
    _activeId = id;
    final controller = StreamController<VideoEvent>.broadcast();
    _events[id] = controller;
    _positions[id] = Duration.zero;
    // VideoPlayerController subscribes to videoEventsFor only after create()
    // returns, so the initialized event has to land after that or it is lost and
    // initialize() waits forever.
    Timer(Duration.zero, () {
      if (controller.isClosed) return;
      controller.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: duration,
          size: const Size(360, 640),
        ),
      );
    });
    return id;
  }

  @override
  Future<void> dispose(int playerId) async {
    disposed += 1;
    await _events.remove(playerId)?.close();
    _positions.remove(playerId);
    if (_activeId == playerId) _activeId = null;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) =>
      _events[playerId]?.stream ?? const Stream<VideoEvent>.empty();

  @override
  Future<void> play(int playerId) async => playing = true;

  @override
  Future<void> pause(int playerId) async => playing = false;

  @override
  Future<void> setLooping(int playerId, bool value) async => looping = value;

  @override
  Future<void> setPlaybackSpeed(int playerId, double value) async =>
      speed = value;

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async =>
      _positions[playerId] = position;

  @override
  Future<Duration> getPosition(int playerId) async =>
      _positions[playerId] ?? Duration.zero;

  @override
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Widget buildView(int playerId) => const SizedBox.expand();
}

class PlatformVideoError implements Exception {
  PlatformVideoError(this.message);

  final String message;

  @override
  String toString() => message;
}
