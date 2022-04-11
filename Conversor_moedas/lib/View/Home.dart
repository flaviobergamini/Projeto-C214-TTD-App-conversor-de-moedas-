import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map> getDataAPI() async {
  const apiFinance = "https://api.hgbrasil.com/finance?key=173e0827";
  http.Response response = await http.get(Uri.parse(apiFinance));
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();
  final bitcoinController = TextEditingController();


  double dolar = 0.0;
  double euro = 0.0;
  double bitcoin = 0.0;
  double ibovespa = 0.0;
  double cdi = 0.0;
  double selic = 0.0;

  // Função para limpar os campos de todos os dados quando estão vazios
  void _limpaCampos(){
    realController.text ="";
    dolarController.text ="";
    euroController.text = "";
    bitcoinController.text="";
  }

  // Funções que realizam as conversões
  void _realChanged(String text){
    if(text.isEmpty){
      _limpaCampos();
      return;
    }
    double real= double.parse(text);
    if(real>0){
      dolarController.text=(real/dolar).toStringAsFixed(2);
      euroController.text=(real/euro).toStringAsFixed(2);
      bitcoinController.text=(real/bitcoin).toStringAsFixed(2);
    }
  }

  void _dolarChanged(String text){
    if(text.isEmpty){
      _limpaCampos();
      return;
    }
    double dolar = double.parse(text);
    if(dolar>0){
      realController.text = (dolar * this.dolar).toStringAsFixed(2);
      euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
      bitcoinController.text=(dolar*this.dolar/bitcoin).toStringAsFixed(2);
    }

  }

  void _euroChanged(String text){
    if(text.isEmpty){
      _limpaCampos();
      return;
    }
    double euro = double.parse(text);
    if(euro>0){
      realController.text = (euro * this.euro).toStringAsFixed(2);
      dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
      bitcoinController.text=(euro*this.euro/bitcoin).toStringAsFixed(3);
    }

  }

  void _bitChanged(String text){
    if(text.isEmpty){
      _limpaCampos();
      return;
    }
    double bitcoin=double.parse(text);

    if(bitcoin>0){
      realController.text=(bitcoin*this.bitcoin).toStringAsFixed(2);
      dolarController.text=(bitcoin*this.bitcoin/dolar).toStringAsFixed(2);
      euroController.text = (bitcoin * this.bitcoin / euro).toStringAsFixed(2);
    }



  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.indigo,
      body: FutureBuilder<Map>(
        future: getDataAPI(),
        builder: (context, snapshot){  // Função anônima que verifica a conexão e dados vindos da API
          switch(snapshot.connectionState){
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(child: CircularProgressIndicator());
            default:
              if(snapshot.hasError){
                return Center(
                  child: Text("Erro ao carregar dados da API",
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              else {
                dolar = snapshot.data!["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data!["results"]["currencies"]["EUR"]["buy"];
                bitcoin = snapshot.data!["results"]["currencies"]["BTC"]["buy"];
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(15, 45, 15, 15),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Icon(Icons.monetization_on_outlined, size: 100, color: Colors.white),
                            Padding(padding: EdgeInsets.all(3)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text("Conversor de ",
                                      style: TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                    Text("moedas ",
                                      style: TextStyle(color: Colors.cyan, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Text("C214 - Engenharia de Software", style: TextStyle(color: Colors.white)),
                                Text("Inatel", style: TextStyle(color: Colors.white))
                              ],
                            ),
                          ],
                        ),
                        Padding(padding: EdgeInsets.all(10)),
                        Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage("https://images.vexels.com/media/users/3/143188/isolated/preview/5f44f3160a09b51b4fa4634ecdff62dd-icone-de-dinheiro.png"),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.all(Radius.circular(25))
                            ),
                            padding: EdgeInsets.fromLTRB(17, 17, 17, 17),
                            child: Column(
                              children: <Widget>[
                                textField("Real", "R\$", realController,_realChanged),
                                Divider(),
                                textField("Dolar", "US\$", dolarController,_dolarChanged),
                                Divider(),
                                textField("Euro", "€", euroController,_euroChanged),
                                Divider(),
                                textField("Bitcoin", "฿", bitcoinController,_bitChanged),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                );
              }
          }
        },
      ),
    );
  }
}

Widget textField(String label, String prefixo, TextEditingController textEditingController,Function(String)? f){
  return TextField(
    controller: textEditingController,

    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(),
        prefixText: prefixo
    ),
    style: TextStyle(color: Colors.black, fontSize: 25, fontWeight: FontWeight.bold),
    keyboardType: TextInputType.numberWithOptions(decimal: true),
    onChanged:f,
    );
}