# Praktikum Mobile Cloud Services (MCS) - BAB 4
## Implementasi REST API & State Management Provider pada Flutter

Dokumentasi ini berisi panduan konfigurasi, implementasi kode program, serta penjelasan lengkap baris demi baris per file pada proyek Flutter aplikasi berita (**MCS BAB 4**).

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

Tambahkan beberapa file dan folder ke dalam folder `lib/`, sehingga struktur tree project menjadi seperti berikut:

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
  
  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      id: json['id'] ?? "berita tidak mempunyai id", 
      name: json['name'] ?? "berita tidak mempunyai nama",
    );
  }
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

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      source: NewsSource.fromJson(json["source"]), 
      penulis: json["author"] ?? "Nama penulis tidak tersedia", 
      judul: json["title"] ?? "Judul artikel tidak tersedia", 
      deskripsi: json["description"] ?? "Deskripsi artikel tidak tersedia", 
      url: json["url"] ?? "-", 
      urlGambar: json["urlToImage"] ?? "https://st3.depositphotos.com/1031343/13659/v/450/depositphotos_136598368-stock-illustration-not-available-sign-or-stamp.jpg", 
      publishedAt: DateTime.parse(DateTime.now().toIso8601String()), 
      content: json["content"] ?? "Artikel tidak memiliki konten",
    );
  }
}
```

### Penjelasan Kode:
File tersebut berisikan beberapa baris program yang digunakan dalam membuat model yang dapat merepresentasikan data API dalam bentuk *Dart Object*. Hal ini diperlukan agar proses konsumsi (*consume*) data API menjadi lebih mudah, aman terhadap tipe data (*type-safe*), dan lebih terstruktur dalam pengembangan aplikasi.

Terdapat 2 class yang dibangun berdasarkan format respon data yang diberikan oleh News API:
- **`[NewsSource]`**: Digunakan untuk merepresentasikan data asal sumber berita yang tersimpan pada array/objek `source` pada API. Class ini memiliki atribut `id` dan `name`. Pada class tersebut terdapat constructor yang bersifat `required` untuk memastikan kedua atribut terisi. Kemudian terdapat *named constructor* factory `NewsSource.fromJson` yang melakukan *mapping* nilai key JSON ke objek Dart dengan operator *null-coalescing* (`??`) sebagai nilai cadangan (*fallback*) jika data bernilai null.
- **`[NewsModel]`**: Merupakan model utama yang merepresentasikan satu entitas data artikel berita secara umum. Class ini memiliki atribut yang lebih komprehensif, meliputi `source` (bertipe `NewsSource`), `penulis`, `judul`, `deskripsi`, `url`, `urlGambar`, `publishedAt`, dan `content`. Constructor pada `NewsModel` bersifat `required` untuk menjamin integritas data. Pada metode `NewsModel.fromJson`, dilakukan pemetaan nilai dari respons JSON:
  - Mengonversi objek bersarang (*nested object*) `source` dengan memanggil `NewsSource.fromJson(json["source"])`.
  - Memberikan nilai default apabila field author, title, description, url, atau content bernilai null.
  - Menyediakan URL gambar placeholder jika `urlToImage` tidak tersedia agar tampilan UI tidak rusak.
  - Mengonversi tanggal ke format objek `DateTime`.

---

## 5. Layanan Pengambilan Data API (`lib/services/news_services.dart`)

Berikutnya masuklah ke dalam file `news_services.dart` dan masukkan kode program berikut di dalamnya:

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
        final responseBody = jsonDecode(response.body);
        final List articleResponse = responseBody["articles"];
        final newsResult = articleResponse
            .map((e) => NewsModel.fromJson(e))
            .toList();
        return newsResult;
      } else {
        throw Exception(
          "Gagal mendapatkan data. Status Code: ${response.statusCode}",
        );
      }
    } catch (e) {
      throw Exception("Error Detail: $e");
    }
  }
}
```

### Penjelasan Kode:
Class **`[NewsServices]`** berisikan logika program yang diperlukan untuk mengambil data berita dari server News API:
- **`universalUrl`**: Variabel yang menyimpan endpoint URL News API beserta parameter pencarian dan API Key milik masing-masing pengembang.
- **`getAllNewsData()`**: Metode *asynchronous* yang mengembalikan `Future<List<NewsModel>>`. 
  - Sistem mengirimkan HTTP request dengan memanggil `http.get(Uri.parse(universalUrl))` dan menampung hasilnya ke dalam variabel `response`.
  - Sistem memeriksa kode status HTTP (`response.statusCode`). Jika kode status bernilai `200` (OK/berhasil), sistem mengambil data body yang masih berupa string JSON mentah dan menguraikannya menggunakan fungsi `jsonDecode(response.body)` ke dalam variabel `responseBody`.
  - Selanjutnya, array data artikel diambil dari key `"articles"` ke dalam variabel `articleResponse` bertipe `List`.
  - Menggunakan metode transformasi `.map((e) => NewsModel.fromJson(e)).toList()`, setiap elemen data JSON diubah menjadi objek Dart `NewsModel` dan dikembalikan sebagai hasil akhir fungsi.
  - Jika `statusCode` bukan 200 atau terjadi kendala koneksi, blok `try-catch` akan menangkap kegagalan tersebut dan melempar `Exception` dengan rincian pesan kesalahan.

