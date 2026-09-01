// `dart:io` does not exist on web, so the filesystem probe is swapped out at
// compile time rather than guarded at runtime.
export 'file_probe_io.dart' if (dart.library.js_interop) 'file_probe_web.dart';
