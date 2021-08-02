import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../api/person_list_firestore.dart';
import '../api/user_data_firestore.dart';
import '../providers/person_list_provider.dart';

/*
    Renders the edit user settings screen
 */
class EditUserSettingsScreen extends StatefulWidget {
  static const routeName = '/user-settings';

  @override
  _EditUserSettingsScreenState createState() => _EditUserSettingsScreenState();
}

class _EditUserSettingsScreenState extends State<EditUserSettingsScreen> {
  var _userData = UserDataFirestore();
  final _db = PersonListFirestore();
  PersonListProvider _personList;
  var _username = '';
  User _userCredentials;
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String _newValue;
  String _pw;
  bool _isLoading = false;
  bool _showLoadingMain = false;

  @override
  void initState() {
    fetchUserData();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _personList = Provider.of<PersonListProvider>(context);
    super.didChangeDependencies();
  }

  Future<String> fetchUserData() async {
    _userCredentials = await _userData.userCredentials;
    try {
      _username = await _userData.userName;
    } catch(e) {
      Navigator.of(context).pop();
      return e;
    }
    return _username;
  }

  _changeUsername() async {
    var result = await _userData.changeUsername(_newValue);
    if (result == 'success') {
      await fetchUserData();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Name erfolgreich geändert'),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.toString()),
        ),
      );
    }
  }

  _changePassword() async {
    var result = await _userData.changePassword(_newValue, _pw);
    if (result == 'success') {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwort erfolgreich geändert'),
        ),
      );
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.toString()),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  _deleteUser() async {
    var signInResult = await _userData.signIn(_userCredentials.email, _newValue);
    if (signInResult == 'success') {
      // delete all person lists without showing snackbars
      await _deleteCollection('all', showSnackbar: false);
      // delete the animal collection of the user
      await _db.deleteCollection('/users/' + FirebaseAuth.instance.currentUser.uid + '/animals');
      // delete the user from firestore's user collection
      await _db.removeUserFromFirebase();
      // delete the user from firebase auth table
      var result = await _userData.deleteUser();

      if (result != 'success') {
        setState(() {
          _showLoadingMain = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.toString()),
          ),
        );
      }
    } else {
      setState(() {
        _showLoadingMain = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(signInResult),
        ),
      );
    }
  }

  // eg path = '/buyers'
  _deleteCollection(String path, {bool showSnackbar = true}) async {
    var result = await _personList.clearList(path, false);
    if (result == null) {
      // only show snackbar for single deletions, not for all delete
      if (showSnackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Liste wurde erfolgreich gelöscht'),
          ),
        );
    } else
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.toString()),
        ),
      );
  }

  _checkCriticalAction(String expected) async {
    if (expected == 'password') {
      _deleteUser();
      _showLoadingMain = true;
    } else if (_checkEnabled(expected))
      await _deleteCollection(expected);
    else
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eingabe nicht korrekt, Löschen nicht möglich'),
        ),
      );
    Navigator.of(context).pop();
  }

  bool _checkEnabled(String expected) {
    if (expected == _newValue) {
      return true;
    }
    return false;
  }

  _deleteCollectionText(String collectionName) {
    return Text.rich(
      TextSpan(
        children: <TextSpan>[
          TextSpan(
              text: 'Achtung, durch das Löschen der Liste werden sämtliche Daten in dieser Liste gelöscht. ' +
                  'Diese Aktion kann nicht rückgängig gemacht werden. ' +
                  ' Wenn Sie diese Liste wirklich löschen möchten, geben Sie '),
          TextSpan(
              text: collectionName,
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
              text:
                  ' in das Textfeld ein und klicken Sie anschließend auf Liste löschen')
        ],
      ),
    );
  }

  _showDeleteCollectionDialog(String collectionName, String dialogTitle,
      String labelText, Text subtitle) {
    _showDialog(
        title: dialogTitle,
        submitButton: 'Liste löschen',
        labeltext: labelText,
        subtitle: subtitle,
        expected: collectionName,
        onPress: _deleteCollection);
  }

  void _emailSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('E-mail Adresse kann nicht geändert werden.'),
      ),
    );
  }

  _showNameDialog() {
    _showDialog(
        title: 'Name ändern',
        subtitle: Text('Geben Sie Ihren neuen Namen ein'),
        labeltext: 'Neuer Name',
        onPress: _changeUsername);
  }

  _showPasswordDialog() {
    _showDialog(
        title: 'Passwort ändern',
        subtitle: Text('Geben Sie ein neues Passwort ein'),
        labeltext: 'Neues Passwort',
        onPress: _changePassword);
  }

  // expected must not be null for critical action
  _showDeleteUserDialog() {
    _showDialog(
        title: 'Account löschen',
        submitButton: 'Account löschen',
        labeltext: 'Passwort',
        subtitle: Text.rich(
          TextSpan(
            children: <TextSpan>[
              TextSpan(
                  text: 'Achtung, durch Löschen Ihres Accounts werden sämtliche Personen- und Accountdaten gelöscht. ' +
                      'Diese Aktion kann nicht rückgängig gemacht werden. ' +
                      ' Wenn Sie Ihren Account wirklich löschen möchten, geben Sie Ihr'),
              TextSpan(
                  text: ' Passwort ',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextSpan(
                  text:
                      'in das Textfeld ein und klicken Sie anschließend auf Account löschen')
            ],
          ),
        ),
        expected: 'password',
        onPress: _deleteUser);
  }

  _oldPassword() {
    return [
      Text('Altes Passwort'),
      SizedBox(height: 10),
      TextField(
        controller: _passwordController,
        onChanged: (val) {
          _pw = val;
        },
        decoration: InputDecoration(
            border: OutlineInputBorder(), hintText: 'Altes Passwort'),
      ),
      SizedBox(height: 10)
    ];
  }

  _showDialog(
      {String title,
      Text subtitle,
      String labeltext,
      Function onPress,
      String expected,
      String submitButton = 'Ändern'}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return _isLoading
            ? Scaffold(body: CircularProgressIndicator())
            : AlertDialog(
                insetPadding: EdgeInsets.all(10),
                title: Text(title),
                content: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width - 20,
                      maxHeight: 300),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title == 'Passwort ändern') ..._oldPassword(),
                      subtitle,
                      SizedBox(height: 10),
                      TextField(
                        controller: _textFieldController,
                        obscureText: (expected == 'password') ? true : false,
                        onChanged: (val) {
                          _newValue = val;
                        },
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), hintText: labeltext),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text("Abbrechen"),
                    onPressed: () {
                      _textFieldController.clear();
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                      child: Text(submitButton),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        if (expected != null)
                          await _checkCriticalAction(expected);
                        else
                          await onPress();
                        _textFieldController.clear();
                        _passwordController.clear();
                        setState(() {
                          _isLoading = false;
                        });
                        // }
                      }),
                ],
              );
      },
    );
  }

  _buildName() {
    return Column(
      children: [
        Text(
          _username,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          _userCredentials.email,
          style: TextStyle(color: Colors.grey),
        )
      ],
    );
  }

  _buildTile(
      {String title,
      String subtitle,
      IconData icon,
      Function onTap,
      Function onTapWithArguments,
      String collectionName,
      String dialogTitle,
      String labelText,
      Text dialogSubtitle,
      Color color}) {
    return ListTile(
      onTap: onTap ??
          () => onTapWithArguments(
              collectionName, dialogTitle, labelText, dialogSubtitle),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: icon != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  color: color ?? Theme.of(context).primaryColor,
                )
              ],
            )
          : null,
      title: title != null
          ? Text(
              title,
              style: TextStyle(color: color ?? null),
            )
          : null,
      subtitle: subtitle != null ? Text(subtitle) : null,
    );
  }

  _buildCard(String title, List<StatelessWidget> tiles) {
    return [
      Container(
        padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
        alignment: Alignment.topLeft,
        child: Text(
          title,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          textAlign: TextAlign.left,
        ),
      ),
      Card(
        child: Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.all(15),
          child: Column(
            children: <Widget>[
              Column(
                children: <Widget>[
                  ...ListTile.divideTiles(color: Colors.grey, tiles: tiles),
                ],
              )
            ],
          ),
        ),
      )
    ];
  }

  Row _buildLogoutButton() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                primary: Theme.of(context).primaryColor),
            child: Text(
              'Logout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
            onPressed: () async {
              var signOutResult = await _userData.signOut();
              if (signOutResult == 'success') {
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Logout nicht erfolgreich' + signOutResult.toString()),
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  buildImage() {
    return Stack(fit: StackFit.loose, children: <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
              width: 140.0,
              height: 140.0,
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).primaryColor, width: 2),
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: ExactAssetImage(
                      'assets/images/icon_foreground_no_shadow_432x432.png',
                      scale: 4),
                  fit: BoxFit.cover,
                ),
              )),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    buildPage() {
      return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Theme.of(context).primaryColor,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              buildImage(),
              const SizedBox(height: 24),
              _buildName(),
              const SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    ..._buildCard('Account Einstellungen', [
                      _buildTile(
                          title: "Name",
                          subtitle: _username,
                          icon: Icons.person,
                          onTap: _showNameDialog),
                      _buildTile(
                          title: "E-Mail",
                          subtitle: _userCredentials.email,
                          icon: Icons.email,
                          onTap: _emailSnackbar),
                      _buildTile(
                          title: "Passwort",
                          subtitle: "********",
                          icon: Icons.lock,
                          onTap: _showPasswordDialog),
                      _buildTile(
                          title: "Account löschen",
                          icon: Icons.delete,
                          onTap: _showDeleteUserDialog,
                          color: Theme.of(context).errorColor),
                    ]),
                    SizedBox(
                      height: 24,
                    ),
                    ..._buildCard('Personenlisten verwalten', [
                      _buildTile(
                          title: 'Liste aller Landwirte',
                          subtitle: 'Anzahl Einträge ' + _personList.farmers.length.toString(),
                          collectionName: 'farmers',
                          dialogTitle: 'Landwirt Liste löschen',
                          labelText: 'farmers',
                          dialogSubtitle: _deleteCollectionText('farmers'),
                          onTapWithArguments: _showDeleteCollectionDialog),
                      _buildTile(
                          title: 'Liste aller Käufer',
                          subtitle: 'Anzahl Einträge '+ _personList.buyers.length.toString(),
                          collectionName: 'buyers',
                          dialogTitle: 'Käufer Liste löschen',
                          labelText: 'buyers',
                          dialogSubtitle: _deleteCollectionText('buyers'),
                          onTapWithArguments: _showDeleteCollectionDialog),
                      _buildTile(
                          title: 'Liste aller Transporter',
                          subtitle: 'Anzahl Einträge '+ _personList.transporters.length.toString(),
                          collectionName: 'transporters',
                          dialogTitle: 'Transporter Liste löschen',
                          labelText: 'transporters',
                          dialogSubtitle: _deleteCollectionText('transporters'),
                          onTapWithArguments: _showDeleteCollectionDialog),
                      _buildTile(
                          title: 'Liste aller Zwischenhändler',
                          subtitle: 'Anzahl Einträge '+ _personList.intermediaries.length.toString(),
                          collectionName: 'intermediaries',
                          dialogTitle: 'Zwischenhändler Liste löschen',
                          labelText: 'intermediaries',
                          dialogSubtitle:
                          _deleteCollectionText('intermediaries'),
                          onTapWithArguments: _showDeleteCollectionDialog),
                      _buildTile(
                          title: 'Liste aller Tierärzte',
                          subtitle: 'Anzahl Einträge '+ _personList.vets.length.toString(),
                          collectionName: 'vets',
                          dialogTitle: 'Tierarzt Liste löschen',
                          labelText: 'vets',
                          dialogSubtitle: _deleteCollectionText('vets'),
                          onTapWithArguments: _showDeleteCollectionDialog),
                      _buildTile(
                          icon: Icons.delete,
                          color: Theme.of(context).errorColor,
                          title: 'Alle Personenlisten löschen',
                          collectionName: 'all',
                          dialogTitle: 'Alle Listen löschen',
                          labelText: 'all',
                          dialogSubtitle: _deleteCollectionText('all'),
                          onTapWithArguments: _showDeleteCollectionDialog),
                    ]),
                    SizedBox(
                      height: 24,
                    ),
                    _buildLogoutButton(),
                  ],
                ),
              ),
              // buildCard(),
            ],
          ),
        ),
      );
    }
    // );

    return FutureBuilder<String>(
      future: fetchUserData(), // async work
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Scaffold(
                body: Center(
              child: CircularProgressIndicator(),
            ));
          default:
            if (snapshot.hasError)
              return Text('Error: ${snapshot.error}');
            else {
              return _showLoadingMain ? Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  )) : buildPage();
            }
        }
      },
    );
  }
}
