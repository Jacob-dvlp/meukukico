import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:venus_robusta/views/definicoes.dart';
import 'package:get/get.dart';
import 'models/widget.dart';
import 'navigation/cliente.dart';
import 'navigation/conta.dart';
import 'navigation/home.dart';
import 'navigation/activos.dart';
import 'util/colors.dart';
import 'util/theme_config.dart';
import 'util/global_functions.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'views/feedback.dart';
import 'views/filtro.dart';
import 'views/suporte.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

//Global String / array
//const host = 'http://192.168.56.1/mulemba/venus/app/api/mobile/';
//const host = 'http://10.0.2.2/mulemba/venus/app/api/mobile/';
const host = 'https://www.venusrobusta.co.ao/app/api/mobile/';
const permitame = 'oratoriam';

void main() {
  final c = Get.put(Controller());
  runApp(GetMaterialApp(
    getPages: [
      GetPage(name: '/', page: () => LoginState()),
      GetPage(name: '/ArtigoId', page: () => ArtigoId()),
    ],
    debugShowCheckedModeBanner: false,
    onInit: () async {
      if (GetPlatform.isWeb == false) {
        await Hive.initFlutter();
      }
      var box = await Hive.openBox('venus_robusta_def');
      if (box.get('theme') is bool) {
        box.get('theme') && Get.isDarkMode != true
            ? c.changeTheme(true)
            : c.changeTheme(false);
      }
    },
    themeMode: ThemeMode.system,
    theme: themeData.lightTheme,
    darkTheme: themeData.darkTheme,
    home: LoginState(),
  ));
}

//Controller
class Controller extends GetxController {
  bool darkMode = false;
  void changeTheme(theme) async {
    if (theme == true && Get.isDarkMode != true) {
      Get.changeTheme(themeData.darkTheme);
    } else if (theme == false && Get.isDarkMode) {
      Get.changeTheme(themeData.lightTheme);
    }
    darkMode = theme;
    var box = await Hive.openBox('venus_robusta_def');
    box.put('theme', theme);
    update();
  }

  int isLogged = 0;
  void login() async {
    if (GetPlatform.isWeb == false) {
      await Hive.initFlutter();
    }
    var box = await Hive.openBox('venus_robusta_user');
    isLogged = box.get('login') is String || box.get('login') is int
        ? int.parse(box.get('login'))
        : 0;
    //if (isLogged is int && isLogged > 0) {
    Get.offAll(HomePage());
    /*} else {
      Get.offAll(Login());
    }*/
  }

  int _selectedIndex = 0;
  final List<Widget> _widgetOptions =
      <Widget>[Home(), Activos(), Cliente(), Conta()].obs;
  void _onItemTapped(int index) {
    _selectedIndex = index;
    update();
  }
}

//Login State
class LoginState extends StatelessWidget {
  final Controller c = Get.put(Controller());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<Controller>(
        init: Controller(),
        initState: (_) {
          c.login();
        },
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final c = Get.put(Controller());
  static TextStyle def = TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600);
  static const TextStyle defTitle = TextStyle(fontSize: 15.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 16.5);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<Controller>(
      init: Controller(),
      builder: (_) {
        final List<String> list = [];
        return Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            backgroundColor: Colors.transparent,
            title: Text(
              'MeuKubico',
              style: TextStyle(fontSize: 20),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: Search(list));
                },
              ),
              IconButton(
                icon: Icon(LineAwesomeIcons.filter),
                onPressed: () {
                  Get.to(Filtro());
                },
              ),
            ],
          ),
          body: Center(
            child: Container(
              child: c._widgetOptions.elementAt(c._selectedIndex),
            ),
          ),
          drawer: Drawer(
            child: Scaffold(
              body: ListView(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                    child: Image.asset(
                      'src/img/logo.png',
                      // color: CoresHexdecimal("bb52d1"),
                      height: 195,
                      width: 230,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(LineAwesomeIcons.helping_hands,
                        color: CoresHexdecimal("bb52d1")),
                    trailing: Icon(Icons.chevron_right,
                        color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Suporte Técnico',
                      style: defTitle,
                    ),
                    onTap: () => Get.to(Suporte()),
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(LineAwesomeIcons.lightbulb,
                        color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Dark Mode',
                      style: defTitle,
                    ),
                    trailing: Switch(
                      onChanged: c.changeTheme,
                      value: c.darkMode,
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(Icons.feedback_outlined,
                        color: CoresHexdecimal("bb52d1")),
                    trailing: Icon(Icons.chevron_right,
                        color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Feedback',
                      style: defTitle,
                    ),
                    onTap: () => Get.to(FeedBack()),
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(LineAwesomeIcons.cog,
                        color: CoresHexdecimal("bb52d1")),
                    trailing: Icon(Icons.chevron_right,
                        color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Definições',
                      style: defTitle,
                    ),
                    onTap: () => Get.to(Def()),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Redes Sociais',
                      style: def,
                    ),
                  ),
                  ListTile(
                    leading: Icon(LineAwesomeIcons.facebook,
                        color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Facebook',
                      style: defTitle,
                    ),
                    onTap: () {
                      launchURL('https://www.facebook.com/Venusimobiliaria');
                    },
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(LineAwesomeIcons.instagram,
                        color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Instagram',
                      style: defTitle,
                    ),
                    onTap: () {
                      launchURL('https://www.instagram.com/venusrobusta/');
                    },
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(LineAwesomeIcons.what_s_app,
                        color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Whatsapp',
                      style: defTitle,
                    ),
                    onTap: () {
                      launchURL(
                          'https://api.whatsapp.com/send?1=pt_PT&phone=244923004945');
                    },
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomAppBar(
              child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  size: 40,
                ),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.location_city,
                  size: 40,
                ),
                label: 'Ativos',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_pin,
                  size: 40,
                ),
                label: 'Cliente',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.person,
                  size: 40,
                ),
                label: 'Perfil',
              ),
            ],
            currentIndex: c._selectedIndex,
            unselectedLabelStyle: TextStyle(color: Color(0xffbf8923)),
            unselectedItemColor: themeData.primaryColor,
            selectedItemColor: CoresHexdecimal("bb52d1"),
            selectedFontSize: 12.0,
            unselectedFontSize: 11.0,
            onTap: c._onItemTapped,
          )), // This trailing comma makes auto-formatting nicer for build methods.
        );
      },
    );
  }
}

