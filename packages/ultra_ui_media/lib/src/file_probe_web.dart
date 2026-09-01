import 'package:video_player/video_player.dart';

bool localFileExists(String path) => false;

/// Web has no filesystem, so [localFileExists] never routes here. This exists
/// only to give callers one signature that compiles on every platform.
VideoPlayerController fileVideoController(String path) =>
    throw UnsupportedError('local video files are not available on web');
