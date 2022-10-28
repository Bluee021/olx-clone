import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/components/item_anuncio.dart';

import '../models/Anuncio.dart';
import '../utils/Configs.dart';

class Anuncios extends StatefulWidget {
  const Anuncios({Key? key}) : super(key: key);

  @override
  State<Anuncios> createState() => _AnunciosState();
}

class _AnunciosState extends State<Anuncios> {
  List<String> itensMenu = ['menu01', 'menu02'];
  String name = '';

    final _controler = StreamController<QuerySnapshot>.broadcast();

  List<DropdownMenuItem<String>> _listaItensDropEstados = [];
  List<DropdownMenuItem<String>> _listaItensDropCategorias = [];

  String _itemSelecionadoEstado = '';
  String _itemSelecionadoCategoria = '';

  _escolhaMenuItem(String itemEscolhido) {
    switch (itemEscolhido) {
      case 'Meus anúncios':
        Navigator.pushNamed(context, '/meus-anuncios');
        break;
      case 'Entrar / Cadastrar':
        Navigator.pushNamed(context, '/login');
        break;
      case 'Deslogar':
        _deslogarUsuario();
        break;
    }
  }


  _deslogarUsuario() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    await auth.signOut().then((value) => _verificarUsuarioLogado());
    
    Navigator.pushNamed(context, '/login');
  }

  Future _verificarUsuarioLogado() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    User? usuarioLogado = await auth.currentUser;
    setState(() {
      if (usuarioLogado == null) {
      itensMenu = ['Entrar / Cadastrar'];
      name = 'Visitante';
    } else {
      itensMenu = ['Meus anúncios', 'Deslogar'];
      name = usuarioLogado.displayName!;
    }
    });
  }

  _carregarItensDropdown(){

    //Categorias
    _listaItensDropCategorias = Configuracoes.getCategorias();
    _itemSelecionadoCategoria = _listaItensDropCategorias[0].value!;
    //Estados
    _listaItensDropEstados = Configuracoes.getEstados();
    _itemSelecionadoEstado = _listaItensDropEstados[0].value!;

  }
  Future<Stream<QuerySnapshot>> _filtrarAnuncios() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Query query = db.collection('anuncios');
    
    if(_itemSelecionadoEstado != ""){
      query = query.where("estado", isEqualTo: _itemSelecionadoEstado);
    print('entrei: ' + _itemSelecionadoEstado);

    }
    if(_itemSelecionadoCategoria != ""){
      query = query.where("categoria", isEqualTo: _itemSelecionadoCategoria);
      print('entrei: ' + _itemSelecionadoCategoria);


    }

    Stream<QuerySnapshot> stream = query.snapshots();

    stream.listen((dados){
      _controler.add(dados);
    });

    return stream;
  }

   Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {

    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("anuncios")
        .snapshots();

    stream.listen((dados){
      _controler.add(dados);
    });

    return stream;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _verificarUsuarioLogado();
    _carregarItensDropdown();
    _adicionarListenerAnuncios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(
              title: Text('OLX -   Olá ${name}'),
              elevation: 0,
              actions: [
                PopupMenuButton<String>(
                    onSelected: _escolhaMenuItem,
                    itemBuilder: (context) {
                      return itensMenu.map((String item) {
                        return PopupMenuItem<String>(
                          value: item,
                          child: Text(item),
                        );
                      }).toList();
                    })
              ],
            ),
            body:Container(

        child: Column(children: <Widget>[
          
          Row(children: <Widget>[

            Expanded(
              child: DropdownButtonHideUnderline(
                  child: Center(
                    child: DropdownButton(
                      iconEnabledColor: Color(0xff9c27b0),
                      value: _itemSelecionadoEstado,
                      items: _listaItensDropEstados,
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.black
                      ),
                      onChanged: (estado){
                        
                        setState(() {
                          _itemSelecionadoEstado = estado.toString();
                          _filtrarAnuncios();
                        });
                      },
                    ),
                  )
              ),
            ),

            Container(
              color: Colors.grey[200],
              width: 2,
              height: 60,
            ),

            Expanded(
              child: DropdownButtonHideUnderline(
                  child: Center(
                    child: DropdownButton(
                      iconEnabledColor: Color(0xff9c27b0),
                      value: _itemSelecionadoCategoria,
                      items: _listaItensDropCategorias,
                      style: TextStyle(
                          fontSize: 22,
                          color: Colors.black
                      ),
                      onChanged: (categoria){
                        setState(() {
                          _itemSelecionadoCategoria = categoria.toString();
                          _filtrarAnuncios();
                        });
                        
                      },
                    ),
                  )
              ),
            )
          ],),
          //Listagem de anúncios
          StreamBuilder<QuerySnapshot>(
            stream: _controler.stream,
            builder: (context, snapshot){
              switch( snapshot.connectionState ){
                case ConnectionState.none:
                case ConnectionState.waiting:
                  return CircularProgressIndicator();
                  break;
                case ConnectionState.active:
                case ConnectionState.done:
                  print('dados: ' + snapshot.data.toString());
                  if(snapshot.hasError){
                    return Text("Erro ao carregar os dados!");
                  }

                  if(snapshot.hasData != null){
                    var querySnapshot =
                        snapshot.data;

                  if( querySnapshot!.docs.length == 0 ){
                    return Container(
                      padding: EdgeInsets.all(25),
                      child: Text("Nenhum anúncio! :( ", style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),),
                    );
                  }

                  return Expanded(
                    child: ListView.builder(
                        itemCount: querySnapshot.docs.length,
                        itemBuilder: (_, indice){
                            
                          List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();
                          DocumentSnapshot documentSnapshot = anuncios[indice];
                          Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);

                          return ItemAnuncio(
                            anuncio: anuncio,
                            onPressedRemover: (){},
                            onTapItem: (){
                                  print('teste');
                              Navigator.pushNamed(context, '/detalhes-anuncio', arguments: anuncio);
                            },
                          );

                        }
                    ),
                  );


                  }               
                                }
              return Container();
            },
          )
        ],),
      ),);
  }
}
