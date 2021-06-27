import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:venus_robusta/models/widget.dart';
import 'package:venus_robusta/util/global_functions.dart';
import '../main.dart';
import './../util/theme_config.dart';
import 'package:get/get.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;

class ProjectCadastro extends StatefulWidget {
  @override
  _ProjectCadastroState createState() => _ProjectCadastroState();
}

class _ProjectCadastroState extends State<ProjectCadastro> {
  bool pogresso = false;
  int processado = 0;
  bool isLoading = false;
  TextEditingController nome = new TextEditingController();
  TextEditingController email = new TextEditingController();
  TextEditingController estadoCivil = new TextEditingController();
  TextEditingController dataNascimento = new TextEditingController();
  TextEditingController naturalidade = new TextEditingController();
  TextEditingController nacionalidade = new TextEditingController();
  TextEditingController provincia = new TextEditingController();
  TextEditingController morada = new TextEditingController();
  TextEditingController bi = new TextEditingController();
  // ignore: non_constant_identifier_names
  TextEditingController bi_emissao = new TextEditingController();
  // ignore: non_constant_identifier_names
  TextEditingController tel_um = new TextEditingController();
  // ignore: non_constant_identifier_names
  TextEditingController tel_dois = new TextEditingController();
  TextEditingController entidade = new TextEditingController();
  TextEditingController salario = new TextEditingController();
  // ignore: non_constant_identifier_names
  TextEditingController nome_entidade = new TextEditingController();

  //Projectos
  static const projecto = <String>[
    'URBT',
  ];

