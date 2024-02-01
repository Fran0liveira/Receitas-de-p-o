import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:receitas_de_pao/models/my_app/credentials.dart';
import 'package:receitas_de_pao/repository/preferences_repository.dart';
import 'package:receitas_de_pao/services/user_storage_service.dart';
import 'package:receitas_de_pao/state/auth_state/auth_cubit.dart';
import 'package:receitas_de_pao/state/auth_state/auth_state.dart';
import 'package:receitas_de_pao/utils/string_utils.dart';
import 'login_page.dart';

class AuthWrapper extends StatefulWidget {
  Widget child;

  AuthWrapper({this.child});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  AuthCubit _authCubit;
  @override
  void initState() {
    super.initState();
    _authCubit = context.read<AuthCubit>();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      stream: _authCubit.authStateChanges,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        User user = snapshot.data;
        if (user != null) {
          return widget.child;
        } else {
          return _widget();
        }
      },
    );
    // return BlocBuilder<AuthCubit, AuthState>(
    //   builder: (_, state) {
    //   final firebaseUser = state.user;
    //   log('usuario autenticado: $firebaseUser');
    //   if (firebaseUser != null) {
    //     return widget.child;
    //   } else {
    //     return _widget();
    //   }
    // });
  }

  _widget() {
    return FutureBuilder(
        future: UserStorageService.getCredentials(),
        builder: (context, AsyncSnapshot<Credentials> snapshot) {
          switch (snapshot.connectionState) {
            case (ConnectionState.waiting):
              {
                return Center(child: CircularProgressIndicator());
              }
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro!' + snapshot.error.toString()),
                );
              } else {
                return _redirectLogin(snapshot);
              }
          }
        });
  }

  _redirectLogin(AsyncSnapshot<Credentials> snapshot) {
    var credentials = snapshot.data;
    var email = credentials.email;
    var password = credentials.password;
    var uid = credentials.uid;

    if (StringUtils.isNullOrEmpty(uid)) {
      _authCubit.loginAsGuest();
      return Center(child: CircularProgressIndicator());
    } else {
      _authCubit.loginWithEmailAndPassword(email: email, password: password);
      return Center(child: CircularProgressIndicator());
    }
  }
}
