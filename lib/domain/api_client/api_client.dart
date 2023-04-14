// ignore_for_file: constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:themoviedb/domain/entity/popular_movie_response.dart';

//             обработка ошибок

/*
ошибки могут быть определены как любой класс. и даже как любые данные
//хоть строка - onString, число или буль
но буль: тру или фолс мало информативные
принято ошибки отправлять в особых эксепшинах
чаще используют класс, унаследованный от class Exeption

ошибки могут быть разными: мб неправильный юрл, мб не доступна сеть(можем
 достучаться до сервера, но не получить обратный ответ, сервер мб не доступен,
 сервера в принципе может не существовать, сервер может ответить с ошибкой, вернуть ошибку
 ошибки эти с сервера мб разными, например, о неполадках не сервере ошибка 500, или
 валидную ошибку(что наш логин и пароль не верные);
 мы можем не правильно распарсить ответ, например мы парсим как мапу и обращаемся
  к мапе по ключу, а этого может и не быть) и другое:
1 нет сети,
2  нет ответа, таймаут соединения
3  сервер не доступен
4  сервер не может обработать запрашиваемый запрос
5  сервер ответил не то что мы ожидали
6  сервер ответил ожидаемой ошибкой


 во-первых нужно обрабатывать ошибки
 также давать обратную связь юзеру, чтобы он понимал что происходит: в 6 случае
 покажем что не верно введен логин/пароль

 в случаях 1-5: минимальный вариант сообщения -  "что-то пошло не так, попробуй еще раз"
или в случаях 1-2: "нет сети"
в случаях 3-5: "что-то пошло не так, попробуй еще раз"

также неплохо было бы делать логи ошибок
они бывают самописанные, на мелких проектах - скорее всего сторонние решения,
например крашлистик от Гугла, Фаербейз
и должен быть человек в компании, который просматривает ошибки. мб часто сервер не
доступен,
каждую ошибку нужно логировать, даже если постоянно водят неверный логин,
тоже повод задуматься
*/
//                   попробуем ловить три типа ошибок
/*
ошибки, связанные с неверным логином или паролем происходят при их проверке в методе
Future<String> _validateUser({
    required String username,
    required String password,
    required String requestToken,
  })
времы подебажить!!!
поставим брейк поинт в этом методе в строке после 
final json = (await response.jsonDecode()) as Map<String, dynamic>;
в переменных дебаг консоли видим следующие данные
json: Map
0: "success" -> false
1: "status_code" -> 32
3: "status_message" -> "Email not verified: Your email address has not been verified."
а response.statusCode равен 401

посмотрим другие случаи
например в апиКей добавим лишнюю 1
в методе _makeToken() поставим брейк поинт в этом методе в строке после 
final json = (await response.jsonDecode()) as Map<String, dynamic>;
получили response.statusCode также 401

в json: Map
"status_code" -> 7
"status_message" -> "Invalid API key: You must be granted a valid key."
*/

// опытным путем определили следущие ошибки(но в документации должно быть описано):
// status_code:
// 30 - неверный логин пароль
// 7- неверный api key
// 33- неверный реквест токен

enum ApiClientExeptionType { Network, Auth, Other }

class ApiClientExeption implements Exception {
  final ApiClientExeptionType type;

  ApiClientExeption(this.type);
}

class ApiClient {
  final _client = HttpClient();
  static const _host = 'https://api.themoviedb.org/3';
  static const _imageUrl = 'https://image.tmdb.org/t/p/w500';
  static const _apiKey = '44cde0328eb5701a11641fce218ab976';

  static String imageUrl(String path) => _imageUrl + path;

  Future<String> auth({
    required String username,
    required String password,
  }) async {
    final token = await _makeToken();
    final validToken = await _validateUser(
        username: username, password: password, requestToken: token);
    final sessionId = await _makeSession(requestToken: validToken);
    return sessionId;
  }

  Uri _makeUri(String path, [Map<String, dynamic>? parameters]) {
    final uri = Uri.parse('$_host$path');
    if (parameters != null) {
      return uri.replace(queryParameters: parameters);
    } else {
      return uri;
    }
  }

  void _validateResponse(HttpClientResponse response, dynamic json) {
    if (response.statusCode == 401) {
/*когда у нас проблемы с сетью 401  в мапе json содержится 'status_code'
  поэтому мы получаем этот код в строке status = json['status_code'];
  и исходя из кода ошибки обрабатываем исключения
  технические ошибки пользователю не нужно сообщать, поэтому если ошибка 
  if (code == 30) то это неверные логин или пароль и соответсвтенно 
  throw ApiClientExeption(ApiClientExeptionType.Auth);
  во всех остальных случаях throw ApiClientExeption(ApiClientExeptionType.Other);
  */
      final dynamic status = json['status_code'];
      final code = status is int ? status : 0;
      if (code == 30) {
        throw ApiClientExeption(ApiClientExeptionType.Auth);
      } else {
        throw ApiClientExeption(ApiClientExeptionType.Other);
      }
    }
  }

