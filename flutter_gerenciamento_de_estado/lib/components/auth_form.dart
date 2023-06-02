import 'package:flutter/material.dart';
import 'package:flutter_gerenciamento_de_estado/exceptions/auth_exception.dart';
import 'package:provider/provider.dart';

import '../models/auth.dart';
enum AuthMode{signup,login}

class AuthForm extends StatefulWidget {
  const AuthForm({Key? key}) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  AuthMode _authMode = AuthMode.login;
  final Map<String, String> _authData ={
    'email':'',
    'password':'',
  };

  bool _isLogin() => _authMode == AuthMode.login;
  bool _isSignup() => _authMode == AuthMode.signup;
  double _myOpacity = 0.0;

  void _switchAuthMode(){
    setState(() {
      if(_isLogin()){
        _authMode = AuthMode.signup;
        _myOpacity = 1.0;
      }
      else{
        _authMode = AuthMode.login;
        _myOpacity =0.0;
      }
      
    });
  }

  void _showErrorDialog(String msg){
   showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
    title: const Text('Ocorreu um Erro') ,
    content: Text(msg),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Fechar'),)
    ],
    ),
   );
  }

  Future<void> _submit() async{
    final isvalid = _formKey.currentState?.validate() ?? false;

    if(!isvalid){
      return;
    }

    setState(() => _isLoading = true);

    _formKey.currentState?.save();
    Auth auth = Provider.of(context,listen: false);
    
    try{
        if(_isLogin()){
        //login
        await auth.login(_authData['email']!, _authData['password']!,);
        _authData.clear();
        _passwordController.clear();
        _formKey.currentState?.reset();
    }else{
        //Registrar
        await auth.signup(_authData['email']!, _authData['password']!,);
        _authData.clear();
        _passwordController.clear();
        _formKey.currentState?.reset();
    }
    }on AuthException catch(error){
     _showErrorDialog(error.toString());
    } catch(error){
      _showErrorDialog('Ocorreu um erro inesperado');
    }

    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),

      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        width: deviceSize.width * 0.75,
        height: _isLogin() ? 310 : 400,
        child: Form(
          key:  _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (email) => _authData['email'] = email ?? '',
                validator: (emaiL){
                  final email = emaiL ?? '';
                  if(email.trim().isEmpty || !email.contains('@')){
                    return 'Informe um email valido';
                  }
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Senha'),
                keyboardType: TextInputType.emailAddress,
                obscureText: true,
                controller: _passwordController,
                onSaved: (password) => _authData['password'] = password ?? '',
                validator: (passWord){
                  final password = passWord ?? '';
                  if(password.isEmpty || password.length < 5){
                   return 'Informe uma senha valida';
                  }

                },
              ),
              
              AnimatedOpacity(
                opacity: _myOpacity,
                duration: const Duration(seconds: 2),
                curve: Curves.ease,
                child :TextFormField(
                decoration: const InputDecoration(labelText: 'Confirmar Senha'),
                keyboardType: TextInputType.emailAddress,
                obscureText: true,
                validator: _isLogin() ? null :(passWord){
                  final password = passWord ?? '';
                  if(password != _passwordController.text){
                    return 'Senhas Informadas não conferem';
                  }
                  return null;
                },
              ),
                 ),
              
              const SizedBox(height:20,),

              if(_isLoading)
              const CircularProgressIndicator()
              else
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 8,
                  ),

                ),
                child: Text(
                  _authMode == AuthMode.login ? 'Entrar' : 'Cadastrar',
                  ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                      _isLogin() ? 'DESEJA REGISTRAR?': 'JÁ POSSUI CONTA?',
                      ),
                  )
                  
            ],
          ),
        ),
      ),
    );
    
  }
}