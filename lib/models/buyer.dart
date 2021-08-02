import './address.dart';
import './person.dart';
import './ama_number.dart';

/*
    Represents a Buyer Person
 */
class Buyer extends Person with AmaNumber {
  Buyer(
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
  Buyer cloneSelf() {
    return Buyer(
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

  factory Buyer.fromJson(Map<String, dynamic> buyer, String documentID,
      {bool dateString = false}) {
    return Buyer(
        id: documentID ?? DateTime.now().toString(),
        lfbisIdOrAma: buyer['lfbisIdOrAma'],
        firstname: buyer['firstname'],
        lastname: buyer['lastname'],
        lastTrade: buyer['lastTrade'] != null
            ? (dateString
                ? DateTime.parse(buyer['lastTrade'])
                : (buyer['lastTrade']).toDate())
            : null,
        createdAt: buyer['createdAt'] != null
            ? (dateString
                ? DateTime.parse(buyer['createdAt'])
                : (buyer['createdAt']).toDate())
            : null,
        phone: buyer['phone'],
        email: buyer['email'],
        address: Address(
          street: buyer['address']['street'],
          streetNr: buyer['address']['streetNr'],
          postalCode: buyer['address']['postalCode'],
          city: buyer['address']['city'],
        ));
  }
}
