import 'dart:convert';

import 'package:bab4/model/news_model.dart';
import 'package:http/http.dart' as http;

class NewsServices {
  final universalUrl =
      "https://newsapi.org/v2/everything?q=tesla&from=2026-09-30&sortBy=publishedAt&apiKey=6274f0390ac74a7da0e066e57722aaf7";

  Future<List<NewsModel>> getAllNewsData() async {
    final response = await http.get(Uri.parse(universalUrl));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body)["articles"];
      return list.map((e) => NewsModel.fromJson(e)).toList();
    }
    throw Exception("Gagal mendapatkan data: ${response.statusCode}");
  }
}
