import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:venus_robusta/navigation/activos.dart';
import 'package:venus_robusta/util/colors.dart';
import 'package:venus_robusta/util/global_functions.dart';
import '../main.dart';
import '../util/theme_config.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

//Widgets globais
class NoGlowBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}

//Widget de carregamento
Widget getCarregameto() {
  return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          new CircularProgressIndicator(),
        ],
      ));
}

//Lista de categorias horizontal
Widget getAChipCategoria(List data, int index) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: GestureDetector(
      onTap: () {
        Get.to(Categoria(), arguments: [
          data[index]['categoria'].toString(),
          data[index]['imagem'].toString()
        ]);
      },
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: CoresHexdecimal("bb52d1"),
          child: Text(
            data[index]['categoria'][0].toUpperCase(),
          ),
        ),
        label: Text(data[index]['categoria']),
        deleteIcon: Icon(Icons.arrow_forward_ios),
        deleteButtonTooltipMessage: 'Avançar',
      ),
    ),
  );
}

Widget getAChipSubCategoria(List data, int index) {
  return Padding(
    padding: const EdgeInsets.only(left: 8.0),
    child: GestureDetector(
      onTap: () {
        Get.to(Subcategorias(), arguments: data[index]['subcategoria']);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Chip(
            avatar: CircleAvatar(
              backgroundColor: Colors.grey.shade500,
              child: Text(
                data[index]['subcategoria'][0].toUpperCase(),
              ),
            ),
            label: Text(data[index]['subcategoria']),
            deleteIcon: Icon(Icons.arrow_forward_ios),
            deleteButtonTooltipMessage: 'Avançar',
          ),
        ],
      ),
    ),
  );
}

//Lista de imoveis horizontal
Widget getArtigoHorizontal(List data, int index, bool replace) {
  return Container(
    height: 250.0,
    child: Column(
      children: [
        CachedNetworkImage(
            imageUrl: host +
                '../../../publico/img/imoveis/' +
                data[index]['imagem'].toString(),
            imageBuilder: (context, imageProvider) => Container(
                width: 190.0,
                height: 150,
                margin: const EdgeInsets.only(top: 4.0, left: 8.0, bottom: 8.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0.0),
                    image: DecorationImage(
                        image: NetworkImage(
                          host +
                              '../../../publico/img/imoveis/' +
                              data[index]['imagem'].toString(),
                        ),
                        fit: BoxFit.cover)),
                child: InkWell(
                  onTap: () {
                    if (replace == true) {
                      Get.put(ArtigoController()).getData(context,
                          int.parse(data[index]['id']), data[index]['titulo']);
                    } else {
                      Get.toNamed(
                          "/ArtigoId?id=${data[index]['id']}&titulo=${data[index]['titulo']}");
                    }
                  },
                )),
            placeholder: (context, url) => Container(
                  width: 150.0,
                  height: 180.0,
                  child: Center(child: CircularProgressIndicator()),
                ),
            errorWidget: (context, url, error) => Center()),
        Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, top: 6.0, bottom: 3.0),
              child: Text(data[index]['titulo'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 0.0, right: 0.0, bottom: 0.0),
              child: Container(
                color: CoresHexdecimal("bb52d1"),
                child: Text(numberFormat(data[index]['preco']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: CoresHexdecimal("ffffff"))),
              ),
            ),
          ],
        )
      ],
    ),
  );
}

//Lista de imoveis vertical
Widget getArtigo(List data, int index) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Card(
      child: InkWell(
        onTap: () {
          Get.toNamed(
            "/ArtigoId?id=${data[index]['id']}&titulo=${data[index]['titulo']}",
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: host +
                  '../../../publico/img/imoveis/' +
                  data[index]['imagem'].toString(),
              imageBuilder: (context, imageProvider) => Container(
                height: 110.0,
                width: Get.width,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              placeholder: (context, url) => Container(
                height: 110.0,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                height: 110.0,
                color: Color.fromRGBO(0, 0, 0, 0.1),
                child: Center(child: Icon(Icons.error, color: Colors.grey)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 8.0, right: 8.0, top: 6.0, bottom: 3.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(data[index]['titulo'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 0.0, right: 0.0, bottom: 0.0),
              child: Container(
                width: 170,
                color: CoresHexdecimal("bb52d1"),
                child: Text(numberFormat(data[index]['preco']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 17.0,
                        fontWeight: FontWeight.bold,
                        color: CoresHexdecimal("ffffff"))),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

//Widget nenhum resultado encontrado!
Widget emptyResult() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Center(
          child: Icon(
            LineAwesomeIcons.file,
            size: 58.0,
            color: Colors.grey,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Nenhum resultado encontrado!',
            style: TextStyle(color: Colors.grey, fontSize: 16.0),
            textAlign: TextAlign.center,
          ),
        )
      ],
    ),
  );
}

Widget cardTile(
  String titulo,
  String subtitulo,
  String descricao,
  String target,
  String versao,
  context,
) {
  return Card(
    elevation: 0.0,
    color: Color.fromRGBO(255, 0, 0, 0.2),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
            padding: const EdgeInsets.only(
                top: 8.0, left: 8.0, right: 8.0, bottom: 4.0),
            child: Text(
              titulo,
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Get.isDarkMode ? Colors.white70 : Colors.black54),
            )),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                          child: Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          Icons.tag,
                          size: 18.0,
                        ),
                      )),
                      TextSpan(
                        text: subtitulo,
                        style: TextStyle(
                            fontSize: 13.5,
                            color: Get.isDarkMode
                                ? Colors.white70
                                : Colors.black54),
                      ),
                    ],
                  ),
                ),
                descricao != ''
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          descricao,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Get.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54),
                        ),
                      )
                    : Center(),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RawMaterialButton(
                        onPressed: () {},
                        elevation: 2.0,
                        fillColor: Colors.white,
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          size: 25.0,
                          color: themeData.primaryColor,
                        ),
                        padding: EdgeInsets.all(8.0),
                        shape: CircleBorder(),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
              top: 4.0, left: 8.0, right: 8.0, bottom: 8.0),
          child: Text(
            versao,
            style: TextStyle(color: Colors.grey, fontSize: 13.0),
          ),
        )
      ],
    ),
  );
}
