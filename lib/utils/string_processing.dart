import 'package:intl/intl.dart';

import '../models/person.dart';
import '../models/address.dart';

/*
    Class provides methods for formatting inputs. Returns correctly formatted output as string.
    Class provides Regex-methods to check characteristic of a given string input.
 */
class StringProcessing {

  /// Returns a one-liner string of format "postalCode city, Street StreetNr"
  /// Returns an empty string if both fields are null
  static String buildAddressString(Address addr) {
    String out = '';
    out = buildStreetNNumber(addr);
    if (out.length > 0) out = out + ', ';
    out = out + buildPLZNCity(addr);
    return out;
  }

  /// Checks if postalCode and city of [addr] exist and gives back a one-liner string with postalCode and city
  /// Returns an empty string if both fields are null
  static String buildPLZNCity(Address addr) {
    String out = '';
    if (addr != null) {
      (addr.postalCode != null && addr.postalCode >= 0)
          ? out = out + addr.postalCode.toString() + ' '
          : out = out;
      (addr.city != null && addr.city.length > 0)
          ? out = out + addr.city
          : out = out;
    }
    return out;
  }

  /// Checks if street and streetNr of [addr] exist and gives back a one-liner string with street and streetNr
  /// Returns an empty string if both fields are null
  static String buildStreetNNumber(Address addr) {
    String out = '';
    if (addr != null) {
      (addr.street != null && addr.street.length > 0)
          ? out = addr.street + ' '
          : out = '';
      (addr.streetNr != null && addr.streetNr.length > 0)
          ? out = out + addr.streetNr
          : out = out;
    }
    return out;
  }

  /// Checks if firstname and lastname of [partner] exist and gives back a one-liner string with first- and lastname
  /// Returns an empty string if both fields are null
  static String buildNameString(Person partner) {
    String out = '';
    (partner.firstname != null && partner.firstname.length > 0)
        ? out = partner.firstname + ' '
        : out = '';
    (partner.lastname != null && partner.lastname.length > 0)
        ? out = out + partner.lastname
        : out = out;
    return out;
  }

  /// Checks if name and address of [partner] exist and gives back a one-liner string
  /// Returns an empty string if both fields are null
  static String buildAddrAndNameString(Person partner) {
    String out = '';
    out = buildNameString(partner);
    if (out.length > 0) out = out + ' ';
    if (partner.address != null)
      out = out + buildAddressString(partner.address);
    return out;
  }

  /// formats [date] to String with format dd.MM.yyyy.
  /// Formats the current date, if no parameter is passed
  static String prettyDate([DateTime date]) {
    date == null ? date = DateTime.now() : date = date;
    return DateFormat('dd.MM.yyyy').format(date);
  }

  /// Formats [date] to format HH:mm
  static String prettyTime([DateTime date]) {
    return DateFormat.Hm().format(date);
  }

  /// Formats input [date] to format HH:mm with HH > 24 possible and returns it as string
  static String prettyDuration(DateTime date) {
    int diff = date.difference(DateFormat("HH:mm").parse('00:00')).inDays;

    int hour = date.hour + diff * 24;
    String out = hour.toString() +
        ':' +
        (date.minute.toString().length > 1
            ? date.minute.toString()
            : (date.minute.toString() + '0'));
    return out;
  }

  /// Formats input [id] to string of length 8
  static String formatDeliveryId(int id) {
    NumberFormat formatter =  NumberFormat("00000000");
    return formatter.format(id);
  }

    // Regex. Inspired by https://github.com/dart-league/validators/blob/master/lib/validators.dart

  /// Check if the string [str] contains only chars a-z, A-Z including umlauts and special symbols
  static bool isAlpha(String str) {
    RegExp _alpha = new RegExp(r'^[a-zA-ZäàáâãāåçčćèéêëìíîïñòóôõöøùúûüÄÀÁÃĀÅÇČĆÈÉÊËÑÒÓÖÔØÙÚÜŨÛßŜŝŸÿĐđŽž]+$');
    return _alpha.hasMatch(str);
  }

  /// Check if the string [str] contains only numbers
  static bool isNumeric(String str) {
    RegExp _numeric = new RegExp(r'^-?[0-9]+$');
    return _numeric.hasMatch(str);
  }

  /// Check if the string [str] contains only letters and numbers
  static bool isAlphanumeric(String str) {
    RegExp _alphanumeric = new RegExp(r'^[a-zA-Z0-9]+$');
    return _alphanumeric.hasMatch(str);
  }

  /// Check if the string contains ASCII chars only
  static bool isAscii(String str) {
    RegExp _ascii = new RegExp(r'^[\x00-\x7F]+$');
    return _ascii.hasMatch(str);
  }
}
