import 'package:flutter/material.dart';
import 'package:themoviedb/Library/Widgets/Inherited/provider.dart';
import 'package:themoviedb/domain/api_client/api_client.dart';
import 'package:themoviedb/ui/widgets/movie_list/movie_list_model.dart';

class MovieListWidget extends StatelessWidget {
  const MovieListWidget({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.watch<MovieListModel>(context);
    if (model == null) return const SizedBox.shrink();
    return Stack(
      children: [
        ListView.builder(
// .onDrag - чтобы после поиска мы немного покрутили список результатов и клавиатура
//сама исчезла, в противном случае нужно тыкать по клаве руками,чтобы она исчезла
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
// добавляем паддинг топ 70 и наш листвью смещается вниз и не перекрывается полем ввода (поиск)
          padding: const EdgeInsets.only(top: 70),
          itemCount: model.movies.length,
          itemExtent: 163,
          itemBuilder: (BuildContext context, int index) {
            model.showedMovieAtIndex(index);
            final movie = model.movies[index];
            final posterPath = movie.posterPath;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Stack(
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              // blurRadius: 8.0 - размыли тень
                              blurRadius: 8.0,
                              //  Offset(0, 5) - тень по горизонтали 0, по вертикали опустили ниже на 5
                              offset: const Offset(0, 5))
                        ],
                        border:
                            Border.all(color: Colors.black.withOpacity(0.2)),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10))),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            bottomLeft: Radius.circular(10),
                          ),
                          child: posterPath != null
                              ? Image.network(ApiClient.imageUrl(posterPath))
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                movie.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Text(
                                model.stringFromDate(movie.releaseDate),
                                style: const TextStyle(color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                movie.overview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        )
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      onTap: () => model.onMovieTap(index, context),
                    ),
                  )
                ],
              ),
            );
          },
        ),
        TextField(
          onChanged: model.searchMovie,
          //controller: _searchController,
          decoration: InputDecoration(
              label: const Text('Поиск'),
              filled: true,
//Colors.white.withAlpha(235): withAlpha(235) - изменяет прозрачность от 0 до 255
// 0  - полностью прозрачно, 255 - не прозрачно
              fillColor: Colors.white.withAlpha(235),
              border: const OutlineInputBorder()),
        )
      ],
    );
  }
}

// class Movie {
//   final int id;
//   final String imageName;
//   final String title;
//   final String time;
//   final String description;

//   Movie(
//       {required this.id,
//       required this.imageName,
//       required this.title,
//       required this.time,
//       required this.description});
// }

  // final _movies = [
  //   Movie(
  //       id: 1,
  //       imageName: AppImages.minions,
  //       title: 'Minions',
  //       time: '7 apr 2021',
  //       description:
  //           'Миллион лет миньоны искали самого великого и ужасного предводителя, пока не встретили ЕГО'),
  //   Movie(
  //       id: 2,
  //       imageName: AppImages.minions,
  //       title: 'Прибытие',
  //       time: '7 apr 2021',
  //       description:
  //           'Миллион лет миньоны искали самого великого и ужасного предводителя, пока не встретили ЕГО'),
  //   Movie(
  //       id: 3,
  //       imageName: AppImages.minions,
  //       title: 'Minions',
  //       time: 'Назад в будущее 1',
  //       description:
  //           'Миллион лет миньоны искали самого великого и ужасного предводителя, пока не встретили ЕГО'),
  //   Movie(
  //       id: 4,
  //       imageName: AppImages.minions,
  //       title: 'Назад в будущее 2',
  //       time: '7 apr 2021',
  //       description:
  //           'Миллион лет миньоны искали самого великого и ужасного предводителя, пока не встретили ЕГО'),
  //   Movie(
  //       id: 5,
  //       imageName: AppImages.minions,
  //       title: 'Тихие зори',
  //       time: '7 apr 2021',
  //       description:
  //           'Миллион лет миньоны искали самого великого и ужасного предводителя, пока не встретили ЕГО'),
  //   Movie(
  //       id: 6,
  //       imageName: AppImages.minions,
  //       title: 'В бой идут одни старики',
  //       time: '7 apr 2021',
  //       description:
  //           'Миллион лет миньоны искали самого великого и ужасного предводителя, пока не встретили ЕГО'),
  //   Movie(
  //       id: 7,
  //       imageName: AppImages.minions,
  //       title: 'Чаплин',
  //       time: '7 apr 2021',
  //       description:
  //           'Миллион лет миньоны искали самого великого и ужасного предводителя, пока не встретили ЕГО'),
  //   Movie(
  //       id: 8,
  //       imageName: AppImages.minions,
  //       title: 'Брат',
  //       time: '7 apr 2021',
  //       description:
  //           'Миллион лет миньоны искали самого великого и ужасного предводителя, пока не встретили ЕГО'),
  //   Movie(
  //       id: 9,
  //       imageName: AppImages.minions,
  //       title: 'Брат 2',
  //       time: '7 apr 2021',
  //       description:
  //           'Миллион лет миньоны искали самого великого и ужасного предводителя, пока не встретили ЕГО'),
  // ];

  // var _filteredMovies = <Movie>[];

  // void _searchMovie() {
  //   final query = _searchController.text;
  //   if (query.isNotEmpty) {
  //     _filteredMovies = _movies.where((Movie movie) {
  //       return movie.title.toLowerCase().contains(query.toLowerCase());
  //     }).toList();
  //   } else {
  //     _filteredMovies = _movies;
  //   }
  //   setState(() {});
  // }

//@override
  // void initState() {
  //   super.initState();
  //   _filteredMovies = _movies;
  //   _searchController.addListener(_searchMovie);
  // }

   // void _onMovieTap(int index) {
  //   final id = _movies[index].id;
  //   Navigator.of(context)
  //       .pushNamed(MainNavigationRouteNames.movieDetails, arguments: id);
  // }

  // class _MovieListWidgetState extends State<MovieListWidget> {
  // final _searchController = TextEditingController();