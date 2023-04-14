/*
главное когда мы размещаем провайдер с моделью это то чтобы наша модель не 
пересоздавалась во время жизни экрана, то есть пока мы работаем с одним экраном
чтобы у нас все было хорошо и модель не пересоздавалась
так вот в роутах
'/': (context) => AuthWidget(),
здесь функция которая порождает экран, она как раз вызывается ровно один раз
и потом пока экран не закроется, она (модель) не пересоздастся
поэтому здесь мы и обернем экран авторизации в провайдер
'/': (context) => AuthProvider(
              model: AuthModel(),
              child: AuthWidget(),
            )

*/
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:themoviedb/ui/navigation/main_navigation.dart';
import 'package:themoviedb/ui/theme/app_colors.dart';
import 'package:themoviedb/ui/widgets/app/my_app_model.dart';

class MyApp extends StatelessWidget {
  final MyAppModel model;
  static final mainNavigation = MainNavigation();
  const MyApp({Key? key, required this.model}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: AppColors.mainDarkBlue),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: AppColors.mainDarkBlue,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey),
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('ru', 'RU'), Locale('en', '')],
      //locale: Locale('ru', 'RU'),
      routes: mainNavigation.routes,
      initialRoute: mainNavigation.initialRoute(model.isAuth),
      onGenerateRoute: mainNavigation.onGenerateRoute,
    );
  }
}
