import '../models/buyer.dart';
import '../models/farmer.dart';
import '../models/intermediary.dart';
import '../models/animal.dart';
import '../models/transport.dart';
import '../models/vet.dart';
import '../models/transporter.dart';
import '../models/address.dart';
import '../models/country_codes.dart';

/*
    Class is used to provide dummy data for animals, farmers, buyers, etc.
    By importing only one class developers can quickly get lists of the needed
    data without creating them new.
*/
final List<Buyer> dummyBuyers = [
  Buyer(
    lfbisIdOrAma: 54545454,
    firstname: 'Bernhard',
    lastname: 'Brett',
    address: Address(
        street: 'Bockelsiedlung',
        streetNr: '17',
        city: 'Salzburg',
        postalCode: 5020),
    phone: '0043 699 44 44 44 44',
    email: 'bernhard.brett@gmail.com',
    lastTrade: null,
  ),
  Buyer(
    lfbisIdOrAma: 93217645,
    firstname: 'Cornelia',
    lastname: 'Cobold',
    address: Address(
        street: 'Cornsteinstrasse',
        streetNr: '18',
        city: 'Salzburg',
        postalCode: 5020),
    phone: '0043 699 77 88 99 00',
    email: 'cornelia.cobold@gmail.com',
    lastTrade: null,
  ),
  Buyer(
    lfbisIdOrAma: 91133267,
    firstname: 'Günther',
    lastname: 'Gürteltier',
    address: Address(
        street: 'Guggenheimerweg',
        streetNr: '2',
        city: 'Salzburg',
        postalCode: 5020),
    phone: '0043 699 12 23 45 78',
    email: 'guenther.guerteltier@gmail.com',
    lastTrade: null,
  ),
];

final Buyer dummyBuyer = dummyBuyers[0];

final Transport dummyTransport = Transport(
    loadingPlace: Address(
        street: 'Hummersiedlung',
        streetNr: '42',
        city: 'Salzburg',
        postalCode: 5020),
    unloadingPlace: Address(
        street: 'Bockelsiedlung',
        streetNr: '17',
        city: 'Salzburg',
        postalCode: 5020),
    startOfTransport: DateTime.now(),
    transportDuration: DateTime.now(),
    lastFeeding: DateTime.now(),
    licensePlate: 'SL 433 UU');

final List<Farmer> dummyFarmers = [
  Farmer(
      lfbisIdOrAma: 1234567,
      firstname: 'Hans',
      lastname: 'Huber',
      address: Address(
          street: 'Hummersiedlung',
          streetNr: '42',
          city: 'Salzburg',
          postalCode: 5020),
      phone: '0043 699 11 11 11 11',
      email: 'hans.huber@gmail.com',
      lastTrade: null,
      marketingAds: {
        MarketingLabel.Bio: '987678',
        MarketingLabel.AMAGuetesiegel: '',
        MarketingLabel.GVOFrei: '',
        MarketingLabel.Other: 'freilebend'
      }),
  Farmer(
      lfbisIdOrAma: 9821006,
      firstname: 'Emilia',
      lastname: 'Erntereich',
      address: Address(
          street: 'Eierfeldensiedlung',
          streetNr: '86',
          city: 'Salzburg',
          postalCode: 5020),
      phone: '0043 699 98 76 54 32',
      email: 'emilia.erntereich@gmail.com',
      lastTrade: null,
      marketingAds: {
        MarketingLabel.AMAGuetesiegel: '',
        MarketingLabel.Other: 'Eigenzucht'
      }),
  Farmer(
      lfbisIdOrAma: 8376902,
      firstname: 'Felix',
      lastname: 'Feuerstein',
      address: Address(
          street: 'Freiheitsgrade',
          streetNr: '9',
          city: 'Salzburg',
          postalCode: 5020),
      phone: '0043 699 76 67 43 34',
      email: 'felix.feuerstein@gmail.com',
      lastTrade: null,
      marketingAds: {
        MarketingLabel.Bio: '39485',
        MarketingLabel.AMAGuetesiegel: '',
      })
];

final Farmer dummyFarmer = dummyFarmers[0];

final List<Intermediary> dummyIntermediaries = [
  Intermediary(
    lfbisIdOrAma: 87654321,
    firstname: 'Ingrid',
    lastname: 'Irnberger',
    address: Address(
        street: 'Ingeborgstrasse',
        streetNr: '14',
        city: 'Salzburg',
        postalCode: 5020),
    phone: '0043 699 00 00 43 11',
    email: 'ingrid.irnberger@gmail.com',
    lastTrade: null,
  ),
  Intermediary(
    lfbisIdOrAma: 57309765,
    firstname: 'Doris',
    lastname: 'Doringer',
    address: Address(
        street: 'Dattelstraße',
        streetNr: '14',
        city: 'Salzburg',
        postalCode: 5020),
    phone: '0043 699 33 33 33 33',
    email: 'doris.doringer@gmail.com',
    lastTrade: null,
  ),
];

final Intermediary dummyIntermediary = dummyIntermediaries[1];

final List<Vet> dummyVets = [
  Vet(
    firstname: 'Anton',
    lastname: 'Almer',
    address: Address(
        street: 'Almerweg', streetNr: '3', city: 'Oberalm', postalCode: 5411),
    phone: '0043 699 22 22 22 22',
    email: 'anton.almer@gmail.com',
    lastTrade: null,
  ),
  Vet(
    firstname: 'Torben',
    lastname: 'Tierlieb',
    address: Address(
        street: 'Tunlichstraße',
        streetNr: '5',
        city: 'Tuttheim',
        postalCode: 5411),
    phone: '0043 699 87 45 98 12',
    email: 'torben.tierlieb@gmail.com',
    lastTrade: null,
  )
];

