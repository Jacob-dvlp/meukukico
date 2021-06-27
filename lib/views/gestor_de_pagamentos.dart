import 'dart:convert';
import 'package:venus_robusta/models/widget.dart';
import 'package:toast/toast.dart';
import 'package:venus_robusta/main.dart';
import 'package:venus_robusta/util/global_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class GetPagamentos extends GetxController {
  bool isLoading = false;
  int limiter = 0;
  List data = [];
  ScrollController _scrollController = new ScrollController();

  void init(context) {
    limiter = 0;
    data.clear();
    this.getData(context);
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        await getData(context);
      }
    });
  }

  //Get data
  Future getData(context) async {
    if (!isLoading) {
      isLoading = true;
      update();
    }

    try {
      var res =
          await http.post(Uri.parse(host + "gestor_de_pagamentos"), body: {
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
}

class MetodoDePagamentos extends StatelessWidget {
  final c = Get.put(GetPagamentos());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestor de pagamentos'),
      ),
      body: Center(
        child: GetBuilder<GetPagamentos>(
          init: GetPagamentos(),
          initState: (_) => c.init(context),
          builder: (_) {
            return CustomScrollView(
              shrinkWrap:
                  c.isLoading == false && c.data.length <= 0 ? true : false,
              controller: c._scrollController,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    c.data.map((feed) {
                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                feed["pagamento"],
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: getHtml(feed["descricao"]),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: c.isLoading == false && c.data.length <= 0
                      ? emptyResult()
                      : Center(),
                ),
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
    );
  }
}
