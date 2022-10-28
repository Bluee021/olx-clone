import 'package:flutter/material.dart';

import '../models/Anuncio.dart';

class ItemAnuncio extends StatelessWidget {
  Anuncio anuncio;
  VoidCallback onTapItem;
  VoidCallback onPressedRemover;
  bool removed;
  ItemAnuncio({
    Key? key,
    this.removed = false, 
    required this.anuncio,
    required this.onTapItem,
    required this.onPressedRemover
  });

  @override
  Widget build(BuildContext context) {
    print('fotos anuncios: ' + anuncio.fotos.toString());
    return GestureDetector(
      onTap:this.onTapItem,
      
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(children: <Widget>[

            SizedBox(
              width: 120,
              height: 120,
              child: Image.network(
                anuncio.fotos[0],
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // ElevatedButton(onPressed: (){
                    //   print('teste');
                    // }, child: Text('teste')),
                  Text(
                      anuncio.titulo + ' - ' + anuncio.estado + ' / ' + anuncio.categoria,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  SizedBox(height: 10,),
                  Text("${anuncio.preco} "),
                ],),
              ),
            ),
            if( this.removed) Expanded(
              flex: 1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(primary: Colors.red),
                onPressed: this.onPressedRemover,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.delete, color: Colors.white,),
                ) 
                
              ),
            )
            //botao remover

          ],),
        ),
      ),
    );
  }
}
