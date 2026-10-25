import 'dart:convert';
import 'package:bab4/model/news_model.dart';
import 'package:http/http.dart' as http;

class NewsServices {
  final universalUrl = "masukkan api key url masing-masing";

  Future<List<NewsModel>> getAllNewsData() async {
    try {
      final response = await http.get(Uri.parse(universalUrl));
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List articleResponse = responseBody["articles"];
        final newsResult = articleResponse
              .map((e) => NewsModel.fromJson(e))
              .toList();
        return newsResult;
      } else {
        throw Exception("Gagal mendapatkan data. Status Code: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error Detail: $e");
    }
  }
}