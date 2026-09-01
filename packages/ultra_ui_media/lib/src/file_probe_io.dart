import 'dart:io';

import 'package:video_player/video_player.dart';

bool localFileExists(String path) {
  try {
    return File(path).existsSync();
  } on FileSystemException {
    return false;
  }
}

VideoPlayerController fileVideoController(String path) =>
    VideoPlayerController.file(File(path));
