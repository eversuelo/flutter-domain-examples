import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' as io;

class PlatformUtils {
  static bool get isWeb => kIsWeb;
  static bool get isAndroid => !kIsWeb && io.Platform.isAndroid;
  static bool get isIOS => !kIsWeb && io.Platform.isIOS;
  static bool get isDesktop => !kIsWeb && (io.Platform.isWindows || io.Platform.isMacOS || io.Platform.isLinux);
}