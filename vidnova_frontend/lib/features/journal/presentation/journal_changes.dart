import 'package:flutter/foundation.dart';

class JournalChanges {
  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  static void bump() {
    version.value = version.value + 1;
  }
}
