import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receitas_de_pao/main.dart';
import 'package:receitas_de_pao/notification/notification_service.dart';
import 'package:receitas_de_pao/state/timer_state/timer_state.dart';

class TimerCubit extends Cubit<TimerState> {
  TimerCubit() : super(TimerState());

  bool started = false;
  bool paused = false;
  bool running = false;
  bool finish = false;
  AudioPlayer _audioPlayer;
  Timer _timer;
  CountDownController countdownController;
  int _countdown = 0;
  int _initialSeconds = 60;
  int _finalInitialSeconds = 60;
  static GlobalKey key = GlobalKey();

  isPausedState() {
    return started && !running && paused && !finish;
  }

  isFinishedState() {
    return started == true &&
        running == false &&
        paused == false &&
        finish == true;
  }

  isInitialState() {
    return started == false &&
        running == false &&
        paused == false &&
        finish == false;
  }

  _initialState() {
    started = false;
    paused = false;
    running = false;
    finish = false;
    emit(TimerState());
  }

  isRunningState() {
    return started == true &&
        running == true &&
        paused == false &&
        finish == false;
  }

  _runningState() {
    started = true;
    running = true;
    paused = false;
    finish = false;
    emit(TimerState());
  }

  _pausedState() {
    started = true;
    running = false;
    paused = true;
    finish = false;
    emit(TimerState());
  }

  _finishedState() {
    started = true;
    paused = false;
    running = false;
    finish = true;
    emit(TimerState());
  }

  _schedule(int remainingSeconds) {
    _countdown = remainingSeconds;

    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (_countdown == 0) {
        _finishedState();

        countdownController.reset();
        timer.cancel();
        flutterLocalNotificationsPlugin.cancel(1);
        await NotificationService.showNotification(
          id: 1,
          body: 'O timer finalizou!',
          onGoing: false,
          title: 'Hora de conferir sua receita!',
          playSound: true,
          enableVibration: true,
        );
        _audioPlayer = AudioPlayer(
          playerId: 'timer_receitas',
        );
        _audioPlayer.setReleaseMode(ReleaseMode.loop);

        await _audioPlayer.play(
          AssetSource(
            'timer_completed.mp3',
          ),
        );
        await Future.delayed(Duration(seconds: 30));

        if (isFinishedState()) {
          _audioPlayer.stop();
          _initialSeconds = _finalInitialSeconds;
          _initialState();
        }
      } else {
        _countdown--;
        _initialSeconds--;
      }
    });
  }

  pause() {
    if (isFinishedState()) {
      _initialSeconds = _finalInitialSeconds;
      _audioPlayer.stop();
      _initialState();
    } else {
      if (_timer != null) {
        _timer.cancel();
      }
      _pausedState();
      countdownController.pause();
    }
  }

  iniciar() async {
    countdownController.start();
    countdownController.pause();
    if (isInitialState()) {
      log('state is initial');
      countdownController.restart(duration: _initialSeconds);
      _schedule(_initialSeconds);
    } else if (isRunningState()) {
      log('state is running');
      countdownController.restart(duration: _countdown);
      _schedule(_countdown);
    }
    _runningState();
  }

  resumir() async {
    _runningState();
    countdownController.restart(duration: _countdown);
    _schedule(_countdown);
  }

  updateDuration(int seconds) {
    if (isFinishedState()) {
      _audioPlayer.stop();
    }
    _initialSeconds = seconds;
    _countdown = seconds;
    _finalInitialSeconds = seconds;
    countdownController.restart(duration: seconds);
    countdownController.pause();
    _initialState();
  }

  duration() {
    if (isInitialState()) {
      log('is initial $_initialSeconds');
      return _initialSeconds;
    } else if (isFinishedState()) {
      return _finalInitialSeconds;
    }
    log('not is initial $_countdown');
    return _countdown;
  }

  initState(int initialSeconds, CountDownController cdController) {
    countdownController = cdController;
    if (isInitialState()) {
      _initialSeconds = initialSeconds;
      _finalInitialSeconds = initialSeconds;
      _initialState();
    } else if (isRunningState()) {
      iniciar();
    }
  }
}