  Future<T> _get<T>(
    String path,
    T Function(dynamic json) parser, [
    Map<String, dynamic>? parameters,
  ]) async {
    final url = _makeUri(path, parameters);
    try {
      final request = await _client.getUrl(url);
      final response = await request.close();
      final dynamic json = (await response.jsonDecode());
      _validateResponse(response, json);
      final result = parser(json);
      return result;
    }
// сетевые исключения находятся в SocketException
    on SocketException {
      throw ApiClientExeption(ApiClientExeptionType.Network);
    } on ApiClientExeption {
/*
rethrow: так как мы генерируем ошибку(исключение) внутри try/catch, а именно в 
методе _validateResponse(response, json);
if (code == 30) {
        throw ApiClientExeption(ApiClientExeptionType.Auth);
      } else {
        throw ApiClientExeption(ApiClientExeptionType.Other);
      }
то они попадут в этот on-bloc  - on ApiClientExeption 
то мы с ними будем делать ничего, а будем просто пробрасывать вверх
*/
      rethrow;
    } catch (_) {
      throw ApiClientExeption(ApiClientExeptionType.Other);
    }
  }

/*
еще раз про исключения:
мы обернули все в трай-кетч и если произойдет какая-либо ошибка, то мы попадем 
в on-bloc/catch-bloc
если это будет SocketException (с сетью что-то), то мы ее перехватим и отправим свое 
исключение throw ApiClientExeption(ApiClientExeptionType.Network);
если встречаем нашу ошибку ApiClientExeption (в методе _validateResponse(response, json); 
то есть if (code == 30) {
        throw ApiClientExeption(ApiClientExeptionType.Auth);
      } else {
        throw ApiClientExeption(ApiClientExeptionType.Other);
      }
в общем если будет наша ошибка ApiClientExeption
то мы прокидываем выше
если другая ошибка
то мы генерируем тип ошибки Other и передаем ее наверх
catch (_) {
      throw ApiClientExeption(ApiClientExeptionType.Other);
)

обрабатывать ошибки будем в AuthModel
on ApiClientExeption catch (e) {
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
*/
  Future<T> _post<T>(
    String path,
    Map<String, dynamic>? bodyParameters,
    T Function(dynamic json) parser, [
    Map<String, dynamic>? UrlParameters,
  ]) async {
    try {
      final url = _makeUri(
        path,
        UrlParameters,
      );

      final request = await _client.postUrl(url);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(bodyParameters));
      final response = await request.close();
      final dynamic json = (await response.jsonDecode());
      //
      _validateResponse(response, json);
//
      final result = parser(json);
      return result;
    } on SocketException {
      throw ApiClientExeption(ApiClientExeptionType.Network);
    } on ApiClientExeption {
      rethrow;
    } catch (_) {
      throw ApiClientExeption(ApiClientExeptionType.Other);
    }
  }

  Future<String> _makeToken() async {
    // final parser = (dynamic json) {
    //   final jsonMap = json as Map<String, dynamic>;
    //   final token = jsonMap['request_token'] as String;
    //   return token;
    // };

    String parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final token = jsonMap['request_token'] as String;
      return token;
    }

    final result = _get('/authentication/token/new', parser,
        <String, dynamic>{'api_key': _apiKey});

    return result;
  }

  Future<String> _validateUser({
    required String username,
    required String password,
    required String requestToken,
  }) async {
    final bodyparameters = <String, dynamic>{
      'username': username,
      'password': password,
      'request_token': requestToken
    };

    String parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final token = jsonMap['request_token'] as String;
      return token;
    }

    final result = _post(
      '/authentication/token/validate_with_login',
      bodyparameters,
      parser,
      <String, dynamic>{'api_key': _apiKey},
    );
    return result;
  }

  Future<String> _validateUserWithoutRefactoring({
    required String username,
    required String password,
    required String requestToken,
  }) async {
    try {
      final url = _makeUri(
        '/authentication/token/validate_with_login',
        <String, dynamic>{'api_key': _apiKey},
      );

      final parameters = <String, dynamic>{
        'username': username,
        'password': password,
        'request_token': requestToken
      };
      final request = await _client.postUrl(url);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(parameters));
      final response = await request.close();
      final json = (await response.jsonDecode()) as Map<String, dynamic>;
      //
      _validateResponse(response, json);
//
      final token = json['request_token'] as String;
      return token;
    } on SocketException {
      throw ApiClientExeption(ApiClientExeptionType.Network);
    } on ApiClientExeption {
      rethrow;
    } catch (_) {
      throw ApiClientExeption(ApiClientExeptionType.Other);
    }
  }

  Future<String> _makeSession({required String requestToken}) async {
    try {
      final url = _makeUri(
        '/authentication/session/new',
        <String, dynamic>{'api_key': _apiKey},
      );

      final parameters = <String, dynamic>{'request_token': requestToken};
      final request = await _client.postUrl(url);
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode(parameters));
      final response = await request.close();

      final json = (await response.jsonDecode()) as Map<String, dynamic>;
      //
      _validateResponse(response, json);
//

      final sessionId = json['session_id'] as String;
      return sessionId;
    } on SocketException {
      throw ApiClientExeption(ApiClientExeptionType.Network);
    } on ApiClientExeption {
      rethrow;
    } catch (_) {
      throw ApiClientExeption(ApiClientExeptionType.Other);
    }
  }

  Future<PopularMovieResponse> popularMovie(int page, String locale) async {
    PopularMovieResponse parser(dynamic json) {
      final jsonMap = json as Map<String, dynamic>;
      final response = PopularMovieResponse.fromJson(jsonMap);
      return response;
    }

    final result = _get('/movie/popular', parser, <String, dynamic>{
      'api_key': _apiKey,
      'language': locale,
      'page': page.toString()
    });

    return result;
  }
}

