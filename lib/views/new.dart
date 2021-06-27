import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:venus_robusta/models/widget.dart';
import 'package:venus_robusta/navigation/conta.dart';
import 'package:venus_robusta/util/global_functions.dart';
import '../util/theme_config.dart';
import 'package:toast/toast.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../main.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class AddactivoController extends GetxController {
  String editTarget = '0';
  bool isLoading = false;
  var imagemVar;
  var documentacaoVar;

  //Text Controller
  TextEditingController titulo = new TextEditingController();
  TextEditingController subtitulo = new TextEditingController();
  TextEditingController imagem = new TextEditingController();
  TextEditingController documentacao = new TextEditingController();
  TextEditingController youtube = new TextEditingController();
  TextEditingController categoria = new TextEditingController();
  TextEditingController subcategoria = new TextEditingController();
  TextEditingController pavimento = new TextEditingController();
  TextEditingController tamanho = new TextEditingController();
  //From tipologia de casa
  TextEditingController dormitorio = new TextEditingController();
  TextEditingController areaConstruida = new TextEditingController();
  TextEditingController banheiro = new TextEditingController();
  TextEditingController garagem = new TextEditingController();
  TextEditingController preco = new TextEditingController();
  TextEditingController descricao = new TextEditingController();
  List dataCategoria = [];
  List dataSubcategoria = [];
  List dataPavimento = [];
  List dataTerreno = [];
  List dataTipologia = [];
  List dataArea = [];
  List dataBanheiro = [];
  List dataGaragem = [];
  List dataImovel = [];

  bool isLoad = true;

  void init(context) async {
    imagemVar = '';
    documentacaoVar = '';
    titulo.text = '';
    subtitulo.text = '';
    imagem.text = '';
    documentacao.text = '';
    youtube.text = '';
    categoria.text = '';
    subcategoria.text = '';
    pavimento.text = '';
    tamanho.text = '';
    dormitorio.text = '';
    areaConstruida.text = '';
    banheiro.text = '';
    garagem.text = '';
    preco.text = '';
    descricao.text = '';

    if (dataCategoria.length <= 0) {
      await this.getCategoria(context);
    }
    if (dataPavimento.length <= 0) {
      await this.getPavimento(context);
    }
    if (dataTerreno.length <= 0) {
      await this.getTerreno(context);
    }
    if (dataTipologia.length <= 0) {
      await this.getTipologia(context);
    }
    if (dataArea.length <= 0) {
      await this.getArea(context);
    }
    if (dataBanheiro.length <= 0) {
      await this.getBanheiro(context);
    }
    if (dataGaragem.length <= 0) {
      await this.getGaragem(context);
    }
    isLoad = false;
    update();
  }

  void initEdit(context, String id) async {
    isLoad = true;
    update();
    imagemVar = '';
    documentacaoVar = '';
    titulo.text = '';
    subtitulo.text = '';
    imagem.text = '';
    documentacao.text = '';
    youtube.text = '';
    categoria.text = '';
    subcategoria.text = '';
    pavimento.text = '';
    tamanho.text = '';
    dormitorio.text = '';
    areaConstruida.text = '';
    banheiro.text = '';
    garagem.text = '';
    preco.text = '';
    descricao.text = '';

    if (dataCategoria.length <= 0) {
      await this.getCategoria(context);
    }
    if (dataPavimento.length <= 0) {
      await this.getPavimento(context);
    }
    if (dataTerreno.length <= 0) {
      await this.getTerreno(context);
    }
    if (dataTipologia.length <= 0) {
      await this.getTipologia(context);
    }
    if (dataArea.length <= 0) {
      await this.getArea(context);
    }
    if (dataBanheiro.length <= 0) {
      await this.getBanheiro(context);
    }
    if (dataGaragem.length <= 0) {
      await this.getGaragem(context);
    }

    await this.getImovel(context, id);

    isLoad = false;
    update();
  }

  //Get Categoria
  Future getCategoria(context) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getCategoria": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataCategoria = resBody;
        }
      }
    } catch (e) {
      print("Categoria error: " + e.toString());
    }
  }

  //Get Categoria
  Future getSubcategoria(context) async {
    customLoading(context);
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getSubcategoria": "true",
        "categoria": categoria.text.trim(),
        "permission": permitame,
      });
      Get.back();
      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        print(resBody);
        if (resBody is List) {
          dataSubcategoria = resBody;
          update();
        }
      }
    } catch (e) {
      print("Subcategoria error: " + e.toString());
    }
  }

  //Get pavimento
  Future getPavimento(context) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getPavimento": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataPavimento = resBody;
        }
      }
    } catch (e) {
      print("Pavimento error: " + e.toString());
    }
  }

  //Get terreno
  Future getTerreno(context) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getTerreno": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataTerreno = resBody;
        }
      }
    } catch (e) {
      print("Terreno error: " + e.toString());
    }
  }

  //Get tipologia
  Future getTipologia(context) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getTipologia": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataTipologia = resBody;
        }
      }
    } catch (e) {
      print("Terreno error: " + e.toString());
    }
  }

  //Get Area
  Future getArea(context) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getArea": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataArea = resBody;
        }
      }
    } catch (e) {
      print("Aréa error: " + e.toString());
    }
  }

  //Get Banheiro
  Future getBanheiro(context) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getBanheiro": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataBanheiro = resBody;
        }
      }
    } catch (e) {
      print("Banheiro error: " + e.toString());
    }
  }

  //Get Area
  Future getGaragem(context) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getGaragem": "true",
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataGaragem = resBody;
        }
      }
    } catch (e) {
      print("Garagem error: " + e.toString());
    }
  }

  Future getImovel(context, String imovelId) async {
    try {
      var res = await http.post(Uri.parse(host + "filtro"), body: {
        "getImovel": "true",
        "idArtigo": imovelId,
        "permission": permitame,
      });

      if (res.statusCode == 200) {
        var resBody = json.decode(res.body);
        if (resBody is List) {
          dataImovel = resBody;
          titulo.text = dataImovel[0]['titulo'];
          subtitulo.text = dataImovel[0]['subtitulo'];
          //imagem.text = dataImovel[0][''];
          //documentacao.text = dataImovel[0][''];
          youtube.text = dataImovel[0]['youtube'];
          categoria.text = dataImovel[0]['categoria'];
          subcategoria.text = dataImovel[0]['subcategoria'];
          pavimento.text = dataImovel[0]['pavimento'];
          tamanho.text = dataImovel[0]['tamanho'];
          dormitorio.text = dataImovel[0]['dormitorio'];
          areaConstruida.text = dataImovel[0]['area_construida'];
          banheiro.text = dataImovel[0]['banheiro'];
          garagem.text = dataImovel[0]['garagem'];
          preco.text = dataImovel[0]['preco'];
          descricao.text = dataImovel[0]['descricao'];
        }
      }
    } catch (e) {
      print("Imovel error: " + e.toString());
    }
  }

  //Selecionar imagens
  void selectImage(context, String target) async {
    if (target == 'imagem') {
      imagemVar = await ImagePicker().getImage(source: ImageSource.gallery);

      if (imagemVar != null) {
        imagemVar = File(imagemVar.path);
        imagem.text = basename(imagemVar.path);
      }
    } else {
      documentacaoVar =
          await ImagePicker().getImage(source: ImageSource.gallery);

      if (documentacaoVar != null) {
        documentacaoVar = File(documentacaoVar.path);
        documentacao.text = basename(documentacaoVar.path);
      }
    }
    update();
  }

  //setData
  Future setData(context) async {
    var box = await Hive.openBox('venus_robusta_user');
    if (imagemVar == null || imagemVar == '') {
      showToast("Adicione uma imagem do seu ativo!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (documentacaoVar == null || documentacaoVar == '') {
      showToast("Adicione uma imagem da documentação!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (titulo.text.trim().length < 3) {
      showToast("Insira um titulo valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (subtitulo.text.trim().length < 3) {
      showToast("Insira um subtitulo valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (categoria.text.trim() == '') {
      showToast("Selecione uma categoria!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (preco.text.trim() == '') {
      showToast("Insira um preço valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (descricao.text.trim() == '') {
      showToast("Insira uma descrição valida!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }

    var youtubeVar = '';
    List youtu = [];
    //Verificando link de video youtube
    if (youtube.text.trim() != '') {
      if (youtube.text.trim().contains('embed')) {
        youtu = youtube.text.trim().split('/');
        if (youtu[youtu.length - 1] is String &&
            youtu[youtu.length - 1].toString().trim().length > 10 &&
            youtu[youtu.length - 1].toString().trim().length < 13) {
          youtubeVar =
              "https://www.youtube.com/embed/" + youtu[youtu.length - 1];
        } else {
          showToast("Insira um link do youtube valido!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
          return;
        }
      } else {
        youtu = youtube.text.toString().split('?v=');
        if (youtu[1] is String &&
            youtu[1].toString().trim().length > 10 &&
            youtu[1].toString().trim().length < 13) {
          youtubeVar = "https://www.youtube.com/embed/" + youtu[1];
        } else {
          showToast("Insira um link do youtube valido!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
          return;
        }
      }
    }

    if (!isLoading) {
      customLoading(context);
      isLoading = true;
    }

    try {
      var stream = new http.ByteStream(imagemVar.openRead());
      var length = await imagemVar.length();

      var stream2 = new http.ByteStream(documentacaoVar.openRead());
      var length2 = await documentacaoVar.length();

      var uri = Uri.parse(host + "perfil");
      var request = new http.MultipartRequest("POST", uri);

      var imagemSend = new http.MultipartFile("img[]", stream, length,
          filename: basename(imagemVar.path));

      var documentacaoSend = new http.MultipartFile(
          "documentacao[]", stream2, length2,
          filename: basename(documentacaoVar.path));

      request.fields["setImovel"] = 'send';
      request.fields["id"] = box.get('login') ?? '0';
      request.fields["titulo"] = titulo.text.trim();
      request.fields["subtitulo"] = subtitulo.text.trim();
      request.fields["youtube"] = youtubeVar.toString().trim();
      request.fields["categoria"] = categoria.text.trim();
      request.fields["subcategoria"] = subcategoria.text.trim();
      request.fields["pavimento"] = pavimento.text.trim();
      request.fields["tamanho"] = tamanho.text.trim();
      //From tipologia de casa
      request.fields["dormitorio"] = dormitorio.text.trim();
      request.fields["area_construida"] = areaConstruida.text.trim();
      request.fields["banheiro"] = banheiro.text.trim();
      request.fields["garagem"] = garagem.text.trim();
      request.fields["preco"] = preco.text.trim();
      request.fields["descricao"] = descricao.text.trim();
      request.fields["permission"] = permitame;
      request.fields["token"] = box.get('token') ?? 'n/a';

      request.files.add(imagemSend);
      request.files.add(documentacaoSend);
      var response = await request.send();

      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }

      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((value) {
          var result = json.decode(value);
          if (result is int && result == 0) {
            showToast('Não foi possível registar o seu ativo!', context,
                duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
          } else if (result is int && result == 1) {
            Get.put(SetActivos()).init(context);
            Get.back();
          } else {
            showToast(result.toString(), context,
                duration: 5, gravity: Toast.TOP);
          }
        });
      }
    } catch (e) {
      print("Data image: " + e.toString());
      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }
      showToast('Não foi possível se conectar com o servidor!', context,
          duration: 5, gravity: Toast.TOP);
    }
  }

  void editImovel(context, String idImovel) async {
    var box = await Hive.openBox('venus_robusta_user');
    if (titulo.text.trim().length < 3) {
      showToast("Insira um titulo valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (subtitulo.text.trim().length < 3) {
      showToast("Insira um subtitulo valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (categoria.text.trim() == '') {
      showToast("Selecione uma categoria!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (preco.text.trim() == '') {
      showToast("Insira um preço valido!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    } else if (descricao.text.trim() == '') {
      showToast("Insira uma descrição valida!", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
      return;
    }

    var youtubeVar = '';
    List youtu = [];
    //Verificando link de video youtube
    if (youtube.text.trim() != '') {
      if (youtube.text.trim().contains('embed')) {
        youtu = youtube.text.trim().split('/');
        if (youtu[youtu.length - 1] is String &&
            youtu[youtu.length - 1].toString().trim().length > 10 &&
            youtu[youtu.length - 1].toString().trim().length < 13) {
          youtubeVar =
              "https://www.youtube.com/embed/" + youtu[youtu.length - 1];
        } else {
          showToast("Insira um link do youtube valido!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
          return;
        }
      } else {
        youtu = youtube.text.toString().split('?v=');
        if (youtu[1] is String &&
            youtu[1].toString().trim().length > 10 &&
            youtu[1].toString().trim().length < 13) {
          youtubeVar = "https://www.youtube.com/embed/" + youtu[1];
        } else {
          showToast("Insira um link do youtube valido!", context,
              duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
          return;
        }
      }
    }

    if (!isLoading) {
      customLoading(context);
      isLoading = true;
    }

    try {
      var uri = Uri.parse(host + "perfil");
      var request = new http.MultipartRequest("POST", uri);
      request.fields["editImovel"] = 'send';
      request.fields["id"] = box.get('login') ?? '0';
      request.fields["imoveis_id"] = idImovel;
      request.fields["titulo"] = titulo.text.trim();
      request.fields["subtitulo"] = subtitulo.text.trim();
      request.fields["youtube"] = youtubeVar.toString().trim();
      request.fields["categoria"] = categoria.text.trim();
      request.fields["subcategoria"] = subcategoria.text.trim();
      request.fields["pavimento"] = pavimento.text.trim();
      request.fields["tamanho"] = tamanho.text.trim();
      //From tipologia de casa
      request.fields["dormitorio"] = dormitorio.text.trim();
      request.fields["area_construida"] = areaConstruida.text.trim();
      request.fields["banheiro"] = banheiro.text.trim();
      request.fields["garagem"] = garagem.text.trim();
      request.fields["preco"] = preco.text.trim();
      request.fields["descricao"] = descricao.text.trim();
      request.fields["permission"] = permitame;
      request.fields["token"] = box.get('token') ?? 'n/a';
      var response = await request.send();

      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }

      if (response.statusCode == 200) {
        response.stream.transform(utf8.decoder).listen((value) {
          var result = json.decode(value);
          if (result is int && result == 0) {
            showToast('Não foi possível atualizar o seu ativo!', context,
                duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
          } else if (result is int && result == 1) {
            showToast('O seu ativo foi atualizado com sucesso!', context,
                duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
            Get.put(SetActivos()).init(context);
          } else {
            showToast(result.toString(), context,
                duration: 5, gravity: Toast.TOP);
          }
        });
      }
    } catch (e) {
      print("Data imagem edit: " + e.toString());
      if (isLoading) {
        Navigator.pop(context);
        isLoading = false;
      }
      showToast('Não foi possível se conectar com o servidor!', context,
          duration: 5, gravity: Toast.TOP);
    }
  }
}

class Addactivo extends StatelessWidget {
  final c = Get.put(AddactivoController());
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: Icon(Icons.location_city),
          title: Text('Registar ativo imobiliário'),
        ),
        body: Center(
          child: GetBuilder<AddactivoController>(
            init: AddactivoController(),
            initState: (_) {
              c.init(context);
            },
            builder: (_) {
              return c.isLoad == false
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
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      c.selectImage(context, 'imagem');
                                    },
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: c.imagem,
                                      decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.image),
                                        enabled: false,
                                        labelText: 'Imagem',
                                        filled: true,
                                        labelStyle: TextStyle(fontSize: 13.0),
                                      ),
                                    ),
                                  )),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    c.selectImage(context, 'documentacao');
                                  },
                                  child: TextFormField(
                                    keyboardType: TextInputType.datetime,
                                    controller: c.documentacao,
                                    decoration: InputDecoration(
                                      enabled: false,
                                      prefixIcon: Icon(Icons.file_copy),
                                      labelText: 'Documentação',
                                      filled: true,
                                      labelStyle: TextStyle(fontSize: 13.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: c.titulo,
                            decoration: InputDecoration(
                              labelText: '* Título',
                              filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: c.subtitulo,
                            decoration: InputDecoration(
                              labelText: '* Subtítulo',
                              filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: c.youtube,
                            decoration: InputDecoration(
                              labelText: 'Link youtube',
                              //filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                              hintText: "Insira um link do youtube valido!",
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(SelectCompnet(),
                                          arguments: "Categoria");
                                    },
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: c.categoria,
                                      decoration: InputDecoration(
                                        labelText: '* Categoria',
                                        enabled: false,
                                        filled: true,
                                        labelStyle: TextStyle(fontSize: 13.0),
                                      ),
                                    ),
                                  )),
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(SelectCompnet(),
                                          arguments: "Subcategoria");
                                    },
                                    child: TextFormField(
                                      keyboardType: TextInputType.datetime,
                                      controller: c.subcategoria,
                                      decoration: InputDecoration(
                                        enabled: false,
                                        labelText: 'Subcategoria',
                                        filled: true,
                                        labelStyle: TextStyle(fontSize: 13.0),
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(SelectCompnet(),
                                        arguments: "Pavimento");
                                  },
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: c.pavimento,
                                    decoration: InputDecoration(
                                      enabled: false,
                                      labelText: 'Pavimento',
                                      filled: true,
                                      labelStyle: TextStyle(fontSize: 13.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(SelectCompnet(),
                                          arguments: "Terreno");
                                    },
                                    child: TextFormField(
                                      keyboardType: TextInputType.datetime,
                                      controller: c.tamanho,
                                      decoration: InputDecoration(
                                        enabled: false,
                                        labelText: 'Terreno',
                                        filled: true,
                                        labelStyle: TextStyle(fontSize: 13.0),
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(SelectCompnet(),
                                        arguments: "Tipologia da casa");
                                  },
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: c.dormitorio,
                                    decoration: InputDecoration(
                                      enabled: false,
                                      labelText: 'Tipologia da casa',
                                      filled: true,
                                      labelStyle: TextStyle(fontSize: 13.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(SelectCompnet(),
                                          arguments: "Banheiro(s)");
                                    },
                                    child: TextFormField(
                                      keyboardType: TextInputType.datetime,
                                      controller: c.banheiro,
                                      decoration: InputDecoration(
                                        enabled: false,
                                        labelText: 'Banheiro(s)',
                                        filled: true,
                                        labelStyle: TextStyle(fontSize: 13.0),
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(SelectCompnet(),
                                          arguments: "Garagem");
                                    },
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: c.garagem,
                                      decoration: InputDecoration(
                                        enabled: false,
                                        labelText: 'Garagem',
                                        filled: true,
                                        labelStyle: TextStyle(fontSize: 13.0),
                                      ),
                                    ),
                                  )),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(SelectCompnet(),
                                        arguments: "Área Construída");
                                  },
                                  child: TextFormField(
                                    keyboardType: TextInputType.datetime,
                                    controller: c.areaConstruida,
                                    decoration: InputDecoration(
                                      enabled: false,
                                      labelText: 'Área Construída',
                                      filled: true,
                                      labelStyle: TextStyle(fontSize: 13.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: c.preco,
                            decoration: InputDecoration(
                              labelText: '* Preço',
                              filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            minLines: 6,
                            maxLines: 50,
                            controller: c.descricao,
                            decoration: InputDecoration(
                              labelText: '* Descrição',
                              filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0)),
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
                                style: TextStyle(
                                    fontSize: 13.0, color: Colors.blue),
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
                          height: Get.height / 10,
                        )
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: getCarregameto(),
                      ),
                    );
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Card(
                  color: Colors.red,
                  child: InkWell(
                    onTap: () async {
                      await Get.defaultDialog(
                        confirmTextColor: Colors.white,
                        title: 'Atenção',
                        content: Text(
                          'Pretende mesmo descartar este ativo?',
                          style: TextStyle(fontSize: 14.0),
                          textAlign: TextAlign.center,
                        ),
                        textConfirm: 'Sim',
                        onConfirm: () {
                          Get.back();
                          Get.back();
                        },
                        textCancel: 'Não',
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          Text(
                            'Descartar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: themeData.goldAccent,
                  child: InkWell(
                    onTap: () {
                      c.setData(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, color: Colors.white),
                          Text(
                            'Salvar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Editar activo
class Editactivo extends StatelessWidget {
  final c = Get.put(AddactivoController());
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.location_city),
          automaticallyImplyLeading: false,
          title: Text('Editar ativo imobiliário'),
        ),
        body: Center(
          child: GetBuilder<AddactivoController>(
            init: AddactivoController(),
            initState: (_) {
              c.initEdit(context, c.editTarget);
            },
            builder: (_) {
              return c.isLoad == false
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
                          child: Card(
                            child: ListTile(
                              leading: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LineAwesomeIcons.image_file),
                                  Icon(LineAwesomeIcons.video_file)
                                ],
                              ),
                              title: Text('Gerenciar arquivos'),
                              onTap: () {
                                Get.to(GerenciadorArquivos());
                              },
                              trailing: Icon(Icons.chevron_right),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: c.titulo,
                            decoration: InputDecoration(
                              labelText: '* Título',
                              filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: c.subtitulo,
                            decoration: InputDecoration(
                              labelText: '* Subtítulo',
                              filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.text,
                            controller: c.youtube,
                            decoration: InputDecoration(
                              labelText: 'Link youtube',
                              //filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                              hintText: "Insira um link do youtube valido!",
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(SelectCompnet(),
                                          arguments: "Categoria");
                                    },
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: c.categoria,
                                      decoration: InputDecoration(
                                        labelText: '* Categoria',
                                        enabled: false,
                                        filled: true,
                                        labelStyle: TextStyle(fontSize: 13.0),
                                      ),
                                    ),
                                  )),
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(SelectCompnet(),
                                          arguments: "Subcategoria");
                                    },
                                    child: TextFormField(
                                      keyboardType: TextInputType.datetime,
                                      controller: c.subcategoria,
                                      decoration: InputDecoration(
                                        enabled: false,
                                        labelText: 'Subcategoria',
                                        filled: true,
                                        labelStyle: TextStyle(fontSize: 13.0),
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(SelectCompnet(),
                                        arguments: "Pavimento");
                                  },
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: c.pavimento,
                                    decoration: InputDecoration(
                                      enabled: false,
                                      labelText: 'Pavimento',
                                      filled: true,
                                      labelStyle: TextStyle(fontSize: 13.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(SelectCompnet(),
                                          arguments: "Terreno");
                                    },
                                    child: TextFormField(
                                      keyboardType: TextInputType.datetime,
                                      controller: c.tamanho,
                                      decoration: InputDecoration(
                                        enabled: false,
                                        labelText: 'Terreno',
                                        filled: true,
                                        labelStyle: TextStyle(fontSize: 13.0),
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(SelectCompnet(),
                                        arguments: "Tipologia da casa");
                                  },
                                  child: TextFormField(
                                    keyboardType: TextInputType.text,
                                    controller: c.dormitorio,
                                    decoration: InputDecoration(
                                      enabled: false,
                                      labelText: 'Tipologia da casa',
                                      filled: true,
                                      labelStyle: TextStyle(fontSize: 13.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(SelectCompnet(),
                                          arguments: "Banheiro(s)");
                                    },
                                    child: TextFormField(
                                      keyboardType: TextInputType.datetime,
                                      controller: c.banheiro,
                                      decoration: InputDecoration(
                                        enabled: false,
                                        labelText: 'Banheiro(s)',
                                        filled: true,
                                        labelStyle: TextStyle(fontSize: 13.0),
                                      ),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Get.to(SelectCompnet(),
                                          arguments: "Garagem");
                                    },
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      controller: c.garagem,
                                      decoration: InputDecoration(
                                        enabled: false,
                                        labelText: 'Garagem',
                                        filled: true,
                                        labelStyle: TextStyle(fontSize: 13.0),
                                      ),
                                    ),
                                  )),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    Get.to(SelectCompnet(),
                                        arguments: "Área Construída");
                                  },
                                  child: TextFormField(
                                    keyboardType: TextInputType.datetime,
                                    controller: c.areaConstruida,
                                    decoration: InputDecoration(
                                      enabled: false,
                                      labelText: 'Área Construída',
                                      filled: true,
                                      labelStyle: TextStyle(fontSize: 13.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            controller: c.preco,
                            decoration: InputDecoration(
                              labelText: '* Preço',
                              filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.multiline,
                            minLines: 6,
                            maxLines: 50,
                            controller: c.descricao,
                            decoration: InputDecoration(
                              labelText: '* Descrição',
                              filled: true,
                              labelStyle: TextStyle(fontSize: 13.0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(2.0)),
                            ),
                          ),
                        ),
                        Container(
                          height: Get.height / 10,
                        )
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: getCarregameto(),
                      ),
                    );
            },
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Card(
                  color: Colors.red,
                  child: InkWell(
                    onTap: () async {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Fechar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  color: themeData.goldAccent,
                  child: InkWell(
                    onTap: () {
                      c.editImovel(context, c.editTarget);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Salvar',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//Select aréa
class SelectCompnet extends StatelessWidget {
  final c = Get.put(AddactivoController());
  static const TextStyle defTitle = TextStyle(fontSize: 13.0);
  static const TextStyle defSubtitle = TextStyle(fontSize: 12.0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Get.arguments),
      ),
      body: Center(
        child: GetBuilder<AddactivoController>(
          init: AddactivoController(),
          builder: (_) {
            return CustomScrollView(
              slivers: [
                //Categoria
                Get.arguments == 'Categoria'
                    ? SliverList(
                        delegate: SliverChildListDelegate(
                          c.dataCategoria.map((data) {
                            return Card(
                              child: ListTile(
                                onTap: () async {
                                  c.categoria.text = data['categoria'];
                                  await c.getSubcategoria(context);
                                  c.subcategoria.text = '';
                                  Get.back();
                                },
                                title:
                                    Text(data['categoria'], style: defSubtitle),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : SliverToBoxAdapter(),
                //Subcategoria
                Get.arguments == 'Subcategoria'
                    ? SliverList(
                        delegate: SliverChildListDelegate(
                          c.dataSubcategoria.map((data) {
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  c.subcategoria.text = data['subcategoria'];
                                  Get.back();
                                },
                                title: Text(data['subcategoria'],
                                    style: defSubtitle),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : SliverToBoxAdapter(),
                //Pavimento
                Get.arguments == 'Pavimento'
                    ? SliverList(
                        delegate: SliverChildListDelegate(
                          c.dataPavimento.map((data) {
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  c.pavimento.text = data['pavimento'];
                                  Get.back();
                                },
                                title:
                                    Text(data['pavimento'], style: defSubtitle),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : SliverToBoxAdapter(),
                //Terreno
                Get.arguments == 'Terreno'
                    ? SliverList(
                        delegate: SliverChildListDelegate(
                          c.dataTerreno.map((data) {
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  c.tamanho.text = data['tamanho'];
                                  Get.back();
                                },
                                title:
                                    Text(data['tamanho'], style: defSubtitle),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : SliverToBoxAdapter(),
                //Tipologia de casa
                Get.arguments == 'Tipologia da casa'
                    ? SliverList(
                        delegate: SliverChildListDelegate(
                          c.dataTipologia.map((data) {
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  c.dormitorio.text = data['dormitorio'];
                                  Get.back();
                                },
                                title: Text(data['dormitorio'],
                                    style: defSubtitle),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : SliverToBoxAdapter(),
                //Tipologia de casa
                Get.arguments == 'Área Construída'
                    ? SliverList(
                        delegate: SliverChildListDelegate(
                          c.dataArea.map((data) {
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  c.areaConstruida.text = data['area'];
                                  Get.back();
                                },
                                title: Text(data['area'], style: defSubtitle),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : SliverToBoxAdapter(),
                //Banheiro
                Get.arguments == 'Banheiro(s)'
                    ? SliverList(
                        delegate: SliverChildListDelegate(
                          c.dataBanheiro.map((data) {
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  c.banheiro.text = data['banheiro'];
                                  Get.back();
                                },
                                title:
                                    Text(data['banheiro'], style: defSubtitle),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : SliverToBoxAdapter(),
                //Banheiro
                Get.arguments == 'Garagem'
                    ? SliverList(
                        delegate: SliverChildListDelegate(
                          c.dataGaragem.map((data) {
                            return Card(
                              child: ListTile(
                                onTap: () {
                                  c.garagem.text = data['garagem'];
                                  Get.back();
                                },
                                title:
                                    Text(data['garagem'], style: defSubtitle),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : SliverToBoxAdapter(),
              ],
            );
          },
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////

class Gerenciador extends GetxController {
  bool isLoading = false;
  List imagem = [];
  List video = [];
  final c2 = Get.put(AddactivoController());

  void init() async {
    //Video

    if (c2.dataImovel[0]['video'] != '' && c2.dataImovel[0]['video'] != null) {
      videoPlayer(
          host + '../../../publico/video/imoveis/' + c2.dataImovel[0]['video']);
    }
  }

  //Video
  VideoPlayerController videoController;
  ChewieController chewieController;
  void videoPlayer(String link) async {
    videoController = VideoPlayerController.network(link);
    await videoController.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoController,
      autoPlay: false,
      looping: false,
      allowPlaybackSpeedChanging: false,
      aspectRatio: 16 / 9,
      errorBuilder: (context, errorMessage) {
        return Card(
          margin: const EdgeInsets.only(
              top: 8.0, left: 0.0, right: 0.0, bottom: 0.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Video não encontrado!'),
          ),
        );
      },
    );
    update();
  }

  Widget chewie() {
    if (chewieController != null) {
      return Card(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Chewie(
            controller: chewieController,
          ),
        ),
      );
    } else {
      return Center();
    }
  }

  void upload(String target, context) async {
    showToast("Ação temporariamente indisponivel!", context,
        duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
  }
}

//Gerenciador de arquivos
class GerenciadorArquivos extends StatelessWidget {
  final c = Get.put(Gerenciador());
  final c2 = Get.put(AddactivoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciador de arquivos'),
      ),
      body: GetBuilder<Gerenciador>(
        init: Gerenciador(),
        initState: (_) {
          c.init();
        },
        builder: (_) {
          return Center(
            child: c.isLoading == true
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: getCarregameto(),
                    ),
                  )
                : ListView(
                    children: [
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.upload_file),
                          title: Text('Carregar video'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            c.upload('video', context);
                          },
                        ),
                      ),
                      Column(
                        children: [
                          c2.dataImovel[0]['video'] != '' &&
                                  c2.dataImovel[0]['video'] != null
                              ? c.chewie()
                              : Center(),
                        ],
                      ),
                      Card(
                        child: ListTile(
                          leading: Icon(Icons.upload_file),
                          title: Text('Carregar imagem'),
                          trailing: Icon(Icons.chevron_right),
                          onTap: () {
                            c.upload('imagem', context);
                          },
                        ),
                      ),
                      Column(
                        children: [
                          c2.dataImovel[0]['imagem'] is String &&
                                  c2.dataImovel[0]['imagem'] != ''
                              ? Card(
                                  child: CachedNetworkImage(
                                    imageUrl: host +
                                        '../../../publico/img/imoveis/' +
                                        c2.dataImovel[0]['imagem'],
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      height: 200.0,
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              : Center()
                        ],
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
