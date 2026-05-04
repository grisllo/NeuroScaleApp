import 'package:flutter_riverpod/flutter_riverpod.dart';

class GcsAnswersNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void setAnswer(String key, int value) {
    state = {...state, key: value};
  }

  void reset() => state = {};
}

final gcsAnswersProvider =
    NotifierProvider<GcsAnswersNotifier, Map<String, int>>(
      GcsAnswersNotifier.new,
    );
