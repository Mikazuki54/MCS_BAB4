# Praktikum Mobile Cloud Services (MCS) - BAB 4
## Implementasi REST API & State Management Provider pada Flutter

Dokumentasi ini berisi panduan konfigurasi, implementasi kode program yang ringkas (*clean & idiomatic Flutter*), serta **penjelasan lengkap untuk orang awam beserta analoginya** pada proyek Flutter aplikasi berita (**MCS BAB 4**).

---

## Gambaran Umum: Analogi Cara Kerja Aplikasi

Agar mudah dipahami oleh orang awam, bayangkan aplikasi berita ini seperti **Sebuah Kios Koran Digital**:

1. **`news_model.dart` (Cetakan / Formulir Berita)**: Template standar yang menentukan setiap berita harus punya Judul, Penulis, Foto, Tanggal, dan Isi.
2. **`news_services.dart` (Kurir Pengambil Berita)**: Kurir yang pergi ke gudang berita di internet (API), mengambil berita mentah, lalu memasukkannya ke dalam cetakan `news_model`.
3. **`app_provider.dart` (Petugas Pembawa Baki Berita Pilihan)**: Petugas yang memegang dan mengingat berita mana yang sedang Anda tunjuk/pilih agar bisa dibaca di halaman sebelah.
4. **`app_styles.dart` (Buku Panduan Seragam Huruf)**: Aturan standar jenis huruf, ukuran, dan warna tulisan agar tampilan koran seragam dan rapi.
5. **`home_page.dart` (Etalase Depan Kios)**: Halaman depan yang memajang daftar foto dan judul berita dalam 3 kolom.
6. **`detail_page.dart` (Ruang Baca Lengkap)**: Halaman khusus untuk membaca rincian satu berita secara penuh setelah berita di etalase diklik.
7. **`main.dart` (Saklar Utama / Tombol Power)**: Pintu utama yang menyalakan aplikasi, menyiapkan petugas `app_provider`, mengatur tema gelap, dan membuka halaman `home_page` pertama kali.

---

## 1. Konfigurasi Izin Internet Android (`AndroidManifest.xml`)

Setelah file project berhasil terbentuk, pastikan tampilan Android Studio berada pada menu **Project**. Bukalah file `AndroidManifest.xml` melalui path:
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

### Analogi & Penjelasan untuk Orang Awam:
- **Analogi**: Bayangkan aplikasi ini seperti kurir yang tinggal di dalam gedung berkeamanan ketat (HP Android). Baris `<uses-permission android:name="android.permission.INTERNET"/>` adalah **surat izin keluar-masuk gerbang** agar kurir aplikasi diizinkan oleh satpam HP untuk pergi ke luar (internet) mengambil berita. Tanpa surat izin ini, kurir akan ditahan di gerbang dan tidak bisa mengambil berita sama sekali.

---

## 2. Konfigurasi Dependensi (`pubspec.yaml`)

Masuklah ke dalam file `pubspec.yaml` dan tambahkan package berikut pada bagian `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.8
  http: ^1.6.0
  provider: ^6.1.5+1
  google_fonts: ^9.0.0
  intl: ^0.20.3
  flutter_staggered_grid_view: ^0.7.0
  device_preview: ^3.0.0
```

### Analogi & Penjelasan Package untuk Orang Awam:
Jika kita membangun rumah/kios, *package* adalah **perkakas siap pakai** agar kita tidak perlu membuat semuanya dari nol:
1. **`http` (Kendaraan Kurir)**: Alat transportasi untuk mengirim pesan dan mengambil data berita dari internet.
2. **`provider` (Sistem Walkie-Talkie / Papan Pengumuman)**: Alat komunikasi antar-halaman agar data berita yang dipilih di halaman depan langsung diketahui oleh halaman detail.
3. **`google_fonts` (Koleksi Gaya Huruf)**: Katalog berbagai jenis huruf bagus dari Google agar tampilan teks lebih menarik.
4. **`intl` (Penerjemah Format Tanggal)**: Alat untuk mengubah format tanggal komputer yang kaku (seperti `2026-11-04T10:00:00Z`) menjadi tulisan yang enak dibaca manusia (seperti `4 November 2026`).
5. **`flutter_staggered_grid_view` (Rak Pajangan Majalah)**: Alat penyusun tata letak kotak-kotak berita bergaya *Pinterest* (3 kolom yang tingginya menyesuaikan isi secara otomatis).
6. **`device_preview` (Simulator Layar HP)**: Alat untuk mencoba tampilan aplikasi di berbagai ukuran layar HP langsung di komputer.

