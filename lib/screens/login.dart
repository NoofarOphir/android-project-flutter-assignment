import 'package:flutter/material.dart';
import 'package:hello_me/screens/register.dart';
import 'package:hello_me/user_manager.dart';

class CustomForm extends StatelessWidget {
  CustomForm({Key? key}) : super(key: key);

  final _controllerEmail = TextEditingController();
  final _controllerPassword = TextEditingController();

  final _loginErrorSnackBar = const SnackBar(
      content: Text('There was an error logging into the app')
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Text('Welcome to Startup Names Generator, please log in below'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: _controllerEmail,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                hintText: 'Enter email',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: _controllerPassword,
              obscureText: true,
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter password',
              ),
            ),
          ),
          TextButton(
            onPressed: CurrentUser.instance().status == Status.authenticating ? null : () {
              _login(context);
              _clearForm();
            },
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: _buttonShape(),
                fixedSize: _buttonSize()
            ),
            child: Text(
              'Login',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              String email = _controllerEmail.text;
              String password = _controllerPassword.text;
              showRegisterModal(context, email, password);
            },
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                shape: _buttonShape(),
                fixedSize: _buttonSize()
            ),
            child: Text(
              'New user? Click to sign up',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary
              ),
            ),
          ),
        ],
      ),
    );
  }

  RoundedRectangleBorder _buttonShape() {
    return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20)
      );
  }

  Size _buttonSize() {
    return const Size(350, 8);
  }

  void _login (BuildContext context) async{
    String email = _controllerEmail.text;
    String password = _controllerPassword.text;
    var loginResult = await CurrentUser.instance().signIn(email, password);
    if (loginResult) {
      Navigator.pop(context, true);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(_loginErrorSnackBar);
    }
  }

  void _clearForm() {
    _controllerEmail.clear();
    _controllerPassword.clear();
  }
}