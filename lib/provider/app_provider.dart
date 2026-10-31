import 'package:bab4/model/news_model.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  NewsModel? selectedNews;

  void setSelectedNews(NewsModel news) {
    selectedNews = news;
    notifyListeners();
  }
}
