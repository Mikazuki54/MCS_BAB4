# Praktikum Mobile Cloud Services (MCS) - BAB 4
## Implementasi REST API & State Management Provider pada Flutter

Dokumentasi ini berisi panduan konfigurasi, implementasi kode program yang telah dioptimasi (*clean code & idiomatic Provider*), serta penjelasan lengkap baris demi baris per file pada proyek Flutter aplikasi berita (**MCS BAB 4**).

---

## 1. Konfigurasi Izin Internet Android (`AndroidManifest.xml`)

Setelah file project berhasil terbentuk, pastikan kembali bahwa tampilan yang diberikan oleh Android Studio sudah berada pada menu **Project**. Jika sudah, bukalah file `AndroidManifest.xml` dan tambahkan izin berikut pada file tersebut.

File tersebut dapat diakses melalui path:
`android` > `app` > `src` > `main` > `AndroidManifest.xml`

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>

    <application
        android:label="bab4"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... -->
    </application>
</manifest>
```

### Penjelasan Kode:
Izin akses internet (`<uses-permission android:name="android.permission.INTERNET"/>`) wajib didefinisikan pada file manifest Android agar aplikasi Flutter diberikan hak oleh sistem operasi Android untuk melakukan komunikasi jaringan data (*networking/HTTP request*) ke server eksternal (News API). Tanpa penambahan izin ini pada level manifest, sistem operasi Android secara otomatis akan memblokir setiap koneksi jaringan keluar dan memicu *exception* (seperti `SocketException`) saat aplikasi berupaya mengambil data dari API.

---

## 2. Konfigurasi Dependensi (`pubspec.yaml`)

Kemudian, masuklah ke dalam file `pubspec.yaml` dan tambahkan package berikut ke dalam bagian `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  http: ^1.6.0
  provider: ^6.1.5+1
  google_fonts: ^9.0.0
  intl: ^0.20.3
  flutter_staggered_grid_view: ^0.7.0
  device_preview: ^3.0.0
```

### Penjelasan Package:
Dalam praktikum kali ini, kita menggunakan beberapa package tambahan untuk mendukung fitur aplikasi:
1. **`http`**: Digunakan untuk menangani proses pengiriman request HTTP (metode `GET`) ke endpoint REST API publik serta menerima dan mengolah respon dari server.
2. **`provider`**: Solusi state management berbasis *reactive listener* (`ChangeNotifier`) untuk mendistribusikan dan mengelola state data secara terpusat di seluruh widget tree tanpa perlu melakukan *prop drilling* (mengoper data berulang kali melalui constructor widget).
3. **`google_fonts`**: Mempermudah integrasi berbagai tipografi dan font modern dari pustaka Google Fonts secara dinamis tanpa harus mengunduh file `.ttf`/`.otf` secara manual.
4. **`intl`**: Menyediakan fungsi utilitas pemformatan tanggal dan waktu (`DateFormat`) agar representasi waktu rilis berita dapat ditampilkan sesuai standar format yang mudah dibaca oleh pengguna.
5. **`flutter_staggered_grid_view`**: Menyediakan widget layout grid dinamis bergaya *masonry* / *staggered* (seperti Pinterest), sehingga kartu berita dengan tinggi yang bervariasi dapat tersusun secara rapi dan estetis.
6. **`device_preview`**: Digunakan untuk melakukan simulasi dan pratinjau tampilan antarmuka aplikasi pada berbagai rasio layar perangkat seluler secara langsung.

---

## 3. Struktur Direktori Proyek (`lib/`)

Struktur folder dan file pada direktori `lib/` adalah sebagai berikut:

```text
lib/
├── main.dart
├── model/
│   └── news_model.dart
├── provider/
│   └── app_provider.dart
├── screens/
│   ├── detail_page.dart
│   └── home_page.dart
├── services/
│   └── news_services.dart
└── utils/
    └── app_styles.dart
