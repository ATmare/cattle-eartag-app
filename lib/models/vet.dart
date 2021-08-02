import './address.dart';
import './person.dart';

/*
    Represents a Vet Person
 */
class Vet extends Person {
  Vet(
      {String id,
      String firstname,
      String lastname,
      Address address,
      String phone,
      String email,
      DateTime createdAt,
      DateTime lastTrade})
      : super(
            id: id,
            firstname: firstname,
            lastname: lastname,
            address: address,
            phone: phone,
            email: email,
            createdAt: createdAt,
            lastTrade: lastTrade);

  @override
  Vet cloneSelf() {
    return Vet(
      id: id,
      firstname: firstname,
      lastname: lastname,
      address: (address == null) ? Address() : address.cloneSelf(),
      phone: phone,
      email: email,
      createdAt: createdAt,
      lastTrade: lastTrade,
    );
  }

  factory Vet.fromJson(Map<String, dynamic> vet, documentID,
      {bool dateString = false}) {
    return Vet(
        id: documentID ?? DateTime.now().toString(),
        firstname: vet['firstname'],
        lastname: vet['lastname'],
        lastTrade: vet['lastTrade'] != null
            ? (dateString
                ? DateTime.parse(vet['lastTrade'])
                : (vet['lastTrade']).toDate())
            : null,
        createdAt: vet['createdAt'] != null
            ? (dateString
                ? DateTime.parse(vet['createdAt'])
                : (vet['createdAt']).toDate())
            : null,
        phone: vet['phone'],
        email: vet['email'],
        address: Address(
          street: vet['address']['street'],
          streetNr: vet['address']['streetNr'],
          postalCode: vet['address']['postalCode'],
          city: vet['address']['city'],
        ));
  }
}
