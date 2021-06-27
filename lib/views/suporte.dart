import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:venus_robusta/util/colors.dart';

class Suporte extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const TextStyle supTitle = TextStyle(fontSize: 15.0);
    const TextStyle supSubtitle = TextStyle(fontSize: 16.5);

    return Scaffold(
      appBar: AppBar(
        title: Text('Suporte Técnico'),
      ),
      body: Center(
        child: Container(
          child: ListView(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    leading: Icon(LineAwesomeIcons.phone,color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Telemóvel',
                      style: supTitle,
                    ),
                    subtitle: Text(
                      '(+244) 923 004 923',
                      style: supSubtitle,
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(LineAwesomeIcons.what_s_app,color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Whatsapp',
                      style: supTitle,
                    ),
                    subtitle: Text(
                      '(+244) 923 004 945',
                      style: supSubtitle,
                    ),
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: Icon(LineAwesomeIcons.envelope,color: CoresHexdecimal("bb52d1")),
                    title: Text(
                      'Email',
                      style: supTitle,
                    ),
                    subtitle: Text(
                      'geral@meukobico.co.ao',
                      style: supSubtitle,
                    ),
                  ),
                  Divider(
                    height: 1,
                  ),
                  ListTile(
                    leading: Icon(LineAwesomeIcons.facebook,color: CoresHexdecimal("bb52d1")),
                    title: Text('Facebook', style: supTitle),
                    subtitle: Text(
                      'www.facebook.com/meukobico',
                      style: supSubtitle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
