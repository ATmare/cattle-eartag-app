import 'package:flutter/material.dart';

import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../widgets/auth_form.dart';
import '../models/animal.dart';
import '../api/user_data_firestore.dart';
import '../utils/custom_swatches.dart';
import '../utils/firebase_error_messages.dart';
import '../utils/dummy_data_creator.dart';

/*
    Renders the login / registration screen
 */
class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  var _userData = UserDataFirestore();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _resetPassword(
    String email,
    BuildContext ctx,
  ) async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (email == null || email.length < 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bitte geben Sie eine gültige E-Mail Adresse an.'),
            backgroundColor: Theme.of(ctx).errorColor,
          ),
        );
      } else {
        await _userData.sendPasswordResetEmail(email);
        _showPasswordEmailSentDialog(email);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err.code);
      print(err.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(FirebaseErrorMsg.getSignInError(err)),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPasswordEmailSentDialog(String email) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: Text("Passwort vergessen"),
          content: Text('Eine E-Mail wurde an die angegebene Adresse ' +
              email +
              ' gesendet um Ihr Passwort zurückzusetzen. Bitte überprüfen Sie auch Ihren Spam-Ordner.'),
          actions: <Widget>[
            TextButton(
              child: new Text("Verstanden"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _submitAuthForm(
    String email,
    String password,
    String username,
    bool isLogin,
    BuildContext ctx,
  ) async {
    UserCredential authResult;

    try {
      setState(() {
        _isLoading = true;
      });
      if (isLogin) {
        authResult = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

      } else {
        authResult = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // creates a user collection for the user with his credentials
        await FirebaseFirestore.instance
            .collection('users')
            .doc(authResult.user.uid)
            .set({
          'username': username,
          'email': email,
        }).then((_) {
          var batch = FirebaseFirestore.instance.batch();

          var randomAnimals = DummyDataCreator().createAnimals();

          // create dummyAnimals for the newly registered user
          for (Animal a in randomAnimals) {
            var animalRef = FirebaseFirestore.instance
                .collection('/users/' + authResult.user.uid + '/animals')
                .doc();
            batch.set(animalRef, a.animalToJson());
          }

          batch.commit().then((_) {
            print('success in batch upload');
          });
        });
      }
    } on PlatformException catch (err) {
      var message =
          'Ein Fehler ist aufgetreten, bitte überprüfen Sie Ihre Eingabe!';

      if (err.message != null) {
        message = err.message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      print(err.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(FirebaseErrorMsg.getSignInError(err)),
          backgroundColor: Theme.of(ctx).errorColor,
        ),
      );

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var gradient = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [
        Theme.of(context).accentColor,
        customAccentColor.shade400,
      ],
    );

    return Scaffold(
        backgroundColor: customColor.shade400,
        body: KeyboardDismissOnTap(
            child: Container(
          decoration: BoxDecoration(gradient: gradient),
          alignment: Alignment.center,
          child: SingleChildScrollView(
            child: AuthForm(_submitAuthForm, _isLoading, _resetPassword),
          ),
        )));
  }
}
