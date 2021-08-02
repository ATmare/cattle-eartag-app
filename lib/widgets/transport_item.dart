import 'package:flutter/material.dart';
import 'package:direct_select_flutter/direct_select_item.dart';
import 'package:direct_select_flutter/direct_select_list.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../models/farmer.dart';
import '../models/buyer.dart';
import '../models/transporter.dart';
import '../models/intermediary.dart';
import '../models/person.dart';
import '../models/vet.dart';
import '../providers/person_list_provider.dart';
import '../utils/string_processing.dart';
import '../utils/custom_swatches.dart';
import '../screens/edit_person_screen.dart';

/*
    Class renders a Card containing Person details which is displayed on the transport_screen
 */
class TransportItem extends StatefulWidget {
  final String role;
  final stream;

  TransportItem(this.role, this.stream);

  @override
  _TransportItemState createState() => _TransportItemState();
}

class _TransportItemState extends State<TransportItem> {
  PersonListProvider _personData;
  var _isInit = true;
  int _selected = 0;
  var _list = [];
  var _labels = [];

  @override
  void initState() {
    super.initState();
  }

  void didChangeDependencies() {
    if (_isInit) {
      _personData = Provider.of<PersonListProvider>(context);
      _setSelectedIndices();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  // creates labels for scroll-select list
  _createLabels() {
    for (int i = 0; i < _list.length; i++) {
      var temp = _list.map<String>((person) {
        return StringProcessing.buildNameString(person);
      }).toList();
      temp[0] = 'Neu hinzufügen';
      if (_list is List<Transporter>) {
        temp[1] = 'gleich wie Landwirt';
        temp[2] = 'gleich wie Zwischenhändler';
      }
      _labels = temp;
    }
  }

  _setSelectedPerson(Person person) {
    // search if the currently selected person is in the stream list
    int idx = person != null ? _list.indexWhere((p) => p.id == person.id) : -1;

    // if the person does not exist in the stream list, select 'Neu hinzufügen' as default value
    if (idx < 0) {
      if (widget.role == 'Transporteur')
        _syncPerson();
      else
        _selected = 0;
    } else {
      _selected = idx;
    }
  }

  // determines which person should be selected in the scroll-select
  _setSelectedIndices() {
    if (widget.role == 'Landwirt')
      _setSelectedPerson(_personData.selectedFarmer);
    else if (widget.role == 'Käufer')
      _setSelectedPerson(_personData.selectedBuyer);
    else if (widget.role == 'Transporteur')
      _setSelectedPerson(_personData.selectedTransporter);
    else if (widget.role == 'Zwischenhändler')
      _setSelectedPerson(_personData.selectedIntermediary);
    else if (widget.role == 'Tierarzt')
      _setSelectedPerson(_personData.selectedVet);
  }

  // determines if the transporter person should be synced with farmer or intermediary
  _syncPerson() {
    if (_personData.selectedTransporterId == 'farmer') {
      _selected = 1;
    } else if (_personData.selectedTransporterId == 'intermediary') {
      _selected = 2;
    } else
      _selected = 0;
  }

  // adds an empty default object to the scroll-list, which is selected if the user
  // scrolls to the 'Neu hinzufügen' option in the scroll-select
  void _insertAdditionalEntries() {
    if (widget.role == 'Landwirt')
      _list.insert(0, Farmer());
    else if (widget.role == 'Käufer')
      _list.insert(0, Buyer());
    else if (widget.role == 'Transporteur') {
      _list.insert(0, Transporter());
      _list.insert(1, Transporter(syncWith: 'farmer', id: 'farmer'));
      _list.insert(
          2, Transporter(syncWith: 'intermediary', id: 'intermediary'));
    } else if (widget.role == 'Zwischenhändler')
      _list.insert(0, Intermediary());
    else if (widget.role == 'Tierarzt') _list.insert(0, Vet());
  }

  // determines if all mandatory fields for vet and farmer have been filled out
  bool _isValid() {
    Person person = _list[_selected];
    if (person != null && _selected != 0) {
      if (widget.role == 'Landwirt' || widget.role == 'Tierarzt') {
        return PersonListProvider.checkPersonCompleteness(person);
      }
    }
    return true;
  }

  TextStyle _boldText() {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    DirectSelectItem<String> _getDropDownMenuItem(String value) {
      return DirectSelectItem<String>(
          itemHeight: 56,
          value: value,
          itemBuilder: (context, value) {
            return Text(value);
          });
    }

    BoxDecoration _getDslDecoration() {
      return BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(width: 1, color: Colors.black12),
          top: BorderSide(width: 1, color: Colors.black12),
        ),
      );
    }

    void _showSnackbar() {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      final snackBar = SnackBar(
        content: Text('Hold & Drag anstatt Tap'),
        duration: Duration(seconds: 2),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }

    Icon _getDropdownIcon() {
      return Icon(
        Icons.unfold_more,
        color: Theme.of(context).primaryColor,
      );
    }

    Container _buildSelect() {
      return Container(
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        border: Border(
                            top: BorderSide(color: Colors.white),
                            left: BorderSide(color: Colors.white),
                            right: BorderSide(color: Colors.white),
                            bottom: BorderSide(color: Colors.white))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Padding(
                            child: SizedBox(
                              height: 36,
                              child: DirectSelectList<String>(
                                  values: _labels,
                                  onUserTappedListener: () {
                                    _showSnackbar();
                                  },
                                  defaultItemIndex: _selected,
                                  itemBuilder: (String value) =>
                                      _getDropDownMenuItem(value),
                                  focusedItemDecoration: _getDslDecoration(),
                                  onItemSelectedListener:
                                      (item, index, context) {
                                    setState(() {
                                      _selected = index;
                                      _personData
                                          .setSelectedPerson(_list[index]);
                                    });
                                  }),
                            ),
                            padding: EdgeInsets.only(
                              left: 10,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: _getDropdownIcon(),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: !(_list is List<Vet>)
                      ? Text(
                          _list[_selected].lfbisIdOrAma != null
                              ? _list[_selected].lfbisIdOrAma.toString()
                              : '',
                          textAlign: TextAlign.end,
                          style: _boldText())
                      : Container(),
                ),
              ],
            ),
          ],
        ),
      );
    }

    Padding _errorChip() {
      return Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Chip(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity(horizontal: 0.0, vertical: -4),
          label: Row(
            children: [
              Text(
                '!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '   Daten fehlen',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).errorColor,
        ),
      );
    }

    Text _cardTitle(String text) {
      return Text(text,
          style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.8),
            fontWeight: FontWeight.w500,
            fontSize: 13,
            letterSpacing: 3,
          ));
    }

    SizedBox _buildCard(Widget child, {double padding = 10, double height = 116}) {
      return SizedBox(
          height: height,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(EditPersonScreen.routeName,
                  arguments: {'person': _list[_selected], 'role': widget.role});
            },
            child: Card(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              shape: _isValid()
                  ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                    )
                  : RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      side: BorderSide(
                        color: Theme.of(context).errorColor,
                        width: 1.0,
                      ),
                    ),
              elevation: 3,
              margin: EdgeInsets.symmetric(vertical: 2, horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      // Theme.of(context).primaryColor,
                      customAccentColor.shade400,
                      customColor.shade300,
                      customAccentColor.shade400,
                    ],
                  ),
                ),
                child: Padding(padding: EdgeInsets.all(padding), child: child),
              ),
            ),
          ));
    }

    _personContent() {
      Widget child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _cardTitle(widget.role),
                  if (!_isValid()) _errorChip(),
                ],
              ),
              !(_list is List<Vet>)
                  ? (!(_list is List<Farmer>)
                      ? _cardTitle('LFBIS- / AMA-Nr.')
                      : _cardTitle('LFBIS- Nr.'))
                  : Container()
            ],
          ),
          SizedBox(
            height: 10,
          ),
          _buildSelect(),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: AutoSizeText(
              StringProcessing.buildAddressString(_list[_selected].address),
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          )
        ],
      );

      return _buildCard(child, height: _isValid() ? 116 : 120);
    }

    return StreamBuilder(
        stream: widget.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          _list = snapshot.data;
          _insertAdditionalEntries();
          _createLabels();
          _setSelectedIndices();
          return _personContent();
        });
  }
}
