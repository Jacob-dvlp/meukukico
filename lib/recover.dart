import 'dart:convert';
import 'package:venus_robusta/main.dart';
import 'package:venus_robusta/util/global_functions.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:venus_robusta/util/theme_config.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class RecoverController extends GetxController {
  int confirm = 0;
  TextEditingController email = new TextEditingController();
  TextEditingController confirmAccount = new TextEditingController();

  //Senha
  TextEditingController keySenha = new TextEditingController();
  TextEditingController keyConfirm = new TextEditingController();

  bool isLoading = false;

  void recover(context) async {
    if (GetUtils.isEmail(email.text.trim()) == false) {
      showToast("Insira um endereço de email valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }

    if (!isLoading) {
      customLoading(context);
      isLoading = true;
    }

    try {
      var res = await http.post(Uri.parse(host + "login"), body: {
        "recover": "true",
        "email": email.text.trim(),
        "permission": permitame,
      });

      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);

        if (resBody is List) {
          confirm = 1;
          update();
        } else if (resBody == 0) {
          showToast("A sua conta não foi encontrada!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        } else {
          showToast(resBody, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  Future confirmCashe(context) async {
    if (confirmAccount.text.trim() == '') {
      showToast(
          'Insira o código enviado para o seu endereço de email!', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }

    if (!isLoading) {
      customLoading(context);
      isLoading = true;
    }

    try {
      var res = await http.post(Uri.parse(host + "login"), body: {
        "recoverkey": "true",
        "email": email.text.trim(),
        "cashe": confirmAccount.text.trim(),
        "permission": permitame,
      });

      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          Get.to(UpdatePassword());
        } else if (resBody == 0) {
          showToast("Código inválido!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        } else {
          showToast(resBody, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }

  Future updatePass(context) async {
    if (keySenha.text.trim().length < 6) {
      showToast('A senha deve ter no mínimo 6 caracteres!', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (keySenha.text.trim() != keyConfirm.text.trim()) {
      showToast('As senhas não combinam!', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }

    if (!isLoading) {
      customLoading(context);
      isLoading = true;
    }

    try {
      var res = await http.post(Uri.parse(host + "login"), body: {
        "recoverpass": "true",
        "email": email.text.trim(),
        "cashe": confirmAccount.text.trim(),
        "senha": keySenha.text.trim(),
        "permission": permitame,
      });

      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          confirm = 0;
          email.text = '';
          confirmAccount.text = '';
          keySenha.text = '';
          keyConfirm.text = '';
          setUserData(resBody);
        } else if (resBody == 0) {
          showToast("Usuário não encontrado!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        } else {
          showToast(resBody, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  void recoverReturn() {
    confirm = 0;
    email.text = '';
    confirmAccount.text = '';
    keySenha.text = '';
    keyConfirm.text = '';
    update();
  }

  void recoverExit() {
    confirm = 0;
    email.text = '';
    confirmAccount.text = '';
    keySenha.text = '';
    keyConfirm.text = '';
    Get.offAll(HomePage());
  }
}

class RecoverMail extends StatelessWidget {
  final c = Get.put(RecoverController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
        title: Text(
          'Recupera Conta',
        ),
      ),
      body: GetBuilder<RecoverController>(
        init: RecoverController(),
        builder: (_) {
          return Container(
            child: ListView(
              children: <Widget>[
                c.confirm <= 0
                    ? Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Center(
                                child: Container(
                                  child: Icon(
                                    Icons.face,
                                    size: 60.0,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Insira o seu endereço de email",
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: c.email,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(2.0)),
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email),
                                  filled: true,
                                  labelStyle: TextStyle(fontSize: 13.0),
                                ),
                              ),
                            ),
                            Container(
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(8.0),
                                child: new SizedBox(
                                  width: double.infinity,
                                  height: 48.0,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: themeData.goldAccent,
                                    ),
                                    child: Text(
                                      "Verificar",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      c.recover(context);
                                    },
                                  ),
                                )),
                          ],
                        ),
                      )
                    : Center(
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 16, left: 8.0, right: 8.0),
                                child: Center(
                                  child: Text(
                                    'Olá ' + c.email.text.trim(),
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    'Insira o codigo enviado para o seu endereço de email',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: c.confirmAccount,
                                  maxLength: 6,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelStyle: TextStyle(fontSize: 14.0),
                                    filled: true,
                                    helperText:
                                        'Verifique também a sua caixa de span.',
                                  ),
                                ),
                              ),
                              Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.all(8.0),
                                  child: new SizedBox(
                                    width: double.infinity,
                                    height: 48.0,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: themeData.goldAccent,
                                      ),
                                      child: Text(
                                        "Seguinte",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () {
                                        c.confirmCashe(context);
                                      },
                                    ),
                                  )),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    c.recoverReturn();
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8.0),
                                        child: Icon(
                                          LineAwesomeIcons.times_circle,
                                          size: 20.0,
                                        ),
                                      ),
                                      Text(
                                        'Esta conta não é minha!',
                                        style: TextStyle(fontSize: 13.0),
                                      )
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
              ],
            ),
          );
        },
      ),
    );
  }
}

//Alterar palavra passe
class UpdatePassword extends StatelessWidget {
  final c = Get.put(RecoverController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
        title: Text('Altera Senha'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Center(
                child: Image.asset(
              "src/img/logoAlt.png",
              height: 40.0,
            )),
          ),
          Center(
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "So mais um passo!",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(157, 157, 157, 1)),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              controller: c.keySenha,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.0)),
                labelText: 'Nova Senha',
                prefixIcon: Icon(Icons.lock),
                filled: true,
                labelStyle: TextStyle(fontSize: 13.0),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              controller: c.keyConfirm,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.0)),
                labelText: 'Verificar Senha',
                prefixIcon: Icon(Icons.lock),
                filled: true,
                labelStyle: TextStyle(fontSize: 13.0),
              ),
            ),
          ),
          Container(
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(8.0),
              child: new SizedBox(
                width: double.infinity,
                height: 48.0,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: themeData.goldAccent,
                  ),
                  child: Text(
                    "Iniciar Sessão",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    c.updatePass(context);
                  },
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: GestureDetector(
              onTap: () {
                c.recoverExit();
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      LineAwesomeIcons.times_circle,
                      size: 20.0,
                    ),
                  ),
                  Text(
                    'Cancelar!',
                    style: TextStyle(fontSize: 13.0),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
