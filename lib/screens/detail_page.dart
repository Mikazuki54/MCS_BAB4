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
