class NewsSource {
  dynamic id;
  dynamic name;

  NewsSource({required this.id, required this.name});

  factory NewsSource.fromJson(Map<String, dynamic> json) => NewsSource(
    id: json['id'] ?? "berita tidak mempunyai id",
    name: json['name'] ?? "berita tidak mempunyai nama",
  );
}

class NewsModel {
  NewsSource sumber;
  String penulis;
  String judul;
  String deskripsi;
  String url;
  String urlGambar;
  DateTime publishedAt;
  String content;

  NewsModel({
    required this.sumber,
    required this.penulis,
    required this.judul,
    required this.deskripsi,
    required this.url,
    required this.urlGambar,
    required this.publishedAt,
    required this.content,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
    sumber: NewsSource.fromJson(json["source"] ?? {}),
    penulis: json["author"] ?? "Nama penulis tidak tersedia",
    judul: json["title"] ?? "Judul artikel tidak tersedia",
    deskripsi: json["description"] ?? "Deskripsi artikel tidak tersedia",
    url: json["url"] ?? "-",
    urlGambar: json["urlToImage"] ?? "https://st3.depositphotos.com/1031343/13659/v/450/depositphotos_136598368-stock-illustration-not-available-sign-or-stamp.jpg",
    publishedAt: DateTime.tryParse(json["publishedAt"] ?? "") ?? DateTime.now(),
    content: json["content"] ?? "Artikel tidak memiliki konten",
  );
}
