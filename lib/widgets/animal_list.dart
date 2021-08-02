import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './animal_item.dart';
import '../utils/custom_icons.dart';
import '../providers/animals_provider.dart';

/*
    Class represents an animal_list that contains animal_items and is rendered on animal_list_screen
 */
class AnimalList extends StatefulWidget {
  @override
  _AnimalListState createState() => _AnimalListState();
}

class _AnimalListState extends State<AnimalList> {

  @override
  Widget build(BuildContext context) {
    final animalData = Provider.of<AnimalsProvider>(context);
    final animals = animalData.animals;

    return animals.isEmpty
        ? SliverToBoxAdapter(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            alignment: Alignment.bottomCenter,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Icon(
              cow_question,
              size: 140,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Text(
            'Noch keine Tiere hinzugefügt',
          ),
        ],
      ),
    )
        : SliverFixedExtentList(
      itemExtent: 76.0,
      delegate: SliverChildListDelegate(
        animals.map((animal) {
          return AnimalItem(
              animal: animal, key: ValueKey(animal.tagId));
        }).toList(),
      ),
    );

  }
}
