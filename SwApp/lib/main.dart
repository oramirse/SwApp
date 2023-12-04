import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:swapp/pages/home.dart';
import 'package:swapp/pages/recuperar_contraseña.dart';
import 'package:swapp/pages/registro.dart';
import 'package:swapp/pages/login.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(SwApp());
}

class SwApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SwApp',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(width: 1, color: Colors.teal),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(width: 1, color: Colors.teal),
          ),
        ),
        fontFamily: 'SF UI  Text',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: '/login',
      routes: {
        '/recuperar_contraseña': (context) => PasswordRecoveryPage(),
        '/registro': (context) => RegistrationPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(userEmail: ModalRoute.of(context)?.settings.arguments as String),
      },
    );
  }
}