import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {

  final String texto;
  final Color corTexto;
  final onPressed;

const CustomButton({Key? key, this.corTexto = Colors.white, this.onPressed, required this.texto}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      
      child: Text(
        this.texto,
        style: TextStyle(
            color: this.corTexto, fontSize: 20
        ),
      ),
      style: ElevatedButton.styleFrom(
        primary: Color(0xff9c27b0),
      padding: EdgeInsets.fromLTRB(32, 16, 32, 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6)
      ),
      ),
      onPressed: this.onPressed,
    );
  }
}
