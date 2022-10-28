import 'dart:io';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:olx/components/input.dart';
import 'package:olx/models/Anuncio.dart';
import 'package:olx/utils/Configs.dart';
import 'package:validadores/Validador.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:olx/components/custom_button.dart';

class NovoAnuncio extends StatefulWidget {
  @override
  _NovoAnuncioState createState() => _NovoAnuncioState();
}

class _NovoAnuncioState extends State<NovoAnuncio> {
  final _formKey = GlobalKey<FormState>();
  List<File> _listImages = [];
  List<DropdownMenuItem<String>> _listaItensDropEstados = [];
  List<DropdownMenuItem<String>> _listaItensDropCategorias = [];
  
  List<String> urls = [];

  Anuncio? anuncio;
  
  String _itemSelecionadoEstado = '';
  String _itemSelecionadoCategoria = '';

  BuildContext? _dialogContext;

  TextEditingController _controllerTitulo = TextEditingController();
  TextEditingController _controllerPreco = TextEditingController();
  TextEditingController _controllerDescricao = TextEditingController();
  TextEditingController _controllerTelefone = TextEditingController();

  _selecionarImagemGaleria() async {
   
    final imagem = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imagem == null) return;
    final imageTemp = File(imagem.path);

      setState(() {
        _listImages.add( imageTemp );
      });
    
  }

  _abrirDialog(BuildContext context){

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context){
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: 20,),
              Text("Salvando anúncio...")
            ],),
          );
        }
    );

  }

   _salvarAnuncio() async {

    _abrirDialog(context);
    //Upload imagens no Storage
    
    await _uploadImagens().then((value) async{
       FirebaseAuth auth = FirebaseAuth.instance;
    User usuarioLogado = await auth.currentUser!;
    String idUsuarioLogado = usuarioLogado.uid;

    FirebaseFirestore db = FirebaseFirestore.instance;
    db.collection("meus_anuncios")
      .doc( idUsuarioLogado )
      .collection("anuncios")
      .doc( anuncio!.id )
      .set( anuncio!.toMap()).then((_){

       db.collection("anuncios")
          .doc( anuncio!.id )
          .set( anuncio!.toMap() ).then((_){

            Navigator.pop(context);
            Navigator.pop(context);

        });
    });
    });
    
    //Salvar anuncio no Firestore
   
  }

    Future _recuperarUrl(TaskSnapshot snap) async {
    String url = '  ';
    await snap.ref.getDownloadURL().then((value){
      url = value;
    });
      return url;
      
  }

 
  Future _uploadImagens() async {

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference pastaRaiz = storage.ref();
    
    for( var imagem in _listImages ){
      String url = '';
      String nomeImagem = DateTime.now().millisecondsSinceEpoch.toString();
      Reference arquivo = pastaRaiz
          .child("meus_anuncios")
          .child( anuncio!.id )
          .child( nomeImagem );

      UploadTask uploadTask = arquivo.putFile(imagem);
      await uploadTask.then((TaskSnapshot snapshot) async{
       
        String url = await _recuperarUrl(snapshot);
        anuncio!.fotos.add( url);

      });
      
    }
        print('url anuncio : ' +anuncio!.fotos.toString());

  }

  _carregarItensDropdown(){

    //Categorias
    _listaItensDropCategorias = Configuracoes.getCategorias();
    //Estados
    _listaItensDropEstados = Configuracoes.getEstados();
    
    setState(() {
      _itemSelecionadoCategoria = _listaItensDropCategorias[0].value!;
      _itemSelecionadoEstado = _listaItensDropEstados[0].value!;
    });
  }
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _carregarItensDropdown();
    
    
  }
  @override
  Widget build(BuildContext context) {
    anuncio = Anuncio();
    return Scaffold(
      appBar: AppBar(
        title: Text("Novo anúncio"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FormField<List>(
                  initialValue: _listImages,
                  validator: (images) {
                    if (images!.length == 0) {
                      return "Necessário selecionar imagem";
                    }
                    return null;
                  },
                  builder: ((field) {
                    return Column(
                      children: [
                        Container(
                            height: 100,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _listImages.length + 1,
                                itemBuilder: ((context, index) {
                                  if (index == 0) {
                                    return Padding(
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 8),
                                        child: GestureDetector(
                                            onTap: () {
                                              _selecionarImagemGaleria();
                                            },
                                            child: CircleAvatar(
                                              backgroundColor: Colors.grey[400],
                                              radius: 50,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: <Widget>[
                                                  Icon(
                                                    Icons.add_a_photo,
                                                    size: 40,
                                                    color: Colors.grey[100],
                                                  ),
                                                  Text(
                                                    "Adicionar",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[100]),
                                                  )
                                                ],
                                              ),
                                            )));
                                  }
                                  return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: GestureDetector(
                                  onTap: (){
                                    showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                            Image.file( _listImages[index - 1] ),
                                            TextButton(
                                              child: Text("Excluir"),
                                              style: TextButton.styleFrom(
                                                primary: Colors.red
                                              ),
                                              onPressed: (){
                                                setState(() {
                                                  _listImages.removeAt(index - 1);
                                                  Navigator.of(context).pop();
                                                });
                                              },
                                            )
                                          ],),
                                        )
                                    );
                                  },
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundImage: FileImage( _listImages[index - 1] ),
                                    child: Container(
                                      color: Color.fromRGBO(255, 255, 255, 0.4),
                                      alignment: Alignment.center,
                                      child: Icon(Icons.delete, color: Colors.red,),
                                    ),
                                  ),
                                ),
                              );
                                }))),
                        if (field.hasError)
                          Container(
                            child: Text(
                              '[${field.errorText}]',
                              style: TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          )
                      ],
                    );
                  }),
                ),
                Row(children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: DropdownButtonFormField(
                      value: _itemSelecionadoEstado,
                      hint: Text("Estados"),
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20
                      ),
                      items: _listaItensDropEstados,
                      onSaved: (value){
                        anuncio!.estado = value.toString();
                      },
                      validator: (valor){
                        return Validador()
                            .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                            .valido(valor.toString());
                      },
                      onChanged: (valor){
                        setState(() {
                          _itemSelecionadoEstado = valor.toString();
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: DropdownButtonFormField(
                      value: _itemSelecionadoCategoria,
                      hint: Text("Categorias"),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20
                      ),
                      items: _listaItensDropCategorias,
                       onSaved: (value){
                        anuncio!.categoria = value.toString();
                      },
                      validator: (valor){
                        return Validador()
                            .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                            .valido(valor.toString());
                      },
                      onChanged: (valor){
                        setState(() {
                          _itemSelecionadoCategoria = valor.toString();
                        });
                      },
                    ),
                  ),
                ),
              ],),
                Padding(
                padding: EdgeInsets.only(bottom: 15, top: 15),
                child: Input(
                  controller: _controllerTitulo,
                  hint: "Título",
                  onSaved: (value){
                        anuncio!.titulo = value.toString();
                      },
                  validator: (valor){
                    return Validador()
                        .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                        .valido(valor);
                  },
                ),
              ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Input(
                    controller: _controllerPreco,
                    hint: "Preço",
                    type: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      
                      RealInputFormatter(moeda: true)
                    ],
                    onSaved: (value){
                        anuncio!.preco = value.toString();
                      },
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Input(
                    hint: "Telefone",
                    controller: _controllerTelefone,
                    type: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      TelefoneInputFormatter()
                    ],
                    onSaved: (value){
                        anuncio!.telefone = value.toString();
                      },
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .valido(valor);
                    },
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: Input(
                    controller: _controllerDescricao,
                    hint: "Descrição (200 caracteres)",
                    maxLines: 1,
                    onSaved: (value){
                        anuncio!.descricao = value.toString();
                      },
                    validator: (valor){
                      return Validador()
                          .add(Validar.OBRIGATORIO, msg: "Campo obrigatório")
                          .maxLength(200, msg: "Máximo de 200 caracteres")
                          .valido(valor);
                    },
                  ),
                ),
                CustomButton(
                  texto: "Cadastrar anúncio",
                  onPressed: ()async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      _dialogContext = context;
                      await _salvarAnuncio();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
