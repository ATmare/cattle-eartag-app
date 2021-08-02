import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/firebase_error_messages.dart';

/*
    Class handles account specific actions like sign in, sign out, changes of username, password etc.
 */
class UserDataFirestore {
  /// Returns currentUser, which holds E-Mail and uid
  get userCredentials {
    return FirebaseAuth.instance.currentUser;
  }

  /// Returns the username of the currently logged in user
  Future<String> get userName async {
    if (FirebaseAuth.instance.currentUser != null) {
      var username = await FirebaseFirestore.instance
          .collection('/users/')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get()
          .then((documentSnapshot) {
        if (documentSnapshot.data() != null)
          return documentSnapshot.data()['username'];
        else
          return Future.error('No userdata');
      });

      return username;
    }
    return null;
  }

  /// Changes the username for the logged in user to [username]
  changeUsername(String username) async {
    String email = await userCredentials.email;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set({
        'username': username,
        'email': email,
      });
      print('username changed');
      return 'success';
    } catch (error) {
      print(error);
      return error;
    }
  }

  /// Changes the password for the logged in user to the new [password]
  changePassword(String password, String oldPassword) {
    final cred = EmailAuthProvider.credential(
        email: userCredentials.email, password: oldPassword);

    return userCredentials.reauthenticateWithCredential(cred).then((value) {
      return userCredentials.updatePassword(password).then((_) {
        print("success");
        return 'success';
      }).catchError((error) {
        print("Password can't be changed" + error.toString());
        return (FirebaseErrorMsg.getSignInError(error));
        //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
      });
    }).catchError((err) {
      print("Login fail" + err.toString());
      return (FirebaseErrorMsg.getSignInError(err));
    });
  }

  /// Sends password reset mail to [email]
  Future<void> sendPasswordResetEmail(String email) async {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  /// Signs out the currently logged in user from Firebase Authentication
  Future<String> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      return 'success';
    } catch (e) {
      return e;
    }
  }

  /// Attempts to sign in a user with the given email address and password using Firebase Authentication
  signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return 'success';
    } catch (err) {
      print(err.code);
      return FirebaseErrorMsg.getSignInError(err);
    }
  }

  /// Deletes the currently logged in user from Firebase Authentication
  Future<String> deleteUser() async {
    var user = FirebaseAuth.instance.currentUser;
    return user.delete().then((_) {
      return 'success';
    }).catchError((error) {
      print("User not deleted" + error.toString());
      return (FirebaseErrorMsg.getDeleteUserError(error));
    });
  }
}
