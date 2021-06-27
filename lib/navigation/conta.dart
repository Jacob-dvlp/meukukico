import 'dart:convert';
import 'package:venus_robusta/login.dart';
import 'package:venus_robusta/main.dart';
import 'package:venus_robusta/models/widget.dart';
import 'package:venus_robusta/util/global_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:toast/toast.dart';
import 'package:venus_robusta/util/theme_config.dart';
import 'package:http/http.dart' as http;
import 'package:venus_robusta/views/gestor_de_pagamentos.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:venus_robusta/views/new.dart';

class UserController extends GetxController {
  //UserData
  bool isLoading = false;
  String avatar = 'n/a';
  String nome = 'n/a';
  String sobrenome = '';
  String email = '';
  String telemovel = '';
  String genero = 'M';
  String morada = 'n/a';
  int isLogged = 0;

  //Text Controller
  TextEditingController inputNome = new TextEditingController();
  TextEditingController inputSobrenome = new TextEditingController();
  TextEditingController inputEmail = new TextEditingController();
  TextEditingController inputTelemovel = new TextEditingController();
  TextEditingController inputMorada = new TextEditingController();

  void init() async {
    var box = await Hive.openBox('venus_robusta_user');
    isLogged = box.get('login') is String || box.get('login') is int
        ? int.parse(box.get('login'))
        : 0;
    nome = box.get('nome') ?? 'n/a';
    sobrenome = box.get('sobrenome') ?? '';
    email = box.get('email') ?? '';
    telemovel = box.get('telemovel') ?? '';
    genero = box.get('genero') ?? 'M';
    morada = box.get('morada') ?? 'n/a';

    //Editor
    inputNome.text = nome;
    inputSobrenome.text = sobrenome;
    inputEmail.text = email;
    inputTelemovel.text = telemovel;
    inputMorada.text = morada;

    if (box.get('nome') is String && box.get('sobrenome') is String) {
      avatar = box.get('nome').toString().trim().toUpperCase()[0] +
          box.get('sobrenome').toString().trim().toUpperCase()[0];
    } else {
      avatar = 'n/a';
    }
    update();
  }

