import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'file_probe.dart';

/// Plays a single video with video_player, for use as
/// [UPShortVideo.videoBuilder].
///
/// [playing] is the source's active-item state: the widget plays when it turns
/// true and pauses when it turns false, so the caller keeps driving playback
/// through the existing `playVideo` / `pauseCurrentVideo` API.
class UPVideoView extends StatefulWidget {
  const UPVideoView({
    super.key,
    required this.src,
    this.playing = false,
    this.looping = true,
    this.playbackRate = 1.0,
    this.fit = BoxFit.cover,
    this.onReady,
    this.onEnded,
    this.onProgress,
    this.onError,
  });

  /// http(s) URL, `file://` URI, bundled asset path, or filesystem path.
  final String src;
  final bool playing;
  final bool looping;
  final double playbackRate;
  final BoxFit fit;
  final VoidCallback? onReady;
  final VoidCallback? onEnded;

  /// Normalised 0..1 position, suitable for the source's `onTimeUpdate`.
  final ValueChanged<double>? onProgress;
  final ValueChanged<String>? onError;

  @override
  State<UPVideoView> createState() => _UPVideoViewState();
}

class _UPVideoViewState extends State<UPVideoView> {
  VideoPlayerController? _controller;
  bool _ready = false;
  bool _reportedEnd = false;

  @override
  void initState() {
    super.initState();
    _create();
  }

  @override
  void didUpdateWidget(covariant UPVideoView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.src != widget.src) {
      _disposeController();
      _create();
      return;
    }
    if (oldWidget.playing != widget.playing) _syncPlayback();
    if (oldWidget.playbackRate != widget.playbackRate) _syncRate();
    if (oldWidget.looping != widget.looping) {
      _controller?.setLooping(widget.looping);
    }
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    _ready = false;
    _reportedEnd = false;
    if (controller == null) return;
    controller.removeListener(_onTick);
    controller.dispose();
  }

  VideoPlayerController _build(String src) {
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return VideoPlayerController.networkUrl(Uri.parse(src));
    }
    if (src.startsWith('file://')) {
      return fileVideoController(Uri.parse(src).toFilePath());
    }
    if (localFileExists(src)) return fileVideoController(src);
    return VideoPlayerController.asset(src);
  }

  Future<void> _create() async {
    if (widget.src.isEmpty) return;
    final controller = _build(widget.src);
    _controller = controller;
    try {
      await controller.initialize();
    } catch (error) {
      if (!mounted || _controller != controller) return;
      widget.onError?.call('$error');
      setState(() => _ready = false);
      return;
    }
    // A newer src may have replaced this controller while it was initializing.
    if (!mounted || _controller != controller) {
      controller.dispose();
      return;
    }
    await controller.setLooping(widget.looping);
    controller.addListener(_onTick);
    setState(() => _ready = true);
    widget.onReady?.call();
    await _syncRate();
    await _syncPlayback();
  }

  Future<void> _syncPlayback() async {
    final controller = _controller;
    if (controller == null || !_ready) return;
    if (widget.playing) {
      await controller.play();
    } else {
      await controller.pause();
    }
  }

  Future<void> _syncRate() async {
    final controller = _controller;
    if (controller == null || !_ready) return;
    await controller.setPlaybackSpeed(widget.playbackRate);
  }

  void _onTick() {
    final controller = _controller;
    if (controller == null || !mounted) return;
    final value = controller.value;
    if (value.hasError) {
      widget.onError?.call(value.errorDescription ?? 'video error');
      return;
    }
    final total = value.duration.inMilliseconds;
    if (total > 0) {
      widget.onProgress?.call(value.position.inMilliseconds / total);
    }
    // Looping playback never reports completion, so only non-looping videos can
    // end, and the flag keeps the callback to one emit per playthrough.
    final ended = value.position >= value.duration && !value.isPlaying;
    if (ended && !_reportedEnd && total > 0) {
      _reportedEnd = true;
      widget.onEnded?.call();
    } else if (!ended && _reportedEnd) {
      _reportedEnd = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !_ready) {
      return const ColoredBox(
        color: Color(0xFF111111),
        child: Center(child: CircularProgressIndicator(color: Colors.white54)),
      );
    }
    return ColoredBox(
      color: const Color(0xFF111111),
      child: FittedBox(
        fit: widget.fit,
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
