import 'dart:async';

import 'package:flutter/material.dart';
import 'package:themoviedb/domain/api_client/api_client.dart';
import 'package:themoviedb/domain/entity/movie.dart';
import 'package:themoviedb/domain/entity/popular_movie_response.dart';
import 'package:themoviedb/ui/navigation/main_navigation.dart';
import 'package:intl/intl.dart';

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

чтобы сделать пагинацию нужно как-то отслеживать что мы дошли до конца списка
когда на экране мы видим предпоследний фильм, то мы уже подошли к концу списка
сделаем условие когда индекс в ListView.Builder не меньше длины списка за минусом 1
то значит это конец списка и нужно подгружать новую порцию данных
создадим метод showedMovieAtIndex(index);

и используем его в ListView.Builder
itemBuilder: (BuildContext context, int index) {
            model.showedMovieAtIndex(index);

var _isLoadingInProgress = false; будет показывать есть ли у нас загрузка или нет
зачем она нужна:
мы когда начинаем грузить одну страницу, было бы не круто начинать грузить следующую
а это изи(очень может быть). если будет загрузка слишком долгая, пользователь будет докручивать 
до конца, и может скроллить туда-сюда, и это спровоцирует несколько загрузок, нам бы этого не хотелось
и вот от этого мы защитимся
_isLoadingInProgress не будет на сетапе (setupLocale) правится. почему? потому что глупо будет сбрасывать
его. представьте что мы например грузим порцию фильмов, поставили ее(_isLoadingInProgress) в тру
потом делаем setupLocale, переставляем ее в фолс, и как-бы у нас может две порции загрузки одновременно
пройти, не самое хорошее что можно сделать
поэтому в методе _loadMovies() нужно сделать несколько проверок
 if(_isLoadingInProgress) , то есть если мы уже грузимся, то нам бы больше грузится уже не нужно
 то есть делаем ретёрн.
 if (_isLoadingInProgress) return;
если у нас уже пачка фильмов загружается то мы просто делаем ретёрн и мы не провоцируем снова загрузку
этой же пачки
а мы бы спровоцировали загрузку именно этой же пачки, почему? потому-что смотрите
мы некст пейдж здесь получаем 
final nextPage = _currentPage + 1;
скидываем ее в popularMovie(nextPage, _locale)
final moviesResponse = await _apiClient.popularMovie(nextPage, _locale);

но пока данные не придут  _currentPage = moviesResponse.page;
мы _currentPage не обновим
то есть если два раза _loadMovies() запустить до того как он у нас закончится,
то мы всегда, абсолютно всегда будем получать одни и те же страницы

и второе условие
если у нас _currentPage >= _totalPage
если мы достигли конца списка, то есть у нас текущая страница она равна общему количеству
страниц, то дальше ничего грузить тоже не нужно

если мы прошли такой барьер
if (_isLoadingInProgress || _currentPage >= _totalPage) return;
то мы ставим _isLoadingInProgress в тру

осталось еще от ошибок защититься, добавить обработку исключений

*/

class MovieListModel extends ChangeNotifier {
  final _apiClient = ApiClient();
  final _movies = <Movie>[];
  List<Movie> get movies => List.unmodifiable(_movies);
  String _locale = '';
  Timer? searchDebounce;

  //завели один раз дейтФормат, и теперь не будет постоянно создаваться как если
  // бы мы использовали в UI конструктор
  late DateFormat _dateFormat;
  late int _currentPage;
  //чтобы ничего не сломалось нужно еще больше контроля или проверок
  //поэтому заведем еще одну переменную тоталПейдж и _isLoadingInProgress
  late int _totalPage;
  var _isLoadingInProgress = false;
  String? _searchQuery;

  Future<void> setupLocale(BuildContext context) async {
    final locale = Localizations.localeOf(context).toLanguageTag(); //'ru-RU'

    if (_locale == locale) return;
    //если локаль поменялась то меняем и нашу глобальную локаль апки
    //например, изменили язык в настройках телефона/симулятора
    _locale = locale;

    //меняем формат даты в зависимости от локали
    _dateFormat = DateFormat.yMMMMd(locale);

    //когда поменялась локаль обнуляем текущую страницу, так как будем грузить список с начала, очищаем старый список фильмов
    // потому что загрузим этот же список но на другом языке и формате даты
    //когда изменяется локаль _currentPage сбрасываем до нуля

    // _currentPage = 0;

    //по умолчанию у нас будет всего одна страница, но мы тоже это изменим
    // _totalPage = 1;
    // _movies.clear();
    // _loadMovies();
    await _resetList();
  }

  Future<void> _resetList() async {
    _currentPage = 0;
    _totalPage = 1;
    _movies.clear();
    await _loadNextPage();
  }

  String stringFromDate(DateTime? date) =>
      date != null ? _dateFormat.format(date) : '';

  Future<PopularMovieResponse> _loadMovies(int nextPage, String locale) async {
    final query = _searchQuery;
    if (query == null) {
      return await _apiClient.popularMovie(nextPage, _locale);
    } else {
      return await _apiClient.searchMovie(nextPage, _locale, query);
    }
  }

  Future<void> _loadNextPage() async {
    if (_isLoadingInProgress || _currentPage >= _totalPage) return;
    _isLoadingInProgress = true;
    final nextPage = _currentPage + 1; //0+1
    try {
      //основное место где может возникнуть ошибка это
      //здесь  final moviesResponse = await _apiClient.popularMovie(nextPage, _locale);
      //а все что ниже не выполнится, если будет ошибка/исключение,
      //поэтому и  notifyListeners(); тоже включим сюда

      final moviesResponse = await _loadMovies(nextPage, _locale);
      _movies.addAll(moviesResponse.movies);
      //затем карентПейдж нужно обновить, берем данные из респонса
      _currentPage = moviesResponse.page;
      _totalPage = moviesResponse.totalPages;
      //после того мы сделали загрузку только тогда можно делать загрузка заново
      _isLoadingInProgress = false;
      notifyListeners();
    } catch (e) {
      //а что делать если ошибка
      //по сути ничего страшного не будет если мы ничего не скажем юзеру вообще
      //можно было бы сделать банер, что произошла ошибка, пусть еще подергает,

      //минимально нужно сделать _isLoadingInProgress = false;
      _isLoadingInProgress = false;

      /*
здесь мы не ставим notifyListeners(); потому что если мы попадем в ошибку
notifyListeners() заставляет обновить стейт и соответствено экран перерисуется 
и если мы видели последнюю ячейку в этот момент на экране, то она тоже перерисуется
у нее тоже вызовется билд и вызовется showedMovieAtIndex и соответсвтено вызовется
загрузка - _loadMovies() и мы попытаемся загрузить еще раз
если ошибка не исправлена мы начнем грузить грузить грузить грузить  ... 
  */
    }
  }

  void onMovieTap(int index, BuildContext context) {
    final id = _movies[index].id;
    Navigator.of(context)
        .pushNamed(MainNavigationRouteNames.movieDetails, arguments: id);
  }

  void showedMovieAtIndex(int index) {
    if (index < _movies.length - 1) return;
    //индекс 19 меньше 20-1, т.е. до 19 индекса ничего не делать
    // а на 19 индексе, препоследнем загружаем фильмы еще
    _loadNextPage();
  }

/*
вот мы начинаем искать. что нам нужно делать если мы сюда новый текст попал
ну во-первых нам нужно будет сбросить абсолютно все результаты, все что есть в методе
setupLocale:
 final locale = Localizations.localeOf(context).toLanguageTag(); //'ru-RU'
    if (_locale == locale) return;
    _locale = locale;
    _dateFormat = DateFormat.yMMMMd(locale);
    _currentPage = 0;
    _totalPage = 1;
    _movies.clear();
    _loadMovies();

нам нужно оставить локаль _locale = locale;
и дейтФормат _dateFormat = DateFormat.yMMMMd(locale);
сбрасываем 
_currentPage = 0;
    _totalPage = 1;
    _movies.clear();
и потом нужно сделать _loadMovies(); но по-другому

вынесим некоторый функционал в метод _resetList
то есть мы разделили метод setupLocale на два метода.
оставили все что касается локали в setupLocale
а все что касается того что после того как мы изменили локаль мы заново начали
грузить фильмы - мы перенесли в метод _resetList

дальше введем переменную searchQuery

также в поиске есть еще один изъян - когда мы вбиваем сюда что-то очень быстро,
каждая буква провоцирует новый запрос на сервер. будем от этого избавляться
для этого нам понадобиться таймер Timer? searchDebounce;
чтобы код отработал правильно нужно еще сверху добавить searchDebounce?.cancel();
без этого экран будет мерцать от каждой буквы, хоть это и будет отложенное мерцание
но после секунды , раз 5 померцает.
строка searchDebounce?.cancel(); отменяет реакцию на каждую букву и только после
секунды берутся данные из переменной text, в котором уже набралась комбинация символов
и только один запрос отправиться, и один раз перерисуется экран
*/
  Future<void> searchMovie(String text) async {
    searchDebounce?.cancel();
    searchDebounce = Timer(Duration(seconds: 1), () async {
      final searchQuery = text.isNotEmpty ? text : null;
      if (_searchQuery == searchQuery) return;
      _searchQuery = searchQuery;
      await _resetList();
    });
  }
}
