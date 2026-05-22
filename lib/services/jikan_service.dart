// lib/services/jikan_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/anime_model.dart';

class JikanService {
  static const String _baseUrl = 'https://api.jikan.moe/v4';

  // ─── Search anime berdasarkan keyword ───────────────────────────────────
  Future<List<Anime>> searchAnime(String query, {int page = 1}) async {
    final uri = Uri.parse(
      '$_baseUrl/anime?q=${Uri.encodeComponent(query)}&page=$page&limit=15&sfw=true',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['data'] ?? [];
      return results.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data: ${response.statusCode}');
    }
  }

  // ─── Ambil anime populer / top airing ───────────────────────────────────
  Future<List<Anime>> getTopAiring({int page = 1}) async {
    final uri = Uri.parse(
      '$_baseUrl/top/anime?filter=airing&page=$page&limit=15',
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['data'] ?? [];
      return results.map((json) => Anime.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil top anime: ${response.statusCode}');
    }
  }

  // ─── Ambil detail anime berdasarkan MAL ID ──────────────────────────────
  Future<Anime> getAnimeDetail(int malId) async {
    final uri = Uri.parse('$_baseUrl/anime/$malId');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Anime.fromJson(data['data']);
    } else {
      throw Exception('Gagal mengambil detail anime: ${response.statusCode}');
    }
  }
}
