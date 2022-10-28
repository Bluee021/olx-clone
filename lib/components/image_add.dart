import 'package:flutter/material.dart';

class ImageAdd extends StatefulWidget {
  final Future func;
  const ImageAdd({Key? key,required this.func}) : super(key: key);

  @override
  State<ImageAdd> createState() => _ImageAddState();
}

class _ImageAddState extends State<ImageAdd> {
  @override
  Widget build(BuildContext context) {
  
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: GestureDetector(
            onTap: () {
              
            },
            child: CircleAvatar(
              backgroundColor: Colors.grey[400],
              radius: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.add_a_photo,
                    size: 40,
                    color: Colors.grey[100],
                  ),
                  Text(
                    "Adicionar",
                    style: TextStyle(color: Colors.grey[100]),
                  )
                ],
              ),
            )));
  }
}
