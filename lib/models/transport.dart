import 'package:cloud_firestore/cloud_firestore.dart';

import './clone_interface.dart';
import './address.dart';

/*
    Represents a Transport
 */
class Transport implements CloneMethod {
  Address loadingPlace;
  Address unloadingPlace;
  DateTime startOfTransport;
  DateTime transportDuration;
  DateTime lastFeeding;
  String licensePlate;
  Timestamp lastEdited;
  String syncUnloadingPlace;

  Transport(
      {this.loadingPlace,
      this.unloadingPlace,
      this.startOfTransport,
      this.transportDuration,
      this.lastFeeding,
      this.licensePlate,
      this.lastEdited,
      this.syncUnloadingPlace});

  Transport cloneSelf() {
    return Transport(
        loadingPlace:
            (loadingPlace == null) ? Address() : loadingPlace.cloneSelf(),
        unloadingPlace:
            (unloadingPlace == null) ? Address() : unloadingPlace.cloneSelf(),
        startOfTransport: startOfTransport,
        transportDuration: transportDuration,
        lastFeeding: lastFeeding,
        licensePlate: licensePlate,
        lastEdited: lastEdited,
        syncUnloadingPlace: syncUnloadingPlace);
  }
}
