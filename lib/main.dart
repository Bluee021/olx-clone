
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:olx/routeGenerator.dart';
import 'package:olx/view/anuncios.dart';
import 'package:olx/view/login.dart';

 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp();
  
  runApp(MaterialApp(
    title: 'OLX',
    debugShowCheckedModeBanner: false,
    home: Anuncios(),
    theme: ThemeData(
      primaryColor: Colors.purple,
      primarySwatch: Colors.purple, 
    ),
    initialRoute: '/',
    onGenerateRoute: RouteGenerator.generateRoute,
  ));
 
 }
