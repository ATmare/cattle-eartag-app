import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './utils/custom_swatches.dart';
import './models/animal.dart';

import './screens/tabs_sceen.dart';
import './screens/pdf_screen.dart';
import './screens/animal_list_screen.dart';
import './screens/transport_screen.dart';
import './screens/edit_tagnumber_screen.dart';
import './screens/edit_animal_screen.dart';
import './screens/edit_person_screen.dart';
import './screens/edit_transport_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './screens/edit_user_settings.dart';

import './providers/animals_provider.dart';
import './providers/delivery_note_provider.dart';
import './providers/person_list_provider.dart';
import './providers/pdf_provider.dart';
import './providers/animal_stream_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // forbid landscape mode
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) {
            return AnimalsProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) {
            return PersonListProvider();
          },
        ),
        ChangeNotifierProvider(
          create: (ctx) {
            return PdfProvider();
          },
        ),
        ChangeNotifierProxyProvider2<AnimalsProvider, PersonListProvider,
            DeliveryNoteProvider>(
          update: (ctx, animalProvider, personListProvider,
                  deliveryNoteProvider) =>
              DeliveryNoteProvider(
                  animalsService: animalProvider,
                  personService: personListProvider),
        ),
      ],
      child: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, appSnapshot) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Tiertransporter',
            theme: ThemeData(
              primarySwatch: customColor,
              accentColor: customAccentColor,
              accentColorBrightness: Brightness.dark,
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  onPrimary: Colors.white,
                  primary: customColor,
                  padding: EdgeInsets.symmetric(vertical: 13, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            home: appSnapshot.connectionState != ConnectionState.done
                ? SplashScreen()
                : StreamBuilder(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (ctx, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return SplashScreen();
                      }
                      if (userSnapshot.hasData) {
                        return TabScreen(1);
                      }
                      return AuthScreen();
                    }),
            routes: {
              TabScreen.routeName: (ctx) => TabScreen(1),
              PdfScreen.routeName: (ctx) => PdfScreen(),
              AnimalListScreen.routeName: (ctx) => AnimalListScreen(),
              TransportScreen.routeName: (ctx) => TransportScreen(),
              EditTagNumberScreen.routeName: (ctx) =>
                  StreamProvider<List<Animal>>(
                    create: (_) => AnimalStreamProvider().allAnimals,
                    child: EditTagNumberScreen(),
                  ),

              EditAnimalScreen.routeName: (ctx) => EditAnimalScreen(),
              EditPersonScreen.routeName: (ctx) => EditPersonScreen(),
              EditTransportScreen.routeName: (ctx) => EditTransportScreen(),
              EditUserSettingsScreen.routeName: (ctx) =>
                  EditUserSettingsScreen(),
              AuthScreen.routeName: (ctx) => AuthScreen(),
            },
            onUnknownRoute: (settings) {
              return MaterialPageRoute(builder: (ctx) => TabScreen(1));
            },
          );
        },
      ),
    );
  }
}
