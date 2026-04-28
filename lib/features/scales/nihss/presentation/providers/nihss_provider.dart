import 'package:flutter_riverpod/flutter_riverpod.dart';

class NihssAnswersNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void setAnswer(String key, int value) {
    state = {...state, key: value};
  }

  void reset() => state = {};
}

final nihssAnswersProvider =
    NotifierProvider<NihssAnswersNotifier, Map<String, int>>(
  NihssAnswersNotifier.new,
);
