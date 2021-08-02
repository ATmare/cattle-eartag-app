import './clone_interface.dart';

/*
    Represents an Address
 */
class Address implements CloneMethod {
  String street;
  String streetNr;
  String city;
  int postalCode;

  Address({this.street, this.streetNr, this.city, this.postalCode});

  Address cloneSelf() {
    return Address(
      street: street,
      streetNr: streetNr,
      city: city,
      postalCode: postalCode,
    );
  }
}
