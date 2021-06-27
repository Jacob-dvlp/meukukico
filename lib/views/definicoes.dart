import 'package:venus_robusta/util/colors.dart';
import 'package:venus_robusta/util/global_functions.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';

class DefController extends GetxController {
  bool notification = false;
  bool gps = false;
  bool imagem = false;
  // ignore: non_constant_identifier_names
  bool updade_data = false;

  Future getDef() async {
    var box = await Hive.openBox('venus_robusta_def');
    notification = box.get('notification') ?? false;
    gps = box.get('gps') ?? false;
    imagem = box.get('imagem') ?? false;
    updade_data = box.get('updade_data') ?? false;
    update();
  }

  Future updateNotification(bool value) async {
    var box = await Hive.openBox('venus_robusta_def');
    box.put('notification', value);
    notification = value;
    update();
  }

  Future updateGps(bool value) async {
    var box = await Hive.openBox('venus_robusta_def');
    box.put('gps', value);
    gps = value;
    update();
  }

  Future updateImagem(bool value) async {
    var box = await Hive.openBox('venus_robusta_def');
    box.put('imagem', value);
    imagem = value;
    update();
  }

  Future updateData(bool value) async {
    var box = await Hive.openBox('venus_robusta_def');
    box.put('updade_data', value);
    updade_data = value;
    update();
  }
}

class Def extends StatelessWidget {
  final c = Get.put(DefController());

  static const TextStyle def = TextStyle(
      color: Color(0xffbf8923), fontSize: 15.0, fontWeight: FontWeight.w600);
  static const TextStyle defTitle = TextStyle(fontSize: 15.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 15.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Definições'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Card(
              elevation: 0.0,
              margin: const EdgeInsets.all(0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Definições gerais',
                      style: def,
                    ),
                  ),
                  GetBuilder(
                    init: DefController(),
                    initState: (_) {
                      c.getDef();
                    },
                    builder: (_) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.notifications,
                                color: CoresHexdecimal("bb52d1")),
                            title: Text(
                              'Notificações',
                              style: defTitle,
                            ),
                            subtitle: Text(
                              'Reproduzir som ao receber notificações',
                              style: defSubtitle,
                            ),
                            trailing: Switch(
                                onChanged: c.updateNotification,
                                value: c.notification),
                          ),
                          Divider(
                            height: 1.0,
                          ),
                          ListTile(
                            title: Text(
                              'Localização',
                              style: defTitle,
                            ),
                            leading: Icon(Icons.location_on,
                                color: CoresHexdecimal("bb52d1")),
                            subtitle: Text(
                              'Conceder acesso a minha localização',
                              style: defSubtitle,
                            ),
                            trailing: Switch(
                              onChanged: c.updateGps,
                              value: c.gps,
                            ),
                          )
                        ],
                      );
                    },
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  ListTile(
                    title: Text(
                      'Utilização de Dados',
                      style: defTitle,
                    ),
                    leading: Icon(Icons.data_usage,
                        color: CoresHexdecimal("bb52d1")),
                    trailing: Icon(Icons.chevron_right,
                        color: CoresHexdecimal("bb52d1")),
                    onTap: () {
                      Get.to(Dados());
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Sobre',
                      style: def,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.web, color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Site oficial',
                      style: defTitle,
                    ),
                    onTap: () {
                      launchURL('https://www.venusrobusta.co.ao');
                    },
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  ListTile(
                    leading: Icon(Icons.description,
                        color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Termos e Políticas de Privacidade',
                      style: defTitle,
                    ),
                    onTap: () {
                      launchURL('https://www.venusrobusta.co.ao/termos');
                    },
                  ),
                  Divider(
                    height: 1.0,
                  ),
                  ListTile(
                    leading: Icon(Icons.info, color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Sobre',
                      style: defTitle,
                    ),
                    trailing: Icon(Icons.chevron_right,
                        color: CoresHexdecimal("bb52d1")),
                    onTap: () {
                      Get.to(AppInfo());
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Utilização de dados
class Dados extends StatelessWidget {
  final c = Get.put(DefController());

  static const TextStyle def = TextStyle(
      color: Color(0xffbf8923), fontSize: 15.0, fontWeight: FontWeight.w600);
  static const TextStyle defTitle = TextStyle(fontSize: 15.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 15.5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Utilização de Dados'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              Card(
                elevation: 0.0,
                margin: const EdgeInsets.all(0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GetBuilder(
                      init: DefController(),
                      initState: (_) {
                        c.getDef();
                      },
                      builder: (_) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.image,color: CoresHexdecimal("bb52d1"),),
                              title: Text(
                                'Qualidade de imagem',
                                style: defTitle,
                              ),
                              subtitle: Text(
                                'Reduzir a qualidade de imagem',
                                style: defSubtitle,
                              ),
                              trailing: Switch(
                                  onChanged: c.updateImagem, value: c.imagem),
                            ),
                            Divider(
                              height: 1.0,
                            ),
                            ListTile(
                              title: Text(
                                'Atualização de dados',
                                style: defTitle,
                              ),
                              leading: Icon(Icons.replay_30,color: CoresHexdecimal("bb52d1")),
                              subtitle: Text(
                                'Desativar atualização automática de dados',
                                style: defSubtitle,
                              ),
                              trailing: Switch(
                                onChanged: c.updateData,
                                value: c.updade_data,
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

//Sobre
class AppInfo extends StatelessWidget {
  static const TextStyle defTitle = TextStyle(fontSize: 15.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sobre',
        ),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    title: Text(
                      'Versão da aplicação',
                      style: defTitle,
                    ),
                    subtitle: Text(
                      '1.0',
                      style: defSubtitle,
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    title: Text(
                      'Revisão de bugs',
                      style: defTitle,
                    ),
                    subtitle: Text(
                      '0.0.1',
                      style: defSubtitle,
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Image.asset(
                      'src/img/logoAlt.png',
                      height: 30.0,
                    ),
                  ),
                  ListTile(
                    title: Text(
                      '©2020 MeuKubico Lda, Todos os direitos reservados.',
                      style: defTitle,
                      textAlign: TextAlign.center,
                    ),
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
