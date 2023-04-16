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
  late int _currentPage;
  //чтобы ничего не сломалось нужно еще больше контроля или проверок
  //поэтому заведем еще одну переменную тоталПейдж и _isLoadingInProgress
  late int _totalPage;
  var _isLoadingInProgress = false;
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

  void setupLocale(BuildContext context) {
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
    _currentPage = 0;

    //по умолчанию у нас будет всего одна страница, но мы тоже это изменим
    _totalPage = 1;
    _movies.clear();
    _loadMovies();
  }

  String stringFromDate(DateTime? date) =>
      date != null ? _dateFormat.format(date) : '';

  Future<void> _loadMovies() async {
    if (_isLoadingInProgress || _currentPage >= _totalPage) return;
    _isLoadingInProgress = true;
    final nextPage = _currentPage + 1; //0+1
    try {
      //основное место где может возникнуть ошибка это
      //здесь  final moviesResponse = await _apiClient.popularMovie(nextPage, _locale);
      //а все что ниже не выполнится, если будет ошибка/исключение,
      //поэтому и  notifyListeners(); тоже включим сюда

      final moviesResponse = await _apiClient.popularMovie(nextPage, _locale);
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
    _loadMovies();
  }

  Future<void> searchMovie(String text) async {
    print(text);
  }
}
