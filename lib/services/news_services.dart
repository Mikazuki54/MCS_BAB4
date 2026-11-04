import 'dart:convert';

import 'package:bab4/model/news_model.dart';
import 'package:http/http.dart' as http;

class NewsServices {
  final universalUrl =
      "";

  Future<List<NewsModel>> getAllNewsData() async {
    final response = await http.get(Uri.parse(universalUrl));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body)["articles"];
      return list.map((e) => NewsModel.fromJson(e)).toList();
    }
    throw Exception("Gagal mendapatkan data: ${response.statusCode}");
  }
}
