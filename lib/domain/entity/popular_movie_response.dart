import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:themoviedb/domain/entity/movie.dart';

// PopularMovieResponse movieFromJson(String str) => PopularMovieResponse.fromJson(json.decode(str));

// String movieToJson(Movie data) => json.encode(data.toJson());
part 'popular_movie_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class PopularMovieResponse {
  PopularMovieResponse({
    required this.page,
    required this.movies,
    required this.totalResults,
    required this.totalPages,
  });

  int page;
  @JsonKey(name: 'results')
  final List<Movie> movies;
  final int totalResults;
  final int totalPages;

  factory PopularMovieResponse.fromJson(Map<String, dynamic> json) =>
      _$PopularMovieResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PopularMovieResponseToJson(this);
}
