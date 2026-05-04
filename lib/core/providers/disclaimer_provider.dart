import 'package:flutter_riverpod/flutter_riverpod.dart';

class DisclaimerAcceptedNotifier extends Notifier<bool> {
  DisclaimerAcceptedNotifier([this._initial = false]);

  final bool _initial;

  @override
  bool build() => _initial;

  void accept() => state = true;
}

final disclaimerAcceptedProvider =
    NotifierProvider<DisclaimerAcceptedNotifier, bool>(
      DisclaimerAcceptedNotifier.new,
    );