---

## 3. Struktur & Urutan File Proyek (`lib/`)

Berikut adalah struktur folder di dalam `lib/` beserta urutan alur penjelasan kodenya:

```text
lib/
├── model/
│   └── news_model.dart        # (1) Cetakan / struktur data berita
├── services/
│   └── news_services.dart     # (2) Kurir pengambil berita dari API internet
├── provider/
│   └── app_provider.dart      # (3) Penyimpan berita yang sedang dipilih
├── utils/
│   └── app_styles.dart        # (4) Aturan gaya huruf / tipografi
├── screens/
│   ├── home_page.dart         # (5) Tampilan halaman daftar berita (Beranda)
│   └── detail_page.dart       # (6) Tampilan halaman isi detail berita
└── main.dart                  # (7) Saklar utama / titik mulai aplikasi
```

---

## 4. Penjelasan Kode Setiap File (Berurutan)

---

### Urutan 1: `lib/model/news_model.dart` (Cetakan Data Berita)

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
    urlGambar: json["urlToImage"] ?? "https://demofree.sirv.com/nope-not-here.jpg",
    publishedAt: DateTime.tryParse(json["publishedAt"] ?? "") ?? DateTime.now(),
    content: json["content"] ?? "Artikel tidak memiliki konten",
  );
}
```

#### Analogi untuk Orang Awam:
Bayangkan file ini seperti **Formulir Biodata Berita**. Data berita yang datang dari internet awalnya masih berantakan seperti tumpukan kertas mentah berbahasa asing (disebut *JSON*). File ini bertugas menjadi **cetakan sekaligus penerjemah** yang menyalin data mentah tersebut ke dalam kotak-kotak formulir yang rapi: kotak *Sumber*, *Penulis*, *Judul*, *Deskripsi*, *URL*, *Gambar*, *Tanggal Terbit*, dan *Konten*.

#### Penjelasan Bagian demi Bagian untuk Orang Awam:
- **`class NewsSource`**: Cetakan kecil khusus untuk mencatat asal media berita (memiliki `id` dan `name`, misalnya: *BBC News* atau *Kompas*).
- **`class NewsModel`**: Cetakan utama untuk satu artikel berita utuh yang berisi 8 informasi penting (`sumber`, `penulis`, `judul`, `deskripsi`, `url`, `urlGambar`, `publishedAt`, `content`).
- **`factory ... fromJson(...)`**: Ini adalah **"mesin penyalin otomatis"**. Saat menerima paket data mentah `json` dari internet, bagian ini mengambil isi tiap label (seperti `json["title"]`) lalu memasukkannya ke variabel `judul`.
- **Tanda `??` (Rencana Cadangan / *Fallback*)**: Artinya *"kalau kosong, pakai nilai di sebelah kanan"*. Contohnya pada `json["author"] ?? "Nama penulis tidak tersedia"`: jika berita dari internet tidak mencantumkan nama penulis (`null`), aplikasi tidak akan error/rusak, melainkan otomatis menulis *"Nama penulis tidak tersedia"*. Begitu juga jika foto berita kosong (`urlToImage`), maka akan diganti dengan gambar cadangan.
- **`DateTime.tryParse(...) ?? DateTime.now()`**: Mengubah teks tanggal dari internet menjadi format kalender yang dimengerti aplikasi. Jika tanggal dari internet rusak/kosong, otomatis memakai waktu hari ini.

---

### Urutan 2: `lib/services/news_services.dart` (Kurir Pengambil Berita)

```dart
import 'dart:convert';
import 'package:bab4/model/news_model.dart';
import 'package:http/http.dart' as http;

