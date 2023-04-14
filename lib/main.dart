import 'package:flutter/material.dart';
import 'package:themoviedb/ui/widgets/app/my_app.dart';
import 'package:themoviedb/ui/widgets/app/my_app_model.dart';

/*
довольно часто перед тем как загрузить первый экран нужно провести
определенную работу: запрос на сервер, что-то уточнить,
какие-то данные предзагрузить
как эту ситуацию решить?
можно решить двумя путями: либо вы покажите сплэш скрин или лоадер скрин. его делают
когда процесс загрузки длительный (относительно, можно заметить)
    в нашем случае это будет еще быстрее, поэтому используем второй подход
WidgetsFlutterBinding.ensureInitialized();
  final model = MyAppModel();
  await model.checkAuth();

*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final model = MyAppModel();
  await model.checkAuth();
  final app = MyApp(model: model);
  runApp(app);
}