extension HttpClientResponseJsonDecode on HttpClientResponse {
  Future<dynamic> jsonDecode() async {
    return transform(utf8.decoder)
        .toList()
        .then((value) => value.join())
        .then<dynamic>((v) => json.decode(v));
  }
}


// // api_client_pre без рефакторинга

// ignore_for_file: constant_identifier_names

// import 'dart:convert';
// import 'dart:io';

// enum ApiClientExeptionType { Network, Auth, Other }

// class ApiClientExeption implements Exception {
//   final ApiClientExeptionType type;

//   ApiClientExeption(this.type);
// }

// class ApiClient {
//   final _client = HttpClient();
//   static const _host = 'https://api.themoviedb.org/3';
//   //static const _imageUrl = 'https://image.tmdb.org/t/p/w500';
//   static const _apiKey = '44cde0328eb5701a11641fce218ab976';

//   Future<String> auth({
//     required String username,
//     required String password,
//   }) async {
//     final token = await _makeToken();
//     final validToken = await _validateUser(
//         username: username, password: password, requestToken: token);
//     final sessionId = await _makeSession(requestToken: validToken);
//     return sessionId;
//   }

//   Uri _makeUri(String path, [Map<String, dynamic>? parameters]) {
//     final uri = Uri.parse('$_host$path');
//     if (parameters != null) {
//       return uri.replace(queryParameters: parameters);
//     } else {
//       return uri;
//     }
//   }

//   Future<String> _makeToken() async {
//     final url = _makeUri(
//       '/authentication/token/new',
//       <String, dynamic>{'api_key': _apiKey},
//     );

//     try {
//       //ошибка мб здесь: если нет сети
//       final request = await _client.getUrl(url);

// //ошибка мб здесь: если сеть, но сервер не доступен
//       final response = await request.close();
// //ошибка мб здесь: если неправильный парсинг
//       final json = (await response.jsonDecode()) as Map<String, dynamic>;
//       // _validateResponse(response, json);

// //ошибка мб здесь: если нет json 'request_token'
//       final token = json['request_token'] as String;
//       return token;
//     } on SocketException {
//       throw ApiClientExeption(ApiClientExeptionType.Network);
//     }
//   }

//   Future<String> _validateUser({
//     required String username,
//     required String password,
//     required String requestToken,
//   }) async {
//     final url = _makeUri(
//       '/authentication/token/validate_with_login',
//       <String, dynamic>{'api_key': _apiKey},
//     );

//     final parameters = <String, dynamic>{
//       'username': username,
//       'password': password,
//       'request_token': requestToken + 'sfg'
//     };
//     final request = await _client.postUrl(url);
//     request.headers.contentType = ContentType.json;
//     request.write(jsonEncode(parameters));
//     final response = await request.close();
//     final json = (await response.jsonDecode()) as Map<String, dynamic>;

//     //
//     _validateResponse(response, json);
// //
//     final token = json['request_token'] as String;
//     return token;
//   }

//   Future<String> _makeSession({required String requestToken}) async {
//     final url = _makeUri(
//       '/authentication/session/new',
//       <String, dynamic>{'api_key': _apiKey},
//     );

//     final parameters = <String, dynamic>{'request_token': requestToken};
//     final request = await _client.postUrl(url);
//     request.headers.contentType = ContentType.json;
//     request.write(jsonEncode(parameters));
//     final response = await request.close();

//     final json = (await response.jsonDecode()) as Map<String, dynamic>;
//     //
//     _validateResponse(response, json);
// //

//     final sessionId = json['session_id'] as String;
//     return sessionId;
//   }

//   void _validateResponse(HttpClientResponse response, dynamic json) {
//     if (response.statusCode == 401) {
//       final dynamic status = json['status_code'];
//       final code = status is int ? status : 0;
//       if (code == 30) {
//         throw ApiClientExeption(ApiClientExeptionType.Auth);
//       } else {
//         throw ApiClientExeption(ApiClientExeptionType.Other);
//       }
//     }
//   }
// }

// extension HttpClientResponseJsonDecode on HttpClientResponse {
//   Future<dynamic> jsonDecode() async {
//     return transform(utf8.decoder).toList().then((value) {
//       final result = value.join();
//       return result;
//     }).then<dynamic>((v) => json.decode(v));
//   }
// }
