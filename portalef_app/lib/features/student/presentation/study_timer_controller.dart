import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final studyTimerProvider =
    StateNotifierProvider.autoDispose<StudyTimerController, StudyTimerState>((ref) {
  return StudyTimerController();
});

class StudyTimerController extends StateNotifier<StudyTimerState> {
  StudyTimerController() : super(const StudyTimerState(isRunning: false, elapsedSeconds: 0));

  Timer? _timer;

  void start() {
    if (state.isRunning) return;
    state = state.copyWith(isRunning: true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  void stop() {
    if (!state.isRunning) return;
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    stop();
    state = state.copyWith(elapsedSeconds: 0);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class StudyTimerState {
  const StudyTimerState({
    required this.isRunning,
    required this.elapsedSeconds,
  });

  final bool isRunning;
  final int elapsedSeconds;

  StudyTimerState copyWith({bool? isRunning, int? elapsedSeconds}) {
    return StudyTimerState(
      isRunning: isRunning ?? this.isRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    );
  }
}

