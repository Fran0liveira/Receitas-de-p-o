import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:receitas_de_pao/ads/ad_state.dart';
import 'package:receitas_de_pao/ads/ad_utils.dart';
import 'package:receitas_de_pao/ads/app_open_ad_cubit.dart';

import 'package:receitas_de_pao/ads/my_ads.dart';
import 'package:receitas_de_pao/arguments/receita_page_arguments.dart';
import 'package:receitas_de_pao/components/app_drawer.dart';
import 'package:receitas_de_pao/components/dialog_login.dart';
import 'package:receitas_de_pao/components/my_nav_bar.dart';
import 'package:receitas_de_pao/models/my_app/direct_link.dart';
import 'package:receitas_de_pao/models/my_app/item_compra.dart';
import 'package:receitas_de_pao/models/produto_afiliado.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/enums/crud_operation.dart';
import 'package:receitas_de_pao/keys/nav_keys.dart';
import 'package:receitas_de_pao/models/my_app/receita.dart';
import 'package:receitas_de_pao/services/user_storage_service.dart';
import 'package:receitas_de_pao/state/auth_state/auth_cubit.dart';
import 'package:receitas_de_pao/state/nav_bar_state/nav_bar_cubit.dart';
import 'package:receitas_de_pao/state/premium_state/premium_cubit.dart';
import 'package:receitas_de_pao/style/palete.dart';
import 'package:receitas_de_pao/utils/screen.dart';
import 'package:receitas_de_pao/views/change_password_page.dart';
import 'package:receitas_de_pao/views/dicas_culinarias_page.dart';
import 'package:receitas_de_pao/views/loja_page.dart';
import 'package:receitas_de_pao/views/minhas_receitas_page.dart';
import 'package:receitas_de_pao/views/new_edit_receita_page.dart';
import 'package:receitas_de_pao/views/new_receitas_feed_page.dart';
import 'package:receitas_de_pao/views/register_user_page.dart';
import 'package:receitas_de_pao/views/search_receitas_page.dart';
import 'package:receitas_de_pao/views/produto_afiliado_details_page.dart';
import 'package:receitas_de_pao/views/web_view_afiliado_page.dart';
import 'package:web_scraper/web_scraper.dart';
import '../main.dart';
import '../models/my_app/credentials.dart';
import '../models/my_app/user_chef.dart';
import '../repository/firebase_repository.dart';
import '../repository/preferences_repository.dart';
import '../scraping/receitas_scraping.dart';
import '../state/ads_state/ads_cubit.dart';
import '../state/ads_state/ads_state.dart';
import '../state/nav_bar_state/nav_bar_state.dart';
import '../state/register_user_state/register_user_cubit.dart';
import '../utils/arguments.dart';
import '../utils/string_utils.dart';
import 'edit_user_page.dart';
import 'lista_de_compras_page.dart';
import 'rate_app_init_widget.dart';
import 'receita_page.dart';
import 'receitas_favoritas_page.dart';
import 'receitas_feed_page.dart';
import 'timer_page.dart';

class InitialPage extends StatefulWidget {
  String redirectPage;

  InitialPage(this.redirectPage);

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  Screen screen;
  //BannerAd banner;
  InterstitialAd _interstitialAd;
  int _interstitialLoadAttempts = 0;
  int _maxFailedLoadAttempts = 3;
  AuthCubit _authCubit;
  User _user;
  Widget _futureReceitas;
  RegisterUserCubit _userCubit;
  NavBarCubit _navBarCubit;

  String get redirectPage => widget.redirectPage;
  AdState adState;
  final bucketGlobal = PageStorageBucket();
  PremiumCubit _premiumCubit;
  AdsCubit _adsCubit;
  OpenAppAdCubit _openAppAdCubit;

  @override
  void initState() {
    super.initState();
    adState = Provider.of<AdState>(context, listen: false);

    _authCubit = context.read<AuthCubit>();
    _premiumCubit = context.read<PremiumCubit>();
    _userCubit = context.read<RegisterUserCubit>();
    _navBarCubit = context.read<NavBarCubit>();
    _adsCubit = context.read<AdsCubit>();
    _openAppAdCubit = context.read<OpenAppAdCubit>();
    _navBarCubit.reset();

    _createInterstitialAd();
    _setupFutureReceitas();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('change dependencies');
  }

