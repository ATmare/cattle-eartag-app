import 'package:flutter/material.dart';
import 'package:direct_select_flutter/direct_select_container.dart';
import 'package:provider/provider.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../models/transport.dart';
import '../models/address.dart';
import '../providers/person_list_provider.dart';
import '../api/person_list_firestore.dart';
import '../utils/string_processing.dart';
import '../utils/custom_swatches.dart';
import '../screens/edit_transport_screen.dart';
import '../widgets/transport_item.dart';
import '../widgets/sliver_header.dart';

/*
    Class renders the transport main screen
 */
class TransportScreen extends StatefulWidget {
  static const routeName = '/transport';

  @override
  _TransportScreenState createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final _db = PersonListFirestore();
  PersonListProvider _personData;
  var _isInit = true;
  var _future;

  Transport _transport;

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  @override
  void initState() {
    _future = Provider.of<PersonListProvider>(context, listen: false)
        .fetchAllPersons();
    super.initState();
  }

  void didChangeDependencies() {
    if (_isInit) {
      _personData = Provider.of<PersonListProvider>(context);
    }

    _updateTransport(false);

    _isInit = false;
    super.didChangeDependencies();
  }

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    await _personData.fetchAllPersons();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    if (mounted) setState(() {});
    _refreshController.loadComplete();
  }

  _updateTransport(bool sync) {
    if (_personData.transport != null) {
      _transport = _personData.transport;
    } else
      _transport = Transport(loadingPlace: Address(), unloadingPlace: Address());
  }

  bool _isValid() {
    if (_personData.transport != null) {
      return PersonListProvider.checkTransportCompleteness(_personData.transport);
    }
    return true;
  }

  _errorChip({String chip}) {
    return chip == null
        ? CircleAvatar(
            backgroundColor: Theme.of(context).errorColor,
            radius: 14,
            child: Padding(
              padding: EdgeInsets.all(4),
              child: FittedBox(
                child: Text(
                  '!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ))
        :
        FittedBox(
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

  TextStyle _boldText({double fontSize = 18}) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18,
      color: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    Text _cardTitle(String text) {
      return Text(text,
          style: TextStyle(
            color: Color.fromRGBO(255, 255, 255, 0.8),
            fontWeight: FontWeight.w500,
            fontSize: 13,
            letterSpacing: 3,
          ));
    }

    _buildCard(Widget child, {double padding = 10, double height = 116}) {
      return SizedBox(
          height: height,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(EditTransportScreen.routeName,
                  arguments: {'transport': _transport});
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

    _showError(String text, String label, double fontSize, double maxFontSize) {
      if (label == 'Fütterung' && (text == null || text == ''))
        return _errorChip();
      if (label == 'Abfahrt' && (text == null || text == ''))
        return _errorChip();
      if (label == 'Von' && (text == null || text == ''))
        return _errorChip(chip: 'chip');

      return AutoSizeText(
        text,
        textAlign: TextAlign.center,
        style: _boldText(fontSize: fontSize),
        minFontSize: 14,
        maxFontSize: maxFontSize,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    Expanded _buildTransportInfoBox(String label, String text,
        {double fontSize = 17,
        double maxFontSize = 17,
        Border border: const Border(right: BorderSide(color: Colors.white))}) {
      return Expanded(
        flex: 2,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: border,
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _cardTitle(label),
                _showError(text, label, fontSize, maxFontSize),
              ]),
        ),
      );
    }

    String _buildAddress(Address addr) {
      if (addr != null) {
        var plz = StringProcessing.buildPLZNCity(addr);
        var street = StringProcessing.buildStreetNNumber(addr);
        if (plz.isNotEmpty && street.isNotEmpty) {
          return street + '\n' + plz;
        } else
          return StringProcessing.buildAddressString(addr);
      } else
        return '';
    }

    String _findLoadingPlace() {
      if (_transport != null) return _buildAddress(_transport.loadingPlace);
      return '';
    }

    String _findUnloadingPlace() {
      if (_transport != null) return _buildAddress(_transport.unloadingPlace);
      return '';
    }

    Row _transportContent() {
      var child = Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTransportInfoBox(
                  'Abfahrt',
                  _transport.startOfTransport != null
                      ? StringProcessing.prettyTime(_transport.startOfTransport)
                      : '',
                  border: const Border(
                      bottom: BorderSide(color: Colors.white),
                      right: BorderSide(color: Colors.white)),
                ),
                _buildTransportInfoBox(
                  'Dauer',
                  _transport.transportDuration != null
                      ? StringProcessing.prettyDuration(
                      _transport.transportDuration)
                      : '',
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 6),
              child: Column(
                children: [
                  _buildTransportInfoBox('Von', _findLoadingPlace(),
                      border: const Border(
                        left: BorderSide.none,
                      ),
                      fontSize: 14,
                      maxFontSize: 15),
                  SizedBox(
                    height: 2,
                  ),
                  _buildTransportInfoBox('Zu', _findUnloadingPlace(),
                      border: const Border(
                        left: BorderSide.none,
                      ),
                      fontSize: 14,
                      maxFontSize: 15)
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTransportInfoBox(
                  'KFZ',
                  _transport.licensePlate != null ? _transport.licensePlate : '',
                  border: const Border(
                      bottom: BorderSide(color: Colors.white),
                      left: BorderSide(color: Colors.white)),
                ),
                _buildTransportInfoBox(
                  'Fütterung',
                  _transport.lastFeeding != null
                      ? StringProcessing.prettyTime(_transport.lastFeeding)
                      : '',
                  border: const Border(
                    left: BorderSide(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

      return child;
    }

    return DirectSelectContainer(
        child: SmartRefresher(
      enablePullDown: true,
      // enablePullUp: true,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      footer: CustomFooter(
        builder: (BuildContext context, LoadStatus mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = Text("pull up load");
          } else if (mode == LoadStatus.loading) {
            body = CircularProgressIndicator();
          } else if (mode == LoadStatus.failed) {
            body = Text("Load Failed!Click retry!");
          } else if (mode == LoadStatus.canLoading) {
            body = Text("release to load more");
          } else {
            body = Text("No more Data");
          }
          return Container(
            height: 55.0,
            child: Center(child: body),
          );
        },
      ),
      header: WaterDropHeader(),
      child: CustomScrollView(
        slivers: <Widget>[
          SliverHeader('Lieferschein', 'Informationen zum Transport'),
          SliverList(
            delegate: SliverChildListDelegate([
              TransportItem('Landwirt', _db.farmerStream()),
              TransportItem('Käufer', _db.buyerStream()),
              TransportItem('Zwischenhändler', _db.intermediaryStream()),
              TransportItem('Transporteur', _db.transporterStream()),
              TransportItem('Tierarzt', _db.vetStream()),
              _buildCard(_transportContent(), padding: 0, height: 135),
            ]),
          ),
          SliverPadding(padding: EdgeInsets.all(10))
        ],
      ),
    ));

  }
}
