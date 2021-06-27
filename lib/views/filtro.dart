import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'package:venus_robusta/main.dart';
import 'package:venus_robusta/models/widget.dart';
import 'package:venus_robusta/util/global_functions.dart';
import 'package:venus_robusta/util/theme_config.dart';

class FilterController extends GetxController {
  bool isLoading = false;

  List dataPavimento = [];
  var pav = '';

  List dataTerreno = [];
  var ter = '';

  List dataTipologia = [];
  var tip = '';

  List dataArea = [];
  var area = '';

  //Get data
  Future getData(context) async {
    if (!isLoading) {
      isLoading = true;
      update();
    }

    if (dataPavimento.length <= 0) {
      await this.getPavimento(context);
    }
    if (dataTerreno.length <= 0) {
      await this.getTerreno(context);
    }
    if (dataTipologia.length <= 0) {
      await this.getTipologia(context);
    }
    if (dataArea.length <= 0) {
      await this.getArea(context);
    }

    if (isLoading) {
      isLoading = false;
    }

    update();
  }

  //Get pavimento
  Future getPavimento(context) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getPavimento": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataPavimento = resBody;
          dataPavimento.forEach((element) {});
        }
      }
    } catch (e) {
      print("Pavimento error: " + e.toString());
    }
  }

  //Get terreno
  Future getTerreno(context) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getTerreno": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataTerreno = resBody;
        }
      }
    } catch (e) {
      print("Terreno error: " + e.toString());
    }
  }

  //Get tipologia
  Future getTipologia(context) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getTipologia": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataTipologia = resBody;
        }
      }
    } catch (e) {
      print("Terreno error: " + e.toString());
    }
  }

  //Get Area
  Future getArea(context) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getArea": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataArea = resBody;
        }
      }
    } catch (e) {
      print("Aréa error: " + e.toString());
    }
  }

  //Resultados de buscas
  ScrollController searchScrollContoller = new ScrollController();
  List dataBusca = [];
  bool isLoadingBusca = true;
  int searchLimiter = 0;

  void init(context) {
    dataBusca.clear();
    searchLimiter = 0;
    this.getDataBusca(context);
    searchScrollContoller.addListener(() async {
      if (searchScrollContoller.position.pixels ==
          searchScrollContoller.position.maxScrollExtent) {
        await getDataBusca(context);
      }
    });
  }

  Future getDataBusca(context) async {
    if (!isLoadingBusca) {
      isLoadingBusca = true;
    }

    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getDataBusca": "true",
        "pavimento": pav.toString().trim(),
        "terreno": ter.toString().trim(),
        "tipologia": tip.toString().trim(),
        "area": area.toString().trim(),
        "limiter": searchLimiter.toString(),
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          resBody.forEach((element) {
            searchLimiter = int.parse(element['id']);
          });
          dataBusca.addAll(resBody);
        }
      } else {
        showToast(
          "Verifique a sua conexão e tente novamente!",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP,
        );
      }
    } catch (e) {
      print("Busca error: " + e.toString());
    }
    if (isLoadingBusca) {
      isLoadingBusca = false;
      update();
    }
  }
}

