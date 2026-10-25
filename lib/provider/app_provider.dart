import 'package:bab4/model/news_model.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  NewsSource? source;
  late String namaPenulis;
  late String judulArtikel;
  late String deskripsiArtikel;
  late String linkArtikel;
  late String gambarArtikel;
  late DateTime tanggalPublish;
  late String kontenArticle;
  int? index;

  

  goToDetailNews({
    required BuildContext context,
    required NewsModel newsModel,
    required int index,
    required navigationPage,
  }) async {
    this.index = index;
    source = newsModel.source;
    namaPenulis = newsModel.penulis;
    judulArtikel = newsModel.judul;
    deskripsiArtikel = newsModel.deskripsi;
    linkArtikel = newsModel.url;
    gambarArtikel = newsModel.urlGambar;
    tanggalPublish = newsModel.publishedAt;
    kontenArticle = newsModel.content;

    notifyListeners();
    Navigator.push(
      context, 
      MaterialPageRoute(builder:(context) => navigationPage));
  }

}