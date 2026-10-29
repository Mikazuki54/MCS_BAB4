import 'package:bab4/model/news_model.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  NewsModel? _selectedNews;
  int? index;

  NewsModel? get selectedNews => _selectedNews;

  // Getter kompatibel dengan kode yang sudah ada tanpa perlu mengubah detail_page
  NewsSource? get sumber => _selectedNews?.sumber;
  String get namaPenulis =>
      _selectedNews?.penulis ?? "Nama penulis tidak tersedia";
  String get judulArtikel =>
      _selectedNews?.judul ?? "Judul artikel tidak tersedia";
  String get deskripsiArtikel =>
      _selectedNews?.deskripsi ?? "Deskripsi artikel tidak tersedia";
  String get linkArtikel => _selectedNews?.url ?? "-";
  String get gambarArtikel =>
      _selectedNews?.urlGambar ??
      "https://st3.depositphotos.com/1031343/13659/v/450/depositphotos_136598368-stock-illustration-not-available-sign-or-stamp.jpg";
  DateTime get tanggalPublish => _selectedNews?.publishedAt ?? DateTime.now();
  String get kontenArticle =>
      _selectedNews?.content ?? "Artikel tidak memiliki konten";

  void setSelectedNews(NewsModel newsModel, [int? itemIndex]) {
    _selectedNews = newsModel;
    index = itemIndex;
    notifyListeners();
  }

  // Tetap disediakan untuk kompatibilitas jika modul tugas mewajibkan method ini
  void goToDetailNews({
    required BuildContext context,
    required NewsModel newsModel,
    required int index,
    required Widget navigationPage,
  }) {
    setSelectedNews(newsModel, index);
    Navigator.push(context, MaterialPageRoute(builder: (_) => navigationPage));
  }
}