  Future<void> _fetchRequiredData() async {
    User user = _authCubit.getUser();
    log('the current user is ${user}');
    if (user == null || user.isAnonymous) {
      _user = user;
      _userCubit.setUserChef(null);
    } else {
      _user = user;
      UserChef userChef = await FirebaseRepository.getUserChef(id: user.uid);
      _userCubit.setUserChef(userChef);
    }
  }

  _setupFutureReceitas() {
    _futureReceitas = FutureBuilder(
      future: _fetchRequiredData(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case (ConnectionState.waiting):
            return Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              log('this is the error: ${snapshot.error}');
              return Center(
                child: Text('Não foi possível encontrar receitas! ' +
                    'Tente novamente mais tarde. Erro: ${snapshot.error.toString()}'),
              );
            } else {
              return _buildApp();
            }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    logCredentials();
    screen = Screen(context);
    return RateAppInitWidget(
      builder: (rate) {
        return _futureReceitas;
      },
    );
  }

  logCredentials() async {
    Credentials credentials = await UserStorageService.getCredentials();
    log('credentials: ' + credentials.toJson().toString());
  }

  _buildApp() {
    Widget widget = WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        drawer: AppDrawer(
          user: _user,
          rateMyApp: RateMyApp(
            googlePlayIdentifier: 'com.ksoft.receitas_de_pao',
            minDays: 0,
            minLaunches: 4,
          ),
        ),
        key: NavKeys.scaffoldKey,
        body: SafeArea(
            child: Container(
          height: screen.height,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BlocBuilder<AdsCubit, AdsState>(builder: (_, state) {
                if (state is LoadAdState) {
                  _createInterstitialAd();
                } else if (state is ShowAdState) {
                  _showInterstitialAd();
                }
                return Container();
              }),
              BlocBuilder<NavBarCubit, NavBarState>(builder: (context, state) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _redirectNestedNavigator());

                return Container();
              }),
              Flexible(
                child: Navigator(
                    key: NavKeys.initialPage,
                    onGenerateRoute: (settings) {
                      final pageName = settings.name;
                      log('page loaded: $pageName');

                      Widget page;
                      switch (pageName) {
                        case AppRoutes.home:
                        case AppRoutes.receitasFeedPage:
                          {
                            page = NewReceitasFeedPage(
                                onNovaReceitaPressed: _loadNovaReceitaPage);
                            break;
                            // page = ReceitasFeedPage(
                            //     onNovaReceitaPressed: _loadNovaReceitaPage);
                            // break;
                          }

                        case AppRoutes.receitaPage:
                          {
                            page = ReceitaPage(
                                settings.arguments as ReceitaPageArguments);
                            break;
                          }

                        case AppRoutes.timerPage:
                          {
                            page = TimerPage();
                            break;
                          }

                        case AppRoutes.minhasReceitasPage:
                          {
                            page = MinhasReceitasPage(
                                onNovaReceitaPressed: _loadNovaReceitaPage,
                                onEditReceitaPressed: (receita) {
                                  _loadEditReceitaPage(receita);
                                });
                            break;
                          }

                        case AppRoutes.editReceitaPage:
                          {
                            Receita receita = settings.arguments;
                            CrudOperation operation = receita == null
                                ? CrudOperation.CREATE
                                : CrudOperation.UPDATE;
                            page = NewEditReceitaPage(
                              receita: receita,
                              crudOperation: operation,
                            );
                            break;
                          }

                        case AppRoutes.receitasFavoritasPage:
                          {
                            page = ReceitasFavoritasPage(
                              onNovaReceitaPressed: _loadNovaReceitaPage,
                              onEditReceitaPressed: (receita) {
                                _loadEditReceitaPage(receita);
                              },
                              user: _user,
                            );
                            break;
                          }

                        case AppRoutes.editUserPage:
                          {
                            page = EditUserPage();
                            break;
                          }

                        case AppRoutes.searchReceitasPage:
                          {
                            page = SearchReceitasPage();
                            break;
                          }

                        case AppRoutes.changePassword:
                          {
                            page = ChangePasswordPage();
                            break;
                          }

                        case AppRoutes.listaComprasPage:
                          {
                            page = ListaComprasPage(
                              onNovaReceitaPressed: _loadNovaReceitaPage,
                            );
                            break;
                          }
                        case AppRoutes.dicasCulinariasPage:
                          {
                            page = DicasCulinariasPage(
                              onNovaReceitaPressed: _loadNovaReceitaPage,
                            );
                            break;
                          }

                        case AppRoutes.webViewAfiliadoPage:
                          {
                            DirectLink directLink = settings.arguments;
                            page = WebViewAfiliadoPage(
                              directLink: directLink,
                            );
                            break;
                          }

                        case AppRoutes.lojaPage:
                          {
                            page = LojaPage(
                              onNovaReceitaPressed: _loadNovaReceitaPage,
                            );
                            break;
                          }

                        // case AppRoutes.prodAfiliadoDetailsPage:
                        //   {
                        //     ProdAfiliado prodAfiliado = settings.arguments;
                        //     page = ProdutoAfiliadoDetailsPage(
                        //         prodAfiliado: prodAfiliado);
                        //     break;
                        //   }

                        default:
                          page = NewReceitasFeedPage(
                              onNovaReceitaPressed: _loadNovaReceitaPage);
                      }

                      return MaterialPageRoute(
                        builder: (context) => PageStorage(
                          child: page,
                          bucket: bucketGlobal,
                        ),
                        settings: settings,
                      );
                    }),
              ),
            ],
          ),
        )),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _showRedirects());
    return widget;
  }

  _showRedirects() {
    if (redirectPage == AppRoutes.editReceitaPage) {
      _loadNovaReceitaPage();
    }
  }

  _redirectNestedNavigator() {
    int currentIndex = _navBarCubit.currentIndex;
    if (currentIndex == NavBarCubit.INDEX_FEED) {
      NavKeys.initialPage.currentState
          .pushReplacementNamed(AppRoutes.receitasFeedPage);
    } else if (currentIndex == NavBarCubit.INDEX_FAVORITOS) {
      NavKeys.initialPage.currentState
          .pushReplacementNamed(AppRoutes.receitasFavoritasPage);
    } else if (currentIndex == NavBarCubit.INDEX_MINHAS_RECEITAS) {
      NavKeys.initialPage.currentState
          .pushReplacementNamed(AppRoutes.minhasReceitasPage);
    } else if (currentIndex == NavBarCubit.INDEX_LOJA) {
      NavKeys.initialPage.currentState.pushReplacementNamed(AppRoutes.lojaPage);
    }
  }

  Future<bool> _onBackPressed() async {
    bool popped = await NavKeys.initialPage.currentState.maybePop();
    if (popped) {
      NavKeys.scaffoldKey.currentState.closeDrawer();
    } else {
      NavKeys.scaffoldKey.currentState.openDrawer();
    }
    return false;
  }

  _changes(String value) {
    setState(() {});
  }

  _loadEditReceitaPage(Receita receita) {
    User user = _authCubit.getUser();
    if (user == null || user.isAnonymous) {
      _showDialogLogin();
      return;
    }
    NavKeys.initialPage.currentState
        .pushNamed(AppRoutes.editReceitaPage, arguments: receita);
  }

  _loadNovaReceitaPage() {
    User user = _authCubit.getUser();
    if (user == null || user.isAnonymous) {
      _showDialogLogin();
      return;
    }
    NavKeys.initialPage.currentState.pushNamed(AppRoutes.editReceitaPage);
    //_loadInterstitialAd();
  }

  _showDialogLogin() {
    DialogLogin().show(context);
  }

  _showInterstitialAd() {
    if (_premiumCubit.isPremiumMode()) {
      return;
    }
    if (_interstitialAd == null) {
      return;
    }

    _interstitialAd.fullScreenContentCallback =
        FullScreenContentCallback(onAdDismissedFullScreenContent: (ad) {
      setState(() {
        log('interstitial dismissed');
        _interstitialAd = null;
        ad.dispose();
      });
    }, onAdFailedToShowFullScreenContent: (ad, error) {
      setState(() {
        log('interstitial failed to show');
        _interstitialAd = null;
        ad.dispose();
        _createInterstitialAd();
      });
    }, onAdImpression: (ad) {
      log('interstitial impression');
    });
    _interstitialAd?.show();
  }

  _createInterstitialAd() {
    if (_premiumCubit.isPremiumMode()) {
      return;
    }
    log('loading interstitial');
    InterstitialAd.load(
      adUnitId: MyAds.intersticialAd,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
        setState(() {
          log('interstitial loaded');
          _interstitialAd = ad;
          _interstitialLoadAttempts = 0;
        });
      }, onAdFailedToLoad: (error) {
        setState(() {
          log('interstitial failed to load');
          _interstitialLoadAttempts++;
          _interstitialAd = null;
          if (_interstitialLoadAttempts <= _maxFailedLoadAttempts) {
            _createInterstitialAd();
          }
        });
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _interstitialAd?.dispose();
  }
}
