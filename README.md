# Praktikum Mobile Cloud Services (MCS) - BAB 4
## Implementasi REST API & State Management Provider pada Flutter

Dokumentasi ini berisi panduan konfigurasi, implementasi kode program yang ringkas (*clean & idiomatic Flutter*), serta penjelasan lengkap per file pada proyek Flutter aplikasi berita (**MCS BAB 4**).

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
```

### Penjelasan Kode:
File tersebut berisikan class model yang merepresentasikan data dari News API dalam bentuk objek Dart (*type-safe*):
- **`NewsSource`**: Merepresentasikan data sumber berita (`id` dan `name`) dengan sintaks *arrow function* (`=>`) yang ringkas.
- **`NewsModel`**: Merepresentasikan satu entitas artikel lengkap.
  - Memanfaatkan operator null-coalescing (`??`) untuk menetapkan nilai default jika respon bernilai `null`.
  - Menyediakan fallback URL gambar placeholder jika `urlToImage` tidak tersedia.
  - Mengonversi data waktu dengan `DateTime.tryParse(json["publishedAt"] ?? "") ?? DateTime.now()` agar aman dari parsing exception.

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
    final response = await http.get(Uri.parse(universalUrl));
    if (response.statusCode == 200) {
      final List list = jsonDecode(response.body)["articles"];
      return list.map((e) => NewsModel.fromJson(e)).toList();
    }
    throw Exception("Gagal mendapatkan data: ${response.statusCode}");
  }
}
```

### Penjelasan Kode:
Class **`NewsServices`** mengisolasi seluruh logika koneksi jaringan dan konsumsi REST API:
- **`universalUrl`**: Menyimpan endpoint URL News API beserta query dan parameter API key.
- **`getAllNewsData()`**: Fungsi *asynchronous* yang mengambil data artikel dari News API:
  - Mengirim HTTP GET request via `http.get(Uri.parse(universalUrl))`.
  - Jika `statusCode == 200`, respon di-decode dan array `"articles"` langsung dipetakan ke list objek `NewsModel` via `.map().toList()`.
  - Jika respon gagal, langsung melempar `Exception` dengan status kodenya.

---

## 6. Manajemen State Aplikasi (`lib/provider/app_provider.dart`)

Berikut implementasi `AppProvider` yang sangat ringkas, bersih, dan mematuhi kaidah State Management Provider:

```dart
import 'package:bab4/model/news_model.dart';
import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  NewsModel? selectedNews;

  void setSelectedNews(NewsModel news) {
    selectedNews = news;
    notifyListeners();
  }
}
```

### Penjelasan Kode:
1. **Model Utuh (`selectedNews`)**: Provider hanya bertugas mengelola state data berita yang sedang aktif dipilih pengguna, tanpa perlu memecah objek ke banyak variabel terpisah atau menggunakan variabel `late`.
2. **`setSelectedNews(news)`**: Memperbarui artikel yang dipilih dan memicu `notifyListeners()` untuk memperbarui widget yang mendengarkan perubahan data.
3. **Pemisahan Peran**: Logika navigasi antar halaman berada di UI layer (widget), sehingga `AppProvider` sepenuhnya independen dari `BuildContext` dan `Navigator`.

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
- **`subTitleFontWIthStrokeStyle`**: Font Google `RobotoMono` dengan garis tepi (*stroke*) hitam 5 px.
- **`universalFontStyle`**: Font Google `Poppins` (14 pt, putih) untuk metadata dan isi deskripsi artikel.

---

## 8. Halaman Beranda (`lib/screens/home_page.dart`)

Berikut implementasi `HomePage` yang ringkas dan efisien:

```dart
import 'package:bab4/model/news_model.dart';
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
      body: FutureBuilder<List<NewsModel>>(
        future: NewsServices().getAllNewsData(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: snapshot.hasError
                  ? Text("Error: ${snapshot.error}")
                  : const CircularProgressIndicator(),
            );
          }
          final articles = snapshot.data!;
          return MasonryGridView.count(
            mainAxisSpacing: 8,
            crossAxisSpacing: 10,
            crossAxisCount: 3,
            itemCount: articles.length,
            itemBuilder: (context, index) {
              final item = articles[index];
              return InkWell(
                onTap: () {
                  context.read<AppProvider>().setSelectedNews(item);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DetailPage()),
                  );
                },
                child: Column(
                  children: [
                    Image.network(
                      item.urlGambar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Image.network(
                        "https://st3.depositphotos.com/1031343/13659/v/450/depositphotos_136598368-stock-illustration-not-available-sign-or-stamp.jpg",
                        fit: BoxFit.cover,
                      ),
                    ),
                    Text(item.judul, style: AppStyles.subTitleFontStyle),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

### Penjelasan Kode:
- **`StatelessWidget`**: Tidak memerlukan state internal sehingga lebih hemat memori dan baris kode.
- **Handling Data Ringkas**: Pengecekan status data dilakukan secara simpel dengan `!snapshot.hasData` yang langsung menampilkan error atau indikator loading.
- **`context.read<AppProvider>()`**: Memanggil fungsi provider hanya ketika artikel diklik (`onTap`) tanpa memicu rebuild yang tidak perlu pada widget induk.
- **`Navigator.push`**: Mengarahkan perpindahan rute langsung dari UI event listener.

---

## 9. Halaman Detail Berita (`lib/screens/detail_page.dart`)

Berikut implementasi halaman detail berita:

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
    final news = context.watch<AppProvider>().selectedNews!;

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
              news.urlGambar,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Image.network(
                "https://st3.depositphotos.com/1031343/13659/v/450/depositphotos_136598368-stock-illustration-not-available-sign-or-stamp.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(news.judul, style: AppStyles.titleFontStyle, textAlign: TextAlign.center),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Penulis", style: AppStyles.universalFontStyle),
                    const SizedBox(width: 50),
                    Expanded(child: Text(": ${news.penulis}")),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Published", style: AppStyles.universalFontStyle),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Text(": ${DateFormat("d MMMM yyyy").format(news.publishedAt)}"),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Text("Description News", style: AppStyles.titleFontStyle),
                Text(news.deskripsi, style: AppStyles.universalFontStyle, textAlign: TextAlign.justify),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Penjelasan Kode:
- **`context.watch<AppProvider>().selectedNews!`**: Mengambil objek berita secara langsung dari provider tanpa wrapper bersarang, sehingga hierarki widget tetap rata (*flat tree*).
- **Akses Langsung ke Properti Model**: Properti seperti `news.urlGambar`, `news.judul`, `news.penulis`, `news.publishedAt`, dan `news.deskripsi` diakses langsung dari objek model.

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
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (_) => AppProvider(),
    child: MaterialApp(
      title: "MCS BAB 4",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    ),
  );
}
```

### Penjelasan Kode:
- **`ChangeNotifierProvider` Tunggal**: Menggantikan pembungkus `MultiProvider` karena aplikasi hanya memerlukan satu provider `AppProvider`.
- **Ekspresi Arrow (`=>`)**: Membuat deklarasi widget dan inisialisasi aplikasi menjadi sangat ringkas.
