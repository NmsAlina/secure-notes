import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:secure_notes/localization/localization_helper.dart';
import 'package:secure_notes/main.dart';
import 'package:secure_notes/models/language.dart';

//Authentification logic

class Authentication{

  static final _auth = LocalAuthentication();

  static Future<bool> canAuthenticate() async =>
    await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  
  static Future<bool> authenticationProcess() async {
    try{
      if(!await canAuthenticate()) return false;
      return await _auth.authenticate(localizedReason: 'Can enter the App');
    }catch(e){
      print('Error $e');
      return false;
    }
  }
}

// Screen itself

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {

void _changeLanguage(Language? language) {
  Locale _temp;

  if (language != null) {
    switch(language.languageCode){
      case 'en':
        _temp = Locale(language.languageCode, 'US');
        break;

      case 'et':
        _temp = Locale(language.languageCode, 'EE');
        break;

      case 'uk':
        _temp = Locale(language.languageCode, 'UA');
        break;

      default:
        _temp = Locale(language.languageCode, 'US');
    }

    MyApp.setLocale(context, _temp);
  }
}


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        actions: <Widget>[
          Padding(padding: EdgeInsets.all(8.0),
          child: DropdownButton(
            onChanged: (Language? language){
              _changeLanguage(language);
            },
            underline: SizedBox(),
            icon: Icon(Icons.language, color: Colors.white),
            items: Language.languageList().map((lang) => DropdownMenuItem(
              value: lang,
              child: Row(
                children: 
                  <Widget>[
                    Text(lang.flag), Text('  '), Text(lang.name)
                  ],
                ),
              )).toList(),
          ),
          )
        ],
      ),
      backgroundColor: Colors.indigo,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                getTranslated(context, 'welcome_top'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5,),

              Text(
                getTranslated(context, 'welcome_bottom'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 28,),

              Text(
                getTranslated(context, 'fingerprint_text'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),

              const SizedBox(height: 28,),
              
              const Divider(
                color: Colors.blueGrey,
              ),

              const SizedBox(height: 28,),

              ElevatedButton.icon(
                onPressed: () async{
                  bool auth = await Authentication.authenticationProcess();
                  print('Can get in: $auth');

                  if(auth){
                    Navigator.pushNamed(context, '/home');
                  }
                }, 
                icon: const Icon(Icons.fingerprint, size: 35,),
                label: Text(
                  getTranslated(context, 'authentificate'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 24.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

