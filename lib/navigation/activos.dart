import 'package:flutter/material.dart';
import 'package:venus_robusta/util/colors.dart';
import 'package:venus_robusta/views/gestor_de_pagamentos.dart';
import 'dart:convert';
import './../util/global_functions.dart';
import './../models/widget.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:venus_robusta/util/global_functions.dart';
import 'package:toast/toast.dart';
import '../main.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import './../util/theme_config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomeController extends GetxController {
  bool isLoading = false;
  int limiter = 0;
  List data = [];
  List destaque = [];
  List categoria = [];
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

    if (categoria.length <= 0) {
      await this.getCategoria(context);
    }

    if (destaque.length <= 0) {
      await this.getDestaque(context);
    }

    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
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
    await this.getCategoria(context);
    await this.getDestaque(context);

    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
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

  //Get categorias
  Future getCategoria(context) async {
    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getCategoria": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          categoria = resBody;
        }
      }
    } catch (e) {
      print("Categoria error: " + e.toString());
    }
  }

  //Get destaques
  Future getDestaque(context) async {
    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getDestaque": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          destaque = resBody;
        }
      }
    } catch (e) {
      print("Destaque error: " + e.toString());
    }
  }
}

class HomeCategoriaController extends GetxController {
  ScrollController _categoriaScrollController = new ScrollController();
  String categoriaSelecionada = '';
  List dataCategoria = [];
  List subcategoria = [];
  bool isLoadingCategoria = false;
  int categoriaLimiter = 0;
  void initCategoria(context, String categoria) {
    this.getDataCategoria(context, categoria);
    _categoriaScrollController.addListener(() async {
      if (_categoriaScrollController.position.pixels ==
          _categoriaScrollController.position.maxScrollExtent) {
        await getDataCategoria(context, categoriaSelecionada);
      }
    });
  }

  Future getDataCategoria(context, String categoria) async {
    if (!isLoadingCategoria) {
      isLoadingCategoria = true;
      update();
    }

    if (categoriaSelecionada != categoria) {
      categoriaSelecionada = categoria;
      categoriaLimiter = 0;
      subcategoria = [];
      dataCategoria = [];
      await this.getSubcategoria(context, categoria);
    }

    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getDataCategoria": "true",
        "limiter": categoriaLimiter.toString(),
        "categoria": categoria,
        "permission": permitame,
      });

      if (isLoadingCategoria) {
        isLoadingCategoria = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          resBody.forEach((element) {
            categoriaLimiter = int.parse(element['id']);
          });
          dataCategoria.addAll(resBody);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print("Data categoria error: " + e.toString());
      if (isLoadingCategoria) {
        isLoadingCategoria = false;
      }
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
    update();
  }

  Future getSubcategoria(context, String categoria) async {
    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getSubcategoria": "true",
        "categoria": categoria,
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          subcategoria = resBody;
        }
      }
    } catch (e) {
      print("Subcategoria error: " + e.toString());
    }
  }

  Future refreshCategoriaData(context, String categoria) async {
    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getDataCategoria": "true",
        "limiter": "0",
        "categoria": categoria,
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          resBody.forEach((element) {
            categoriaLimiter = int.parse(element['id']);
          });
          categoriaSelecionada = categoria;
          dataCategoria = resBody;
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print("Data categoria error: " + e.toString());
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
    update();
  }
}

class HomeSubcategoriaController extends GetxController {
  ScrollController _subcategoriaScrollController = new ScrollController();
  String subcategoriaSelecionada = '';

  List dataSubcategoria = [];
  bool isLoadingSubcategoria = false;
  int subcategoriaLimiter = 0;
  void initSubcategoria(context, String subcategoria) {
    this.getDataSubcategoria(context, subcategoria);
    _subcategoriaScrollController.addListener(() async {
      if (_subcategoriaScrollController.position.pixels ==
          _subcategoriaScrollController.position.maxScrollExtent) {
        await getDataSubcategoria(context, subcategoriaSelecionada);
      }
    });
  }

