import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:venus_robusta/models/widget.dart';
import 'package:venus_robusta/util/global_functions.dart';
import 'package:venus_robusta/util/theme_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import 'package:venus_robusta/views/project_cadastro.dart';
import '../main.dart';
import 'package:toast/toast.dart';

class HomeControllerInicio extends GetxController {
  bool isLoading = false;
  int limiter = 0;
  List data = [];
  ScrollController _scrollController = new ScrollController();

  void init(context) {
    this.getData(context);
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        await getData(context);
      }
    });
  }

  //Get artigos
  Future getData(context) async {
    if (!isLoading) {
      isLoading = true;
      update();
    }

    try {
      var res = await http.post(Uri.parse(host + "home"), body: {
        "getData": "true",
        "limiter": limiter.toString(),
        "permission": permitame,
      });

      if (isLoading) {
        isLoading = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          resBody.forEach((element) {
            limiter = int.parse(element['id']);
          });
          data.addAll(resBody);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print("Data error: " + e.toString());
      if (isLoading) {
        isLoading = false;
      }
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
    update();
  }

  //Actualizar os dados
  Future refreshData(context) async {
    try {
      var res = await http.post(Uri.parse(host + "home"), body: {
        "getData": "true",
        "limiter": "0",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          resBody.forEach((element) {
            limiter = int.parse(element['id']);
          });
          data = resBody;
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print("Data error: " + e.toString());
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
    update();
  }
}

class Home extends StatelessWidget {
  static TextStyle titleHeader = TextStyle(fontSize: 18.0);
  final c = Get.put(HomeControllerInicio());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeControllerInicio>(
      init: HomeControllerInicio(),
      initState: (_) {
        c.init(context);
      },
      builder: (_) {
        return CustomScrollView(
          controller: c._scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, top: 12.0, right: 8.0, bottom: 8.0),
                child: Text(
                  'Projectos urbanísticos',
                  style: titleHeader,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: CarouselSlider(
                options: CarouselOptions(
                  height: 250.0,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 7),
                ),
                items: [1, 2, 3].map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(horizontal: 10.0),
                          decoration: BoxDecoration(
                              color: themeData.goldAccent,
                              borderRadius: BorderRadius.circular(0.0)),
                          child: CachedNetworkImage(
                            imageUrl:
                                host + "../../../publico/img/imoveis/1$i.jpg",
                            imageBuilder: (context, imageProvider) => Container(
                              height: 250.0,
                              width: Get.width,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Container(
                                    height: Get.height,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        color: Color.fromRGBO(0, 0, 0, 0.5)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Stack(
                                        alignment: AlignmentDirectional.center,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              i == 1
                                                  ? Text(
                                                      'Projecto Urbanístico Bita Tanque',
                                                      style: TextStyle(
                                                          color: Colors.yellow,
                                                          fontSize: 17.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  : Center(),
                                              i == 2
                                                  ? Text(
                                                      'Projecto Urbanístico Barra Do Dande',
                                                      style: TextStyle(
                                                          color: Colors.yellow,
                                                          fontSize: 18.0,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    )
                                                  : Center(),
                                              i == 3
                                                  ? Column(
                                                    children: [
                                                      Text(
                                                          'Projecto Urbanístico Km25',
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              fontSize: 18.0,
                                                              fontWeight:
                                                                  FontWeight.bold),
                                                        ),
                                                    ],
                                                  )
                                                  : Center(),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 120),
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            primary: themeData
                                                                .goldAccent),
                                                    onPressed: () {
                                                      Get.to(ProjectCadastro(),
                                                          transition:
                                                              Transition.zoom);
                                                    },
                                                    child: Text(
                                                      'Faça ja o seu pré cadastro',
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            placeholder: (context, url) => Container(
                              height: 250.0,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 250.0,
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              child: Center(
                                  child: Icon(Icons.error, color: Colors.grey)),
                            ),
                          ));
                    },
                  );
                }).toList(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 8.0, top: 12.0, right: 8.0, bottom: 8.0),
                child: Text(
                  'Nossos projectos',
                  style: titleHeader,
                ),
              ),
            ),
            c.data.length > 0
                ? SliverGrid(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return getArtigo(c.data, index);
                    },
                        childCount: c.data.length,
                        addAutomaticKeepAlives: false),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 0.0,
                        crossAxisSpacing: 0.0,
                        childAspectRatio: 1))
                : SliverToBoxAdapter(),
            SliverToBoxAdapter(
              child: Center(
                child: c.isLoading == true ? getCarregameto() : Center(),
              ),
            ),
          ],
        );
      },
    );
  }
}
