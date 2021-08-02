import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share/share.dart';

import './pdf_screen.dart';
import './animal_list_screen.dart';
import './transport_screen.dart';
import './edit_tagnumber_screen.dart';

import '../utils/custom_icons.dart';
import '../utils/image_input.dart';
import '../providers/animals_provider.dart';
import '../providers/pdf_provider.dart';
import '../providers/person_list_provider.dart';
import '../widgets/custom_appbar.dart';

enum ListOptions { ClearList, All, Logout, PDFExport }

/*
    Main screen after user logged in.
 */
class TabScreen extends StatefulWidget {
  static const routeName = '/main';
  final index;

  TabScreen(this.index);

  @override
  _TabScreenState createState() => _TabScreenState(index);
}

class _TabScreenState extends State<TabScreen> {
  int _selectedPageIndex;

  _TabScreenState([this._selectedPageIndex = 1]);

  final List<Map<String, Object>> _pages = [
    {
      'page': null,
      'title': 'Kamera',
      'appBar': null,
    },
    {
      'page': AnimalListScreen(),
      'title': 'Tierliste',
      'appBar': null,
    },
    {
      'page': TransportScreen(),
      'title': 'Lieferschein',
      'appBar': null,
    },
    {
      'page': PdfScreen(),
      'title': 'PDF Vorschau',
      'appBar': null,
    }
  ];

  @override
  void initState() {
    Provider.of<PersonListProvider>(context, listen: false).fetchAllPersons();
    super.initState();
  }

  void didChangeDependencies() {
    _buildAnimalAppBar();
    _buildTransportAppBar();
    _buildPdfAppBar();
    super.didChangeDependencies();
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }

  void _selectPage(int index) async {
    if (index == 0) {
      File savedImage = await ImageInput.pickPicture('Camera');

      if (savedImage != null) {
        Navigator.of(context)
            .pushNamed(EditTagNumberScreen.routeName, arguments: {
          'pickedImage': savedImage,
        });
      }
    } else
      setState(() {
        _selectedPageIndex = index;
      });
  }

  Widget _buildActionButton() {
    if (_selectedPageIndex == 1) {
      return FloatingActionButton(
        heroTag: "btn1",
        child: Icon(Icons.add),
        onPressed: () =>
            {Navigator.of(context).pushNamed(EditTagNumberScreen.routeName)},
      );
    }
    return null;
  }

  PopupMenuItem<ListOptions> _buildLogoutButton() {
    return PopupMenuItem(
      child: Container(
        child: Row(children: [
          Icon(
            Icons.exit_to_app,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(
            width: 8,
          ),
          Text('Logout'),
        ]),
      ),
      value: ListOptions.Logout,
    );
  }

  void _buildAnimalAppBar() async {
    _pages[1]['appBar'] = CustomAppBar(
      title: 'Tierliste',
      actions: [
        PopupMenuButton(
          onSelected: (ListOptions selectedValue) {
            setState(() {
              if (selectedValue == ListOptions.ClearList) {
                Provider.of<AnimalsProvider>(context, listen: false).clear();
              } else if (selectedValue == ListOptions.Logout) {
                _signOut();
              }
            });
          },
          icon: Icon(Icons.more_vert),
          itemBuilder: (_) => [
            PopupMenuItem(
                child: Text('Tierliste leeren'), value: ListOptions.ClearList),
            _buildLogoutButton(),
          ],
        ),
      ],
    );
  }

  void _buildTransportAppBar() {
    _pages[2]['appBar'] = CustomAppBar(
      title: 'Lieferschein',
      actions: [
        PopupMenuButton(
          onSelected: (ListOptions selectedValue) {
            setState(() {
              if (selectedValue == ListOptions.ClearList) {
                Provider.of<PersonListProvider>(context, listen: false)
                    .setSelectedPersonNull();
              } else if (selectedValue == ListOptions.All) {
                Provider.of<PersonListProvider>(context, listen: false)
                    .populateDummyData();
              } else if (selectedValue == ListOptions.Logout) {
                _signOut();
              }
            });
          },
          icon: Icon(Icons.more_vert),
          itemBuilder: (_) => [
            // Uncomment this line for testing. Enables users to load dummy data for persons with one click.
            // PopupMenuItem(
            //     child: Text('Testdaten laden'), value: ListOptions.All),
            PopupMenuItem(
                child: Text('Felder zurücksetzen'),
                value: ListOptions.ClearList),
            _buildLogoutButton(),
          ],
        ),
      ],
    );
  }

  void _buildPdfAppBar() {
    _pages[3]['appBar'] = CustomAppBar(
      title: 'Pdf Export',
      actions: [
        PopupMenuButton(
          onSelected: (ListOptions selectedValue) {
            if (selectedValue == ListOptions.PDFExport) {
              _getPdfPath();
            } else if (selectedValue == ListOptions.Logout) {
              _signOut();
            }
          },
          icon: Icon(Icons.more_vert),
          itemBuilder: (_) => [
            PopupMenuItem(
                child: Text('PDF teilen'), value: ListOptions.PDFExport),
            _buildLogoutButton(),
          ],
        ),
      ],
    );
  }

  _getPdfPath() {
    var path = Provider.of<PdfProvider>(context, listen: false).pdfPath;
    Share.shareFiles([path], text: path);
  }

  @override
  Widget build(BuildContext context) {
    final bottomBar = BottomAppBar(
      color: Theme.of(context).primaryColor,
      shape: CircularNotchedRectangle(),
      notchMargin: 4,
      clipBehavior: Clip.antiAlias,
      child: BottomNavigationBar(
        elevation: 0,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        backgroundColor: Theme.of(context).primaryColor,
        currentIndex: _selectedPageIndex,
        onTap: _selectPage,
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt_outlined),
            label: 'Foto',
          ),
          BottomNavigationBarItem(
            icon: Icon(cow_male),
            label: 'Tierliste',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_outlined),
            label: 'Lieferschein',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_forward),
            label: 'PDF',
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: _pages[_selectedPageIndex]['appBar'],
      body: _pages[_selectedPageIndex]['page'],
      bottomNavigationBar: bottomBar,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildActionButton(),
    );
  }
}
