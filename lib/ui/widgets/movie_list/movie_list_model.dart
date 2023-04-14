import 'package:flutter/material.dart';
import 'package:themoviedb/domain/api_client/api_client.dart';
import 'package:themoviedb/domain/entity/movie.dart';
import 'package:themoviedb/ui/navigation/main_navigation.dart';
import 'package:intl/intl.dart';

class MovieListModel extends ChangeNotifier {
  final _apiClient = ApiClient();
  final _movies = <Movie>[];
  List<Movie> get movies => List.unmodifiable(_movies);
  String _locale = '';

  //завели один раз дейтФормат, и теперь не будет постоянно создаваться как если
  // бы мы использовали в UI конструктор
  late DateFormat _dateFormat;
/*
нам в коде нужна локаль
но локаль мы здесь взять не можем, ее нужно брать специальными методами
из контекста, а тут контекста нигде нет
и вообще локаль нужна по всей программе
для начала заведем метод setupLocale
Зачем мы вообще делаем таким образом, зачем мы храним локаль, настраиваем локаль
потому что как было сказано ее не получить без контекста, а контекста здесь нет
плюс локаль еще может меняться - method Localizations.localeOf(context) это dependOnInheritedWidgetOfExactType
то есть она еще и подписывается на изменения
и мы не можем ее где-попало вызвать, например, не можем в инитСтейт  и так далее
(и поэтому будем использовать метод  didChangeDependencies)
еще она поменяться может как-то во время работы приложения
ее нужно переустанавливать - setupLocale, если что-то будет происходить

если вывести на печать локаль, то оказывается что она у нас сейчас английская
чтобы переделать в русскую нужно согласно документации флатера установить 
Flutter_localizations package, поставить intl
и нужно прописать в MaterialApp несколько строк
*/

  void setupLocale(BuildContext context) {
    final locale = Localizations.localeOf(context).toLanguageTag();

    if (_locale == locale) return;
    _locale = locale;
    _dateFormat = DateFormat.yMMMMd(locale);
    _movies.clear();
    _loadMovies();
  }

  String stringFromDate(DateTime? date) =>
      date != null ? _dateFormat.format(date) : '';

  Future<void> _loadMovies() async {
    final moviesResponse = await _apiClient.popularMovie(1, _locale);
    _movies.addAll(moviesResponse.movies);
    notifyListeners();
  }

  void onMovieTap(int index, BuildContext context) {
    final id = _movies[index].id;
    Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.movieDetails, arguments: id);
  }
}
