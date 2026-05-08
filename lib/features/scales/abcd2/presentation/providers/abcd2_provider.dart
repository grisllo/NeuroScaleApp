import 'package:flutter_riverpod/flutter_riverpod.dart';

class Abcd2AnswersNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() => {};

  void setAnswer(String key, int value) {
    state = {...state, key: value};
  }

  void reset() => state = {};
}

final abcd2AnswersProvider =
    NotifierProvider.autoDispose<Abcd2AnswersNotifier, Map<String, int>>(
      Abcd2AnswersNotifier.new,
    );