```

---

## 4. Model Data Berita (`lib/model/news_model.dart`)

Masuklah ke dalam file `news_model.dart` dan masukkan kode program berikut:

```dart
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
  NewsSource source;
  String penulis;
  String judul;
  String deskripsi;
  String url;
  String urlGambar;
  DateTime publishedAt;
  String content;

  NewsModel({
    required this.source,
    required this.penulis,
    required this.judul,
    required this.deskripsi,
    required this.url,
    required this.urlGambar,
    required this.publishedAt,
    required this.content,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) => NewsModel(
    source: NewsSource.fromJson(json["source"] ?? {}),
    penulis: json["author"] ?? "Nama penulis tidak tersedia",
    judul: json["title"] ?? "Judul artikel tidak tersedia",
    deskripsi: json["description"] ?? "Deskripsi artikel tidak tersedia",
    url: json["url"] ?? "-",
    urlGambar: json["urlToImage"] ??
        "https://st3.depositphotos.com/1031343/13659/v/450/depositphotos_136598368-stock-illustration-not-available-sign-or-stamp.jpg",
    publishedAt: DateTime.tryParse(json["publishedAt"] ?? "") ?? DateTime.now(),
    content: json["content"] ?? "Artikel tidak memiliki konten",
  );
}
```

### Penjelasan Kode:
File tersebut berisikan class model yang merepresentasikan data dari News API dalam bentuk objek Dart (*type-safe*):
- **`NewsSource`**: Merepresentasikan data sumber berita (`id` dan `name`). Menggunakan *arrow syntax* (`=>`) pada constructor factory `fromJson` untuk pemetaan JSON yang ringkas.
- **`NewsModel`**: Merepresentasikan satu entitas artikel lengkap.
  - Memanfaatkan operator null-coalescing (`??`) untuk memberikan nilai default apabila data bernilai `null` dari server.
  - Menyediakan fallback URL gambar placeholder jika `urlToImage` kosong agar tidak menyebabkan error tampilan.
  - Mengonversi data waktu dengan fungsi `DateTime.tryParse(json["publishedAt"] ?? "") ?? DateTime.now()` sehingga waktu rilis berita asli dari API dapat dibaca dengan aman tanpa risiko exception parsing.

---

## 5. Layanan Pengambilan Data API (`lib/services/news_services.dart`)

Berikutnya masuklah ke dalam file `news_services.dart` dan masukkan kode program berikut:

```dart
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
```

### Penjelasan Kode:
Class **`NewsServices`** mengisolasi seluruh logika koneksi jaringan dan konsumsi REST API:
- **`universalUrl`**: Menyimpan endpoint URL News API beserta query dan parameter API key.
- **`getAllNewsData()`**: Fungsi *asynchronous* yang mengembalikan `Future<List<NewsModel>>`:
  - Mengirim HTTP GET request via `http.get(Uri.parse(universalUrl))`.
  - Jika `statusCode == 200`, respon JSON didecode dan array `"articles"` langsung dipetakan ke list objek `NewsModel` melalui chaining ringkas `.map((e) => NewsModel.fromJson(e)).toList()`.
  - Jika server merespon dengan status code selain 200 atau terjadi kendala jaringan, blok `try-catch` melempar `Exception` deskriptif.

---

## 6. Manajemen State Aplikasi (`lib/provider/app_provider.dart`)

Berikut implementasi `AppProvider` yang mematuhi standar *State Management* Provider dan prinsip pemisahan tanggung jawab (*Separation of Concerns*):

```dart
import 'package:bab4/model/news_model.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  NewsModel? _selectedNews;
  int? index;

  NewsModel? get selectedNews => _selectedNews;

  // Getter kompatibel dengan kode yang sudah ada tanpa perlu mengubah detail_page
  NewsSource? get source => _selectedNews?.source;
  String get namaPenulis => _selectedNews?.penulis ?? "Nama penulis tidak tersedia";
  String get judulArtikel => _selectedNews?.judul ?? "Judul artikel tidak tersedia";
  String get deskripsiArtikel => _selectedNews?.deskripsi ?? "Deskripsi artikel tidak tersedia";
  String get linkArtikel => _selectedNews?.url ?? "-";
  String get gambarArtikel => _selectedNews?.urlGambar ??
      "https://st3.depositphotos.com/1031343/13659/v/450/depositphotos_136598368-stock-illustration-not-available-sign-or-stamp.jpg";
  DateTime get tanggalPublish => _selectedNews?.publishedAt ?? DateTime.now();
  String get kontenArticle => _selectedNews?.content ?? "Artikel tidak memiliki konten";

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
```

### Penjelasan & Peningkatan Arsitektur:
1. **Single Source of Truth (`_selectedNews`)**: Alih-alih membongkar `NewsModel` ke 8 variabel terpisah dengan kata kunci `late` (yang rawan menyebabkan crash `LateInitializationError` jika diakses sebelum diinisialisasi), provider kini menyimpan referensi objek model tunggal yang dipilih.
2. **Getter Kompatibel**: Seluruh getter (`namaPenulis`, `judulArtikel`, `gambarArtikel`, dll.) disediakan sehingga kode antarmuka pada halaman detail tetap dapat membaca data secara langsung tanpa perlu mengubah pemanggilan variabel.
3. **`setSelectedNews()`**: Metode inti untuk memperbarui state berita terpilih dan memicu `notifyListeners()` untuk memberi tahu seluruh widget konsumen.
4. **Pemisahan Navigasi**: Urusan routing navigasi UI diarahkan ke widget asal (UI layer), sementara method `goToDetailNews()` tetap dipertahankan dengan tipe data parameter yang aman (`Widget navigationPage`) untuk menjamin kompatibilitas modul praktikum.

---

## 7. Sistem Desain dan Tipografi (`lib/utils/app_styles.dart`)

Masuklah ke dalam file `app_styles.dart` untuk mendefinisikan gaya teks yang konsisten di seluruh aplikasi:

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppStyles {
  static final titleFontStyle = GoogleFonts.oswald(
    fontSize: 17,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static final subTitleFontStyle = GoogleFonts.robotoFlex(
    fontSize: 17,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  );

  static final subTitleFontWIthStrokeStyle = GoogleFonts.robotoMono(
    fontSize: 17,
    color: Colors.white,
    textStyle: TextStyle(
      fontWeight: FontWeight.bold,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = Colors.black,
    ),
  );

  static final universalFontStyle = GoogleFonts.poppins(
    fontSize: 14,
    color: Colors.white,
  );
}
```