Vet dummyVet = dummyVets[0];

final Transporter dummyTransporter = Transporter(
  lfbisIdOrAma: 76576576,
  firstname: 'Tobias Elias',
  lastname: 'Trabherr-Mayerhofer',
  address: Address(
      street: 'Treppelweg',
      streetNr: '19b',
      city: 'Salzburg',
      postalCode: 5020),
  phone: '0043 699 55 55 55 55',
  email: 'tobi.trabherr@gmail.com',
  lastTrade: null,
);

List<Animal> dummyAnimals = [
  Animal(
      tagId: 'AT123456789',
      category: AnimalCategory.Stier,
      dateOfBirth: DateTime.utc(2012, 11, 9),
      placeOfBirth: CountryCode('AT'),
      placeOfRearing: [CountryCode('AT'), CountryCode('DE'), CountryCode('PL')],
      purchaseDate: DateTime.utc(2013, 11, 9),
      breed: 'Fleckvieh',
      additionalInfos: 'Medikamente',
      slaugther: true),
  Animal(
    tagId: 'AT589822165',
    category: AnimalCategory.Kuh,
    dateOfBirth: DateTime.utc(2016, 10, 3),
    placeOfBirth: CountryCode('AT'),
    placeOfRearing: [CountryCode('AT')],
    purchaseDate: DateTime.utc(2016, 10, 3),
    breed: 'Braunvieh',
    additionalInfos: 'Bio',
  ),
  Animal(
    tagId: 'AT888574431',
    category: AnimalCategory.Kalb,
    dateOfBirth: DateTime.utc(2009, 03, 12),
    placeOfBirth: CountryCode('DE'),
    placeOfRearing: [CountryCode('AT')],
    purchaseDate: DateTime.utc(2013, 10, 9),
    breed: 'Pinzgauer',
    additionalInfos: 'Wartezeit',
  ),
  Animal(
      tagId: 'AT987654321',
      category: AnimalCategory.Jungrind,
      dateOfBirth: DateTime.utc(2009, 03, 12),
      placeOfBirth: CountryCode('DE'),
      placeOfRearing: [CountryCode('AT')],
      purchaseDate: DateTime.utc(2013, 10, 9),
      breed: 'Pinzgauer',
      additionalInfos: 'Wartezeit',
      slaugther: true),
  Animal(
    tagId: 'AT887766554',
    category: AnimalCategory.Kalbin,
    dateOfBirth: DateTime.utc(2018, 03, 12),
    placeOfRearing: [CountryCode('AT')],
    purchaseDate: DateTime.utc(2019, 10, 9),
    breed: 'Fleckvieh',
    additionalInfos: 'Bio',
  ),
  Animal(
      tagId: 'AT224455667',
      category: AnimalCategory.Stier,
      dateOfBirth: DateTime.utc(2021, 04, 12),
      placeOfBirth: CountryCode('AT'),
      placeOfRearing: [CountryCode('AT')],
      purchaseDate: DateTime.utc(2021, 04, 9),
      breed: 'Braunvieh',
      additionalInfos: 'Medikamente',
      slaugther: true),
  Animal(
    tagId: 'AT999989997',
    category: AnimalCategory.Kuh,
    dateOfBirth: DateTime.utc(2007, 04, 12),
    placeOfBirth: CountryCode('AT'),
    placeOfRearing: [CountryCode('AT')],
    purchaseDate: DateTime.utc(2007, 04, 9),
    breed: 'Fleckvieh',
  ),
  Animal(
    tagId: 'AT888688888',
    category: AnimalCategory.Ochs,
  ),
  Animal(
      tagId: 'DK03327301486',
      category: AnimalCategory.Kalbin,
      dateOfBirth: DateTime.utc(2000, 03, 11),
      placeOfBirth: CountryCode('DK'),
      placeOfRearing: [CountryCode('AT'), CountryCode('DK')],
      purchaseDate: DateTime.utc(2007, 01, 1),
      breed: 'Braunvieh',
      additionalInfos: 'Medikamente',
      slaugther: true),
  Animal(
      tagId: 'DE1272431125',
      category: AnimalCategory.Kuh,
      dateOfBirth: DateTime.utc(2002, 09, 04),
      placeOfBirth: CountryCode('DE'),
      placeOfRearing: [CountryCode('AT'), CountryCode('DE')],
      purchaseDate: DateTime.utc(2012, 07, 7),
      breed: 'Fleckvieh',
      slaugther: true),
  Animal(
      tagId: 'AT684431669',
      category: AnimalCategory.Kuh,
      dateOfBirth: DateTime.utc(2019, 05, 09),
      placeOfBirth: CountryCode('AT'),
      placeOfRearing: [CountryCode('AT')],
      purchaseDate: DateTime.utc(2015, 03, 7),
      breed: 'Fleckvieh',
      slaugther: true),
];

var dummyAnimalsJSON = [
  {
    'tagId': 'AT123456789',
    'category': 'Stier',
    'dateOfBirth': null,
    'placeOfBirth': null,
    'placeOfRearing': null,
    'purchaseDate': null,
    'breed': 'Stier',
    'additionalInfos': null,
  },
  {
    'tagId': 'aaaaaaaaa',
    'category': 'Stier',
    'dateOfBirth': null,
    'placeOfBirth': null,
    'placeOfRearing': null,
    'purchaseDate': null,
    'breed': 'Stier',
    'additionalInfos': null,
  },

];
