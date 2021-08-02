import './address.dart';
import './person.dart';
import './ama_number.dart';

/*
    Represents an Intermediary Person
 */
class Intermediary extends Person with AmaNumber {
  Intermediary(
      {lfbisIdOrAma,
      String id,
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
            lastTrade: lastTrade) {
    initAmaNumber(lfbisIdOrAma);
  }

  @override
  Intermediary cloneSelf() {
    return Intermediary(
      lfbisIdOrAma: lfbisIdOrAma,
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

  factory Intermediary.fromJson(Map<String, dynamic> intermediary, documentID,
      {bool dateString = false}) {
    return Intermediary(
        id: documentID ?? DateTime.now().toString(),
        lfbisIdOrAma: intermediary['lfbisIdOrAma'],
        firstname: intermediary['firstname'],
        lastname: intermediary['lastname'],
        lastTrade: intermediary['lastTrade'] != null
            ? (dateString
                ? DateTime.parse(intermediary['lastTrade'])
                : (intermediary['lastTrade']).toDate())
            : null,
        createdAt: intermediary['createdAt'] != null
            ? (dateString
                ? DateTime.parse(intermediary['createdAt'])
                : (intermediary['createdAt']).toDate())
            : null,
        phone: intermediary['phone'],
        email: intermediary['email'],
        address: Address(
          street: intermediary['address']['street'],
          streetNr: intermediary['address']['streetNr'],
          postalCode: intermediary['address']['postalCode'],
          city: intermediary['address']['city'],
        ));
  }
}