### Penjelasan Kode:
Class **`AppStyles`** berfungsi sebagai token desain tipografi terpusat:
- **`titleFontStyle`**: Font Google `Oswald` (17 pt, bold, putih) untuk AppBar dan judul artikel.
- **`subTitleFontStyle`**: Font Google `RobotoFlex` (17 pt, bold, putih) untuk judul artikel pada kartu grid beranda.
- **`subTitleFontWIthStrokeStyle`**: Font Google `RobotoMono` dengan outline border hitam 5 px.
- **`universalFontStyle`**: Font Google `Poppins` (14 pt, putih) untuk metadata dan isi deskripsi artikel.

---

## 8. Halaman Beranda (`lib/screens/home_page.dart`)

Berikut implementasi `HomePage` yang ringkas dan efisien:

```dart
import 'package:bab4/provider/app_provider.dart';
import 'package:bab4/screens/detail_page.dart';
import 'package:bab4/services/news_services.dart';
import 'package:bab4/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MCS BAB 4", style: AppStyles.titleFontStyle),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: NewsServices().getAllNewsData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: $snapshot"));
          } else {
            final getAllArticle = snapshot.data;
            return MasonryGridView.count(
              mainAxisSpacing: 8,
              crossAxisSpacing: 10,
              crossAxisCount: 3,
              itemCount: getAllArticle!.length,
              itemBuilder: (context, index) {
                final getSingleArticle = getAllArticle[index];
                return InkWell(
                  onTap: () {
                    context.read<AppProvider>().setSelectedNews(getSingleArticle, index);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DetailPage()),
                    );
                  },
                  child: Column(
                    children: [
                      Image.network(
                        getSingleArticle.urlGambar,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Image.network(
                          "https://st3.depositphotos.com/1031343/13659/v/450/depositphotos_136598368-stock-illustration-not-available-sign-or-stamp.jpg",
                          fit: BoxFit.cover,
                        ),
                      ),
                      Text(
                        getSingleArticle.judul,
                        style: AppStyles.subTitleFontStyle,
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
```