---

## 6. Manajemen State Aplikasi (`lib/provider/app_provider.dart`)

Selanjutnya dibentuklah class provider bernama `AppProvider` yang menge-*extends* `ChangeNotifier`. Berikut kode yang digunakan pada class `AppProvider`:

```dart
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
      MaterialPageRoute(builder: (context) => navigationPage),
    );
  }
}
```

### Penjelasan Kode:
Class **`[AppProvider]`** bertindak sebagai pengelola state (*State Management*) terpusat dengan mengimplementasikan pola *Observer* melalui `ChangeNotifier`:
- **State Properties**: Menyimpan variabel status artikel yang sedang aktif dipilih pengguna, antara lain `source`, `namaPenulis`, `judulArtikel`, `deskripsiArtikel`, `linkArtikel`, `gambarArtikel`, `tanggalPublish`, `kontenArticle`, dan `index`.
- **`goToDetailNews()`**: Fungsi yang dieksekusi ketika salah satu kartu berita pada halaman utama diklik oleh pengguna. Fungsi ini menerima `BuildContext`, data `NewsModel` terpilih, indeks berita, serta halaman tujuan `navigationPage` (`DetailPage`).
- **`notifyListeners()`**: Berfungsi mengirimkan sinyal notifikasi kepada seluruh widget pendengar (*listener*) yang dibungkus oleh `Consumer<AppProvider>` bahwa nilai data state telah diperbarui sehingga antarmuka detail langsung terisi data terbaru.
- **`Navigator.push`**: Mengarahkan perpindahan rute halaman secara dinamis menuju `DetailPage`.

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
Class **`[AppStyles]`** berfungsi sebagai *Design Token* untuk standardisasi gaya teks (*typography*) pada aplikasi:
- **`titleFontStyle`**: Menggunakan font Google `Oswald` ukuran 17 pt, warna putih, dan `FontWeight.bold`, digunakan untuk judul utama pada AppBar dan judul artikel berita.
- **`subTitleFontStyle`**: Menggunakan font Google `RobotoFlex` ukuran 17 pt, warna putih, dan `FontWeight.bold`, digunakan untuk judul artikel pada kartu grid beranda.
- **`subTitleFontWIthStrokeStyle`**: Menggunakan font Google `RobotoMono` dengan atribut `foreground: Paint()` berupa garis tepi (*stroke*) warna hitam setebal 5 px untuk menciptakan teks dengan efek kontras outline.
- **`universalFontStyle`**: Menggunakan font Google `Poppins` ukuran 14 pt warna putih, digunakan untuk teks umum, label metadata, serta isi deskripsi berita.

---

## 8. Halaman Beranda (`lib/screens/home_page.dart`)

Masuklah ke dalam file `home_page.dart` dan masukkan kode program berikut:

```dart
import 'package:bab4/provider/app_provider.dart';
import 'package:bab4/screens/detail_page.dart';
import 'package:bab4/services/news_services.dart';
import 'package:bab4/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text("MCS BAB 4", style: AppStyles.titleFontStyle),
            centerTitle: true,
          ),
          body: FutureBuilder(
            future: NewsServices().getAllNewsData(), 
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
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
                      child: Column(
                        children: [
                          Image.network(
                            getSingleArticle.urlGambar,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.network(
                                "https://st3.depositphotos.com/1031343/13659/v/450/depositphotos_136598368-stock-illustration-not-available-sign-or-stamp.jpg",
                                fit: BoxFit.cover,
                              );
                            },
                          ),
                          Text(
                            getSingleArticle.judul,
                            style: AppStyles.subTitleFontStyle,
                          ),
                        ],
                      ),
                      onTap: () {
                        appProvider.goToDetailNews(
                          context: context, 
                          newsModel: getSingleArticle, 
                          index: index, 
                          navigationPage: const DetailPage(),
                        );
                      },
                    );
                  },
                );
              }
            },
          ),
        );
      },
    );
  }
}
```

### Penjelasan Kode:
Class **`[HomePage]`** merupakan antarmuka utama yang menampilkan feed berita dalam bentuk grid staggered:
- **`Consumer<AppProvider>`**: Membungkus seluruh tampilan halaman agar dapat berinteraksi secara langsung dengan state dan metode yang ada di `AppProvider`.
- **`FutureBuilder`**: Widget pembangun UI berbasis proses *asynchronous* dari pemanggilan fungsi `NewsServices().getAllNewsData()`:
  - `ConnectionState.waiting`: Menampilkan indikator loading animasi `CircularProgressIndicator` di tengah layar saat data berita masih dalam proses unduh dari API.
  - `snapshot.hasError`: Menampilkan pesan teks kesalahan apabila terjadi kegagalan jaringan atau parsing.
  - Kondisi data berhasil diterima: Data artikel disimpan pada variabel `getAllArticle`.
