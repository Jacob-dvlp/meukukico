import 'dart:convert';
import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:venus_robusta/models/widget.dart';
import 'package:venus_robusta/util/global_functions.dart';
import '../main.dart';
import '../util/global_functions.dart';
import '../util/theme_config.dart';
import './../util/theme_config.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

class ClienteController extends GetxController {
  var idLote = '';
  bool isLoading = false;
  bool isLoadingPage = true;
  List clientData = [];
  TextEditingController idCliente = new TextEditingController();
  TextEditingController senha = new TextEditingController();

  //Projectos
  static const projecto = <String>[
    'URBT',
  ];

  String defaultGenero = 'URBT';
  void generoUpdate(value) {
    defaultGenero = value;
    update();
  }

  final List<DropdownMenuItem<String>> _dropDownMenuItems = projecto
      .map(
        (String value) => DropdownMenuItem<String>(
          value: value,
          child: Row(
            children: <Widget>[
              value == 'URBT'
                  ? Text(
                      'Urbanização Bita Tanque',
                      style: TextStyle(color: Color.fromRGBO(157, 157, 157, 1)),
                    )
                  : Center(),
            ],
          ),
        ),
      )
      .toList();

  void clienteLogo(context) async {
    if (idCliente.text.trim() == "") {
      showToast("Insira um id de cliente valido!", context,
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
      var res = await http.post(Uri.parse(host + "cliente"), body: {
        "login": "true",
        "id_cliente": idCliente.text.trim(),
        "propriedade": defaultGenero.toString(),
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
          var box = await Hive.openBox('venus_robusta_user');
          box.put('ClienteId', resBody[0]['id_cliente']);
          clientData = resBody;
          isLogued(context);
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
      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  Future isLogued(context) async {
    isLoadingPage = true;
    update();
    idCliente.text = '';
    senha.text = '';
    clientData = [];

    var box = await Hive.openBox('venus_robusta_user');

    if (box.get('ClienteId') is String || box.get('ClienteId') is int) {
      var clientId = await box.get('ClienteId') ?? '0';

      try {
        var res = await http.post(Uri.parse(host + "cliente"), body: {
          "getData": "true",
          "id_cliente": clientId.toString(),
        });

        if (res.statusCode == 200) {
          var resBody = json.decode(res.body);
          if (resBody is List) {
            clientData = resBody;
          }
        } else {
          showToast("Verifique a sua conexão e tente novamente!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        }
      } catch (e) {
        showToast(
            "Verifique a sua conexão ou tente novamente mais tarde!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    }
    isLoadingPage = false;
    update();
  }

  void loginOff(context) async {
    var box = await Hive.openBox('venus_robusta_user');
    box.delete('ClienteId');
    isLogued(context);
  }

  ////////// Carregamentos ////////////
  bool carregamentoLoading = true;
  List dataPagamento = [];
  List dataSearch = [];
  void getClientePagamento(context, int id) async {
    dataPagamento = [];
    carregamentoLoading = true;
    try {
      var res = await http.post(Uri.parse(host + "cliente"), body: {
        "getDataMeses": "true",
        "id_cliente": id.toString(),
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataPagamento = resBody;
          dataPagamento.forEach((element) {
            dataSearch.add(element['mes_pago']);
          });
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }

    if (dataPagamento.length <= 0) {
      dataSearch.clear();
    }
    carregamentoLoading = false;
    update();
  }

  ///
  //Editar perfil
  //Text Controller
  TextEditingController inputNome = new TextEditingController();
  TextEditingController inputEmail = new TextEditingController();
  TextEditingController inputTelemovel = new TextEditingController();
  TextEditingController inputMorada = new TextEditingController();

  void editarPerfil(context) async {
    var box = await Hive.openBox('venus_robusta_user');
    if (inputNome.text.trim().length < 3) {
      showToast("Insira uma nome valido!", context,
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
      var res = await http.post(Uri.parse(host + "cliente"), body: {
        "edit_cliente": "true",
        "id_cliente": clientData[0]['id'].toString(),
        "nome": inputNome.text.trim(),
        "email": inputEmail.text.trim(),
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
          showToast("O seu perfil foi editado com sucesso!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
          isLogued(context);
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

  ///
  ///  //Altera senha
  int senhaFase = 0;
  TextEditingController senhaCliente = new TextEditingController();
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
      if (inputEmail.text.trim() == "" ||
          !GetUtils.isEmail(inputEmail.text.trim())) {
        showToast("O seu endereço de email não é valido!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        return;
      } else if (senhaCliente.text.trim() == "") {
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
        var res = await http.post(Uri.parse(host + "cliente"), body: {
          "update_password": "true",
          "id_cliente": clientData[0]['id'].toString(),
          "email": inputEmail.text.trim(),
          "senha": senhaCliente.text.trim(),
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
            senhaCliente.text = '';
            newSenha.text = '';
            confirmSenha.text = '';
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
}

//Factura
class HistoricoController extends GetxController {
  //Global
  bool isLoading = false;
  List data = [];
  ScrollController _scrollController = new ScrollController();

  void init(context, id) {
    data.clear();
    this.getData(context, id);
  }

  Future getData(context, int id) async {
    if (!isLoading) {
      isLoading = true;
      update();
    }

    try {
      var res = await http.post(Uri.parse(host + "cliente"), body: {
        "getDataComprovativo": "true",
        "id_cliente": id.toString(),
        "permission": permitame,
      });

      if (isLoading) {
        isLoading = false;
      }

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          data.addAll(resBody);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print(e.toString());
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

class Cliente extends StatelessWidget {
  final c = Get.put(ClienteController());
  static const TextStyle defTitle = TextStyle(fontSize: 13.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 11.5);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GetBuilder<ClienteController>(
        init: ClienteController(),
        initState: (_) {
          c.isLogued(context);
        },
        builder: (_) {
          return c.isLoadingPage == true
              ? getCarregameto()
              : c.clientData.length <= 0
                  ? ListView(
                      shrinkWrap: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: Center(
                              child: Image.asset(
                            "src/img/logo.png",
                            height: 60.0,
                          )),
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
                            keyboardType: TextInputType.number,
                            controller: c.idCliente,
                            decoration: InputDecoration(
                              labelText: 'ID',
                              prefixIcon: Icon(Icons.person),
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0)),
                              labelStyle: TextStyle(fontSize: 13.0),
                              hintText: "Insira o seu id de cliente",
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: c.senha,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: Icon(Icons.vpn_key),
                              filled: true,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0)),
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
                                child: Text("Entrar",
                                    style: TextStyle(color: Colors.white)),
                                onPressed: () {
                                  c.clienteLogo(context);
                                },
                              ),
                            )),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                          child: GestureDetector(
                            onTap: () {
                              Get.defaultDialog(
                                  title: 'Esqueceu a senha?',
                                  content: Text(
                                    'Para a recuperação da sua conta entre em contacto com o email geral@venusrobusta.co.ao ou o contacto +244 923 004 923.',
                                    style: TextStyle(fontSize: 12.5),
                                  ));
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
                    )
                  : ListView(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            c.clientData[0]['propriedade'] +
                                ' - ' +
                                c.clientData[0]['id_cliente'],
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                        ),
                        Card(
                          child: ListTile(
                            leading: SizedBox(
                              height: 60.0,
                              width: 60.0,
                              child: CircleAvatar(
                                  child: Text(c.clientData[0]['nome'] is String
                                          ? c.clientData[0]['nome'][0]
                                              .toString()
                                              .toUpperCase()
                                          : 'n/a') ??
                                      'n/a'),
                            ),
                            title: Text(
                              c.clientData[0]['nome'],
                              style: defTitle,
                            ),
                            subtitle: Text(
                              c.clientData[0]['email'],
                              style: defSubtitle,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.settings_power),
                              onPressed: () {
                                c.loginOff(context);
                              },
                            ),
                          ),
                        ),
                        Card(
                          child: //////////////
                              Table(
                            border: TableBorder.all(
                                width: 1.0,
                                color: themeData.goldAccent,
                                style: BorderStyle.solid),
                            children: [
                              TableRow(children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Meses a pagar',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: themeData.goldAccent),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Meses pago',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: themeData.goldAccent),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      'Total mensal',
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: themeData.goldAccent),
                                    ),
                                  ),
                                ),
                              ]),
                              TableRow(children: [
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      c.clientData[0]['meses'],
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: themeData.goldAccent),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      c.clientData[0]['meses_pago'],
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: themeData.goldAccent),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      numberFormat(
                                          c.clientData[0]['valor_mensal']),
                                      style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w600,
                                          color: themeData.goldAccent),
                                    ),
                                  ),
                                )
                              ]),
                            ],
                          ),
                          ///////////,
                        ),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ListTile(
                                title: Text(
                                  'Editar perfil de cliente',
                                  style: defTitle,
                                ),
                                trailing: Icon(Icons.chevron_right),
                                onTap: () {
                                  Get.to(EditarCliente());
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Divider(
                                  height: 1,
                                ),
                              ),
                              ListTile(
                                onTap: () {
                                  Get.to(ClientePagamento(),
                                      arguments: c.clientData[0]['meses'] +
                                          ',' +
                                          c.clientData[0]['id']);
                                },
                                title: Text(
                                  'Estado do pagamento',
                                  style: defTitle,
                                ),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'RESUMO',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                        ),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ListTile(
                                title: Text(
                                  'Projecto',
                                  style: defTitle,
                                ),
                                subtitle: Text(c.clientData[0]['propriedade'] +
                                    '-' +
                                    c.clientData[0]['id_cliente']),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Divider(
                                  height: 1,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Bloco',
                                  style: defTitle,
                                ),
                                subtitle: Text(c.clientData[0]['bloco']
                                            .toString()
                                            .trim() !=
                                        ''
                                    ? c.clientData[0]['bloco']
                                    : 'n/a'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Divider(
                                  height: 1,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Código',
                                  style: defTitle,
                                ),
                                subtitle: Text(c.clientData[0]['codigo']
                                            .toString()
                                            .trim() !=
                                        ''
                                    ? c.clientData[0]['codigo']
                                    : 'n/a'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Divider(
                                  height: 1,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Tipologia',
                                  style: defTitle,
                                ),
                                subtitle: Text(c.clientData[0]['tipologia']
                                            .toString()
                                            .trim() !=
                                        ''
                                    ? c.clientData[0]['tipologia']
                                    : ''),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Divider(
                                  height: 1,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Dimensão',
                                  style: defTitle,
                                ),
                                subtitle: Text(c.clientData[0]['dimensao']
                                            .toString()
                                            .trim() !=
                                        ''
                                    ? c.clientData[0]['dimensao']
                                    : 'n/a'),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Divider(
                                  height: 1,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Total a pagar',
                                  style: defTitle,
                                ),
                                subtitle: Text(
                                    numberFormat(c.clientData[0]['total'])),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'DESCRIÇÃO',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey),
                          ),
                        ),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ListTile(
                                title: Text(
                                  'Taxa administrativa',
                                  style: defTitle,
                                ),
                                subtitle: Text(numberFormat(
                                    c.clientData[0]['taxa_administrativa'])),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Divider(
                                  height: 1,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Data do pagamento',
                                  style: defTitle,
                                ),
                                subtitle: Text(c.clientData[0]
                                                ['data_taxa_administrativa']
                                            .toString()
                                            .trim() !=
                                        ''
                                    ? c.clientData[0]
                                            ['data_taxa_administrativa']
                                        .toString()
                                        .replaceAll('-', '/')
                                    : 'n/a'),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ListTile(
                                title: Text(
                                  'Valor de entrada',
                                  style: defTitle,
                                ),
                                subtitle: Text(numberFormat(
                                    c.clientData[0]['valor_de_entrada'])),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Divider(
                                  height: 1,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Data do pagamento',
                                  style: defTitle,
                                ),
                                subtitle: Text(c.clientData[0]
                                                ['data_valor_de_entrada']
                                            .toString()
                                            .trim() !=
                                        ''
                                    ? c.clientData[0]['data_valor_de_entrada']
                                        .toString()
                                        .replaceAll('-', '/')
                                    : 'n/a'),
                              ),
                            ],
                          ),
                        ),
                        Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ListTile(
                                title: Text(
                                  'Total pago',
                                  style: TextStyle(
                                      fontSize: 13.0, color: Colors.green),
                                ),
                                subtitle: Text(
                                  numberFormat((int.parse(c.clientData[0]
                                              ['valor_de_entrada']) +
                                          (int.parse(c.clientData[0]
                                                  ['valor_mensal']) *
                                              int.parse(c.clientData[0]
                                                  ['meses_pago'])))
                                      .toString()),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 8.0, right: 8.0),
                                child: Divider(
                                  height: 1,
                                ),
                              ),
                              ListTile(
                                title: Text(
                                  'Em falta',
                                  style: TextStyle(
                                      fontSize: 13.0, color: Colors.red),
                                ),
                                subtitle: Text(
                                  numberFormat(
                                    (int.parse(c.clientData[0]['total']) -
                                            (int.parse(c.clientData[0]
                                                    ['valor_de_entrada']) +
                                                (int.parse(c.clientData[0]
                                                        ['valor_mensal']) *
                                                    int.parse(c.clientData[0]
                                                        ['meses_pago']))))
                                        .toString(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListTile(
                          title: Text(
                            'Data da assinatura do contrato',
                            style: defTitle,
                          ),
                          subtitle: Text(c.clientData[0]
                                          ['data_assinatura_do_contrato']
                                      .toString()
                                      .trim() !=
                                  ''
                              ? c.clientData[0]['data_assinatura_do_contrato']
                                  .toString()
                                  .replaceAll('-', '/')
                              : 'n/a'),
                        ),
                      ],
                    );
        },
      ),
    );
  }
}

class ClientePagamento extends StatelessWidget {
  final c = Get.put(ClienteController());
  @override
  Widget build(BuildContext context) {
    List meses = Get.arguments.toString().split(',');
    var mes = meses[0].toString();
    return Scaffold(
      appBar: AppBar(
        title: Text('Estado do pagamento'),
      ),
      body: GetBuilder<ClienteController>(
        initState: (_) {
          c.getClientePagamento(context, int.parse(meses[1].toString()));
        },
        builder: (_) {
          return CustomScrollView(
            slivers: [
              c.carregamentoLoading == true
                  ? SliverToBoxAdapter(
                      child: Center(child: getCarregameto()),
                    )
                  : SliverToBoxAdapter(
                      child: Card(
                        child: Column(
                          children: [
                            ListTile(
                              onTap: () {
                                c.idLote = meses[1].toString();
                                Get.to(ProcessarPagamento());
                              },
                              leading: Icon(Icons.payment),
                              title: Text(
                                'Processar pagamento',
                                style: TextStyle(fontSize: 13.0),
                              ),
                              trailing: Icon(Icons.chevron_right),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Divider(
                                height: 1,
                              ),
                            ),
                            ListTile(
                              onTap: () {
                                Get.to(HistoricoPagamentoCliente(),
                                    arguments: int.parse(meses[1].toString()));
                              },
                              leading: Icon(Icons.history),
                              title: Text(
                                'Histórico de pagamento',
                                style: TextStyle(fontSize: 13.0),
                              ),
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ],
                        ),
                      ),
                    ),
              SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (c.dataPagamento.length > 0 &&
                          c.dataSearch.contains((index + 1).toString())) {
                        Get.to(VisualizeFatura(),
                            arguments: c.dataPagamento[index]);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          color: c.dataPagamento.length > 0 &&
                                  c.dataSearch.contains((index + 1).toString())
                              ? Colors.green
                              : Colors.red,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text((index + 1).toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                              textAlign: TextAlign.center)
                        ],
                      ),
                    ),
                  );
                }, childCount: int.parse(mes), addAutomaticKeepAlives: false),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 0.0,
                  crossAxisSpacing: 0.0,
                  childAspectRatio: 1,
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

//Visualizar factura
class VisualizeFatura extends StatelessWidget {
  final c = Get.put(ClienteController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Get.arguments["mes_pago"] + "º Mês",
        ),
      ),
      body: GetBuilder<ClienteController>(
        builder: (_) {
          return Card(
            child: InkWell(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  (Get.arguments["comprovativo"] is String) == true &&
                          Get.arguments["comprovativo"].toString().trim() !=
                              '' &&
                          Get.arguments["comprovativo"]
                                  .toString()
                                  .split('.')
                                  .last
                                  .trim()
                                  .toLowerCase() ==
                              'pdf'
                      ? Center(
                          child: SizedBox(
                            width: double.infinity,
                            height: 48.0,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: themeData.goldAccent,
                              ),
                              onPressed: () {
                                Get.to(
                                  PdfView(),
                                  arguments: Get.arguments["comprovativo"]
                                      .toString()
                                      .trim(),
                                );
                              },
                              child: Text(
                                "Visualizar Pdf",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          imageUrl: host +
                              '../../../publico/img/comprovativo/' +
                              Get.arguments["comprovativo"],
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
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                  Divider(
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Emitido aos: " + Get.arguments["data_do_pagamento"],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          "Registado aos: " + Get.arguments["registo"],
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Get.arguments["estado"] == '0'
                            ? Text(
                                "Estado: Pendente",
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: themeData.goldAccent),
                              )
                            : Center(),
                        Get.arguments["estado"] == '1'
                            ? Text(
                                "Estado: Confirmado",
                                style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.green),
                              )
                            : Center(),
                        Get.arguments["estado"] == '2'
                            ? Column(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Estado: Negado",
                                    style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.red),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "Motivo: " +
                                          Get.arguments["motivo"].toString(),
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                ],
                              )
                            : Center()
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Total pago: " + numberFormat(Get.arguments["total"]),
                      style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: themeData.goldAccent),
                      textAlign: TextAlign.end,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class HistoricoPagamentoCliente extends StatelessWidget {
  final c = Get.put(HistoricoController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de pagamento'),
      ),
      body: Center(
        child: GetBuilder<HistoricoController>(
          init: HistoricoController(),
          initState: (_) {
            c.init(context, Get.arguments);
          },
          builder: (_) {
            return CustomScrollView(
              shrinkWrap:
                  c.isLoading == false && c.data.length <= 0 ? true : false,
              controller: c._scrollController,
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate(
                    c.data.map((historico) {
                      return Card(
                        child: InkWell(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  historico["mes_pago"] + "º Mês",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              (historico["comprovativo"] is String) == true &&
                                      historico["comprovativo"]
                                              .toString()
                                              .trim() !=
                                          '' &&
                                      historico["comprovativo"]
                                              .toString()
                                              .split('.')
                                              .last
                                              .trim()
                                              .toLowerCase() ==
                                          'pdf'
                                  ? Center(
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 48.0,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            primary: themeData.goldAccent,
                                          ),
                                          onPressed: () {
                                            Get.to(
                                              PdfView(),
                                              arguments:
                                                  historico["comprovativo"]
                                                      .toString()
                                                      .trim(),
                                            );
                                          },
                                          child: Text(
                                            "Visualizar Pdf",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: host +
                                          '../../../publico/img/comprovativo/' +
                                          historico["comprovativo"],
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
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
                                                image: AssetImage(
                                                    'src/img/default.png'),
                                                fit: BoxFit.cover)),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        height: 200.0,
                                        decoration: BoxDecoration(
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    'src/img/default.png'),
                                                fit: BoxFit.cover)),
                                      ),
                                    ),
                              Divider(
                                height: 1,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Emitido aos: " +
                                      historico["data_do_pagamento"],
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      "Registado aos: " + historico["registo"],
                                      style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w400),
                                    )
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    historico["estado"] == '0'
                                        ? Text(
                                            "Estado: Pendente",
                                            style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w500,
                                                color: themeData.goldAccent),
                                          )
                                        : Center(),
                                    historico["estado"] == '1'
                                        ? Text(
                                            "Estado: Confirmado",
                                            style: TextStyle(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.green),
                                          )
                                        : Center(),
                                    historico["estado"] == '2'
                                        ? Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Estado: Negado",
                                                style: TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.red),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8.0),
                                                child: Text(
                                                  "Motivo: " +
                                                      historico["motivo"]
                                                          .toString(),
                                                  style: TextStyle(
                                                      fontSize: 12.5,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              )
                                            ],
                                          )
                                        : Center()
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  numberFormat(historico["total"]),
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: themeData.goldAccent),
                                  textAlign: TextAlign.end,
                                ),
                              )
                            ],
                          ),
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

class ProcessarPagamento extends StatefulWidget {
  @override
  _ProcessarPagamentoState createState() => _ProcessarPagamentoState();
}

class _ProcessarPagamentoState extends State<ProcessarPagamento> {
  bool pogresso = false;

  int processado = 0;

  var imageFile;

  TextEditingController dataPagamento = new TextEditingController();

  TextEditingController dataMes = new TextEditingController();

  TextEditingController dataValue = new TextEditingController();

  Future image() async {
    imageFile = await ImagePicker().getImage(source: ImageSource.camera);

    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Ferramenta de recorte',
            toolbarColor: themeData.goldAccent,
            statusBarColor: themeData.goldAccent,
            toolbarWidgetColor: Colors.white,
            hideBottomControls: true,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));

    setState(() {
      imageFile = croppedFile;
    });
  }

  Future carregar(context) async {
    int input;

    if (imageFile == null || imageFile == '') {
      showToast('Adicione uma imagem da fatura!', context,
          duration: 5, gravity: Toast.TOP);
      return;
    } else if (dataPagamento.text.trim() == "" ||
        dataPagamento.text.length < 3) {
      showToast('Insira uma data valida!', context,
          duration: 5, gravity: Toast.TOP);
      return;
    } else if (dataMes.text.trim() == "") {
      showToast('Insira o mês a se pagar!', context,
          duration: 5, gravity: Toast.TOP);
      return;
    } else if (dataValue.text.trim() == "") {
      showToast("Insira um valor valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }

    //Convert String to int
    try {
      input = int.parse(dataValue.text.trim());

      if (input <= 0) {
        showToast("Insira um valor valido!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        return;
      }
    } catch (e) {
      showToast(
          "Insira um valor valido, Evite o uso de texto ou caracteres especiais como ([ , ], [ . ], [ - ], [  ], etc)!",
          context,
          duration: Toast.LENGTH_LONG,
          gravity: Toast.TOP);
      return;
    }

    setState(() {
      pogresso = true;
    });

    try {
      var idLote = Get.put(ClienteController()).idLote;
      //Enviando imagem ao servidor
      var stream = new http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var uri = Uri.parse(host + "cliente");
      var request = new http.MultipartRequest("POST", uri);

      var multpartFile = new http.MultipartFile("img[]", stream, length,
          filename: basename(imageFile.path));
      request.fields["id_cliente"] = idLote.toString();
      request.fields["atualizarPagamento"] = "true";
      request.fields["mes"] = dataMes.text.trim();
      request.fields["data_do_pagamento"] = dataPagamento.text.trim();
      request.fields["total"] = input.toString();

      request.files.add(multpartFile);
      var response = await request.send();

      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((value) {
          var result = json.decode(value);
          print(value);
          if (result == 0) {
            showToast('Não foi possível agendar o seu carregamento!', context,
                duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
          } else if (result == 1) {
            setState(() {
              imageFile = null;
              dataPagamento.text = '';
              dataMes.text = '';
              dataValue.text = '';
              processado = 1;
            });
          } else {
            showToast(result.toString(), context,
                duration: 5, gravity: Toast.TOP);
          }

          setState(() {
            pogresso = false;
          });
        });
      }
    } catch (e) {
      showToast('Não foi possível se conectar com o servidor!', context,
          duration: 5, gravity: Toast.TOP);
      setState(() {
        pogresso = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Processar pagamento'),
      ),
      body: Center(
        child: processado == 1
            ? ScrollConfiguration(
                behavior: NoGlowBehavior(),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Icon(
                                  Icons.check_circle,
                                  color: themeData.goldAccent,
                                  size: 60.0,
                                )
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'O seu carregamento foi agendado com sucesso',
                              style: TextStyle(fontSize: 13.0),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: 48.0,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: themeData.goldAccent,
                                ),
                                onPressed: () {
                                  setState(() {
                                    processado = 0;
                                  });
                                },
                                child: Text(
                                  'Confirmar',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
            : ListView(
                shrinkWrap: false,
                children: <Widget>[
                  pogresso == false
                      ? Container(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(top: 18.0),
                                child: Center(
                                    child: imageFile == null
                                        ? Column(
                                            children: <Widget>[
                                              IconButton(
                                                iconSize: 40.0,
                                                color: themeData.goldAccent,
                                                icon: Icon(Icons.camera_alt),
                                                onPressed: () {
                                                  image();
                                                },
                                              ),
                                              Text(
                                                'Adicione uma imagem da fatura.',
                                                style:
                                                    TextStyle(fontSize: 12.0),
                                              )
                                            ],
                                          )
                                        : Column(
                                            children: <Widget>[
                                              Container(
                                                width: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        300
                                                    ? 300
                                                    : MediaQuery.of(context)
                                                        .size
                                                        .width,
                                                height: 200.0,
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      width: 1.0,
                                                      color: Colors.white),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                  image: DecorationImage(
                                                    image: FileImage(imageFile),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: InkWell(
                                  onTap: () {
                                    var data = DateTime.now();

                                    var dataConfirm = "";
                                    for (var i = 0; i < 4; i++) {
                                      dataConfirm += data.toString()[i];
                                    }

                                    if (dataConfirm != '2021') {
                                      showToast('Verifique a sua data e hora!',
                                          context,
                                          duration: 5, gravity: Toast.TOP);
                                      return;
                                    }

                                    showDatePicker(
                                      context: context,
                                      initialDate: data,
                                      firstDate: DateTime(2021),
                                      lastDate: DateTime(2022),
                                    ).then((DateTime value) {
                                      if (value != null) {
                                        dataPagamento.text =
                                            value.day.toString() +
                                                '/' +
                                                value.month.toString() +
                                                '/' +
                                                value.year.toString();
                                      }
                                    });
                                  },
                                  child: TextFormField(
                                    enabled: false,
                                    controller: dataPagamento,
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.date_range),
                                      labelText: 'Data do pagamento',
                                      labelStyle: TextStyle(fontSize: 14.0),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: TextFormField(
                                  controller: dataMes,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  maxLength: 3,
                                  decoration: InputDecoration(
                                    labelText: 'Mês a pagar',
                                    labelStyle: TextStyle(fontSize: 15.0),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(3.0)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: TextFormField(
                                  controller: dataValue,
                                  keyboardType:
                                      TextInputType.numberWithOptions(),
                                  decoration: InputDecoration(
                                    labelText: 'Quantia paga',
                                    suffixText: 'AOA',
                                    labelStyle: TextStyle(fontSize: 15.0),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(3.0)),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Esta sendo protegido por uma criptografia de 360 bits.',
                                  style: TextStyle(fontSize: 12.0),
                                ),
                              )
                            ],
                          ),
                        )
                      : Center(child: getCarregameto()),
                ],
              ),
      ),
      floatingActionButton: pogresso == false && processado == 0
          ? FloatingActionButton(
              backgroundColor: themeData.goldAccent,
              child: Icon(
                Icons.send,
              ),
              onPressed: () {
                carregar(context);
              },
            )
          : Center(),
    );
  }
}

//Editar perfil
class EditarCliente extends StatelessWidget {
  final c = Get.put(ClienteController());
  static const TextStyle defTitle = TextStyle(fontSize: 13.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 11.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
        title: Text('Editar perfil de cliente'),
      ),
      body: GetBuilder<ClienteController>(
        init: ClienteController(),
        initState: (_) {
          c.inputNome.text = c.clientData[0]['nome'];
          c.inputEmail.text = c.clientData[0]['email'];
          c.inputTelemovel.text = c.clientData[0]['telemovel'];
          c.inputMorada.text = c.clientData[0]['morada'];
        },
        builder: (_) {
          return ListView(
            children: <Widget>[
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
                      "Salvar",
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () {
                      c.editarPerfil(context);
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    c.senhaFase = 0;
                    Get.to(UpdatePassword());
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
                        'Altera senha',
                        style: TextStyle(fontSize: 13.0),
                      )
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class UpdatePassword extends StatelessWidget {
  final c = Get.put(ClienteController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Altera senha'),
        elevation: 0,
        backgroundColor: Color.fromRGBO(0, 0, 0, 0),
      ),
      body: GetBuilder<ClienteController>(
        init: ClienteController(),
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
                              ),
                            ),
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
                                  onPressed: () =>
                                      c.updatePassFase(c.senhaFase, context),
                                ),
                              ),
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
                                height: 45.0,
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Segurança em primeiro lugar!",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(157, 157, 157, 1)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              controller: c.senhaCliente,
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
                              ),
                            ),
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
                                    c.senhaFase = 0;
                                    Get.back();
                                  },
                                ),
                              ),
                            ),
                          )
                        ],
                      )
                    : Center(),
              ],
            ),
          ));
        },
      ),
    );
  }
}

///Load pdf
class PdfControl extends GetxController {
  bool isLoading = false;
  PDFDocument doc;
  Future pdf(String url) async {
    if (!isLoading) {
      isLoading = true;
      update();
    }
    // Load from URL
    doc = await PDFDocument.fromURL(
      host + '../../../publico/img/comprovativo/' + url,
    );

    if (isLoading) {
      isLoading = false;
      update();
    }
  }
}

class PdfView extends StatelessWidget {
  final c = Get.put(PdfControl());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Get.arguments.toString(),
        ),
      ),
      body: GetBuilder<PdfControl>(
        init: PdfControl(),
        initState: (_) {
          c.pdf(Get.arguments.toString());
        },
        builder: (_) {
          return Center(
            child: c.isLoading
                ? getCarregameto()
                : c.doc != null
                    ? PDFViewer(document: c.doc)
                    : Text(
                        "Não foi possível visualizar o seu arquivo em pdf!",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey,
                        ),
                      ),
          );
        },
      ),
    );
  }
}
