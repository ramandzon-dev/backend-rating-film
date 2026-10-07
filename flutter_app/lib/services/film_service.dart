import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/film.dart';

class FilmService {
  // Default URL: user can change this to their live online hosting URL
  String baseUrl;

  FilmService({this.baseUrl = 'http://127.0.0.1:8000/api'});

  void updateBaseUrl(String newUrl) {
    var trimmed = newUrl.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    baseUrl = trimmed;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // GET: Fetch all films
  Future<List<Film>> getFilms() async {
    final uri = Uri.parse('$baseUrl/films');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Film.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load films (${response.statusCode}): ${response.body}');
    }
  }

  // GET: Fetch single film detail
  Future<Film> getFilmDetail(int id) async {
    final uri = Uri.parse('$baseUrl/films/$id');
    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final dynamic data = jsonDecode(response.body);
      return Film.fromJson(data);
    } else {
      throw Exception('Film not found or failed to load (${response.statusCode})');
    }
  }

  // POST: Create a new film
  Future<Film> createFilm({
    required String title,
    required String genre,
    required int rating,
  }) async {
    final uri = Uri.parse('$baseUrl/films');
    final body = jsonEncode({
      'title': title,
      'genre': genre,
      'rating': rating,
    });

    final response = await http.post(uri, headers: _headers, body: body);

    if (response.statusCode == 201) {
      final dynamic responseData = jsonDecode(response.body);
      return Film.fromJson(responseData['data']);
    } else if (response.statusCode == 422) {
      final dynamic err = jsonDecode(response.body);
      final errors = err['errors']?.toString() ?? err['message'] ?? 'Validation Error';
      throw Exception('Validation failed: $errors');
    } else {
      throw Exception('Failed to create film (${response.statusCode}): ${response.body}');
    }
  }

  // PUT: Update an existing film
  Future<Film> updateFilm({
    required int id,
    required String title,
    required String genre,
    required int rating,
  }) async {
    final uri = Uri.parse('$baseUrl/films/$id');
    final body = jsonEncode({
      'title': title,
      'genre': genre,
      'rating': rating,
    });

    final response = await http.put(uri, headers: _headers, body: body);

    if (response.statusCode == 200) {
      final dynamic responseData = jsonDecode(response.body);
      return Film.fromJson(responseData['data']);
    } else if (response.statusCode == 422) {
      final dynamic err = jsonDecode(response.body);
      final errors = err['errors']?.toString() ?? err['message'] ?? 'Validation Error';
      throw Exception('Validation failed: $errors');
    } else {
      throw Exception('Failed to update film (${response.statusCode}): ${response.body}');
    }
  }

  // DELETE: Delete a film
  Future<bool> deleteFilm(int id) async {
    final uri = Uri.parse('$baseUrl/films/$id');
    final response = await http.delete(uri, headers: _headers);

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to delete film (${response.statusCode}): ${response.body}');
    }
  }
}
