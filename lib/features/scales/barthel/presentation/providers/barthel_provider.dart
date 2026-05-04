import 'package:flutter_riverpod/flutter_riverpod.dart';

class BarthelAnswersNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void setAnswer(String key, int value) {
    state = {...state, key: value};
  }

  void reset() => state = {};
}

final barthelAnswersProvider =
    NotifierProvider<BarthelAnswersNotifier, Map<String, int>>(
      BarthelAnswersNotifier.new,
    );
