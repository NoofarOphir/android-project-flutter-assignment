import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../user_manager.dart';

void showRegisterModal(BuildContext context, email, password) async{
  final controllerValidation = TextEditingController();
  final registerKey = GlobalKey<FormState>();

  await showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Form(
        key: registerKey,
        child: SizedBox(
          height: 300,
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: Text('Please confirm your password below'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                child: TextFormField(
                  controller: controllerValidation,
                  validator: (value) {
                    return value == password ? null : 'Passwords must match';
                  },
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (registerKey.currentState!.validate()) {
                    _signup(context, email, password);
                  }
                  controllerValidation.clear();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child: Text(
                  'Confirm',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _signup(BuildContext context, email, password) async {
  await CurrentUser.instance().signUp(email, password);
  Navigator.of(context)..pop()..pop();
}