- **`MasonryGridView.count`**: Komponen dari package `flutter_staggered_grid_view` yang menyusun tata letak grid dengan 3 kolom (`crossAxisCount: 3`), jarak antar kolom 10 px (`crossAxisSpacing: 10`), dan jarak vertikal 8 px (`mainAxisSpacing: 8`).
- **`InkWell`**: Memberikan efek respons sentuhan (*splash/ripple effect*) pada setiap kartu berita. Ketika ditekan (`onTap`), sistem memanggil fungsi `appProvider.goToDetailNews()` untuk menyetel data artikel yang dipilih ke provider dan menavigasikan pengguna ke `DetailPage`.
- **`Image.network` & `errorBuilder`**: Memuat gambar artikel dari internet. Apabila link gambar rusak atau tidak dapat dimuat, fungsi `errorBuilder` akan memuat gambar cadangan (*placeholder*) sehingga tampilan aplikasi tetap rapi.

---

## 9. Halaman Detail Berita (`lib/screens/detail_page.dart`)

Masuklah ke dalam file `detail_page.dart` dan masukkan kode program berikut:

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
    return Consumer<AppProvider>(
      builder: ((context, appProvider, child) {
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
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      "https://st3.depositphotos.com/1031343/13659/v/450/depositphotos_136598368-stock-illustration-not-available-sign-or-stamp.jpg",
                      fit: BoxFit.cover,
                    );
                  },
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
                        Text(
                          "Penulis",
                          style: AppStyles.universalFontStyle,
                        ),
                        const SizedBox(width: 50),
                        Expanded(child: Text(": ${appProvider.namaPenulis}")),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Published",
                          style: AppStyles.universalFontStyle,
                        ),
                        const SizedBox(width: 30),
                        Expanded(
                          child: Text(
                            ": ${DateFormat("d MMMM yyyy").format(appProvider.tanggalPublish)}",
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      "Description News",
                      style: AppStyles.titleFontStyle,
                    ),
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
      }),
    );
  }
}
```

### Penjelasan Kode:
Class **`[DetailPage]`** merupakan antarmuka untuk menyajikan rincian lengkap dari artikel berita yang telah dipilih:
- **`Consumer<AppProvider>`**: Mengonsumsi data state berita secara langsung dari `AppProvider` tanpa perlu mengirimkan objek melalui parameter constructor widget.
- **`AspectRatio(aspectRatio: 16 / 9, ...)`**: Menjaga proporsi tampilan gambar utama berita pada rasio layar 16:9 agar gambar tidak terdistorsi dan mengisi lebar layar secara konsisten.
- **`DateFormat("d MMMM yyyy")`**: Memanfaatkan pustaka `intl` untuk memformat objek `DateTime` (`appProvider.tanggalPublish`) menjadi format penanggalan yang rapi dan mudah dipahami (misalnya: *25 Oktober 2026*).
- **Struktur Metadata (`Row` & `Expanded`)**: Menampilkan nama penulis dan tanggal terbit secara terstruktur menggunakan perataan horizontal.
- **Deskripsi Berita**: Menampilkan teks deskripsi artikel dengan gaya teks `AppStyles.universalFontStyle` dan perataan rata kiri-kanan (`TextAlign.justify`).

---

## 10. Titik Masuk Utama Aplikasi (`lib/main.dart`)

Masuklah ke dalam file `main.dart` dan masukkan kode program berikut:

```dart
import 'package:bab4/provider/app_provider.dart';
import 'package:bab4/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AppProvider()),
      ],
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
File `main.dart` merupakan titik awal (*entry point*) eksekusi program Flutter:
- **`void main()`**: Fungsi utama yang memanggil `runApp(const MyApp())` untuk menginisialisasi dan merender root widget ke layar perangkat.
- **`MultiProvider` & `ChangeNotifierProvider`**: Ditempatkan di puncak hierarki widget tree aplikasi untuk menginstansiasi `AppProvider`. Penempatan ini memastikan seluruh widget turunan dalam aplikasi dapat mengakses dan mendengarkan perubahan state pada `AppProvider`.
- **`MaterialApp`**:
  - `title: "MCS BAB 4"`: Menentukan judul aplikasi pada task manager sistem operasi.
  - `debugShowCheckedModeBanner: false`: Menghilangkan banner debug di pojok kanan atas tampilan aplikasi.
  - `theme: ThemeData.dark()`: Menerapkan tema gelap (*dark theme*) secara global pada seluruh halaman dan elemen antarmuka.
  - `home: const HomePage()`: Menetapkan `HomePage` sebagai halaman awal yang pertama kali dimuat saat aplikasi dibuka.
