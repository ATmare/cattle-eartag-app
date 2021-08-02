import './address.dart';
import './person.dart';
import './ama_number.dart';

/*
    Represents a Transporter Person
 */
class Transporter extends Person with AmaNumber {
  String syncWith;

  Transporter(
      {lfbisIdOrAma,
      String id,
      String firstname,
      String lastname,
      Address address,
      String phone,
      String email,
      this.syncWith,
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
  Transporter cloneSelf() {
    return Transporter(
        lfbisIdOrAma: lfbisIdOrAma,
        id: id,
        firstname: firstname,
        lastname: lastname,
        address: (address == null) ? Address() : address.cloneSelf(),
        phone: phone,
        email: email,
        createdAt: createdAt,
        lastTrade: lastTrade,
        syncWith: syncWith);
  }

  factory Transporter.fromJson(Map<String, dynamic> transporter, documentID,
      {bool dateString = false}) {
    return Transporter(
        id: documentID ?? DateTime.now().toString(),
        lfbisIdOrAma: transporter['lfbisIdOrAma'],
        firstname: transporter['firstname'],
        lastname: transporter['lastname'],
        lastTrade: transporter['lastTrade'] != null
            ? (dateString
                ? DateTime.parse(transporter['lastTrade'])
                : (transporter['lastTrade']).toDate())
            : null,
        createdAt: transporter['createdAt'] != null
            ? (dateString
                ? DateTime.parse(transporter['createdAt'])
                : (transporter['createdAt']).toDate())
            : null,
        phone: transporter['phone'],
        email: transporter['email'],
        syncWith: null,
        address: Address(
          street: transporter['address']['street'],
          streetNr: transporter['address']['streetNr'],
          postalCode: transporter['address']['postalCode'],
          city: transporter['address']['city'],
        ));
  }
}
