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
