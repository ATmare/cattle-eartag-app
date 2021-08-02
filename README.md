# Application to create delivery notes for cattles in Dart/Flutter

In Austria it is required to carry along a specific delivery note called Viehverkehrsschein
during the transportation of cattles. Such a document summarizes the relevant
data of the transported animals as well as further transportation details.
The focus of this thesis is to simplify and automate the process of producing such
an accompanying delivery note. It demonstrates the development of a smartphone
application for android and iOS devices, which aims at facilitating the
error-free and uncomplicated filling of the form. The function scope of the application
includes the extraction of cattle ear tag IDs from images by the use
of text recognition techniques and the fetching of animal data from a database.
Furthermore, information concerning the trading partners can be managed and
delivery notes can be shared and exported in PDF format. The application is
implemented in Dart and uses the mobile UI framework flutter.

## Important notes 

The following files have to be provided by you:
- For iOS Application: ios -> GoogleService-Info.plist (To connect iOS app with Firebase)
- For Android Application: android -> app -> google-service.json (To connect Android app with Firebase)
- Due to legal restrictions the form for the delivery note can not be provided. The created PDF will therefore differ from the PDF shown in the GIFs. 

## iOS Look and Feel

<img src="screenshots/01_login_and_add_animal.gif" height="420px" > <img src="screenshots/02_dd_animal_via_gallery.gif" height="420px" > <img src="screenshots/03_edit_animal.gif" height="420px" > 
<img src="screenshots/04_addPerson.gif" height="420px" > <img src="screenshots/05_changeTransport.gif" height="420px" > <img src="screenshots/06_completeDeliveryNote.gif" height="420px" >
<img src="screenshots/07_loadOldSchein.gif" height="420px" > <img src="screenshots/08_deleteAllPersons.gif" height="420px" >

## Android Look and Feel

<img src="screenshots/Screenshot_2021-05-22-21-01-42-248.jpg" height="420px" > <img src="screenshots/Screenshot_2021-05-22-21-06-23-442.jpg" height="420px" > <img src="screenshots/Screenshot_2021-05-22-21-07-12-558.jpg" height="420px" >
<img src="screenshots/Screenshot_2021-05-22-21-09-23-218.jpg" height="420px" > <img src="screenshots/Screenshot_2021-05-22-21-10-33-846.jpg" height="420px" > <img src="screenshots/Screenshot_2021-05-22-21-11-04-553.jpg" height="420px" >
<img src="screenshots/Screenshot_2021-05-22-21-19-47-487.jpg" height="420px" > <img src="screenshots/Screenshot_2021-05-22-21-34-22-146.jpg" height="420px" > <img src="screenshots/Screenshot_2021-05-22-21-34-52-131.jpg" height="420px" >
<img src="screenshots/Screenshot_2021-05-22-21-37-11-50.jpg" height="420px" > <img src="screenshots/Screenshot_2021-05-22-21-39-58-016.jpg" height="420px" > <img src="screenshots/Screenshot_2021-05-22-21-40-14-174ion.jpg" height="420px" >
<img src="screenshots/Screenshot_2021-05-22-21-43-18-692_android.jpg" height="420px" > <img src="screenshots/Screenshot_2021-05-22-21-43-31-330.jpg" height="420px" > <img src="screenshots/Screenshot_2021-06-18-13-12-36-157.jpg" height="420px" >
