import 'package:flutter/material.dart';
import 'package:themoviedb/ui/theme/app_colors.dart';
import 'package:themoviedb/ui/widgets/auth/auth_model.dart';
import 'package:themoviedb/ui/widgets/auth/auth_widget.dart';
import 'package:themoviedb/ui/widgets/main_screen/main_screen_widget.dart';
import 'package:themoviedb/ui/widgets/movie_details/movie_details_widget.dart';

void main() {
  runApp(const MyApp());
}

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
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
      routes: {
        '/': (context) => AuthProvider(
              model: AuthModel(),
              child: const AuthWidget(),
            ),
        '/main_screen': (context) => const MainScreenWidget(),
        '/main_screen/movie_details': (context) {
          final arguments = ModalRoute.of(context)?.settings.arguments;
          if (arguments is int) {
            return MovieDetailsWidget(
              movieId: arguments,
            );
          } else {
            return const MovieDetailsWidget(
              movieId: 1,
            );
          }
        }
      },
    );
  }
}
