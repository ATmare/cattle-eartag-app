import 'package:flutter/material.dart';

import '../screens/edit_user_settings.dart';

/*
    Class returns AppBar with custom actions for main screens
 */
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final String title;
  final List<Widget> actions;

  CustomAppBar({
    this.title,
    this.actions,
  }) : preferredSize = Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      titleSpacing: 0,
      title: Text(title),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context)
              .pushNamed(EditUserSettingsScreen.routeName, );
        },
        icon: Icon(Icons.person, color: Colors.white),
      ),
      actions: actions,
    );

    return appBar;
  }
}
