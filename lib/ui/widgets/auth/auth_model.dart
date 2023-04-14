import 'dart:async';

import 'package:flutter/material.dart';
import 'package:themoviedb/domain/api_client/api_client.dart';
import 'package:themoviedb/domain/data_providers/session_data_provider.dart';
import 'package:themoviedb/ui/navigation/main_navigation.dart';

/*
1
форму авторизации мы сделали из стейтфул в стейтлес
теперь наша модель будет хранить стейт виджета

2
контроллеры сделаем не приватными
*/
class AuthModel extends ChangeNotifier {
  final _apiClient = ApiClient();
  final _sessionDataProvider = SessionDataProvider();
  final loginTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool _isAuthProgress = false;
  bool get canStartAuth => !_isAuthProgress;
  bool get isAuthProgress => _isAuthProgress;

//запросы в сеть - асинхронные
  Future<void> auth(BuildContext context) async {
    final login = loginTextController.text;
    final password = passwordTextController.text;

    if (login.isEmpty || password.isEmpty) {
      _errorMessage = 'Заполните логин и пароль';
      notifyListeners();
      return;
    }
    _errorMessage = null;
    _isAuthProgress = true;
    notifyListeners();
    String? sessionId;
    try {
      sessionId = await _apiClient.auth(username: login, password: password);
    } on ApiClientExeption catch (e) {
      switch (e.type) {
        case ApiClientExeptionType.Network:
          _errorMessage =
              'Сервер не доступен. Проверьте подключение к интернету';
          break;
        case ApiClientExeptionType.Auth:
          _errorMessage = 'Неправильный логин пароль';
          break;
        case ApiClientExeptionType.Other:
          _errorMessage = 'Произошла ошибка. Попробуйте еще раз';
          break;
      }
    }

    _isAuthProgress = false;
    if (_errorMessage != null) {
      notifyListeners();
      return;
    }
    if (sessionId == null) {
      _errorMessage = 'Неизвестная ошибка, повторите попытку';
      notifyListeners();
      return;
    }
    await _sessionDataProvider.setSessionId(sessionId);

    // ignore: use_build_context_synchronously
    unawaited(
        // ignore: use_build_context_synchronously
        Navigator.of(context)
            .pushReplacementNamed(MainNavigationRouteNames.mainScreen));
  }
}

// class AuthProvider extends InheritedNotifier {
//   final AuthModel model;
//   const AuthProvider({Key? key, required this.model, required Widget child})
//       : super(key: key, notifier: model, child: child);

//   static AuthProvider? of(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<AuthProvider>();
//   }

//   static AuthProvider? watch(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<AuthProvider>();
//   }

//   static AuthProvider? read(BuildContext context) {
//     final widget =
//         context.getElementForInheritedWidgetOfExactType<AuthProvider>()?.widget;
//     return widget is AuthProvider ? widget : null;
//   }
// }

