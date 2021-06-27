import 'package:flutter/material.dart';
import 'package:venus_robusta/util/colors.dart';
import 'package:venus_robusta/util/theme_config.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:venus_robusta/main.dart';
import 'dart:convert';
import 'package:venus_robusta/util/global_functions.dart';
import 'package:toast/toast.dart';

class FeedbackController extends GetxController {
  bool isLoading = false;
  TextEditingController nome = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController mensagem = new TextEditingController();

  //Set Data
  Future setData(context) async {
    if (nome.text.trim().length <= 3) {
      showToast("Insira um nome valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (!GetUtils.isEmail(email.text.trim())) {
      showToast("Insira um endereço de email valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (mensagem.text.trim() == "") {
      showToast("Insira a sua mensagem!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }

    if (!isLoading) {
      customLoading(context);
      isLoading = true;
    }

    try {
      var res = await http.post(Uri.parse(host + "feedback"), body: {
        "setData": "true",
        "nome": nome.text.trim(),
        "email": email.text.trim(),
        "mensagem": mensagem.text.trim(),
        "permission": permitame,
      });

      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is int && resBody == 1) {
          nome.text = '';
          email.text = '';
          mensagem.text = '';
          showToast("O seu feedback foi enviado com sucesso!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        } else if (resBody is int && resBody == 0) {
          showToast("Não foi possível enviar o seu feedback!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print(e.toString());
      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }
}

class FeedBack extends StatelessWidget {
  final c = Get.put(FeedbackController());
  static TextStyle feedLabel = TextStyle(fontSize: 15.0);
  static OutlineInputBorder borderStyle =
      OutlineInputBorder(borderRadius: BorderRadius.circular(3.0));

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Feedback"),
      ),
      body: Center(
        child: Container(
          child: ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Center(
                          child: Icon(LineAwesomeIcons.comment,
                              size: 50.0, color: themeData.goldAccent)),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextFormField(
                        controller: c.nome,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person,
                              color: CoresHexdecimal("bb52d1")),
                          labelText: 'Nome',
                          labelStyle: feedLabel,
                          filled: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextFormField(
                        controller: c.email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email,
                              color: CoresHexdecimal("bb52d1")),
                          labelText: 'Email',
                          labelStyle: feedLabel,
                          filled: true,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: TextFormField(
                        controller: c.mensagem,
                        minLines: 4,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Reclamações ou sugestões para melhorias!',
                          labelStyle: feedLabel,
                          border: borderStyle,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 0.0, top: 12.0, right: 12.0, bottom: 12.0),
                      child: Text(
                          "Pedimos que evite palavrões, ou frases que direita o indiretamente violem os direitos humanos.",
                          style: TextStyle(
                            fontSize: 15,
                          )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        isExtended: true,
        onPressed: () {
          c.setData(context);
        },
        child: Icon(
          Icons.send,
        ),
      ),
    );
  }
}
