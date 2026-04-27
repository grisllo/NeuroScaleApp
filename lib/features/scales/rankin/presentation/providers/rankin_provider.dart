import 'package:flutter_riverpod/flutter_riverpod.dart';

class RankinAnswersNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void setAnswer(String key, int value) {
    state = {...state, key: value};
  }

  void reset() => state = {};
}

final rankinAnswersProvider =
    NotifierProvider<RankinAnswersNotifier, Map<String, int>>(
  RankinAnswersNotifier.new,
);
