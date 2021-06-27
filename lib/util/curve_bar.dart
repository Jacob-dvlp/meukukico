import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:venus_robusta/navigation/activos.dart';
import 'package:venus_robusta/navigation/cliente.dart';
import 'package:venus_robusta/navigation/conta.dart';
import 'package:venus_robusta/navigation/home.dart';
import 'package:venus_robusta/util/colors.dart';

class BottomNavBar extends StatefulWidget {
  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  int paginas = 0;

  final home = new Home();
  final activo = new Activos();
  final cliente = new Cliente();
  final conta = new Conta();

  Widget showPage = new Home();

  Widget escolherPage(int page) {
    switch (page) {
      case 0:
        return home;
        break;
      case 1:
        return activo;
        break;
      case 2:
        return cliente;
        break;
      case 3:
        return conta;
        break;
      case 4:
        return conta;
        break;
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        index: paginas,
        height: 55.0,
        items: <Widget>[
          Icon(
            Icons.home,
            size: 40,
            color: Colors.white,
          ),
          Icon(
            Icons.support_agent,
            size: 40,
            color: Colors.white,
          ),
          Icon(
            Icons.event,
            size: 40,
            color: Colors.white,
          ),
          Icon(
            Icons.room,
            size: 40,
            color: Colors.white,
          ),
          Icon(
            Icons.group,
            size: 40,
            color: Colors.white,
          ),
        ],
        color: CoresHexdecimal("0b3f57"),
        buttonBackgroundColor: CoresHexdecimal("0b3f57"),
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 200),
        onTap: (int changePage) {
          setState(() {
            showPage = escolherPage(changePage);
          });
        },
      ),
      body: Center(
        child: showPage,
      ),
    );
  }
}
