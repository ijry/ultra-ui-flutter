/// Real PDF and video backends for `ultra_ui`.
///
/// `ultra_ui` deliberately ships no native dependencies, so `UPPdfReader` and
/// `UPShortVideo` render placeholders until a host supplies a real engine. Wire
/// these widgets into their builder hooks to get working playback and rendering:
///
/// ```dart
/// UPPdfReader(
///   src: 'https://example.com/doc.pdf',
///   viewerBuilder: (viewerUrl) =>
///       UPPdfView(target: resolvePdfTarget(viewerUrl)),
/// )
///
/// UPShortVideo(
///   videoList: items,
///   videoBuilder: (item, index, playing) =>
///       UPVideoView(src: '${item['src']}', playing: playing),
/// )
/// ```
library;

export 'src/up_pdf_view.dart' show UPPdfView, resolvePdfTarget;
export 'src/up_video_view.dart' show UPVideoView;
