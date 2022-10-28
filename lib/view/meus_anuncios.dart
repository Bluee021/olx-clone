import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx/models/Anuncio.dart';

import '../components/item_anuncio.dart';

class MeusAnuncios extends StatefulWidget {
  @override
  _MeusAnunciosState createState() => _MeusAnunciosState();
}

class _MeusAnunciosState extends State<MeusAnuncios> {
  
  final _controller = StreamController<QuerySnapshot>.broadcast();
  String? _idUsuarioLogado;

  _recuperaDadosUsuarioLogado() async {

    FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser!;
    _idUsuarioLogado = usuarioLogado.uid;

  }
  
  Future<Stream<QuerySnapshot>> _adicionarListenerAnuncios() async {
    print("entrei");
    await _recuperaDadosUsuarioLogado();

    FirebaseFirestore db = FirebaseFirestore.instance;
    Stream<QuerySnapshot> stream = db
        .collection("meus_anuncios")
        .doc( _idUsuarioLogado )
        .collection("anuncios")
        .snapshots();

    stream.listen((dados){
      _controller.add( dados );
    });
    return stream;
  }

  _removerAnuncio(String idAnuncio){

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("meus_anuncios")
      .doc( _idUsuarioLogado )
      .collection("anuncios")
      .doc( idAnuncio )
      .delete();

     db.collection("anuncios")
          .doc( idAnuncio )
          .delete();
          
  }
  
  @override
  void initState() {
    super.initState();
    _adicionarListenerAnuncios();
  }
  
  @override
  Widget build(BuildContext context) {
    
    var carregandoDados = Center(
      child: Column(children: <Widget>[
        Text("Carregando anúncios"),
        CircularProgressIndicator()
      ],),
    );
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Meus Anúncios"),
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.pushNamed(context, "/novo-anuncio");
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _controller.stream,
        builder: (context, snapshot){
          
          switch( snapshot.connectionState ){
            case ConnectionState.none:
            case ConnectionState.waiting:
              print('carregando...');
              return carregandoDados;
              break;
            case ConnectionState.active:
            case ConnectionState.done:
              
              //Exibe mensagem de erro
              if(snapshot.hasError)
                return Text("Erro ao carregar os dados!");
              
              QuerySnapshot? querySnapshot = snapshot.data;

              return ListView.builder(
                  itemCount: querySnapshot!.docs.length,
                  itemBuilder: (_, indice){
                    
                    List<DocumentSnapshot> anuncios = querySnapshot.docs.toList();

                    DocumentSnapshot documentSnapshot = anuncios[indice];
                    
                    Anuncio anuncio = Anuncio.fromDocumentSnapshot(documentSnapshot);
                    return ItemAnuncio(
                      removed: true,
                      anuncio: anuncio,
                      onTapItem: (){},
                      onPressedRemover: (){
                        showDialog(
                            context: context,
                          builder: (context){
                              return AlertDialog(
                                title: Text("Confirmar"),
                                content: Text("Deseja realmente excluir o anúncio?"),
                                actions: <Widget>[

                                  ElevatedButton(
                                    child: Text(
                                        "Cancelar",
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                  ),

                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      shadowColor: Colors.white
                                    ),
                                    child: Text(
                                      "Remover",
                                      style: TextStyle(
                                          color: Colors.white
                                      ),
                                    ),
                                    onPressed: (){
                                      _removerAnuncio( anuncio.id );
                                      Navigator.of(context).pop();
                                    },
                                  ),


                                ],
                              );
                          }
                        );
                      },
                    );
                  }
              );
              
          }
          
          return Container();
          
        },
      ),
    );
  }
}
