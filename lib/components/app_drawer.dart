import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/src/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:receitas_de_pao/components/circular_border_radius.dart';
import 'package:receitas_de_pao/components/rounded.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/keys/nav_keys.dart';
import 'package:receitas_de_pao/models/my_app/image_uploaded.dart';
import 'package:receitas_de_pao/repository/firebase_repository.dart';
import 'package:receitas_de_pao/services/emoji_service.dart';
import 'package:receitas_de_pao/state/ads_state/ads_cubit.dart';
import 'package:receitas_de_pao/state/auth_state/auth_cubit.dart';
import 'package:receitas_de_pao/state/nav_bar_state/nav_bar_cubit.dart';
import 'package:receitas_de_pao/state/register_user_state/register_user_cubit.dart';
import 'package:receitas_de_pao/utils/assets.dart';
import 'package:receitas_de_pao/utils/screen.dart';
import 'package:receitas_de_pao/views/modal/modal_fale_conosco.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/my_app/user_chef.dart';
import '../utils/show_start_rate.dart';
import '../utils/string_utils.dart';
import '../views/rate_app_init_widget.dart';
import 'dialog_login.dart';

class AppDrawer extends StatefulWidget {
  User user;
  RateMyApp rateMyApp;

  AppDrawer({this.user, this.rateMyApp});
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Screen screen;
  AuthCubit _authCubit;

  User get _user => widget.user;
  RegisterUserCubit _userCubit;
  NavBarCubit _navBarCubit;
  AdsCubit _adsCubit;

  @override
  void initState() {
    super.initState();
    _adsCubit = context.read<AdsCubit>();
    _authCubit = context.read<AuthCubit>();
    _userCubit = context.read<RegisterUserCubit>();

    _navBarCubit = context.read<NavBarCubit>();
  }

  @override
  Widget build(BuildContext context) {
    screen = Screen(context);
    return Container(
      height: screen.height,
      child: Drawer(
        key: NavKeys.drawer,
        child: _drawerChild(),
      ),
    );
  }

