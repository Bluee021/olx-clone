import 'package:flutter/material.dart';
import 'package:olx/models/Anuncio.dart';
import 'package:olx/view/detalhes_anuncio.dart';
import 'package:olx/view/meus_anuncios.dart';
import 'package:olx/view/novo_anuncio.dart';
import 'view/anuncios.dart';
import 'view/login.dart';

class RouteGenerator{
  
  static Route<dynamic> generateRoute(RouteSettings settings ){
    final args = settings.arguments;

    switch(settings.name){

      case '/anuncios':
        return MaterialPageRoute(
          builder: (_) => Anuncios()
        );
      case '/login':
        return MaterialPageRoute(
          builder: (_) => Login()
        );
      case '/meus-anuncios':
        return MaterialPageRoute(
          builder: (_) => MeusAnuncios()
        );
      case '/novo-anuncio':
        return MaterialPageRoute(
          builder: (_) =>  NovoAnuncio()
        );
      case '/detalhes-anuncio':
        
        return MaterialPageRoute(
          builder: (_) =>  DetalhesAnuncio(anuncio: args,)
        );
      
      default:
        _errorRota();
    }
    return generateRoute(settings);
  }

  static Route<dynamic> _errorRota(){

    return MaterialPageRoute(builder: (_){
      return Scaffold(
        appBar: AppBar(
          title: Text('Tela não encontrada'),
        ),
        body: Center(child: Text('tela nao encontrada'),)
      );
    });
  }

}