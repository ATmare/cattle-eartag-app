import './person.dart';

/*
    Specifies AmaNumber specific methods for Person objects
 */
mixin AmaNumber on Person {
  int _lfbisIdOrAma;

  int get lfbisIdOrAma => _lfbisIdOrAma;

  void initAmaNumber(int amaNr) {
    assert(_lfbisIdOrAma == null);
    _lfbisIdOrAma = amaNr;
  }

  // parameter is dynamic, because this way
  // _lfbisIdOrAma can be set if it is a string or an int
  @override
  void setAmaNr(amaNr) {
    if (amaNr == null || amaNr is int)
      _lfbisIdOrAma = lfbisIdOrAma;
    else
      _lfbisIdOrAma = num.tryParse(amaNr);
  }

  @override
  int get hasAmaNr {
    return lfbisIdOrAma;
  }

  Map<String, dynamic> toJson(String id, {bool dateString = false}) {
    return Person.toJson(this, id);
  }
}
