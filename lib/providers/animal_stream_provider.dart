import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/animal.dart';

/*
    Returns the Animals stored in Firestore for the logged in User as a stream
 */
class AnimalStreamProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _uid = FirebaseAuth.instance.currentUser.uid;

  var _allAnimals;

  Stream<List<Animal>> get allAnimals {
    if (_uid != null && _uid == FirebaseAuth.instance.currentUser.uid)
      try {
        _allAnimals = _firestore
            .collection(
                '/users/' + FirebaseAuth.instance.currentUser.uid + '/animals')
            .orderBy(
              'tagId',
            )
            .snapshots()
            .map((event) => event.docs.map((DocumentSnapshot documentSnapshot) {
                  var animal = documentSnapshot.data();
                  return Animal.animalFromJson(animal);
                }).toList());

        return _allAnimals;
      } catch (e) {
        print(e);
      }
  }
}