  Future getDataSubcategoria(context, String subcategoria) async {
    if (!isLoadingSubcategoria) {
      isLoadingSubcategoria = true;
      update();
    }

    if (subcategoriaSelecionada != subcategoria) {
      subcategoriaLimiter = 0;
      dataSubcategoria = [];
    }

    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getDataSubcategoria": "true",
        "limiter": subcategoriaLimiter.toString(),
        "subcategoria": subcategoria,
        "categoria": Get.put(HomeCategoriaController()).categoriaSelecionada,
        "permission": permitame,
      });

      if (isLoadingSubcategoria) {
        isLoadingSubcategoria = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          resBody.forEach((element) {
            subcategoriaLimiter = int.parse(element['id']);
          });
          subcategoriaSelecionada = subcategoria;
          dataSubcategoria.addAll(resBody);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print("Data subcategoria error: " + e.toString());
      if (isLoadingSubcategoria) {
        isLoadingSubcategoria = false;
      }
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
    update();
  }

  Future refreshSubcategoriaData(context, String subcategoria) async {
    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getDataSubcategoria": "true",
        "limiter": "0",
        "subcategoria": subcategoria,
        "categoria": Get.put(HomeCategoriaController()).categoriaSelecionada,
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          resBody.forEach((element) {
            subcategoriaLimiter = int.parse(element['id']);
          });
          subcategoriaSelecionada = subcategoria;
          dataSubcategoria = resBody;
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print("Data subcategoria error: " + e.toString());
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
    update();
  }
}

class ArtigoController extends GetxController {
  int artigoId = 0;
  String title = '';

  //Quantidade
  int quantidade = 1;
  var total = 'n/a';

  bool isLoading = false;
  List data = [];
  List destaque = [];

  //Imagem
  List dataImagem = [];
  String seletedImage = '';

  void reload(context) {
    if (artigoId != 0 && title != '') {
      getData(context, artigoId, title);
    }
  }

  Future getData(context, int id, String nome) async {
    if (!isLoading && artigoId != id) {
      isLoading = true;
      title = nome;
      dataImagem.clear();
      update();
    }
    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getDataId": "true",
        "idArtigo": id.toString().trim(),
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          if (artigoId != id) {
            //await
            await getImage(id);
            await getDestaque();
          }
          data = resBody;
          seletedImage = host +
              '../../../publico/img/imoveis/' +
              data[0]['imagem'].toString();
          total = numberFormat(data[0]['preco']);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print("Data id error: " + e.toString());
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
    if (isLoading) {
      isLoading = false;
    }
    //Video
    if (data.length > 0 && artigoId != id) {
      if (data[0]['video'] != '' && data[0]['video'] != null) {
        videoPlayer(
            host + '../../../publico/video/imoveis/' + data[0]['video']);
      }
    }
    //Youtube video
    if (data.length > 0 && artigoId != id) {
      if (data[0]['youtube'] != '' && data[0]['youtube'] != null) {
        List youtubeId = data[0]['youtube'].toString().split('/');
        await youtubePlayer(youtubeId[youtubeId.length - 1]);
      }
    }
    artigoId = id;
    update();
  }

  //Get imagem
  Future getImage(id) async {
    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getImagem": "true",
        "idArtigo": id.toString().trim(),
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);

        if (resBody is List) {
          dataImagem = resBody;
        } else {
          dataImagem.clear();
        }
      }
    } catch (e) {
      print("Imagem error: " + e.toString());
    }
    update();
  }

  //Get destaques
  Future getDestaque() async {
    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getDestaque": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          destaque = resBody;
        }
      }
    } catch (e) {
      print("Destaque error: " + e.toString());
    }
    update();
  }

  void changeImage(String url) {
    seletedImage = url;
    update();
  }

  //Video
  VideoPlayerController videoController;
  ChewieController chewieController;
  void videoPlayer(String link) async {
    videoController = VideoPlayerController.network(link);
    await videoController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: false,
      looping: false,
      allowPlaybackSpeedChanging: false,
      aspectRatio: 16 / 9,
      errorBuilder: (context, errorMessage) {
        return Card(
          margin: const EdgeInsets.only(
              top: 8.0, left: 0.0, right: 0.0, bottom: 0.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Video não encontrado!'),
          ),
        );
      },
    );
    update();
  }

  Widget chewie() {
    if (chewieController != null) {
      return Card(
        margin:
            const EdgeInsets.only(top: 8.0, left: 0.0, right: 0.0, bottom: 0.0),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Chewie(
            controller: chewieController,
          ),
        ),
      );
    } else {
      return Center();
    }
  }

  //Video Youtube
  YoutubePlayerController youtubeController;
  Future youtubePlayer(String link) async {
    youtubeController = YoutubePlayerController(
        initialVideoId: link.trim(),
        flags: YoutubePlayerFlags(
          autoPlay: false,
          captionLanguage: 'pt',
        ));

    update();
  }

  Widget youtubePlay() {
    if (youtubeController != null) {
      return Card(
        margin:
            const EdgeInsets.only(top: 8.0, left: 0.0, right: 0.0, bottom: 0.0),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: YoutubePlayer(
            controller: youtubeController,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
          ),
        ),
      );
    } else {
      return Center();
    }
  }
}

