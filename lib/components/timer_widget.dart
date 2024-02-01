import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:duration_picker/duration_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:receitas_de_pao/state/ads_state/ads_cubit.dart';
import 'package:receitas_de_pao/state/timer_state/timer_cubit.dart';
import 'package:receitas_de_pao/state/timer_state/timer_state.dart';
import 'package:receitas_de_pao/style/palete.dart';
import 'package:receitas_de_pao/utils/screen.dart';

class TimerWidget extends StatefulWidget {
  int seconds;

  TimerWidget({this.seconds});

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  int get seconds => widget.seconds;
  TimerCubit _timerCubit;
  AdsCubit _adsCubit;
  CountDownController cdController = CountDownController();

  @override
  void initState() {
    super.initState();
    _timerCubit = context.read<TimerCubit>();
    _adsCubit = context.read<AdsCubit>();
    log('teste 1');
  }

  @override
  Widget build(BuildContext context) {
    log('teste 2');
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _timerCubit.initState(
        seconds,
        cdController,
      );
    });

    return BlocBuilder<TimerCubit, TimerState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                CircularCountDownTimer(
                  controller: cdController,
                  height: Screen.of(context).height * 0.15,
                  duration: _timerCubit.duration(),
                  fillColor: Palete().RED_100,
                  ringColor: Palete().PINK_700,
                  autoStart: false,
                  isReverse: true,
                  timeFormatterFunction: (formatter, duration) {
                    String horas = duration.inHours.toString().padLeft(2, '0');
                    String minutos = duration.inMinutes
                        .remainder(60)
                        .toString()
                        .padLeft(2, '0');
                    String segundos = duration.inSeconds
                        .remainder(60)
                        .toString()
                        .padLeft(2, '0');

                    String tempo = '$horas:$minutos:$segundos';
                    if (tempo == '00:00:00') {
                      return 'Completo!';
                    }
                    return tempo;
                  },
                  textStyle: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 5),
                _btnPlay(),
                _btnPause(),
                Text('*Não encerrar o app para receber a notificação!')
              ],
            ),
            SizedBox(
              width: 10,
            ),
            GestureDetector(
              onTap: () async {
                Duration duration = await showDurationPicker(
                    context: context,
                    initialTime: Duration(minutes: 30),
                    snapToMins: 5);
                if (duration != null &&
                    duration.compareTo(Duration(seconds: 0)) > 0) {
                  _timerCubit.updateDuration(duration.inSeconds);
                }
              },
              child: Column(
                children: [
                  Text(
                    'Editar',
                    style: TextStyle(
                      color: Palete().PINK_700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.edit,
                    color: Palete().PINK_700,
                  )
                ],
              ),
            )
          ],
        );
      },
    );
  }

  _btnPlay() {
    if (_timerCubit.isPausedState()) {
      return ElevatedButton(
        onPressed: () {
          _adsCubit.showAd();
          _timerCubit.resumir();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow),
            Text('Resumir'),
          ],
        ),
      );
    } else if (_timerCubit.isInitialState()) {
      return ElevatedButton(
        onPressed: () {
          _adsCubit.showAd();
          _timerCubit.iniciar();
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow),
            Text('Iniciar'),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  _btnPause() {
    if (_timerCubit.isInitialState() || _timerCubit.isPausedState()) {
      return Container();
    }
    return ElevatedButton(
      onPressed: () {
        _timerCubit.pause();
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pause),
          Text('Pausar'),
        ],
      ),
    );
  }

  // backgroundNotification() async {
  //   AndroidAlarmManager.oneShotAt(
  //     DateTime.now(),
  //     1,
  //     callBackDispatcher,
  //     exact: true,
  //     wakeup: true,
  //     rescheduleOnReboot: false,
  //     allowWhileIdle: true,
  //   );
  // }

}
