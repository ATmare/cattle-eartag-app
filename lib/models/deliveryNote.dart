import './buyer.dart';
import './farmer.dart';
import './intermediary.dart';
import './animal.dart';
import './transport.dart';
import './vet.dart';
import './transporter.dart';

/*
    Represents a DeliveryNote
 */
class DeliveryNote {
  int deliveryId;
  Farmer farmer;
  Buyer buyer;
  Transporter transporter;
  Intermediary intermediary;
  Vet vet;
  Transport transport;
  List<Animal> animalList;

  DeliveryNote(
      {this.deliveryId,
      this.farmer,
      this.buyer,
      this.transporter,
      this.intermediary,
      this.vet,
      this.transport,
      this.animalList});
}
