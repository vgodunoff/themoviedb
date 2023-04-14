import 'package:flutter/material.dart';
import 'package:themoviedb/Library/Widgets/Inherited/provider.dart';
import 'package:themoviedb/domain/data_providers/session_data_provider.dart';
import 'package:themoviedb/ui/widgets/main_screen/main_screen_model.dart';
import 'package:themoviedb/ui/widgets/movie_list/movie_list_model.dart';
import 'package:themoviedb/ui/widgets/news/news_widget.dart';
import 'package:themoviedb/ui/widgets/tv_shows_list/tv_show_list_widget.dart';

import '../movie_list/movie_list_widget.dart';

class MainScreenWidget extends StatefulWidget {
  const MainScreenWidget({Key? key}) : super(key: key);

  @override
  State<MainScreenWidget> createState() => _MainScreenWidgetState();
}

class _MainScreenWidgetState extends State<MainScreenWidget> {
  int _selectedTab = 1;
  final movieListModel = MovieListModel();
  // //static final List<Widget> _widgetOptions = <Widget>[
  //   const NewsWidget(),
  //   const MovieListWidget(),
  //   const Text(
  //     'Index 2: Сериалы',
  //   ),
  // ];

  void onSelectedTab(int index) {
    if (_selectedTab == index) return;

    setState(() {
      _selectedTab = index;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   movieListModel.loadMovies();
  // }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    movieListModel.setupLocale(context);
  }

  @override
  Widget build(BuildContext context) {
    final model = NotifierProvider.read<MainScreenModel>(context);
    // ignore: avoid_print
    print('model is $model');
    return Scaffold(
      appBar: AppBar(
        title: const Text('TMDB'),
        actions: [
          IconButton(
              onPressed: () => SessionDataProvider().setSessionId(null),
              icon: const Icon(Icons.search))
        ],
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          const NewsWidget(),
          NotifierProvider(
            model: movieListModel,
            child: const MovieListWidget(),
          ),
          const TWShowListWidget(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Новости'),
          BottomNavigationBarItem(icon: Icon(Icons.movie), label: 'Фильмы'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'Сериалы'),
        ],
        onTap: onSelectedTab,
      ),
    );
  }
}
