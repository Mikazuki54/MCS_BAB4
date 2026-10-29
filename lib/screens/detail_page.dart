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
