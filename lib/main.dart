import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:receitas_de_pao/keys/nav_keys.dart';

import 'package:receitas_de_pao/notification/notification_service.dart';
import 'package:receitas_de_pao/repository/asset_repository.dart';
import 'package:receitas_de_pao/repository/preferences_repository.dart';
import 'package:receitas_de_pao/routes/app_router.dart';
import 'package:receitas_de_pao/scraping/receitas_scraping.dart';
import 'package:receitas_de_pao/state/ads_state/ads_cubit.dart';
import 'package:receitas_de_pao/state/carousel_state/carousel_cubit.dart';
import 'package:receitas_de_pao/state/etapa_cubit.dart';
import 'package:receitas_de_pao/state/lista_compras_state/lista_compras_cubit.dart';
import 'package:receitas_de_pao/state/nav_bar_state/nav_bar_cubit.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/state/register_user_state/register_user_cubit.dart';
import 'package:receitas_de_pao/state/timer_state/timer_cubit.dart';
import 'package:receitas_de_pao/style/palete.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';
import 'package:receitas_de_pao/views/auth_wrapper.dart';
import 'package:receitas_de_pao/views/edit_receita_page_old.dart';
import 'package:receitas_de_pao/views/receita_page.dart';
import 'package:receitas_de_pao/views/register_user_page.dart';
import 'package:receitas_de_pao/views/search_receitas_page.dart';
import 'package:receitas_de_pao/views/timer_page.dart';

import 'ads/ad_state.dart';
import 'ads/app_open_ad_cubit.dart';
import 'ads/my_ads.dart';
import 'api/purchase_api.dart';
import 'routes/app_routes.dart';
import 'enums/notification_channel_keys.dart';
import 'state/auth_state/auth_cubit.dart';
import 'state/receita_state/new_receita_cubit.dart';
import 'state/receita_state/receita_cubit.dart';
import 'utils/arguments.dart';
import 'utils/assets.dart';
import 'utils/screen.dart';
import 'views/initial_page.dart';
import 'views/login_page.dart';
import 'package:provider/provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'views/new_edit_receita_page.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'notification_channel',
  'Receitas de Pães',
  description: 'Teste de Notificação',
  importance: Importance.high,
  playSound: false,
);

void callBackDispatcher() async {
  await NotificationService.showNotification(
    id: 1,
    body: 'O timer finalizou!',
    onGoing: false,
    title: 'Receita pronta!',
    playSound: true,
    enableVibration: true,
  );
  final _audioPlayer = AudioPlayer(
    playerId: 'timer_receitas',
  );
  _audioPlayer.setReleaseMode(ReleaseMode.loop);

  await _audioPlayer.play(
    AssetSource(
      'timer_completed.mp3',
    ),
  );
  await Future.delayed(Duration(seconds: 10));
  _audioPlayer.stop();
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //await AndroidAlarmManager.initialize();
  await NotificationService.initialize();
  _initializeNotifications();

  final initFuture = MobileAds.instance.initialize();
  final adState = AdState(initFuture);

  await PurchaseApi.init();

  runApp(MultiProvider(
    providers: [
      Provider.value(
        value: adState,
      ),
      BlocProvider(create: (_) => AdsCubit()),
      BlocProvider(create: (_) => NewReceitaCubit()),
      BlocProvider(create: (_) => AuthCubit(FirebaseAuth.instance)),
      BlocProvider(create: (_) => EtapaCubit()),
      BlocProvider(create: (_) => RegisterUserCubit()),
      BlocProvider(create: (_) => NavBarCubit()),
      BlocProvider(create: (_) => CarouselCubit()),
      BlocProvider(create: (_) => TimerCubit()),
      BlocProvider(create: (_) => OpenAppAdCubit()),
      BlocProvider(create: (_) => ListaComprasCubit()),
      BlocProvider(create: (_) => PremiumCubit()),
    ],
    child: MyApp(),
  ));
}

_initializeNotifications() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseNotificationBackgroundHandler);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  _configureNotificationTestDevice();
  _listenFirebaseNotifications();
}

Future<void> _firebaseNotificationBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp();
  log('firebase message: ${message.messageId}');
}

_configureNotificationTestDevice() async {
  await FirebaseMessaging.instance
      .getToken()
      .then((value) => log('firebase message token: $value '));
}

_listenFirebaseNotifications() {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    log('firebase message received');
    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          color: Colors.pink[900],
          channelDescription: channel.description,
          icon: 'ic_notification',
          largeIcon: DrawableResourceAndroidBitmap('codex_logo'),
        )),
      );
    }
  });
}

// _initializeNotifications() async {
//   var initializationSettingsAndroid =
//       AndroidInitializationSettings('codex_logo');
//   var initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onSelectNotification: (String payload) async {
//     if (payload != null) {
//       debugPrint('notification payload: $payload');
//     }
//   });
// }

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  OpenAppAdCubit _openAppAdCubit;
  PremiumCubit _premiumCubit;
  @override
  void initState() {
    super.initState();
    _openAppAdCubit = context.read<OpenAppAdCubit>();
    _premiumCubit = context.read<PremiumCubit>();
    _premiumCubit.init();
    WidgetsBinding.instance.addObserver(this);

    //_openAppAdCubit.loadOpenAd(true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final paused = state == AppLifecycleState.paused;
    final resumed = state == AppLifecycleState.resumed;

    if (paused) {
      _openAppAdCubit.updateAppPaused(paused);
    } else if (resumed) {
      if (_openAppAdCubit.isAppPaused()) {
        _openAppAdCubit.updateAppPaused(false);
        _openAppAdCubit.showAd();
      }
    }

    log('open ad app state: $state');
  }

  @override
  Widget build(BuildContext context) {
    return _buildApp();
  }

  _buildApp() {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('pt', 'BR'),
      ],
      theme: _createTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.initialPage,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }

  _createTheme() {
    var palete = Palete();
    return ThemeData(
      fontFamily: GoogleFonts.lato().fontFamily,
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(palete.RED_700))),
      //accentColor: palete.RED_700,
      appBarTheme: AppBarTheme(color: palete.RED_700),
    );
  }
}