///Pesquisas e animações
class SearchController extends GetxController {
  int permite = 0;
  bool isLoading = false;
  List<String> searchList = [];
  int searchLimiter = 0;
  List data = [];
  String currentSearch = '';
  ScrollController searchScrollContoller = new ScrollController();
  void init(query, context) {
    searchScrollContoller.addListener(() async {
      if (searchScrollContoller.position.pixels ==
          searchScrollContoller.position.maxScrollExtent) {
        await getQueryData(query, context);
      }
    });
  }

  Future search(String query, context) async {
    if (permite == 1) {
      return;
    } else {
      permite = 1;
    }
    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getSearchData": "true",
        "query": query,
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);

        if (resBody is List) {
          searchList = [];
          resBody.forEach((element) {
            searchList.add(element['titulo']);
          });
        } else {
          searchList = [];
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print("Data search error: " + e.toString());
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
    permite = 0;
    update();
  }

  Future getQueryData(String query, context) async {
    if (!isLoading) {
      isLoading = true;
      update();
    }
    if (query != currentSearch) {
      currentSearch = query;
      searchLimiter = 0;
      data = [];
    }
    try {
      var res = await http.post(Uri.parse(host + "activos"), body: {
        "getQueryData": "true",
        "query": query,
        "limiter": searchLimiter.toString(),
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          resBody.forEach((element) {
            searchLimiter = int.parse(element['id']);
          });
          data.addAll(resBody);
        }
      } else {
        showToast("Verifique a sua conexão e tente novamente!", context,
            duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      }
    } catch (e) {
      print("Data search error: " + e.toString());
      showToast(
          "Verifique a sua conexão ou tente novamente mais tarde!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
    }
    if (isLoading) {
      isLoading = false;
      update();
    }
  }
}

class Search extends SearchDelegate {
  final c = Get.put(SearchController());
  //appBar
  final String searchFieldLabel = "Procure aqui...";
  //Variaveis de sugestões
  final List<String> listExample;
  Search(this.listExample);
  List<String> recentList = [];
  //Resultado
  String selectedResult;
  //Texto
  static const TextStyle defTitle = TextStyle(fontSize: 13.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 11.5);

  @override
  appBarTheme(BuildContext context) {
    return ThemeData(
        primaryColor: themeData.whiteColor,
        primarySwatch: themeData.primaryColor,
        iconTheme: new IconThemeData(color: themeData.goldAccent));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () => query = "",
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () => Get.back(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    selectedResult = query;
    c.getQueryData(selectedResult, context);
    return Container(
      child: GetBuilder<SearchController>(
        init: SearchController(),
        builder: (_) {
          return CustomScrollView(
            controller: c.searchScrollContoller,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildListDelegate(
                  c.data.map((data) {
                    return Card(
                      child: InkWell(
                        onTap: () => Get.toNamed(
                          "/ArtigoId?id=${data['id']}&titulo=${data['titulo']}",
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            CachedNetworkImage(
                              imageUrl: host +
                                  '../../../publico/img/imoveis/' +
                                  data['imagem'].toString(),
                              imageBuilder: (context, imageProvider) =>
                                  Container(
                                width: 90.0,
                                height: 90.0,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: imageProvider,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              placeholder: (context, url) => Container(
                                width: 90.0,
                                height: 90.0,
                                child:
                                    Center(child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 90.0,
                                height: 90.0,
                                color: Color.fromRGBO(0, 0, 0, 0.1),
                                child: Center(
                                    child:
                                        Icon(Icons.error, color: Colors.grey)),
                              ),
                            ),
                            Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, left: 8.0, right: 8.0),
                                      child: Text(
                                        data['titulo'],
                                        style: defTitle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        parseHtmlString(data['descricao']),
                                        style: defSubtitle,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                    )
                                  ],
                                ))
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
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
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    c.search(query, context);
    List<String> suggestionList = c.searchList;
    query.isEmpty
        ? suggestionList = recentList
        : suggestionList
            .addAll(listExample.where((element) => element.contains(query)));

    return GetBuilder(
      init: SearchController(),
      builder: (_) {
        return ListView.builder(
            itemCount: c.searchList.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Icon(Icons.search),
                trailing: Icon(Icons.chevron_right),
                title: Text(c.searchList[index], style: defTitle),
                onTap: () {
                  selectedResult = c.searchList[index];
                  query = c.searchList[index];
                  showResults(context);
                },
              );
            });
      },
    );
  }
}
