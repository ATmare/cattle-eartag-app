import 'package:flutter/material.dart';

import '../utils/custom_swatches.dart';

/*
    Class includes registration / login form and cow background image. Class is rendered on auth_screen
 */
class AuthForm extends StatefulWidget {
  final bool isLoading;
  final void Function(
    String email,
    String password,
    String userName,
    bool isLogin,
    BuildContext ctx,
  ) submitFn;

  final Function(String email, BuildContext ctx) resetPassword;

  AuthForm(
    this.submitFn,
    this.isLoading,
    this.resetPassword,
  );

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _userEmail = '';
  var _userName = '';
  var _userPassword = '';

  void _trySubmit() {
    final isValid = _formKey.currentState.validate();
    FocusScope.of(context).unfocus();

    if (isValid) {
      _formKey.currentState.save();
      widget.submitFn(
        _userEmail.trim(),
        _userPassword.trim(),
        _userName.trim(),
        _isLogin,
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var borderStyle = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.green, width: 0.0),
      borderRadius: const BorderRadius.all(
        const Radius.circular(15.0),
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            'Tiertransporter',
            style: TextStyle(
                color: Colors.white,
                letterSpacing: 1,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(
            'RINDER',
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 8,
              color: Colors.white,
            ),
          ),
        ),
        Stack(
          children: [
            Container(
              width: 200,
              height: 200,
              child: CircleAvatar(
                backgroundColor: customColor.shade800,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('assets/images/svg_cow.png'),
                ),
              ),
            ),
          ],
        ),
        Card(
          elevation: 0,
          color: Color.fromRGBO(255, 255, 255, 0),
          margin: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      key: ValueKey('email'),
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                      enableSuggestions: false,
                      validator: (value) {
                        if (value.isNotEmpty && !value.contains('@')) {
                          return 'Bitte geben Sie eine gültige E-Mail Addresse an';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        border: borderStyle,
                        enabledBorder: borderStyle,
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'E-Mail Adresse',
                      ),
                      onChanged: (value) {
                        _userEmail = value;
                      },
                      onSaved: (value) {
                        _userEmail = value;
                      },
                    ),
                    if (!_isLogin)
                      SizedBox(
                        height: 10,
                      ),
                    if (!_isLogin)
                      TextFormField(
                        key: ValueKey('username'),
                        autocorrect: true,
                        textCapitalization: TextCapitalization.words,
                        enableSuggestions: false,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: borderStyle,
                          enabledBorder: borderStyle,
                          hintText: 'Username',
                        ),
                        onSaved: (value) {
                          _userName = value;
                        },
                      ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      key: ValueKey('password'),
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: borderStyle,
                          enabledBorder: borderStyle,
                          hintText: 'Passwort'),
                      obscureText: true,
                      onSaved: (value) {
                        _userPassword = value;
                      },
                    ),
                    SizedBox(height: 12),
                    if (widget.isLoading)
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    if (!widget.isLoading)
                      Row(children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 20),
                              primary: Colors.white,
                            ),
                            child: Text(
                              _isLogin ? 'Einloggen' : 'Registrieren',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            onPressed: _trySubmit,
                          ),
                        ),
                      ]),
                    if (!widget.isLoading)
                      TextButton(
                        style: TextButton.styleFrom(primary: Colors.white),
                        child: Text(_isLogin
                            ? 'Neuen Account anlegen'
                            : 'Ich habe bereits einen Account'),
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                      ),
                    if (!widget.isLoading && _isLogin)
                      TextButton(
                          style: TextButton.styleFrom(primary: Colors.white),
                          child: Text('Passwort vergessen'),
                          onPressed: () {
                            widget.resetPassword(_userEmail.trim(), context);
                          })
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
