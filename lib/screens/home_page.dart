import 'package:bab4/provider/app_provider.dart';
import 'package:bab4/screens/detail_page.dart';
import 'package:bab4/services/news_services.dart';
import 'package:bab4/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const new({super.key});

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
              }  else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot}"));
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
                            errorBuilder: (context, error, StackTrace) {
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
                          navigationPage: DetailPage());
                      },
                    );
                  }
                );
              }
            } 
          ),
        );
      },
    );
  }
}