class Filtro extends StatelessWidget {
  final c = Get.put(FilterController());
  static const TextStyle defTitle = TextStyle(fontSize: 13.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 11.5);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtros de busca'),
      ),
      body: GetBuilder<FilterController>(
        initState: (_) {
          c.getData(context);
        },
        init: FilterController(),
        builder: (_) {
          return c.isLoading == false
              ? CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ListTile(
                        leading: Icon(Icons.terrain_outlined),
                        title: Text('Pavimento', style: defTitle),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        c.dataPavimento.map((data) {
                          return Card(
                            child: ListTile(
                              title: Text(data['pavimento'], style: defTitle),
                              trailing: Checkbox(
                                value:
                                    c.pav.toString().contains(data['pavimento'])
                                        ? true
                                        : false,
                                onChanged: (value) {
                                  if (c.pav
                                      .toString()
                                      .contains(data['pavimento'])) {
                                    c.pav = c.pav.replaceAll(
                                        data['pavimento'] + ",", '');
                                  } else {
                                    c.pav = c.pav + data['pavimento'] + ",";
                                  }
                                  Get.put(FilterController()).update();
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Divider(
                          height: 1,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ListTile(
                        leading: Icon(Icons.straighten_outlined),
                        title: Text('Terrenos', style: defTitle),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        c.dataTerreno.map((data) {
                          return Card(
                            child: ListTile(
                              title: Text(data['tamanho'], style: defTitle),
                              trailing: Checkbox(
                                value:
                                    c.ter.toString().contains(data['tamanho'])
                                        ? true
                                        : false,
                                onChanged: (value) {
                                  if (c.ter
                                      .toString()
                                      .contains(data['tamanho'])) {
                                    c.ter = c.ter
                                        .replaceAll(data['tamanho'] + ",", '');
                                  } else {
                                    c.ter = c.ter + data['tamanho'] + ",";
                                  }
                                  Get.put(FilterController()).update();
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Divider(
                          height: 1,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ListTile(
                        leading: Icon(LineAwesomeIcons.home),
                        title: Text('Tipologias De Casas', style: defTitle),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        c.dataTipologia.map((data) {
                          return Card(
                            child: ListTile(
                              title: Text(data['dormitorio'], style: defTitle),
                              trailing: Checkbox(
                                value: c.tip
                                        .toString()
                                        .contains(data['dormitorio'])
                                    ? true
                                    : false,
                                onChanged: (value) {
                                  if (c.tip
                                      .toString()
                                      .contains(data['dormitorio'])) {
                                    c.tip = c.tip.replaceAll(
                                        data['dormitorio'] + ",", '');
                                  } else {
                                    c.tip = c.tip + data['dormitorio'] + ",";
                                  }
                                  Get.put(FilterController()).update();
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Divider(
                          height: 1,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: ListTile(
                        leading: Icon(Icons.home_work_outlined),
                        title: Text('Área Construída', style: defTitle),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        c.dataArea.map((data) {
                          return Card(
                            child: ListTile(
                              title: Text(data['area'], style: defTitle),
                              trailing: Checkbox(
                                value: c.area.toString().contains(data['area'])
                                    ? true
                                    : false,
                                onChanged: (value) {
                                  if (c.area
                                      .toString()
                                      .contains(data['area'])) {
                                    c.area = c.area
                                        .replaceAll(data['area'] + ",", '');
                                  } else {
                                    c.area = c.area + data['area'] + ",";
                                  }
                                  Get.put(FilterController()).update();
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: getCarregameto(),
                );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            c.isLoading == false
                ? Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                          color: themeData.goldAccent,
                          elevation: 0.0,
                          margin: const EdgeInsets.all(0.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(0.0),
                              topRight: Radius.circular(0.0),
                              bottomLeft: Radius.circular(0.0),
                              bottomRight: Radius.circular(0.0),
                            ),
                          ),
                          child: InkWell(
                            onTap: () {
                              if (c.pav.toString().trim() == '' &&
                                  c.ter.toString().trim() == '' &&
                                  c.tip.toString().trim() == '' &&
                                  c.area.toString().trim() == '') {
                                showToast(
                                  "Selecione no mínimo um checkbox!",
                                  context,
                                  duration: Toast.LENGTH_LONG,
                                  gravity: Toast.TOP,
                                );
                                return;
                              }
                              Get.to(BuscarResultados());
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Icon(
                                      Icons.search,
                                      color: Colors.white,
                                      size: 24.0,
                                    ),
                                  ),
                                  Text(
                                    'Buscar resultados',
                                    style: TextStyle(
                                        fontSize: 14.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              ),
                            ),
                          )),
                    ),
                  )
                : Expanded(
                    child: SizedBox(
                      height: 0.0,
                      width: MediaQuery.of(context).size.width,
                      child: Center(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

//Buscar resultados
class BuscarResultados extends StatelessWidget {
  final c = Get.put(FilterController());
  //Texto
  static const TextStyle defTitle = TextStyle(fontSize: 13.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 11.5);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resultados de busca"),
      ),
      body: Center(
        child: GetBuilder<FilterController>(
          init: FilterController(),
          initState: (_) async => c.init(context),
          builder: (_) {
            return CustomScrollView(
              shrinkWrap: c.dataBusca.length <= 0 && c.isLoadingBusca == false
                  ? true
                  : false,
              controller: c.searchScrollContoller,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    c.dataBusca.map((data) {
                      return Card(
                        child: InkWell(
                          onTap: () => Get.toNamed(
                            "/ArtigoId?id=${data['id']}&titulo=${data['titulo']}",
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              CachedNetworkImage(
                                imageUrl: host +
                                    '../../../publico/img/imoveis/' +
                                    data['imagem'].toString(),
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  width: 90.0,
                                  height: 90.0,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => Container(
                                  width: 90.0,
                                  height: 90.0,
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  width: 90.0,
                                  height: 90.0,
                                  color: Color.fromRGBO(0, 0, 0, 0.1),
                                  child: Center(
                                      child: Icon(Icons.error,
                                          color: Colors.grey)),
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8.0, left: 8.0, right: 8.0),
                                        child: Text(
                                          data['titulo'],
                                          style: defTitle,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          parseHtmlString(data['descricao']),
                                          style: defSubtitle,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      )
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: c.dataBusca.length <= 0 && c.isLoadingBusca == false
                      ? Center(
                          child: emptyResult(),
                        )
                      : Center(),
                ),
                SliverToBoxAdapter(
                  child: Center(
                    child:
                        c.isLoadingBusca == true ? getCarregameto() : Center(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