  //Editar perfil
  void editarPerfil(context) async {
    var box = await Hive.openBox('venus_robusta_user');
    if (inputNome.text.trim().length < 3) {
      showToast("Insira uma nome valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (inputSobrenome.text.trim().length < 3) {
      showToast("Insira um sobrenome valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (inputMorada.text.trim().length < 6) {
      showToast("Insira uma morada valida!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }

    if (!isLoading) {
      customLoading(context);
      isLoading = true;
    }

    try {
      var res = await http.post(Uri.parse(host + "perfil"), body: {
        "edit_usuario": "true",
        "id": isLogged.toString(),
        "nome": inputNome.text.trim(),
        "sobrenome": inputSobrenome.text.trim(),
        "email": email.trim(),
        "morada": inputMorada.text.trim(),
        "telemovel": inputTelemovel.text.trim(),
        "permission": permitame,
        "token": box.get('token') ?? 'n/a'
      });

      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);

        if (resBody is int && resBody == 1) {
          var box = await Hive.openBox('venus_robusta_user');

          box.put('nome', inputNome.text.trim());
          box.put('sobrenome', inputSobrenome.text.trim());
          box.put('telemovel', inputTelemovel.text.trim());
          box.put('morada', inputMorada.text.trim());

          nome = box.get('nome') ?? 'n/a';
          sobrenome = box.get('sobrenome') ?? '';
          telemovel = box.get('telemovel') ?? 'n/a';
          morada = box.get('morada') ?? 'n/a';

          showToast("O seu perfil foi editado com sucesso!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
          init();
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

  //Altera senha
  int senhaFase = 0;
  TextEditingController senha = new TextEditingController();
  TextEditingController newSenha = new TextEditingController();
  TextEditingController confirmSenha = new TextEditingController();
  void updatePassFase(int fase, context) async {
    var box = await Hive.openBox('venus_robusta_user');
    if (senhaFase == 0) {
      senhaFase = 1;
      update();
      return;
    }
    if (senhaFase == 1) {
      if (email.trim() == "" || !GetUtils.isEmail(email.trim())) {
        showToast("O seu endereço de email não é valido!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        return;
      } else if (senha.text.trim() == "") {
        showToast("Insira a sua senha actual!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        return;
      } else if (newSenha.text.trim().length < 6) {
        showToast("A sua nova senha deve ter no mínimo 6 caracteres!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        return;
      } else if (newSenha.text.trim() != confirmSenha.text.trim()) {
        showToast("As senhas não combinam!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        return;
      }

      if (!isLoading) {
        customLoading(context);
        isLoading = true;
      }

      try {
        var res = await http.post(Uri.parse(host + "perfil"), body: {
          "update_password": "true",
          "id": isLogged.toString(),
          "email": email.trim(),
          "senha": senha.text.trim(),
          "senha_new": newSenha.text.trim(),
          "permission": permitame,
          "token": box.get('token') ?? 'n/a'
        });

        if (isLoading) {
          Navigator.pop(context);
          isLoading = false;
        }

        if (res.statusCode == 200) {
          var resBody = json.decode(res.body);

          if (resBody is int && resBody == 1) {
            senhaFase = 2;
            update();
            return;
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
  }

  void rout(String nome, context) {
    if (isLogged == 0) {
      showToast("Faça login para aceder a esta funcionalidade!", context,
          duration: 2, gravity: Toast.TOP);
      return;
    }
    switch (nome) {
      case 'editar_perfil':
        Get.to(EditarPerfil());
        break;
      case 'pagamentos':
        Get.to(MetodoDePagamentos());
        break;
      case 'ativos':
        Get.to(MeusActivos());
        break;
      case 'altera_password':
        senhaFase = 0;
        senha.text = '';
        newSenha.text = '';
        confirmSenha.text = '';
        Get.to(UpdatePassword());
        break;
      case 'anuncios':
        showToast("Serviço temporáriamente indisponível!", context,
            duration: 2, gravity: Toast.TOP);
        break;
      default:
        showToast("Nenhuma routa selecionada!", context,
            duration: 2, gravity: Toast.TOP);
    }
  }
}

class Conta extends StatelessWidget {
  final c = Get.put(UserController());
  static const TextStyle defTitle = TextStyle(fontSize: 13.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 11.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GetBuilder(
                init: UserController(),
                initState: (_) {
                  c.init();
                },
                builder: (_) {
                  return Card(
                    child: ListTile(
                      leading: SizedBox(
                        height: 60.0,
                        width: 60.0,
                        child: CircleAvatar(child: Text(c.avatar)),
                      ),
                      title: Text(
                        c.nome + ' ' + c.sobrenome,
                        style: defTitle,
                      ),
                      subtitle: Text(
                        c.email,
                        style: defSubtitle,
                      ),
                      trailing: IconButton(
                        icon: c.isLogged == 0
                            ? Icon(LineAwesomeIcons.alternate_sign_in)
                            : Icon(Icons.settings_power),
                        onPressed: () {
                          c.isLogged == 0 ? Get.to(Login()) : loginOff();
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      'Editar perfil',
                      style: defTitle,
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      c.rout('editar_perfil', context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Anúncios',
                      style: defTitle,
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      c.rout('anuncios', context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Meus ativos',
                      style: defTitle,
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      c.rout('ativos', context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Gestor de pagamentos',
                      style: defTitle,
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      c.rout('pagamentos', context);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Altera senha',
                      style: defTitle,
                    ),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      c.rout('altera_password', context);
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

//Editar perfil
class EditarPerfil extends StatelessWidget {
  final c = Get.put(UserController());
  static const TextStyle defTitle = TextStyle(fontSize: 13.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 11.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
        title: Text('Editar Perfil'),
      ),
      body: GetBuilder<UserController>(
        init: UserController(),
        builder: (_) {
          return ListView(
            children: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 70.0,
                    width: 70.0,
                    child: CircleAvatar(child: Text(c.avatar)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: c.inputNome,
                    decoration: InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.assignment_ind),
                      filled: true,
                      labelStyle: TextStyle(fontSize: 13.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: c.inputSobrenome,
                    decoration: InputDecoration(
                      labelText: 'Sobrenome',
                      prefixIcon: Icon(Icons.assignment),
                      filled: true,
                      labelStyle: TextStyle(fontSize: 13.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    controller: c.inputEmail,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                      filled: true,
                      labelStyle: TextStyle(fontSize: 13.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    controller: c.inputTelemovel,
                    decoration: InputDecoration(
                      labelText: 'Telemóvel',
                      prefixIcon: Icon(Icons.phone),
                      filled: true,
                      labelStyle: TextStyle(fontSize: 13.0),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  child: TextFormField(
                    keyboardType: TextInputType.text,
                    controller: c.inputMorada,
                    decoration: InputDecoration(
                      labelText: 'Morada',
                      prefixIcon: Icon(Icons.map),
                      filled: true,
                      labelStyle: TextStyle(fontSize: 13.0),
                    ),
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
                        "Editar Perfil",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        c.editarPerfil(context);
                      },
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class UpdatePassword extends StatelessWidget {
  final c = Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Altera senha'),
          elevation: 0,
          backgroundColor: Color.fromRGBO(0, 0, 0, 0),
        ),
        body: GetBuilder<UserController>(
          init: UserController(),
          builder: (_) {
            return Center(
                child: ScrollConfiguration(
              behavior: NoGlowBehavior(),
              child: ListView(
                shrinkWrap: c.senhaFase == 0 || c.senhaFase == 2 ? true : false,
                children: <Widget>[
                  c.senhaFase == 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: Text(
                                'Antes de prosseguir certifique-se de que não tem alguem a observa-lo!',
                                textAlign: TextAlign.center,
                              )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: SizedBox(
                                    height: 70.0,
                                    width: 70.0,
                                    child: FloatingActionButton(
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 25.0,
                                      ),
                                      onPressed: () => c.updatePassFase(
                                          c.senhaFase, context),
                                    )),
                              ),
                            )
                          ],
                        )
                      : Center(),
                  c.senhaFase == 1
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 12.0),
                              child: Center(
                                  child: Image.asset(
                                "src/img/logoAlt.png",
                                height: 60.0,
                              )),
                            ),
                            Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    "Segurança em primeiro lugar!",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Color.fromRGBO(157, 157, 157, 1)),
                                  )),
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
                                  labelText: 'Senha actual',
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
                                controller: c.newSenha,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(2.0)),
                                  labelText: 'Nova senha',
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
                                controller: c.confirmSenha,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(2.0)),
                                  labelText: 'Verificar senha',
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
                                      "Altera senha",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    onPressed: () {
                                      c.updatePassFase(c.senhaFase, context);
                                    },
                                  ),
                                )),
                          ],
                        )
                      : Center(),
                  c.senhaFase == 2
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                  child: Text(
                                'A sua senha foi alterada com sucesso.',
                                textAlign: TextAlign.center,
                              )),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: SizedBox(
                                    height: 70.0,
                                    width: 70.0,
                                    child: FloatingActionButton(
                                      child: Icon(
                                        Icons.check,
                                        size: 25.0,
                                      ),
                                      onPressed: () {
                                        Get.back();
                                      },
                                    )),
                              ),
                            )
                          ],
                        )
                      : Center(),
                ],
              ),
            ));
          },
        ));
  }
}

//Meus activos
//////////////////////////////
class SetActivos extends GetxController {
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

    var box = await Hive.openBox('venus_robusta_user');

    try {
      var res = await http.post(Uri.parse(host + "perfil"), body: {
        "getData": "true",
        "id": box.get('login') ?? '0',
        "id_usuario": box.get('login') ?? '0',
        "limiter": limiter.toString(),
        "permission": permitame,
        "token": box.get('token') ?? 'n/a',
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

  //Eliminar activo
  void deleteAtivo(context, int id) async {
    Get.back();
    if (!isLoading) {
      isLoading = true;
      update();
    }

    var box = await Hive.openBox('venus_robusta_user');

    try {
      var res = await http.post(Uri.parse(host + "perfil"), body: {
        "remove_post": "true",
        "id": box.get('login') ?? '0',
        "imoveis_id": id.toString(),
        "permission": permitame,
        "token": box.get('token') ?? 'n/a',
      });

      if (isLoading) {
        isLoading = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        print(res.body);
        if (resBody is int && resBody == 1) {
          init(context);
          showToast("O seu ativo foi eliminado com sucesso!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        } else {
          showToast("Não foi possível eliminar o seu ativo!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print("Delete error: " + e.toString());
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

class MeusActivos extends StatelessWidget {
  final c = Get.put(SetActivos());
  static const TextStyle defTitle = TextStyle(fontSize: 13.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 12.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meus ativos'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => c.init(context),
        child: GetBuilder<SetActivos>(
          init: SetActivos(),
          initState: (_) => c.init(context),
          builder: (_) {
            return Center(
              child: CustomScrollView(
                shrinkWrap:
                    c.isLoading == false && c.data.length <= 0 ? true : false,
                controller: c._scrollController,
                slivers: <Widget>[
                  SliverList(
                      delegate: SliverChildListDelegate(
                    c.data.map((data) {
                      return Card(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Get.toNamed(
                                  "/ArtigoId?id=${data['id']}&titulo=${data['titulo']}",
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: CachedNetworkImage(
                                      imageUrl: host +
                                          '../../../publico/img/imoveis/' +
                                          data['imagem'].toString(),
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        height: 100.0,
                                        width: 100.0,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      placeholder: (context, url) => Container(
                                        height: 100.0,
                                        width: 100.0,
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        height: 100.0,
                                        width: 100.0,
                                        color: Color.fromRGBO(0, 0, 0, 0.1),
                                        child: Center(
                                          child: Icon(Icons.error,
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 10,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0.0,
                                                bottom: 8.0,
                                                right: 8.0,
                                                left: 8.0),
                                            child: Text(data['titulo'],
                                                style: defTitle,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 0.0,
                                                bottom: 8.0,
                                                right: 8.0,
                                                left: 8.0),
                                            child: Text(
                                              data['subtitulo'],
                                              style: defSubtitle,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ))
                                ],
                              ),
                            ),
                            Divider(
                              height: 1,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await Get.defaultDialog(
                                      confirmTextColor: Colors.white,
                                      title: 'Atenção',
                                      content: Text(
                                        'Pretende mesmo eliminar este ativo?',
                                        style: TextStyle(fontSize: 14.0),
                                        textAlign: TextAlign.center,
                                      ),
                                      textConfirm: 'Sim',
                                      onConfirm: () {
                                        c.deleteAtivo(
                                            context, int.parse(data['id']));
                                      },
                                      textCancel: 'Não',
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: themeData.goldAccent,
                                  ),
                                  onPressed: () {
                                    Get.put(AddactivoController()).editTarget =
                                        data['id'];
                                    Get.to(Editactivo());
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  )),
                  SliverToBoxAdapter(
                    child: c.isLoading == false && c.data.length <= 0
                        ? Center(child: emptyResult())
                        : Center(),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: c.isLoading == true ? getCarregameto() : Center(),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Get.to(Addactivo(), arguments: 'Novo');
        },
      ),
    );
  }
}
