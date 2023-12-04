import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:swapp/pages/home.dart';
import 'package:swapp/pages/recuperar_contraseña.dart';
import 'package:swapp/pages/registro.dart';
import 'package:swapp/pages/login.dart';
import 'package:swapp/widgets/make_offer.dart';
import 'package:swapp/widgets/group_schedule_form.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(SwApp());
}

final key = GlobalKey<GroupScheduleFormState>();

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
      initialRoute: '/realizar-oferta',
      routes: {
        '/formulario-grupo': (context) => GroupScheduleForm(key: key),
        '/realizar-oferta': (context) => MakeOffer(userEmail: "ssss"),
        '/recuperar_contraseña': (context) => PasswordRecoveryPage(),
        '/registro': (context) => RegistrationPage(),
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(
            userEmail: ModalRoute.of(context)?.settings.arguments as String),
      },
    );
  }
}