class Activos extends StatelessWidget {
  final c = Get.put(HomeController());
  static TextStyle titleHeader = TextStyle(
      fontSize: 18.0, color: Colors.black, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: new RefreshIndicator(
          onRefresh: () async => await c.refreshData(context),
          child: GetBuilder(
            init: HomeController(),
            initState: (_) => c.init(context),
            builder: (_) {
              return CustomScrollView(
                controller: c._scrollController,
                slivers: <Widget>[
                  c.destaque.length > 0
                      ? SliverToBoxAdapter(
                          child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0,
                                  top: 12.0,
                                  right: 8.0,
                                  bottom: 8.0),
                              child: Container(
                                child: Text(
                                  'Destaques',
                                  style: titleHeader,
                                ),
                              )),
                        )
                      : SliverToBoxAdapter(),
                  c.destaque.length > 0
                      ? SliverToBoxAdapter(
                          child: Container(
                            height: 230.0,
                            width: 220,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: c.destaque.length,
                                itemBuilder: (context, index) {
                                  return getArtigoHorizontal(
                                      c.destaque, index, false);
                                }),
                          ),
                        )
                      : SliverToBoxAdapter(),
                  c.categoria.length > 0
                      ? SliverToBoxAdapter(
                          child: Container(
                            height: 30.0,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: c.categoria.length,
                                itemBuilder: (context, index) {
                                  return getAChipCategoria(c.categoria, index);
                                }),
                          ),
                        )
                      : SliverToBoxAdapter(),
                  c.data.length > 0
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Mais recentes',
                              style: titleHeader,
                            ),
                          ),
                        )
                      : SliverToBoxAdapter(),
                  c.data.length > 0
                      ? SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return getArtigo(c.data, index);
                          },
                              childCount: c.data.length,
                              addAutomaticKeepAlives: false),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
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
          ),
        ),
      ),
    );
  }
}

//Filtro de categorias
class Categoria extends StatelessWidget {
  final c = Get.put(HomeCategoriaController());
  static TextStyle titleHeader = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    final categoriaName = Get.arguments[0].toString();
    final categoriaImagem = Get.arguments[1].toString();
    return Scaffold(
        body: Center(
      child: new RefreshIndicator(
        onRefresh: () async =>
            await c.refreshCategoriaData(context, categoriaName),
        child: GetBuilder(
          init: HomeCategoriaController(),
          initState: (_) => c.initCategoria(context, categoriaName),
          builder: (_) {
            return CustomScrollView(
              controller: c._categoriaScrollController,
              slivers: <Widget>[
                SliverAppBar(
                  leading: IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.arrow_back, color: themeData.goldAccent),
                  ),
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(categoriaName,
                        style: TextStyle(
                          color: themeData.goldAccent,
                        )),
                    background: CachedNetworkImage(
                      imageUrl: host +
                          '../../../publico/img/categorias/' +
                          categoriaImagem,
                      imageBuilder: (context, imageProvider) => Container(
                        height: 200.0,
                        width: Get.width,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      placeholder: (context, url) => Container(
                        height: 200.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('src/img/default.png'),
                                fit: BoxFit.cover)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200.0,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image: AssetImage('src/img/default.png'),
                                fit: BoxFit.cover)),
                      ),
                    ),
                  ),
                ),
                c.subcategoria.length > 0
                    ? SliverToBoxAdapter(
                        child: Container(
                        height: 50.0,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: c.subcategoria.length,
                            itemBuilder: (context, index) {
                              return getAChipSubCategoria(
                                  c.subcategoria, index);
                            }),
                      ))
                    : SliverToBoxAdapter(),
                c.dataCategoria.length > 0
                    ? SliverToBoxAdapter(
                        /*child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            '',
                            style: titleHeader,
                          ),
                        ),*/
                        )
                    : SliverToBoxAdapter(),
                c.dataCategoria.length > 0
                    ? SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return getArtigo(c.dataCategoria, index);
                        },
                            childCount: c.dataCategoria.length,
                            addAutomaticKeepAlives: false),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 0.0,
                            crossAxisSpacing: 0.0,
                            childAspectRatio: 0.65))
                    : SliverToBoxAdapter(),
                SliverToBoxAdapter(
                  child: Center(
                    child: c.isLoadingCategoria == true
                        ? getCarregameto()
                        : Center(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ));
  }
}

