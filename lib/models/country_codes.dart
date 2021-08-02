/*
    Represents a CountryCode.
 */
class CountryCode {
  String _code;

  CountryCode(String code) {
    if (code != null &&
        code.isNotEmpty &&
        COUNTRIES.indexOf(code.toUpperCase()) < 0)
      print("The country code $code is not an EU country code");
    this._code = code;
  }

  String get code {
    if (_code != null && _code.isNotEmpty) return _code;
    return null;
  }

  static String checkEUCode(String code) {
    if (code != null &&
        code.isNotEmpty &&
        COUNTRIES.indexOf(code.toUpperCase()) < 0) {
      return '$code ist kein gültiger EU-Ländercode';
    }
    return null;
  }

  // List of european country codes
  static const List<String> COUNTRIES = const [
    'AT',
    'BE',
    'DE',
    'CZ',
    'CY',
    'DK',
    'EE',
    'ES',
    'FI',
    'FR',
    'GR',
    'HU',
    'IE',
    'IT',
    'LT',
    'LU',
    'LV',
    'MT',
    'NL',
    'PL',
    'PT',
    'SE',
    'SI',
    'SK',
    'UK'
  ];
}