  String defaultGenero = 'URBT';
  void generoUpdate(value) {
    setState(() {
      defaultGenero = value;
    });
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

  void registar(context) async {
    if (nome.text.toString().trim() == "") {
      showToast("Insira um nome valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (email.text.toString().trim() == "") {
      showToast("Insira um email valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (estadoCivil.text.toString().trim() == "") {
      showToast("Insira o seu estado civil!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (dataNascimento.text.toString().trim() == "") {
      showToast("Insira a sua data de nascimento!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (naturalidade.text.toString().trim() == "") {
      showToast("Insira a sua naturalidade!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (nacionalidade.text.toString().trim() == "") {
      showToast("Insira a sua nacionalidade!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (provincia.text.toString().trim() == "") {
      showToast("Insira a sua província de origem!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (morada.text.toString().trim() == "") {
      showToast("Insira a sua morada atual!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (bi.text.toString().trim() == "") {
      showToast("Insira o seu numero do BI!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (bi_emissao.text.toString().trim() == "") {
      showToast(
          "Insira a data de caducidade do seu bilhete de identidade!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (tel_um.text.toString().trim() == "") {
      showToast("Insira o seu contacto telefônico!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (tel_um.text.toString().trim() == "") {
      showToast("Insira o seu contacto telefônico!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (entidade.text.toString().trim() == "") {
      showToast("Insira a sua entidade empregadora!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (entidade.text.toString().trim() == "") {
      showToast("Insira a sua entidade empregadora!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (nome_entidade.text.toString().trim() == "") {
      showToast("Insira o nome da sua entidade empregadora!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }

    List save = [
      {
        'projecto': defaultGenero,
        'nome': nome.text.toString().trim(),
        'email': email.text.toString().trim(),
        'estadoCivil': estadoCivil.text.toString().trim(),
        'dataNascimento': dataNascimento.text.toString().trim(),
        'naturalidade': naturalidade.text.toString().trim(),
        'nacionalidade': nacionalidade.text.toString().trim(),
        'provincia': provincia.text.toString().trim(),
        'morada': morada.text.toString().trim(),
        'bi': bi.text.toString().trim(),
        'bi_emissao': bi_emissao.text.toString().trim(),
        'tel_um': tel_um.text.toString().trim(),
        'tel_dois': tel_dois.text.toString().trim(),
        'entidade': entidade.text.toString().trim(),
        'salario': salario.text.toString().trim(),
        'nome_entidade': nome_entidade.text.toString().trim(),
      }
    ];

    var env = jsonEncode(save);

    setState(() {
      if (!isLoading) {
        customLoading(context);
        isLoading = true;
      }
    });

    try {
      var res = await http.post(Uri.parse(host + "venus_project"), body: {
        "userData": env,
        "permission": permitame,
      });

      setState(() {
        if (isLoading) {
          Navigator.pop(context);
          isLoading = false;
        }
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          setState(() {
            processado = 1;
          });
        } else {
          showToast(
              "Não foi possível prosseguir com o seu pré resgisto!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      showToast(e.toString(), context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro', style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: Center(
        child: processado == 0
            ? ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Center(
                        child: Image.asset(
                      "src/img/logoAlt.png",
                      height: 40.0,
                    )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Projecto urbanístico',
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
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
                        items: _dropDownMenuItems,
                        value: defaultGenero,
                        isDense: true,
                        underline: DropdownButtonHideUnderline(child: Center()),
                        onChanged: (value) {
                          generoUpdate(value);
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Dados pessoais',
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: nome,
                      decoration: InputDecoration(
                        labelText: '* Nome completo',
                        filled: true,
                        labelStyle: TextStyle(fontSize: 13.0),
                        hintText: "Insira o seu nome completo",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: email,
                      decoration: InputDecoration(
                        labelText: '* Email',
                        filled: true,
                        labelStyle: TextStyle(fontSize: 13.0),
                        hintText: "Insira o seu endereço eletrônico",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: estadoCivil,
                      decoration: InputDecoration(
                        labelText: '* Estado civil',
                        filled: true,
                        labelStyle: TextStyle(fontSize: 13.0),
                        hintText:
                            "Casado(a), Divorciado, União de Fato, Separado, Solteiro",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.datetime,
                      maxLength: 10,
                      controller: dataNascimento,
                      decoration: InputDecoration(
                        labelText: '* Data de nascimento',
                        filled: true,
                        labelStyle: TextStyle(fontSize: 13.0),
                        hintText: "dd/mm/AAAA",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: naturalidade,
                      decoration: InputDecoration(
                        labelText: '* Naturalidade',
                        filled: true,
                        labelStyle: TextStyle(fontSize: 13.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: nacionalidade,
                      decoration: InputDecoration(
                        labelText: '* Nacionalidade',
                        filled: true,
                        labelStyle: TextStyle(fontSize: 13.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: provincia,
                      decoration: InputDecoration(
                        labelText: '* Província',
                        filled: true,
                        labelStyle: TextStyle(fontSize: 13.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: morada,
                      decoration: InputDecoration(
                        labelText: '* Morada atual',
                        filled: true,
                        labelStyle: TextStyle(fontSize: 13.0),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            maxLength: 16,
                            controller: bi,
                            decoration: InputDecoration(
                              labelText: '* BI nº',
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
                            keyboardType: TextInputType.datetime,
                            maxLength: 10,
                            controller: bi_emissao,
                            decoration: InputDecoration(
                              labelText: '* Data de emissão',
                              filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                              hintText: "dd/mm/AAAA",
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            maxLength: 12,
                            controller: tel_um,
                            decoration: InputDecoration(
                                labelText: '* Contacto telefônico 1',
                                filled: true,
                                labelStyle: TextStyle(fontSize: 13.0),
                                hintMaxLines: 12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: tel_dois,
                            maxLength: 12,
                            decoration: InputDecoration(
                                labelText: 'Contacto telefônico 2',
                                filled: true,
                                labelStyle: TextStyle(fontSize: 13.0),
                                hintText: "dd/mm/AAAA",
                                hintMaxLines: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Dados profissionais',
                      style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: entidade,
                      decoration: InputDecoration(
                        labelText: '* Entidade empregadora',
                        filled: true,
                        labelStyle: TextStyle(fontSize: 13.0),
                        hintText: "Estado, Privado, Conta própria",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: salario,
                      decoration: InputDecoration(
                          labelText: 'Salário base',
                          filled: true,
                          labelStyle: TextStyle(fontSize: 13.0),
                          suffixText: 'AOA'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      controller: nome_entidade,
                      decoration: InputDecoration(
                        labelText: 'Nome da entidade',
                        filled: true,
                        labelStyle: TextStyle(fontSize: 13.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text.rich(TextSpan(children: [
                      TextSpan(
                        text:
                            '* Ao preencher este formulário estara concordando com os ',
                        style: TextStyle(
                          fontSize: 13.5,
                        ),
                      ),
                      WidgetSpan(
                          child: InkWell(
                        onTap: () => launchURL(
                            'https://www.venusrobusta.co.ao/privacidade'),
                        child: Text(
                          'Termos de serviços & privacidade',
                          style: TextStyle(fontSize: 13.0, color: Colors.blue),
                        ),
                      )),
                      TextSpan(
                        text: ' da Vénus Robusta.',
                        style: TextStyle(
                          fontSize: 13.5,
                        ),
                      ),
                    ])),
                  ),
                  Container(
                    height: Get.height / 4,
                  )
                ],
              )
            : ScrollConfiguration(
                behavior: NoGlowBehavior(),
                child: ListView(
                  shrinkWrap: true,
                  children: [
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
                      child: Center(
                        child: Text(
                          'O seu pré registo foi efetuado com sucesso, a equipe técnica entrara em contacto consigo o mais breve possível!',
                          style: TextStyle(fontSize: 13.0),
                          textAlign: TextAlign.center,
                        ),
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
                            Get.back();
                          },
                          child: Text(
                            'Confirmar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
      ),
      floatingActionButton: pogresso == false && processado == 0
          ? FloatingActionButton(
              backgroundColor: themeData.goldAccent,
              child: Icon(
                Icons.send,
              ),
              onPressed: () {
                registar(context);
              },
            )
          : Center(),
    );
  }
}
