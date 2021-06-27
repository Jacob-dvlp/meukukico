import 'dart:convert';
import 'package:venus_robusta/recover.dart';
import 'package:venus_robusta/util/global_functions.dart';
import 'package:venus_robusta/util/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:toast/toast.dart';
import 'cadastro.dart';
import 'package:get/get.dart';
import 'main.dart';

class LoginController extends GetxController {
  TextEditingController email = new TextEditingController();
  TextEditingController senha = new TextEditingController();
  bool isLoading = false;

  Future loginUser(dynamic context) async {
    if (email.text.trim() == "" || !GetUtils.isEmail(email.text.trim())) {
      showToast("Insira um endereço de email valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (senha.text.trim() == "") {
      showToast("Insira uma senha valida!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }

    if (!isLoading) {
      customLoading(context);
      isLoading = true;
    }

    try {
      var res = await http.post(Uri.parse(host + "login"), body: {
        "login": "true",
        "email": email.text.trim(),
        "senha": senha.text.trim(),
        "permission": permitame,
      });

      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);

        if (resBody is List) {
          email.text = '';
          senha.text = '';
          setUserData(resBody);
          return;
        } else if (resBody is int && resBody == 0) {
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

class Login extends StatelessWidget {
  final c = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
        title: Text(
          'Login',
        ),
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
                  "Faça login para continuar",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(157, 157, 157, 1)),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              controller: c.email,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                filled: true,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.0)),
                labelStyle: TextStyle(fontSize: 13.0),
                hintText: "Insira o seu endereço de email",
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              keyboardType: TextInputType.visiblePassword,
              obscureText: true,
              controller: c.senha,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2.0)),
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
                filled: true,
                labelStyle: TextStyle(fontSize: 13.0),
                hintText: "Insira a sua palavra-passe",
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
                    c.loginUser(context);
                  },
                ),
              )),
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
                    "Não é membro? Cadastre-se",
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () {
                    Get.to(Cadastro());
                  },
                ),
              )),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: GestureDetector(
              onTap: () {
                Get.to(RecoverMail());
              },
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Icon(
                      Icons.vpn_key,
                      size: 20.0,
                    ),
                  ),
                  Text(
                    'Esqueceu a senha?',
                    style: TextStyle(fontSize: 13.0),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
