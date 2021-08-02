import '../models/buyer.dart';
import '../models/farmer.dart';
import '../models/intermediary.dart';
import '../models/animal.dart';
import '../models/transport.dart';
import '../models/vet.dart';
import '../models/transporter.dart';
import '../models/address.dart';

/*
    Class is used to return empty dummy objects with empty string values.
    Avoids writing redundant code, if several classes need empty default objects.
 */

final Buyer emptyBuyer = Buyer(
  lfbisIdOrAma: null,
  firstname: '',
  lastname: '',
  address: Address(street: '', streetNr: '', city: '', postalCode: null),
  phone: '',
  email: '',
  lastTrade: null,
);

final Transport emptyTransport = Transport(
    loadingPlace: Address(street: '', streetNr: '', city: '', postalCode: null),
    unloadingPlace:
        Address(street: '', streetNr: '', city: '', postalCode: null),
    startOfTransport: null,
    transportDuration: null,
    lastFeeding: null,
    licensePlate: '');

final Farmer emptyFarmer = Farmer(
    lfbisIdOrAma: null,
    firstname: '',
    lastname: '',
    address: Address(
        street: '',
        streetNr: '',
        city: '',
        postalCode: null),
    phone: '',
    email: '',
    lastTrade: null,
    marketingAds: {});

final Intermediary emptyIntermediary = Intermediary(
  lfbisIdOrAma: null,
  firstname: '',
  lastname: '',
  address: Address(street: '', streetNr: '', city: '', postalCode: null),
  phone: '',
  email: '',
  lastTrade: null,
);

final Vet emptyVet =
  Vet(
    firstname: '',
    lastname: '',
    address: Address(
        street: '', streetNr: '', city: '', postalCode: null),
    phone: '',
    email: '',
    lastTrade: null,
  );

final Transporter emptyTransporter = Transporter(
  lfbisIdOrAma: null,
  firstname: '',
  lastname: '',
  address: Address(
      street: '',
      streetNr: '',
      city: '',
      postalCode: null),
  phone: '',
  email: '',
  lastTrade: null,
);

List<Animal> emptyAnimals = [];
