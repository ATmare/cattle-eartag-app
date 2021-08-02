import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:enum_to_string/enum_to_string.dart';

import '../providers/animals_provider.dart';
import '../models/animal.dart';
import '../utils/custom_icons.dart';
import '../screens/edit_animal_screen.dart';

/*
    Class represents a row with animal data which is rendered in animal_list
 */
class AnimalItem extends StatelessWidget {
  const AnimalItem({
    Key key,
    @required this.animal,
  }) : super(key: key);

  final Animal animal;

  IconData _getIcon(Animal animal) {
    if (animal.category != null) {
      if (animal.category == AnimalCategory.Stier ||
          animal.category == AnimalCategory.Ochs ||
          animal.category == AnimalCategory.Jungrind ||
          animal.category == AnimalCategory.Kalb) {
        return cow_male;
      } else if (animal.category == AnimalCategory.Kuh ||
          animal.category == AnimalCategory.Kalbin) {
        return cow_female;
      }
    }
    return cow_female;
  }

  ListTile _buildListTile(BuildContext context, Widget leadingIcon,
      List<Widget> titleChildren, List<Widget> subtitleChildren) {
    return ListTile(
      contentPadding:
          EdgeInsets.only(left: 0.0, top: 0.0, right: 16.0, bottom: 0.0),
      leading: Container(
        width: 60,
        alignment: Alignment.center,
        child: leadingIcon,
        decoration: BoxDecoration(
          border: Border(
            right:
                BorderSide(width: 1.0, color: Theme.of(context).primaryColor),
          ),
        ),
      ),
      title: Container(
        padding: EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: titleChildren,
        ),
      ),
      subtitle: Container(
        padding: EdgeInsets.only(bottom: 4, top: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: subtitleChildren,
        ),
      ),
    );
  }

  ListTile _buildErrorItem(BuildContext context) {
    return _buildListTile(
        context,
        CircleAvatar(
          backgroundColor: Theme.of(context).errorColor,
          radius: 20,
          child: Padding(
            padding: EdgeInsets.all(6),
            child: FittedBox(
              child: Text(
                '!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        <Widget>[
          Text(
            '${animal.tagId}',
            style: new TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
        <Widget>[
          Text('Daten fehlen')
        ]);
  }

  ListTile _buildAnimalItem(BuildContext context) {
    return _buildListTile(
      context,
      Icon(
        _getIcon(animal),
        size: 30,
      ),
      <Widget>[
        Text(
          '${animal.tagId}',
          style: new TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            if (animal.slaugther)
              Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(math.pi),
                    child: Icon(
                      cow_knife,
                      // cow_knife,
                      size: 20,
                      color: Theme.of(context).primaryColor,
                    ),
                  )),
            Chip(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity(horizontal: 0.0, vertical: -4),
              label: Text(
                EnumToString.convertToString(animal.category),
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(context).primaryTextTheme.subtitle1.color,
                ),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ],
      <Widget>[
        Text('Geb.: ' + DateFormat('dd.MM.yyyy').format(animal.dateOfBirth)),
        Text(
          animal.breed,
          style: new TextStyle(color: Colors.grey, fontSize: 14.0),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(EditAnimalScreen.routeName, arguments: animal.tagId);
      },
      child: Dismissible(
        key: ValueKey(animal.tagId),
        background: Container(
          color: Theme.of(context).errorColor,
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 30,
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          Provider.of<AnimalsProvider>(context, listen: false)
              .removeAnimal(animal.tagId);
        },
        child: Card(
          elevation: 3,
          shape: AnimalsProvider.checkAnimalCompleteness(animal)
              ? null
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(
                    color: Theme.of(context).errorColor,
                    width: 1.0,
                  ),
                ),
          margin: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: AnimalsProvider.checkAnimalCompleteness(animal)
              ? _buildAnimalItem(context)
              : _buildErrorItem(context),
        ),
      ),
    );
  }
}