### Penjelasan & Peningkatan:
- **`StatelessWidget`**: Menggantikan `StatefulWidget` karena `HomePage` tidak mengelola state lokal (tidak ada `setState`), menghemat baris kode dan alokasi memori.
- **Konsumsi Provider yang Tepat (`context.read`)**: Menghilangkan wrapper `Consumer<AppProvider>` yang sebelumnya membungkus seluruh `Scaffold`. Pemanggilan provider hanya dibutuhkan saat interaksi klik pengguna (`onTap`) melalui `context.read<AppProvider>().setSelectedNews(...)`, sehingga layar utama tidak perlu di-rebuild secara berlebihan.
- **Navigasi UI**: Menggunakan rute navigasi standar `Navigator.push(context, MaterialPageRoute(...))` langsung pada UI layer.
- **`MasonryGridView.count`**: Menata feed kartu berita dengan tata letak grid staggered 3 kolom secara rapi.
- **Wildcard Parameter (`_, _, _`)**: Menggunakan sintaks wildcard modern Dart untuk parameter yang tidak digunakan pada `errorBuilder`.

---

## 9. Halaman Detail Berita (`lib/screens/detail_page.dart`)

Berikut implementasi halaman detail berita yang bersih dan bebas nesting berlebih:

```dart
import 'package:bab4/provider/app_provider.dart';
import 'package:bab4/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Detail News", style: AppStyles.titleFontStyle),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              appProvider.gambarArtikel,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.network(
                "https://st3.depositphotos.com/1031343/13659/v/450/depositphotos_136598368-stock-illustration-not-available-sign-or-stamp.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appProvider.judulArtikel,
                  style: AppStyles.titleFontStyle,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Penulis", style: AppStyles.universalFontStyle),
                    const SizedBox(width: 50),
                    Expanded(child: Text(": ${appProvider.namaPenulis}")),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Published", style: AppStyles.universalFontStyle),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Text(
                        ": ${DateFormat("d MMMM yyyy").format(appProvider.tanggalPublish)}",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text("Description News", style: AppStyles.titleFontStyle),
                Text(
                  appProvider.deskripsiArtikel,
                  style: AppStyles.universalFontStyle,
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Penjelasan & Peningkatan:
- **`context.watch<AppProvider>()`**: Menggantikan pembungkus `Consumer<AppProvider>(builder: ...)` bersarang, meratakan hierarki widget (*flat widget tree*), serta memangkas indentasi kode tanpa mengubah fungsionalitas reaktivitas.
- **Konsistensi Properti**: Seluruh nilai properti berita (`appProvider.gambarArtikel`, `appProvider.judulArtikel`, `appProvider.namaPenulis`, `appProvider.tanggalPublish`, `appProvider.deskripsiArtikel`) terbaca langsung secara mulus melalui getter pada provider.
- **`AspectRatio(aspectRatio: 16 / 9)`**: Menjaga proporsi tampilan banner berita.
- **`DateFormat` dari package `intl`**: Memformat objek `DateTime` ke format teks tanggal yang mudah dipahami (contoh: *25 Oktober 2026*).

---

## 10. Titik Masuk Utama Aplikasi (`lib/main.dart`)

Berikut implementasi file `main.dart`:

```dart
import 'package:bab4/provider/app_provider.dart';
import 'package:bab4/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AppProvider())],
      child: MaterialApp(
        title: "MCS BAB 4",
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const HomePage(),
      ),
    );
  }
}
```

### Penjelasan Kode:
- **`void main() => runApp(const MyApp());`**: Menggunakan ekspresi arrow satu baris untuk inisialisasi aplikasi.
- **`MultiProvider` & `ChangeNotifierProvider`**: Menginisialisasi `AppProvider` di root aplikasi agar seluruh widget turunan dapat mendengarkan perubahan state secara global.
- **`MaterialApp`**: Mengonfigurasi tema gelap (`ThemeData.dark()`), mematikan banner debug (`debugShowCheckedModeBanner: false`), dan menetapkan `const HomePage()` sebagai rute tampilan awal aplikasi.
