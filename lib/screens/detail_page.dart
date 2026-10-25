import 'package:bab4/provider/app_provider.dart';
import 'package:bab4/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DetailPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
        builder: ((context, appProvider, child){
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
                        SizedBox(height: 20),
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
                                    SizedBox(height: 15),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                            Text(
                                                "Penulis",
                                                style: AppStyles.universalFontStyle,
                                            ),
                                            SizedBox(width: 50),
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
                                            SizedBox(width: 30),
                                            Expanded(
                                                child: Text(
                                                    ": ${DateFormat("d MMMM yyyy").format(appProvider.tanggalPublish)}"
                                                ),
                                            ),
                                        ],
                                    ),
                                    SizedBox(height: 40),
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
        }
        ),
    );
  }
}