import 'dart:convert';
import 'package:venus_robusta/main.dart';
import 'package:venus_robusta/util/global_functions.dart';
import 'package:venus_robusta/util/theme_config.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class CadastroController extends GetxController {
  int fase = 0;
  bool isLoading = false;
  int cashe = 0;
  TextEditingController nome = new TextEditingController();
  TextEditingController sobrenome = new TextEditingController();
  TextEditingController morada = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController casheInput = new TextEditingController();
  TextEditingController keySenha = new TextEditingController();

  //Genero
  static const genero = <String>[
    'Masculino',
    'Feminino',
  ];

  String defaultGenero = 'Masculino';

  final List<DropdownMenuItem<String>> _dropDownMenuItems = genero
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: <Widget>[
              value == 'Masculino'
                  ? Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(
                        LineAwesomeIcons.male,
                        color: Color.fromRGBO(157, 157, 157, 1),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Icon(LineAwesomeIcons.female,
                          color: Color.fromRGBO(157, 157, 157, 1)),
                    ),
              Text(
                value,
                style: TextStyle(color: Color.fromRGBO(157, 157, 157, 1)),
              )
            ],
          ),
        ),
      )
      .toList();
  void generoUpdate(value) {
    defaultGenero = value;
    update();
  }

  Future cadastrarUsuario(context) async {
    if (nome.text.trim().length < 3) {
      showToast("Insira uma nome valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (sobrenome.text.trim().length < 3) {
      showToast("Insira um sobrenome valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (morada.text.trim().length < 6) {
      showToast("Insira uma morada valida!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (email.text.trim() == "" ||
        !GetUtils.isEmail(email.text.trim())) {
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
        "emailConfirm": "true",
        "nome": nome.text.trim(),
        "sobrenome": sobrenome.text.trim(),
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
          fase = 1;
          print(resBody[0]['cashe']);
          cashe = resBody[0]['cashe'];
          update();
        } else if (resBody is int && resBody == 1) {
          showToast("Esta conta de email ja se encontra registada!", context,
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

  void confirmCashe(context) async {
    if (casheInput.text.trim().length < 3 ||
        int.parse(casheInput.text.trim()) != cashe) {
      showToast("Codigo inválido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }
    fase = 2;
    update();
  }

  Future cadastrar(context) async {
    if (keySenha.text.trim().length < 6) {
      showToast('A senha deve ter no mínimo 6 caracteres!', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }
    if (!isLoading) {
      customLoading(context);
      isLoading = true;
    }

    try {
      var res = await http.post(Uri.parse(host + "login"), body: {
        "cadastro": "true",
        "nome": nome.text.trim(),
        "sobrenome": sobrenome.text.trim(),
        "morada": morada.text.trim(),
        "email": email.text.trim(),
        "genero": defaultGenero == 'Masculino' ? 'M' : 'F',
        "senha": keySenha.text.trim(),
        "cashe": casheInput.text.trim(),
        "permission": permitame,
      });

      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          fase = 0;
          cashe = 0;
          casheInput.text = '';
          nome.text = '';
          sobrenome.text = '';
          morada.text = '';
          email.text = '';
          keySenha.text = '';
          setUserData(resBody);
          return;
        } else if (resBody is int && resBody == 0) {
          showToast("Serviço temporáriamente indisponível!", context,
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

  void reload() {
    fase = 0;
    cashe = 0;
    casheInput.text = '';
    nome.text = '';
    sobrenome.text = '';
    morada.text = '';
    email.text = '';
    keySenha.text = '';
    update();
  }
}

//cadastro de usuario
class Cadastro extends StatelessWidget {
  final c = Get.put(CadastroController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
        title: Text(
          'Cadastro',
        ),
      ),
      body: GetBuilder<CadastroController>(
        init: CadastroController(),
        initState: (_) {
          c.reload();
        },
        builder: (_) {
          return ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Center(
                    child: Image.asset(
                  "src/img/logoAlt.png",
                  height: 40.0,
                )),
              ),
              c.fase == 0
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Center(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Criar conta",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(157, 157, 157, 1)),
                              )),
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: c.nome,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.0)),
                                    labelText: 'Nome',
                                    filled: true,
                                    labelStyle: TextStyle(fontSize: 13.0),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.text,
                                  controller: c.sobrenome,
                                  maxLength: 10,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(2.0)),
                                    labelText: 'Sobrenome',
                                    filled: true,
                                    labelStyle: TextStyle(fontSize: 13.0),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: c.morada,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0)),
                              labelText: 'Morada',
                              prefixIcon: Icon(Icons.map),
                              filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                            ),
                          ),
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
                                  c.cadastrarUsuario(context);
                                },
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Get.back();
                            },
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(
                                    Icons.person,
                                    size: 20.0,
                                  ),
                                ),
                                Text(
                                  'Já é menbro? faça login!',
                                  style: TextStyle(fontSize: 13.0),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : Center(),
              c.fase == 1
                  ? Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Center(
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
                                    controller: c.casheInput,
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
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  : Center(),
              c.fase == 2
                  ? Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
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
                          child: Text('Gênero'),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                              border: Border.fromBorderSide(
                                  BorderSide(width: 1.0, color: Colors.grey)),
                              borderRadius: BorderRadius.circular(2.0)),
                          child: DropdownButton(
                              isExpanded: true,
                              items: c._dropDownMenuItems,
                              value: c.defaultGenero,
                              isDense: true,
                              underline:
                                  DropdownButtonHideUnderline(child: Center()),
                              onChanged: (value) {
                                c.generoUpdate(value);
                              }),
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
                              labelText: 'Senha',
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
                                  "Criar conta",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  c.cadastrar(context);
                                },
                              ),
                            )),
                      ],
                    )
                  : Center(),
            ],
          );
        },
      ),
    );
  }
}
