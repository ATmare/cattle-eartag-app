import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/animal_list.dart';
import '../widgets/sliver_header.dart';
import '../providers/animals_provider.dart';
import '../models/animal.dart';

/*
    Renders the screen which holds the animal_list
 */
class AnimalListScreen extends StatefulWidget {
  static const routeName = '/animal-list';

  @override
  _AnimalListScreenState createState() => _AnimalListScreenState();
}

class _AnimalListScreenState extends State<AnimalListScreen> {
  var _future;

  @override
  void initState() {
    _future = Provider.of<AnimalsProvider>(context, listen: false).initAnimals;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Animal>>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<List<Animal>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return CustomScrollView(
                slivers: <Widget>[
                  SliverHeader(
                    'Erfasste Tiere',
                    'Zum Transport erfasste Tiere',
                  ),
                  SliverPadding(padding: EdgeInsets.all(10))
                ],
              );
            default:
              if (snapshot.hasError)
                return Text('Error: ${snapshot.error}');
              else
                return CustomScrollView(
                  slivers: <Widget>[
                    SliverHeader(
                        'Erfasste Tiere',
                        'Zum Transport erfasste Tiere',
                        Provider.of<AnimalsProvider>(context).animalCount),
                    AnimalList(),
                    SliverPadding(padding: EdgeInsets.all(10))
                  ],
                );
          }
        });
  }
}
