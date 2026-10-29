import 'dart:convert';

import 'package:bab4/model/news_model.dart';
import 'package:http/http.dart' as http;

class NewsServices {
  final universalUrl = "masukkan API KEY URL masing-masing";

  Future<List<NewsModel>> getAllNewsData() async {
    try {
      final response = await http.get(Uri.parse(universalUrl));
      if (response.statusCode == 200) {
        final List articles = jsonDecode(response.body)["articles"];
        return articles.map((e) => NewsModel.fromJson(e)).toList();
      }
      throw Exception(
        "Gagal mendapatkan data. Status Code: ${response.statusCode}",
      );
    } catch (e) {
      throw Exception("Error Detail: $e");
    }
  }
}
