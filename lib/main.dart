import 'package:flutter/material.dart';
import 'package:secure_notes/localization/demo_localisations.dart';
import 'package:secure_notes/screens/auth_screen.dart';
import 'package:secure_notes/screens/home_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale locale) {
    final state = context.findAncestorStateOfType<_MyAppState>();
    if (state != null) {
      state.setLocale(locale);
    }
  }

  @override
  State<MyApp> createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {
  Locale? _locale;

  void setLocale(Locale locale){
    setState(() {
      _locale = locale;
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Notes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      locale: _locale,
      localizationsDelegates: [
        DemoLocalization.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en', 'US'),
        Locale('et', 'EE'),
        Locale('uk', 'UA')
      ],

      localeListResolutionCallback: (locales, supportedLocales) {
        if (locales == null || locales.isEmpty) {
          // If the locales list is null or empty, return the first supported locale
          return supportedLocales.first;
        }

        for (var locale in locales) {
          // if (locale != null) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
          // }
        }
        // If no exact language match is found, fallback to the first supported locale
        return supportedLocales.first;
      },




      initialRoute: '/',
      routes: {
        '/': (context) => AuthScreen(), // Authentication Screen
        '/home': (context) => HomeScreen(), // Home Screen
      },
    );
  }
}
