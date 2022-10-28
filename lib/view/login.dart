import 'package:flutter/material.dart';
import 'package:olx/components/Input.dart';
import 'package:olx/models/Usuario.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _cadastrar = false;
  TextEditingController controllerEmail = TextEditingController(text: 'mateusbluee@gmail.com');
  TextEditingController controllerName = TextEditingController(text: 'mateus');
  TextEditingController controllerPassword = TextEditingController(text: '123456');

  String _messageError = '';
  String _textButton = 'Entrar';
  
  _cadastrarUsuario(usuario) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    print('cadastrar');

      await auth.createUserWithEmailAndPassword(
      email: usuario.email, 
      password: usuario.senha
      
      ).then((firebaseUser){
        firebaseUser.user!.updateDisplayName(usuario.nome);
        // Navigator.pushReplacementNamed(context, '/');
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      });

  }
  _logarUsuario(usuario) {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signInWithEmailAndPassword(
      email: usuario.email, 
      password: usuario.senha
      ).then((fireBaseUser){
        print('logar');
        // Navigator.pushReplacementNamed(context, '/anuncios');
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }).catchError((error){
        setState(() {
          _messageError = 'Usuário não encontrado verifique os campos';
        });
      });
  }
  _validarCampos() {
    String email = controllerEmail.text;
    String password = controllerPassword.text;
    String name = controllerName.text;
    
     print('email: ' + controllerEmail.text );
     print(' senha: '+ controllerPassword.text);
    if (email.isNotEmpty && email.contains('@')) {
      
      if (password.isNotEmpty && password.length >= 6) {
        Usuario usuario = Usuario();
        usuario.email = email;
        usuario.senha = password;
        usuario.nome = name;
        if(_cadastrar){
          _cadastrarUsuario(usuario);
        }else{
          _logarUsuario(usuario);
        }
      } else {

        setState(() {
          _messageError = 'A senha precisa ter mais que 6 caracteres';
        });
      }
    } else {
      setState(() {
        _messageError = 'Digite um e-mail válido';
        
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Container(
          padding: EdgeInsets.all(16),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      "images/logo.png",
                      width: 200,
                      height: 150,
                    ),
                  ),
                  _cadastrar ? Input(
                    controller: controllerName,
                    hint: 'Nome',
                    type: TextInputType.text,
                  ) :SizedBox(), 
                  SizedBox(
                    height: _cadastrar ?  20 : 0,
                  ),
                  Input(
                    controller: controllerEmail,
                    hint: 'Email',
                    type: TextInputType.emailAddress,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Input(
                    controller: controllerPassword,
                    hint: 'Senha',
                    obscure: true,
                    maxLines: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Logar'),
                      Switch(
                          value: _cadastrar,
                          onChanged: (value) {
                            setState(() {
                              _cadastrar = value;
                              if(_cadastrar){
                                setState(() {
                                  _textButton = 'Cadastrar';
                                });
                              }else{
                                setState(() {
                                  _textButton = "Entrar";
                                });
                              }
                            });
                          }),
                      Text('Cadastrar')
                    ],
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _validarCampos();
                    },
                    child: Text(
                      _textButton,
                      style: TextStyle(
                        fontSize: 20,
                        // color: Colors.white
                      ),
                    ),
                    style:
                        ElevatedButton.styleFrom(padding: EdgeInsets.all(16)),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      _messageError,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
