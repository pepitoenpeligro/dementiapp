import 'dart:async';
import 'package:location/state/AuthState.dart';
import 'package:meta/meta.dart';

class TimerService {
  TimerService();

  final listeners = <void Function()>[];

  void addListener(void Function() listener) {
    assert(!listeners.contains(listener));
    listeners.add(listener);
  }

  void removeListener(void Function() listener) {
    assert(listeners.contains(listener));
    listeners.remove(listener);
  }

  bool get isRunning => _isRunning;

  void fire() {
    if (isRunning) {
      for (final listener in listeners) {
        listener();
      }
    }
  }

  @mustCallSuper
  void start() {
    _isRunning = true;
  }

  @mustCallSuper
  void stop() {
    _isRunning = false;
  }

  @mustCallSuper
  void dispose() {
    stop();
    listeners.clear();
  }

  bool _isRunning = false;
}

class ProgramaticTimerService extends TimerService {
  Function codeToExecute;

  ProgramaticTimerService(
      {required this.interval, required this.codeToExecute});

  late Duration interval;

  @override
  void start() {
    _timer ??= Timer.periodic(interval, (_) => {codeToExecute()});
    super.start();
  }

  @override
  void stop() {
    _timer?.cancel();
    _timer = null;
    super.stop();
  }

  @override
  bool get isRunning {
    return _timer != null;
  }

  Timer? _timer;
}
