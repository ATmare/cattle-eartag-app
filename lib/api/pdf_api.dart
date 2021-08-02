import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:enum_to_string/enum_to_string.dart';

import '../models/animal.dart';
import '../models/deliveryNote.dart';
import '../models/address.dart';
import '../models/farmer.dart';
import '../models/person.dart';
import '../utils/string_processing.dart';
import '../utils/dummy_data_empty.dart';

/*
    Class creates a PDF document and persists it in device storage
 */
class PdfApi {
  /// Generates a delivery Note PDF from information inside [deliveryNote]
  /// and saves the PDF to storage. Storage path contains [uid]
  static Future<File> generatePDF(DeliveryNote deliveryNote, String uid) async {
    final _pdf = pw.Document();
    final _vvs = await rootBundle.loadString('assets/images/VVK_newDesignBlank.svg');
    final _name =
        'vvs_' + StringProcessing.formatDeliveryId(deliveryNote.deliveryId);
    final _uid = uid;

    final _buyer = deliveryNote.buyer ?? emptyBuyer;
    final _farmer = deliveryNote.farmer ?? emptyFarmer;
    final _intermediary = deliveryNote.intermediary ?? emptyIntermediary;
    final _vet = deliveryNote.vet ?? emptyVet;
    final _transport = deliveryNote.transport ?? emptyTransport;
    final _transporter = deliveryNote.transporter ?? emptyTransporter;
    final _animals = deliveryNote.animalList ?? emptyAnimals;

    final _pageTheme = pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.only(top: 71, left: 46, right: 14),
      buildBackground: (context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.Positioned(
            child: pw.SvgImage(svg: _vvs),
            left: 0,
            top: 0,
          ),
        );
      },
    );

    pw.SizedBox _credentialText(String text, pw.Context context,
        {double bottomMargin = 10,
        double leftMargin = 0,
        double placeHoldHeight = 21,
        pw.Alignment align = pw.Alignment.bottomLeft}) {
      if (text.length > 0)
        return pw.SizedBox(
            height: placeHoldHeight,
            child: pw.Padding(
              padding:
                  pw.EdgeInsets.only(left: leftMargin, bottom: bottomMargin),
              child: pw.FittedBox(
                alignment: align,
                fit: pw.BoxFit.scaleDown,
                child: (text != null && text.length > 0)
                    ? pw.Text(
                        text,
                        textAlign: pw.TextAlign.left,
                        textScaleFactor: 0.8,
                        tightBounds: true,
                      )
                    : pw.Placeholder(),
              ),
            ));
      else
        return pw.SizedBox(
          height: placeHoldHeight,
          width: 1,
        );
    }

    // placeholder that is rendered if null-values or empty strings occur
    pw.SizedBox _placeHolder() {
      return pw.SizedBox(height: 2, width: 2);
    }

    pw.SizedBox _smallText(String text, pw.Context context,
        {double bottomMargin = 4.5,
        double leftMargin = 0,
        double width = 10,
        double height = 14}) {
      return pw.SizedBox(
        height: height,
        width: width,
        child: pw.Padding(
          padding: pw.EdgeInsets.only(left: leftMargin, bottom: bottomMargin),
          child: pw.FittedBox(
            fit: pw.BoxFit.scaleDown,
            alignment: pw.Alignment.bottomLeft,
            child: (text != null && text.length > 0)
                ? pw.Text(
                    text ?? '',
                    textScaleFactor: 0.7,
                    tightBounds: true,
                  )
                : _placeHolder(),
          ),
        ),
      );
    }

    pw.SizedBox _addrOneLine(Address addr, pw.Context context,
        {double bottomMargin}) {
      return _credentialText(
        StringProcessing.buildAddressString(addr),
        context,
        bottomMargin: bottomMargin,
        placeHoldHeight: 16,
      );
    }

    pw.SizedBox _nameOneLine(Person partner, pw.Context context,
        {double bottomMargin = 0}) {
      return _credentialText(StringProcessing.buildNameString(partner), context,
          bottomMargin: bottomMargin, placeHoldHeight: 16);
    }

    // renders one digit of the AMA number
    pw.SizedBox _singleAmaNumber(String number, pw.Context context) {
      return pw.SizedBox(
        width: 20.5,
        child: pw.Container(
          alignment: pw.Alignment.center,
          child: (number != null && number.length > 0)
              ? pw.Text(
                  number,
                  textAlign: pw.TextAlign.center,
                  textScaleFactor: 1.2,
                  style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontWeight: pw.FontWeight.bold,
                      ),
                )
              : _placeHolder(),
        ),
      );
    }

    // renders the ama number of the partner
    pw.Container _amaNumber(dynamic partner, pw.Context context,
        {double leftMargin = 111, double bottomMargin = 18}) {
      var lfbisNr;
      (partner != null && partner.lfbisIdOrAma != null)
          ? lfbisNr = partner.lfbisIdOrAma.toString()
          : lfbisNr = '';

      List<pw.SizedBox> numbers = [];
      int maxLength = partner is Farmer ? 7 : 8;
      for (int i = 0; i < lfbisNr.length && i < maxLength; i++) {
        i < lfbisNr.length - 1
            ? numbers
                .add(_singleAmaNumber(lfbisNr.substring(i, i + 1), context))
            : numbers.add(_singleAmaNumber(lfbisNr.substring(i), context));
      }

      return pw.Container(
          padding: pw.EdgeInsets.only(
              left: leftMargin, bottom: bottomMargin, top: 15),
          child: pw.SizedBox(
            height: 17,
            child: pw.Row(
              children: [...numbers],
            ),
          ));
    }

    pw.SizedBox _createAnimalCell(String text, double cellWidth) {
      return pw.SizedBox(
        height: 21.1,
        width: cellWidth,
        child: pw.FittedBox(
          fit: pw.BoxFit.scaleDown,
          child: (text != null && text.length > 0)
              ? pw.Text(
                  text,
                  textScaleFactor: 0.8,
                  tightBounds: true,
                )
              : _placeHolder(),
        ),
      );
    }

    pw.Row _createAnimalRow(Animal animal) {
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 21.1, width: 10),
          _createAnimalCell(animal.tagId, 132),
          _createAnimalCell(animal.slaugther ? 'X' : '', 12),
          _createAnimalCell(
              animal.category != null
                  ? EnumToString.convertToString(animal.category)
                  : '',
              51),
          _createAnimalCell(
              animal.dateOfBirth != null
                  ? StringProcessing.prettyDate(animal.dateOfBirth)
                  : '',
              63),
          _createAnimalCell(
              animal.placeOfBirth != null ? animal.placeOfBirth.code : '', 19),
          _createAnimalCell(
              animal.placeOfRearing != null
                  ? (animal.placesOfRearing()).join(', ')
                  : '',
              29),
          _createAnimalCell(
              animal.purchaseDate != null
                  ? StringProcessing.prettyDate(animal.purchaseDate)
                  : '',
              68),
          _createAnimalCell(animal.breed ?? '', 62),
          _createAnimalCell(animal.additionalInfos ?? '', 89),
        ],
      );
    }

    pw.Container _createAnimalList() {
      List<pw.Row> list = [];
      for (int i = 0; i < _animals.length; i++) {
        list.add(_createAnimalRow(_animals[i]));
      }
      return pw.Container(
          height: 170,
          child: pw.Column(
            children: list,
          ));
    }

    pw.Row _transportRow(String textLeft, String textRight, pw.Context context,
        {double textLeftmarginLeft = 73,
        double textLeftWidth = 250,
        double gapSize = 104,
        double textRightWidth = 175}) {
      return pw.Row(
        children: [
          _smallText(
            textLeft,
            context,
            leftMargin: textLeftmarginLeft,
            width: textLeftWidth,
          ),
          pw.SizedBox(width: gapSize, height: 16.7),
          _smallText(
            textRight,
            context,
            width: textRightWidth,
          ),
        ],
      );
    }

    pw.Row _buildTwoLiner(pw.Context context, Person person,
        {double boxWidth = 250, double boxHeight = 33, double gapBetween = 1}) {
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: boxWidth,
            height: boxHeight,
            child: person != null
                ? pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      (person.firstname != null || person.lastname != null)
                          ? _nameOneLine(
                              person,
                              context,
                            )
                          : _placeHolder(),
                      pw.SizedBox(height: gapBetween),
                      _addrOneLine(person.address, context, bottomMargin: 0),
                    ],
                  )
                : _placeHolder(),
          ),
        ],
      );
    }

    pw.SizedBox _createPartner(dynamic partner, pw.Context context,
        {double boxHeight = 88}) {
      return pw.SizedBox(
        height: boxHeight,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _amaNumber(partner, context, leftMargin: 90, bottomMargin: 13),
            _buildTwoLiner(context, partner, gapBetween: 4, boxHeight: 38),
          ],
        ),
      );
    }

    pw.Row _createDeliveryId(pw.Context context) {
      return pw.Row(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 2, bottom: 6),
            child: (deliveryNote.deliveryId.toString() != null &&
                    deliveryNote.deliveryId.toString().length > 0)
                ? pw.Text(
                    StringProcessing.formatDeliveryId(deliveryNote.deliveryId),
                    textScaleFactor: 1.4,
                    style: pw.Theme.of(context)
                        .defaultTextStyle
                        .copyWith(fontWeight: pw.FontWeight.normal),
                  )
                : _placeHolder(),
          ),
        ],
      );
    }

    pw.Row _createFarmerCredentials(pw.Context context) {
      return pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 250,
            height: 119,
            child: _farmer != null
                ? pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _credentialText(
                        StringProcessing.buildNameString(_farmer),
                        context,
                      ),
                      _credentialText(
                        StringProcessing.buildStreetNNumber(_farmer.address),
                        context,
                      ),
                      _credentialText(
                        StringProcessing.buildPLZNCity(_farmer.address),
                        context,
                      ),
                      _credentialText(
                        _farmer.phone != null ? _farmer.phone : '',
                        context,
                        leftMargin: 47,
                      ),
                      _credentialText(
                        _farmer.email != null ? _farmer.email : '',
                        context,
                        leftMargin: 47,
                      ),
                    ],
                  )
                : pw.Container(),
          ),
        ],
      );
    }

    List<pw.Row> _createFarmerMarketing(pw.Context context) {
      return [
        pw.Row(
          children: [
            // AMA Guetesiegel Checkbox
            _smallText(
                _farmer.marketingAds.containsKey(MarketingLabel.AMAGuetesiegel)
                    ? 'X'
                    : '',
                context,
                leftMargin: 1.5,
                width: 132.3),
            // zert. GVO-Frei Checkbox
            _smallText(
                _farmer.marketingAds.containsKey(MarketingLabel.GVOFrei)
                    ? 'X'
                    : '',
                context),
          ],
        ),
        pw.Row(
          children: [
            // Bio Checkbox
            _smallText(
                _farmer.marketingAds.containsKey(MarketingLabel.Bio) ? 'X' : '',
                context,
                leftMargin: 1.5,
                width: 32),
            // Bio Text
            _smallText(
                _farmer.marketingAds.containsKey(MarketingLabel.Bio)
                    ? _farmer.marketingAds[MarketingLabel.Bio]
                    : '',
                context,
                width: 100.3),
            // Other
            _smallText(
                _farmer.marketingAds.containsKey(MarketingLabel.Other)
                    ? 'X'
                    : '',
                context),
            _smallText(
                _farmer.marketingAds.containsKey(MarketingLabel.Other)
                    ? _farmer.marketingAds[MarketingLabel.Other]
                    : '',
                context,
                width: 108),
          ],
        )
      ];
    }

    pw.Row _createVet(pw.Context context) {
      return _buildTwoLiner(context, _vet);
    }

    pw.SizedBox _createTransporter(pw.Context context) {
      return pw.SizedBox(
        height: 82,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _amaNumber(_transporter, context, leftMargin: 90, bottomMargin: 22),
            pw.SizedBox(
              width: 250,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(
                    height: 11,
                    child: _credentialText(
                        StringProcessing.buildAddrAndNameString(_transporter),
                        context,
                        bottomMargin: 0,
                        placeHoldHeight: 11),
                  ),
                  pw.Row(
                    children: [
                      _smallText(
                          _transporter.syncWith == 'farmer' ? 'X' : '', context,
                          bottomMargin: 0,
                          leftMargin: 70,
                          width: 170,
                          height: 10),
                      _smallText(
                          _transporter.syncWith == 'intermediary' ? 'X' : '',
                          context,
                          bottomMargin: 0,
                          height: 10),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      );
    }

    pw.SizedBox _createTransport(pw.Context context) {
      return pw.SizedBox(
        height: 160,
        child: pw.Container(
          padding: pw.EdgeInsets.only(top: 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _transportRow(
                  StringProcessing.buildAddressString(_transport.loadingPlace),
                  _transport.licensePlate ?? '',
                  context),
              _transportRow(
                  _transport.startOfTransport != null
                      ? StringProcessing.prettyTime(_transport.startOfTransport)
                      : '',
                  _transport.unloadingPlace != null
                      ? StringProcessing.buildAddressString(
                          _transport.unloadingPlace)
                      : '',
                  context),
              _transportRow(
                  _transport.lastFeeding != null
                      ? StringProcessing.prettyTime(_transport.lastFeeding)
                      : '',
                  _transport.transportDuration != null
                      ? StringProcessing.prettyDuration(
                          _transport.transportDuration)
                      : '',
                  context,
                  textLeftmarginLeft: 115,
                  gapSize: 155,
                  textRightWidth: 124),
            ],
          ),
        ),
      );
    }

    pw.Container _createSignature(
      Person partner,
      pw.Context context,
    ) {
      var date = StringProcessing.prettyDate();
      var nameString =
          partner != null ? StringProcessing.buildNameString(partner) : '';
      var text = (nameString.isNotEmpty) ? date + ', ' + nameString : '';

      return pw.Container(
        alignment: pw.Alignment.center,
        width: 170,
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            _credentialText(text, context,
                bottomMargin: 0, align: pw.Alignment.center),
          ],
        ),
      );
    }

    _pdf.addPage(
      pw.Page(
        pageTheme: _pageTheme,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Delivery ID Number Section
            _createDeliveryId(context),
            // Credentials Section
            pw.Container(
              height: 254,
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.SizedBox(width: 277),
                      // Farmer Section
                      _amaNumber(_farmer, context),
                      _createFarmerCredentials(context),
                      ..._createFarmerMarketing(context),
                      pw.SizedBox(height: 21),
                      // Vet Section
                      _createVet(context),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Intermediary Section
                      _createPartner(_intermediary, context),
                      // Transporteur Section
                      _createTransporter(context),
                      // Buyer Section
                      _createPartner(_buyer, context, boxHeight: 84),
                    ],
                  ),
                ],
              ),
            ),

            // Transport Section
            _createTransport(context),
            // Animal List Section
            _createAnimalList(),
            // Signatures
            pw.SizedBox(height: 38),
            pw.Container(
              child: pw.Row(
                children: [
                  _createSignature(_farmer, context),
                  _createSignature(null, context),
                  _createSignature(null, context),
                ],
              ),
            )
          ],
        ),
      ),
    );
    return _saveDocument(name: _name, pdf: _pdf, uid: _uid);
  }

  static Future<File> _saveDocument({
    @required String name,
    @required pw.Document pdf,
    @required String uid,
  }) async {
    final bytes = await pdf.save();
    var dir;
    if (Platform.isIOS)
      dir = await getLibraryDirectory();
    else
      dir = await getExternalStorageDirectory();

    Directory userFolder = Directory('${dir.path}/$uid');
    if (!userFolder.existsSync()) {
      userFolder.createSync();
    }

    final file = File('${dir.path}/$uid/$name' + '.pdf');

    await file.writeAsBytes(bytes);
    return file;
  }
}