class NewsServices {
  final universalUrl =
      "https://newsapi.org/v2/everything?q=tesla&from=2026-11-01&sortBy=publishedAt&apiKey=MASUKKAN_API_KEY";

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

#### Analogi untuk Orang Awam:
Bayangkan `NewsServices` adalah **Kurir Pengantar Koran**. Anda memberi kurir ini alamat gudang berita pusat (`universalUrl`). Kurir tersebut berangkat ke internet, mengambil kardus besar berisi kumpulan berita, membukanya, lalu mencetak setiap berita menggunakan cetakan `NewsModel` tadi hingga menjadi tumpukan berita yang siap dipajang di etalase.

#### Penjelasan Bagian demi Bagian untuk Orang Awam:
- **`universalUrl`**: Alamat tujuan di internet (NewsAPI) tempat berita disimpan, lengkap dengan kata kunci topik yang dicari (misalnya `q=tesla`) dan kunci rahasia akses (`apiKey`).
- **`Future<List<NewsModel>> getAllNewsData() async`**: Tugas pengambilan berita yang bersifat *"janji di masa depan"* (`Future`). Karena mengambil data dari internet butuh waktu beberapa detik, kata `async` dan `await` menyuruh aplikasi menunggu kurir kembali dengan sabar tanpa membuat layar HP pengguna macet (*freeze*).
- **`http.get(Uri.parse(universalUrl))`**: Perintah bagi kurir untuk berangkat mengambil data ke alamat URL tersebut.
- **`if (response.statusCode == 200)`**: Dalam bahasa internet, angka **`200`** artinya **"Sukses / Gudang Buka & Data Diterima"**.
- **`jsonDecode(response.body)["articles"]`**: Membuka bungkus paket dari internet dan mengambil daftar berita di dalam kantong bernama `"articles"`.
- **`list.map((e) => NewsModel.fromJson(e)).toList()`**: Memasukkan satu per satu berita mentah (`e`) ke dalam mesin cetakan `NewsModel.fromJson`, lalu menyusunnya menjadi satu daftar (`List`) yang rapi.
- **`throw Exception(...)`**: Jika angka statusnya bukan `200` (misal `404` alamat tidak ditemukan atau `401` kunci API salah), kurir akan melapor bahwa pengambilan data gagal.

---

### Urutan 3: `lib/provider/app_provider.dart` (Pengelola Berita yang Dipilih)

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

#### Analogi untuk Orang Awam:
Bayangkan `AppProvider` adalah **Petugas Pembawa Baki (atau Papan Pengumuman Pusat)**.
Di halaman depan ada puluhan berita. Ketika jari Anda mengklik **satu berita**, bagaimana caranya halaman baca (`DetailPage`) tahu berita mana yang baru saja Anda klik?
Di sinilah tugas `AppProvider`: begitu Anda mengklik sebuah berita, petugas ini menaruh berita tersebut di atas bakinya (`selectedNews`), lalu membunyikan bel (`notifyListeners()`) agar halaman detail langsung menampilkan isi berita yang ada di baki tersebut.

#### Penjelasan Bagian demi Bagian untuk Orang Awam:
- **`extends ChangeNotifier`**: Memberikan kemampuan "membunyikan bel pengumuman" pada class ini setiap kali ada perubahan data.
- **`NewsModel? selectedNews`**: Tempat penyimpanan (baki) untuk menampung **1 berita** yang sedang dipilih pengguna. Tanda tanya `?` artinya saat aplikasi baru dibuka dan pengguna belum mengklik berita apa pun, baki ini boleh kosong (`null`).
- **`void setSelectedNews(NewsModel news)`**: Fungsi untuk mengganti isi baki dengan berita baru (`news`) yang diklik pengguna, lalu memanggil `notifyListeners()` untuk memberi tahu layar yang sedang memantau bahwa datanya sudah siap.

---

### Urutan 4: `lib/utils/app_styles.dart` (Katalog Seragam Huruf / Tipografi)

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

#### Analogi untuk Orang Awam:
Bayangkan file ini adalah **Buku Aturan Seragam Tulisan di Percetakan Koran**. Daripada di setiap halaman kita harus mengatur ulang ukuran huruf, warna putih, dan ketebalan huruf satu-satu, kita cukup membuat "seragam" siap pakai di sini. Jika suatu saat kita ingin mengubah ukuran judul di seluruh aplikasi, kita cukup mengubahnya di satu file ini saja.

#### Penjelasan Bagian demi Bagian untuk Orang Awam:
- **`static final`**: Membuat gaya huruf ini bisa langsung dipakai dari mana saja cukup dengan memanggil `AppStyles.namaGaya` tanpa perlu membuat objek baru.
- **`titleFontStyle`**: Seragam untuk **Judul Utama** (memakai font *Oswald*, ukuran 17, warna putih, cetak tebal/bold).
- **`subTitleFontStyle`**: Seragam untuk **Judul Kartu Berita di Beranda** (memakai font *Roboto Flex*, ukuran 17, putih, tebal).
- **`subTitleFontWIthStrokeStyle`**: Seragam huruf dengan efek garis tepi (*outline/stroke*) warna hitam setebal 5 piksel.
- **`universalFontStyle`**: Seragam untuk **teks biasa / isi berita** (memakai font *Poppins*, ukuran 14, warna putih agar nyaman dibaca di latar gelap).

---

### Urutan 5: `lib/screens/home_page.dart` (Etalase Halaman Beranda)

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
                        "https://demofree.sirv.com/nope-not-here.jpg",
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

#### Analogi untuk Orang Awam:
Bayangkan `HomePage` adalah **Etalase Depan Kios Koran**. Begitu pengunjung datang, etalase ini menyuruh kurir (`NewsServices`) mengambil berita. Sambil menunggu kurir datang, etalase menampilkan roda loading berputar. Begitu kurir sampai membawa berita, etalase langsung memajang foto dan judul berita berjejer 3 kolom. Jika pengunjung menyentuh salah satu berita, berita itu ditaruh ke baki `AppProvider` dan pengunjung diantar masuk ke ruang baca (`DetailPage`).

#### Penjelasan Bagian demi Bagian untuk Orang Awam:
- **`Scaffold` & `AppBar`**: Kerangka dasar layar HP yang memiliki balok judul di bagian paling atas bertuliskan `"MCS BAB 4"` tepat di tengah (`centerTitle: true`).
- **`FutureBuilder<List<NewsModel>>`**: "Satpam pemantau kurir". Ia memanggil `NewsServices().getAllNewsData()` lalu memantau hasilnya lewat `snapshot`:
  - **`if (!snapshot.hasData)`**: Jika paket berita belum ada, ia mengecek apakah karena ada masalah (`snapshot.hasError`) untuk menampilkan teks error, atau karena kurir masih di jalan sehingga cukup menampilkan lingkaran berputar (`CircularProgressIndicator`).
- **`MasonryGridView.count(...)`**: Rak pajangan 3 kolom (`crossAxisCount: 3`) dengan jarak antar baris `8` piksel dan jarak antar kolom `10` piksel.
- **`InkWell` & `onTap`**: Membuat kartu berita bisa disentuh/diklik dengan efek riak air:
  1. `context.read<AppProvider>().setSelectedNews(item)`: Menitipkan berita yang diklik (`item`) ke petugas `AppProvider`.
  2. `Navigator.push(...)`: Membuka lembaran halaman baru menuju `DetailPage`.
- **`Image.network` & `errorBuilder`**: Menampilkan foto berita dari internet. Jika link foto dari berita tersebut ternyata rusak/mati, `errorBuilder` otomatis menggantinya dengan foto cadangan agar layar tidak menampilkan kotak merah error.

---

### Urutan 6: `lib/screens/detail_page.dart` (Ruang Baca Detail Berita)

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
                "https://demofree.sirv.com/nope-not-here.jpg",
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

#### Analogi untuk Orang Awam:
Bayangkan `DetailPage` adalah **Ruang Baca Khusus**. Begitu Anda masuk ke ruangan ini setelah mengklik salah satu berita di depan, ruangan ini langsung mengambil berita yang dibawa oleh petugas `AppProvider`, lalu membentangkannya secara lengkap di atas meja baca: ada foto besar di bagian atas, judul di tengah, keterangan nama penulis dan tanggal rilis, serta paragraf isi deskripsi berita yang rapi.

#### Penjelasan Bagian demi Bagian untuk Orang Awam:
- **`final news = context.watch<AppProvider>().selectedNews!`**: Mengambil berita yang tadi dititipkan di baki `AppProvider` dan menyimpannya ke dalam variabel `news`.
- **`ListView`**: Membuat halaman bisa digulir (*scroll*) ke atas dan ke bawah jika teks beritanya panjang.
- **`AspectRatio(aspectRatio: 16 / 9)`**: Bingkai foto otomatis yang menjaga ukuran gambar utama selalu proporsional seperti layar TV/YouTube (16 banding 9), tidak gepeng dan tidak terlalu memanjang.
- **`Padding(padding: EdgeInsets.all(20))`**: Memberi jarak pinggiran (margin dalam) sebesar 20 piksel di sekeliling teks agar tulisan tidak menempel mepet ke tepi kaca layar HP.
- **`Row` & `Expanded`**: Menyusun informasi `"Penulis : ..."` dan `"Published : ..."` secara menyamping kiri-kanan. `Expanded` memastikan jika nama penulis sangat panjang, teksnya otomatis turun ke baris bawah tanpa menabrak batas layar.
- **`DateFormat("d MMMM yyyy").format(news.publishedAt)`**: Mengubah tanggal berita menjadi format tanggal yang indah dan lengkap (contoh: `4 November 2026`).
- **`TextAlign.justify`**: Membuat paragraf deskripsi berita rata kiri-kanan seperti layaknya koran atau buku cetak.

---

### Urutan 7: `lib/main.dart` (Saklar Utama / Pintu Masuk Aplikasi)

```dart
import 'package:bab4/provider/app_provider.dart';
import 'package:bab4/screens/home_page.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  DevicePreview.enable();

  runApp(const MyApp());
}

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

#### Analogi untuk Orang Awam:
Bayangkan `main.dart` adalah **Saklar Induk Gedung Kios Koran**. Saat Anda menekan ikon aplikasi di layar HP, file inilah yang pertama kali dijalankan oleh HP Anda. Tugasnya adalah menyalakan listrik gedung, memanggil petugas `AppProvider` agar bersiap di posnya untuk melayani seluruh ruangan, memasang dekorasi tema gelap di seluruh gedung, lalu membuka pintu ruang depan (`HomePage`) untuk pengunjung.

#### Penjelasan Bagian demi Bagian untuk Orang Awam:
- **`void main()`**: Titik start wajib pada setiap program Flutter. Semua kode di dalamnya dieksekusi paling pertama saat aplikasi dibuka.
- **`DevicePreview.enable()`**: Menyalakan fitur pratinjau perangkat agar tampilan aplikasi dapat diuji coba dengan mudah.
- **`runApp(const MyApp())`**: Perintah untuk mulai menampilkan widget utama aplikasi (`MyApp`) ke layar.
- **`ChangeNotifierProvider(create: (_) => AppProvider(), ...)`**: Menempatkan petugas `AppProvider` di posisi paling atas (*root*) aplikasi. Karena ditaruh di puncak gedung, maka semua halaman di bawahnya (baik `HomePage` maupun `DetailPage`) bisa memanggil dan mengakses data dari `AppProvider` kapan saja.
- **`MaterialApp`**: Pengaturan global aplikasi:
  - `title: "MCS BAB 4"`: Nama aplikasi di sistem HP.
  - `debugShowCheckedModeBanner: false`: Menghilangkan pita merah bertuliskan *"DEBUG"* di pojok kanan atas layar agar tampilan bersih.
  - `theme: ThemeData.dark()`: Mengubah warna dasar seluruh aplikasi menjadi mode gelap (*Dark Mode*).
  - `home: const HomePage()`: Menentukan bahwa halaman pertama yang langsung dibuka saat aplikasi menyala adalah halaman beranda (`HomePage`).
