import 'package:venus_robusta/models/widget.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:html/parser.dart' as parse;
import 'package:flutter_html/flutter_html.dart';
import 'package:venus_robusta/util/theme_config.dart';
import '../navigation/conta.dart';
import '../main.dart';
import './theme_config.dart';

//Funções Globais
//Login
void setUserData(dynamic userData) async {
  var box = await Hive.openBox('venus_robusta_user');
  box.put('login', userData[0]['id']);
  box.put('nome', userData[0]['nome']);
  box.put('sobrenome', userData[0]['sobrenome']);
  box.put('email', userData[0]['email']);
  box.put('telemovel', userData[0]['telemovel']);
  box.put('genero', userData[0]['genero']);
  box.put('morada', userData[0]['morada']);
  box.put('token', userData[1]['token']);
  Get.offAll(HomePage());
}

//Terminar sessão
void loginOff() async {
  bool confirm = false;
  final c = Get.put(UserController());

  await Get.defaultDialog(
      confirmTextColor: Colors.white,
      title: 'Atenção',
      content: Text(
        'Pretende mesmo terminar a sessão?',
        style: TextStyle(fontSize: 14.0),
        textAlign: TextAlign.center,
      ),
      textConfirm: 'Sim',
      onConfirm: () async {
        Get.back();
        var box = await Hive.openBox('venus_robusta_user');
        box.delete('login');
        box.delete('nome');
        box.delete('sobrenome');
        box.delete('email');
        box.delete('telemovel');
        box.delete('genero');
        box.delete('morada');
        box.delete('token');
        c.init();
        Get.offAll(LoginState());
      },
      textCancel: 'Não');

  if (confirm == false) {
    return;
  }
}

//Toast
void showToast(String msg, context, {int duration, int gravity}) {
  Toast.show(msg, context, duration: duration, gravity: gravity);
}

//Loading
void customLoading(dynamic context) {
  Dialog dialog = Dialog(
    elevation: 3.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
    child: ScrollConfiguration(
        behavior: NoGlowBehavior(),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Aguarde...',
                      style: TextStyle(fontSize: 13.0),
                    ),
                  ),
                ],
              ),
            )
          ],
        )),
  );
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => dialog);
}

//Urllaucher - Custom tab
void launchURL(String url) async {
  try {
    FlutterWebBrowser.openWebPage(
      url: url,
      customTabsOptions: CustomTabsOptions(
        colorScheme: CustomTabsColorScheme.dark,
        toolbarColor: themeData.goldAccent,
        secondaryToolbarColor: Colors.black,
        navigationBarColor: Colors.grey,
        addDefaultShareMenuItem: true,
        instantAppsEnabled: true,
        showTitle: true,
        urlBarHidingEnabled: true,
      ),
      safariVCOptions: SafariViewControllerOptions(
        barCollapsingEnabled: true,
        preferredBarTintColor: Colors.black,
        preferredControlTintColor: Colors.grey,
        dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
        modalPresentationCapturesStatusBarAppearance: true,
      ),
    );
  } catch (e) {
    print(e.toString());
  }
}

//Remover tags html
String parseHtmlString(String htmlString) {
  final document = parse.parse(htmlString);
  final String parsedString =
      parse.parse(document.body.text).documentElement.text;

  return parsedString;
}

//Ler tags html
Widget getHtml(String htmlString) {
  return Html(data: htmlString);
}

//Number Format
String numberFormat(String number) {
  var conversor = new NumberFormat("#,##0.00", "pt");

  if (int.parse(number.trim()) is int) {
    int format = int.parse(number.trim());
    return conversor.format(format).toString() + ' AOA';
  } else {
    return conversor.format(0).toString() + ' AOA';
  }
}