  _drawerChild() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 15,
                child: _userName(),
              ),
              Flexible(
                flex: 70,
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      child: _imageDrawer(),
                    ),
                  ),
                ),
              ),
              Flexible(flex: 15, child: _email()),
            ],
          ),
          decoration: BoxDecoration(
            color: Colors.pink,
          ),
        ),
        _receitasTile(),
        //s_lojaTile(),
        //_perfilTile(),
        _listaComprasTile(),
        _fazerLoginTile(),
        _logoutTile(),
        Divider(),

        _avaliarTile(),

        //_dicasCulinariasTile(),

        //_timerTile(),

        _sugestoesTile(),
        _recomendarTile(),
      ],
    );
  }

  _timerTile() {
    return ListTile(
        leading: Text(
          'Timer',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        trailing: Icon(
          Icons.timer,
          color: Colors.pink[900],
        ),
        onTap: () {
          Navigator.of(context).pop();
          NavKeys.initialPage.currentState
              .restorablePushNamed(AppRoutes.timerPage);
        });
  }

  _receitasTile() {
    return ListTile(
      leading: Text(
        'Ver Receitas',
        style: TextStyle(fontSize: 18),
      ),
      trailing: Icon(
        Icons.copy,
        color: Colors.pink[900],
      ),
      onTap: () {
        _adsCubit.showAd();
        Navigator.of(context).pop();
        NavKeys.initialPage.currentState
            .pushNamedAndRemoveUntil(AppRoutes.receitasFeedPage, (route) {
          return route.settings.name == AppRoutes.initialPage;
        });

        _navBarCubit.updateIndex(NavBarCubit.INDEX_FEED);
      },
    );
  }

  _lojaTile() {
    return ListTile(
      leading: Text(
        'Cursos e Ebooks',
        style: TextStyle(fontSize: 18),
      ),
      trailing: Icon(
        Icons.school,
        color: Colors.pink[900],
      ),
      onTap: () {
        Navigator.of(context).pop();
        NavKeys.initialPage.currentState.pushNamed(AppRoutes.lojaPage);
      },
    );
  }

  _listaComprasTile() {
    return ListTile(
      leading: Text(
        'Lista de Compras',
        style: TextStyle(fontSize: 18),
      ),
      trailing: Icon(
        Icons.checklist_rounded,
        color: Colors.pink[900],
      ),
      onTap: () {
        _adsCubit.showAd();
        Navigator.of(context).pop();
        NavKeys.initialPage.currentState.pushNamed(AppRoutes.listaComprasPage);
      },
    );
  }

  // _dicasCulinariasTile() {
  //   return ListTile(
  //     leading: Text(
  //       'Dicas Culinárias',
  //       style: TextStyle(fontSize: 18),
  //     ),
  //     trailing: Icon(
  //       Icons.tips_and_updates_rounded,
  //       color: Colors.pink[900],
  //     ),
  //     onTap: () {
  //       Navigator.of(context).pop();
  //       NavKeys.initialPage.currentState
  //           .pushNamed(AppRoutes.dicasCulinariasPage);
  //     },
  //   );
  // }

  // _perfilTile() {
  //   if (_userNotAuthenticated()) {
  //     return Container();
  //   } else {
  //     return ListTile(
  //       leading: Text(
  //         'Meu Perfil',
  //         style: TextStyle(fontSize: 18),
  //       ),
  //       trailing: Icon(
  //         Icons.person,
  //         color: Colors.pink[900],
  //       ),
  //       onTap: () {
  //         Navigator.of(context).pop();
  //         NavKeys.initialPage.currentState.pushNamed(AppRoutes.editUserPage);
  //       },
  //     );
  //   }
  // }

  _sugestoesTile() {
    return ListTile(
        leading: Text(
          'Fale Conosco (sugestões)',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        trailing: Icon(
          Icons.email,
          color: Colors.pink[900],
        ),
        onTap: () {
          _showModalSugestoes();
        });
  }

  _recomendarTile() {
    return ListTile(
        leading: Text(
          'Recomendar o app',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        trailing: Icon(
          Icons.share,
          color: Colors.pink[900],
        ),
        onTap: () {
          _recomendarApp();
        });
  }

  _recomendarApp() async {
    String message = await _formatMessageRecomendar();
    await Share.share(message, subject: 'App - Receitas de Pães');
  }

  Future<String> _formatMessageRecomendar() async {
    String appLink = await _getAppLink();

    var sb = StringBuffer();

    var winkingEmoji = EmojiService.winking();
    var pointingDown = EmojiService.pointingDown();
    var smiling = EmojiService.smiling();
    var festim = EmojiService.festim();

    sb.write('Olá, eu estou usando o app *Receitas de Pães*!');
    sb.write('\n\n');
    sb.write('Baixe agora você também! $smiling $festim $pointingDown');
    sb.write('\n');
    sb.write(appLink);
    return sb.toString();
  }

  _getAppLink() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var packageName = packageInfo.packageName;

    return "http://play.google.com/store/apps/details?id=$packageName";
  }

  _showModalSugestoes() {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.95,
          child: DraggableScrollableSheet(
            initialChildSize: 1,
            minChildSize: 0.5,
            maxChildSize: 1,
            builder: (_, scrollController) {
              return Rounded(
                radius: CircularBorderRadius.onlyTop(15),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.only(
                    top: 20,
                    right: 20,
                    left: 20,
                    bottom: 20,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: ModalFaleConosco(onComplete: () {
                      Navigator.of(context).pop();
                    }),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  _avaliarTile() {
    return ListTile(
        leading: Text(
          'Avalie nosso app!',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        trailing: Icon(
          Icons.star,
          color: Colors.pink[900],
        ),
        onTap: () async {
          Navigator.of(context).pop();
          String appLink = await _getAppLink();
          launchUrl(
            Uri.parse(appLink),
            mode: LaunchMode.externalApplication,
          );
          //ShowStarRate(context: context, rateMyApp: widget.rateMyApp).show();
        });
  }

  _listaDeComprasTile() {
    return ListTile(
        leading: Text(
          'Lista de Compras',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        trailing: Icon(
          Icons.shopping_cart,
          color: Colors.pink[900],
        ),
        onTap: () {
          Navigator.of(context, rootNavigator: true).pop();
          NavKeys.initialPage.currentState
              .pushNamed(AppRoutes.listaComprasPage);
        });
  }

  _fazerLoginTile() {
    if (_user != null && !_user.isAnonymous) {
      return Container();
    } else {
      return ListTile(
          leading: Text(
            'Fazer Login',
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          trailing: Icon(
            Icons.account_circle,
            color: Colors.pink[900],
          ),
          onTap: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil(AppRoutes.loginPage, (route) => false);
          });
    }
  }

  _logoutTile() {
    UserChef userChef = _userCubit.userChef;
    if (_userNotAuthenticated() || userChef == null) {
      return Container();
    }
    return ListTile(
        leading: Text(
          'Sair',
          style: TextStyle(
            fontSize: 18,
          ),
        ),
        trailing: Icon(
          Icons.logout,
          color: Colors.pink[900],
        ),
        onTap: () {
          log('log out clicked $_authCubit');
          _authCubit.logout();
          Navigator.of(context)
              .pushNamedAndRemoveUntil(AppRoutes.loginPage, (route) => false);
        });
  }

  _email() {
    UserChef userChef = _userCubit.userChef;
    if (_userNotAuthenticated() || userChef == null) {
      return Container();
    } else {
      return Text(
        userChef.email,
        style: TextStyle(
          color: Colors.red[100],
        ),
      );
    }
  }

  _userName() {
    UserChef userChef = _userCubit.userChef;
    String userName;
    if (_userNotAuthenticated() || _userCubit.isInvalidUser) {
      userName = 'Receitas de Pães!';
    } else {
      userName = userChef.nome + ' ' + userChef.sobrenome;
    }
    return Text(
      userName,
      style: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  _imageDrawer() {
    UserChef userChef = _userCubit.userChef;
    if (showDefaultImage()) {
      return _defaultUserImage();
    } else {
      ImageUploaded imagePerfil = userChef.imagePerfil;
      return Image.network(
        imagePerfil.url,
        errorBuilder: (context, obj, stk) {
          return Image.asset(MyAssets.IMAGE_ERROR);
        },
      );
    }
  }

  bool _userNotAuthenticated() {
    return _user == null || _user.isAnonymous;
  }

  showDefaultImage() {
    UserChef userChef = _userCubit.userChef;
    if (_userNotAuthenticated()) {
      return true;
    }

    if (_userCubit.isInvalidUser) {
      return true;
    }

    bool hasValidImage = userChef.imagePerfil != null &&
        !StringUtils.isNullOrEmpty(userChef.imagePerfil.url);
    if (!hasValidImage) {
      return true;
    }

    return false;
  }

  _defaultUserImage() {
    return Image.asset(MyAssets.CHEF_PERFIL);
  }
}
