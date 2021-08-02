# Applikation zur Erstellung von Viehverkehrsscheinen in Dart/Flutter

Bei der Beförderung von Rindern ist es in Österreich erforderlich, einen ausgedruckten
Viehverkehrsschein im Transportfahrzeug mitzuführen, in dem die
wesentlichen Angaben zum Transport und zu den beförderten Tieren zusammengefasst
werden. Das Projekt befasst sich damit, den Prozess zur
Erstellung dieses Begleitdokuments zu vereinfachen und zu automatisieren. Gezeigt
wird die Entwicklung einer Smartphone-Applikation für Android- und iOSGeräte,
die das Einpflegen der erforderlichen Daten erleichtert und dabei hilft,
Übertragungsfehler beim Ausfüllen eines solchen Lieferscheins zu vermeiden. Der
Funktionsumfang der Anwendung umfasst das Auslesen von Ohrmarken-Nummern
aus Bilddateien mittels Texterkennung und das Beziehen von Tierdaten aus einer
Rinderdatenbank. Des Weiteren können Handelspartner verwaltet und Lieferscheine
im PDF-Format erstellt und anschließend exportiert werden. Die Realisierung
der Applikation erfolgt in der Programmiersprache Dart unter Verwendung
des Mobile UI Frameworks Flutter.

## Hinweis

Folgende Datein sind selbst einzufügen, um die App mit Firebase zu verbinden: 
- Für iOS Applikation: ios -> GoogleService-Info.plist
- Für Android Applikation: android -> app -> google-service.json

Aus rechtlichlichen Gründen kann das Blanko Formular des Viehverkehrsscheins nicht mitgeliefert werden.

## iOS Look and Feel

<img src="screenshots/01_login_and_add_animal.gif" height="420px" > <img src="screenshots/02_dd_animal_via_gallery.gif" height="420px" > <img src="screenshots/03_edit_animal.gif" height="420px" > 
<img src="screenshots/04_addPerson.gif" height="420px" > <img src="screenshots/05_changeTransport.gif" height="420px" > <img src="screenshots/06_completeDeliveryNote.gif" height="420px" >
<img src="screenshots/07_loadOldSchein.gif" height="420px" > <img src="screenshots/08_deleteAllPersons.gif" height="420px" >