//Filtro de subcategorias
class Subcategorias extends StatelessWidget {
  final c = Get.put(HomeSubcategoriaController());
  static TextStyle titleHeader = TextStyle(fontSize: 18.0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Text(Get.arguments)),
        body: Center(
          child: new RefreshIndicator(
            onRefresh: () async =>
                await c.refreshSubcategoriaData(context, Get.arguments),
            child: GetBuilder(
              init: HomeSubcategoriaController(),
              initState: (_) => c.initSubcategoria(context, Get.arguments),
              builder: (_) {
                return CustomScrollView(
                  controller: c._subcategoriaScrollController,
                  slivers: <Widget>[
                    c.dataSubcategoria.length > 0
                        ? SliverToBoxAdapter(
                            /*child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '',
                                style: titleHeader,
                              ),
                            ),*/
                            )
                        : SliverToBoxAdapter(),
                    c.dataSubcategoria.length > 0
                        ? SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                                (context, index) {
                              return getArtigo(c.dataSubcategoria, index);
                            },
                                childCount: c.dataSubcategoria.length,
                                addAutomaticKeepAlives: false),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3,
                                    mainAxisSpacing: 0.0,
                                    crossAxisSpacing: 0.0,
                                    childAspectRatio: 0.65))
                        : SliverToBoxAdapter(),
                    SliverToBoxAdapter(
                      child: Center(
                        child: c.isLoadingSubcategoria == true
                            ? getCarregameto()
                            : Center(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ));
  }
}

class ArtigoId extends StatelessWidget {
  final c = Get.put(ArtigoController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ArtigoController>(
        init: ArtigoController(),
        initState: (_) async {
          c.getData(context, int.parse(Get.parameters['id'].toString()),
              Get.parameters['titulo'].toString());
        },
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              title: Text(c.title),
              actions: [
                IconButton(
                    icon: Icon(Icons.help_outline_rounded),
                    onPressed: () => Get.to(MetodoDePagamentos()))
              ],
            ),
            body: ListView(
              children: <Widget>[
                c.isLoading == false && c.data.length > 0
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          CachedNetworkImage(
                            imageUrl: c.seletedImage,
                            imageBuilder: (context, imageProvider) => Container(
                              height: 200.0,
                              width: Get.width,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            placeholder: (context, url) => Container(
                              height: 200.0,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200.0,
                              color: Color.fromRGBO(0, 0, 0, 0.1),
                              child: Center(
                                  child: Icon(Icons.error, color: Colors.grey)),
                            ),
                          ),
                          c.dataImagem.length > 0
                              ? Card(
                                  margin: const EdgeInsets.only(
                                      top: 0.0,
                                      left: 0.0,
                                      right: 0.0,
                                      bottom: 8.0),
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                        top: 8.0, bottom: 8.0),
                                    height: 75.0,
                                    child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: c.dataImagem.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            margin: const EdgeInsets.only(
                                                left: 8.0),
                                            height: 75.0,
                                            width: 75.0,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  width: c.seletedImage ==
                                                          host +
                                                              '../../../publico/img/imoveis/' +
                                                              c.dataImagem[
                                                                      index]
                                                                      ['imagem']
                                                                  .toString()
                                                      ? 2.5
                                                      : 0,
                                                  color: themeData.goldAccent),
                                            ),
                                            child: CachedNetworkImage(
                                              imageUrl: host +
                                                  '../../../publico/img/imoveis/' +
                                                  c.dataImagem[index]['imagem']
                                                      .toString(),
                                              imageBuilder:
                                                  (context, imageProvider) =>
                                                      InkWell(
                                                onTap: () {
                                                  c.changeImage(
                                                    host +
                                                        '../../../publico/img/imoveis/' +
                                                        c.dataImagem[index]
                                                                ['imagem']
                                                            .toString(),
                                                  );
                                                },
                                                child: Container(
                                                  height: 75.0,
                                                  width: 75.0,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              placeholder: (context, url) =>
                                                  Container(
                                                height: 75.0,
                                                width: 75.0,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator()),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                height: 75.0,
                                                width: 75.0,
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.1),
                                                child: Center(
                                                    child: Icon(Icons.error,
                                                        color: Colors.grey)),
                                              ),
                                            ),
                                          );
                                        }),
                                  ),
                                )
                              : Center(),
                          Card(
                            margin: const EdgeInsets.only(
                                top: 0.0, left: 0.0, right: 0.0, bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 8.0, right: 8.0),
                                  child: Text(
                                    'Características',
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Icon(Icons.straighten_outlined),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  c.data[0]['tamanho']
                                                              .toString()
                                                              .trim() ==
                                                          ''
                                                      ? 'n/a'
                                                      : c.data[0]['tamanho']
                                                          .toString(),
                                                  style:
                                                      TextStyle(fontSize: 12.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Icon(LineAwesomeIcons.home),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  c.data[0]['dormitorio']
                                                              .toString()
                                                              .trim() ==
                                                          ''
                                                      ? 'n/a'
                                                      : c.data[0]['dormitorio']
                                                          .toString(),
                                                  style:
                                                      TextStyle(fontSize: 12.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Icon(Icons.accessible_outlined),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  c.data[0]['banheiro']
                                                              .toString()
                                                              .trim() ==
                                                          ''
                                                      ? 'n/a'
                                                      : c.data[0]['banheiro']
                                                          .toString(),
                                                  style:
                                                      TextStyle(fontSize: 12.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            children: [
                                              Icon(LineAwesomeIcons.car),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  c.data[0]['garagem']
                                                              .toString()
                                                              .trim() ==
                                                          ''
                                                      ? 'n/a'
                                                      : c.data[0]['garagem']
                                                          .toString(),
                                                  style:
                                                      TextStyle(fontSize: 12.0),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          Card(
                            margin: EdgeInsets.all(0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 8.0, left: 8.0, right: 8.0),
                                  child: Text(
                                    'Disponível desde: ' + c.data[0]['registo'],
                                    style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: getHtml(c.data[0]['descricao']),
                                ),
                              ],
                            ),
                          ),
                          c.data[0]['video'] != '' && c.data[0]['video'] != null
                              ? c.chewie()
                              : Center(),
                          c.data[0]['youtube'] != '' &&
                                  c.data[0]['youtube'] != null
                              ? c.youtubePlay()
                              : Center(),
                          Card(
                            margin: const EdgeInsets.only(
                                top: 8.0, left: 0.0, right: 0.0, bottom: 0.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: c.isLoading == false
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Center(),
                                                  ),
                                                  Expanded(
                                                    child: Center(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        mainAxisSize:
                                                            MainAxisSize.max,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .stretch,
                                                        children: <Widget>[
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              top: 8.0,
                                                              bottom: 8.0,
                                                              left: 8.0,
                                                            ),
                                                            child: Text(
                                                              'Referência: #00' +
                                                                  c.data[0]
                                                                      ['id'],
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: themeData
                                                                      .goldAccent),
                                                              textAlign:
                                                                  TextAlign.end,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                              top: 8.0,
                                                              bottom: 8.0,
                                                              left: 8.0,
                                                            ),
                                                            child: Text(
                                                              'Preço: ' +
                                                                  numberFormat(c
                                                                          .data[0]
                                                                      [
                                                                      'preco']),
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      12.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: themeData
                                                                      .goldAccent),
                                                              textAlign:
                                                                  TextAlign.end,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : c.isLoading == true
                                            ? getCarregameto()
                                            : Center()),

                                //Final de quantidades
                              ],
                            ),
                          ),
                          ////////////
                          Card(
                            margin: const EdgeInsets.only(
                                top: 8.0, left: 0.0, right: 0.0, bottom: 0.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.security_outlined),
                                    title: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        'Seguro',
                                        style: TextStyle(fontSize: 12.5),
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                          'Acompanhamos a sua compra até a entrega do seu imóvel!',
                                          style: TextStyle(fontSize: 12.0)),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.verified_user_outlined),
                                    title: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        'Confiavel',
                                        style: TextStyle(fontSize: 12.5),
                                      ),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                          'Somos uma empresa 100% Angolana centrada no sector imobiliário e arquitectónico!',
                                          style: TextStyle(fontSize: 12.0)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          c.destaque.length > 0
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 12.0,
                                          left: 8.0,
                                          right: 8.0,
                                          bottom: 8.0),
                                      child: Text(
                                        'Você tambem pode gostar',
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w600),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Card(
                                      margin: const EdgeInsets.only(
                                          top: 0.0,
                                          left: 0.0,
                                          right: 0.0,
                                          bottom: 8.0),
                                      child: Container(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        height: 180.0,
                                        child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: c.destaque.length,
                                            itemBuilder: (context, index) {
                                              if (c.destaque[index]['id'] !=
                                                  c.artigoId.toString()) {
                                                return getArtigoHorizontal(
                                                    c.destaque, index, true);
                                              } else {
                                                return Center();
                                              }
                                            }),
                                      ),
                                    ),
                                  ],
                                )
                              : Center(),
                        ],
                      )
                    : Center(
                        child: c.isLoading == true
                            ? getCarregameto()
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text('Nenhum resultado encontrado!',
                                      style: TextStyle(
                                          fontSize: 20.0, color: Colors.grey)),
                                ),
                              )),
              ],
            ),
            bottomNavigationBar: BottomAppBar(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                          elevation: 0.0,
                          color: Colors.white,
                          margin: const EdgeInsets.all(0.0),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(0.0)),
                          ),
                          child: InkWell(
                            onTap: () {
                              if (c.isLoading) {
                                return;
                              }
                              Dialog dialog = Dialog(
                                elevation: 3.0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.0)),
                                child: ScrollConfiguration(
                                    behavior: NoGlowBehavior(),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              'Detalhes do vendedor',
                                              style: TextStyle(fontSize: 16.0),
                                            ),
                                          ),
                                          Divider(),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              "Nome: " +
                                                      c.data[0]['publicador']
                                                          .toString() ??
                                                  'n/a',
                                              style: TextStyle(fontSize: 14.0),
                                            ),
                                          ),
                                          Divider(),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              'Email: ' +
                                                      c.data[0]['email']
                                                          .toString() ??
                                                  'n/a',
                                              style: TextStyle(fontSize: 14.0),
                                            ),
                                          ),
                                          Divider(),
                                          Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Text(
                                              'Contacto: ' +
                                                      c.data[0]['contacto']
                                                          .toString() ??
                                                  'n/a',
                                              style: TextStyle(fontSize: 14.0),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0,
                                                left: 8.0,
                                                right: 8.0,
                                                bottom: 8.0),
                                            child: FloatingActionButton(
                                                mini: true,
                                                isExtended: false,
                                                onPressed: () => Get.back(),
                                                child: Icon(Icons.close)),
                                          ),
                                        ],
                                      ),
                                    )),
                              );
                              showDialog(
                                  barrierDismissible: true,
                                  context: context,
                                  builder: (context) => dialog);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  IconButton(
                                    onPressed: null,
                                    icon: Icon(
                                      Icons.info_outline,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'Detalhes do vendedor',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.black54,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
