import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:swapp/pages/buscar_publicaciones.dart';
import 'package:swapp/pages/crear_publicaciones.dart';
import 'package:swapp/pages/editar_perfil.dart';
import 'package:swapp/pages/ver_publicaciones.dart';



class HomePage extends StatefulWidget {
  final String userEmail;

  HomePage({required this.userEmail});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? userFullName;
  String? imagePath;
  String? userId;
  int selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    getDeviceToken();
    _getUserId();

  }
  void getDeviceToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? deviceToken = await messaging.getToken();
    print('Device Token: $deviceToken');
    saveDeviceToken(deviceToken);
  }

  void saveDeviceToken(String? deviceToken) {
    if (deviceToken != null) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userRef = firestore.collection('usuarios').doc(userId);

      userRef.update({
        'deviceToken': deviceToken,
      }).then((value) {
        print('Token de registro del dispositivo guardado para el usuario');
      }).catchError((error) {
        print('Error al guardar el token en la base de datos: $error');
      });
    }
  }

  Future<void> fetchUserData() async {
    final userSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('email', isEqualTo: widget.userEmail)
        .get();

    if (userSnapshot.docs.isNotEmpty) {
      final userData = userSnapshot.docs.first.data();
      setState(() {
        userFullName = '${userData['nombre']}';
        imagePath = '${userData['image']}';
      });
    }
  }

  void saveTokenToDatabase(String token) {
    print('Token guardado en la base de datos: $token');
  }


  @override
  Widget build(BuildContext context) {
    double w = MediaQuery
        .of(context)
        .size
        .width;
    double h = MediaQuery
        .of(context)
        .size
        .height;
    final colors = Theme
        .of(context)
        .colorScheme;
    final screens = [
      HomePage(userEmail: widget.userEmail),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: w,
              height: h * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D9DA0), Color(0xFF28D5D9)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:[
                  CircleAvatar(
                    radius: 52.0,
                    backgroundImage: imagePath != null ? NetworkImage(imagePath!) : null,
                  ),
                    SizedBox(height: 10),
                    Text(
                      'Hola, ${userFullName ?? ""}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ]
              )
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20),
              width: w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 16),
                  Text(
                      "¿Qué quieres hacer?",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center
                  ),
                ]
              )
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: [
                  buildGridButton("Buscar publicaciones", Icons.search, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPostsPage(userEmail: widget.userEmail)),
                    );
                  }),
                  buildGridButton("Crear una publicación", Icons.add_circle_outline, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MakePostsPage(userEmail: widget.userEmail)),
                    );
                  }),
                  buildGridButton("Ver tus publicaciones", Icons.mode_comment_outlined, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserPostsPage(userEmail: widget.userEmail)),
                    );
                  }),
                  buildGridButton("Editar tu perfil", Icons.mode_edit,() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfilePage(userEmail: widget.userEmail)),
                    );
                  }),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _signOut(),
              child: Text(
                "Cerrar sesión",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGridButton(String buttonText, IconData iconData, Function()? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[100],
        padding: EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            size: 50,
            color: Colors.teal,
          ),
          SizedBox(height: 10),
          Text(
            buttonText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  void _getUserId() async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('email', isEqualTo: widget.userEmail)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot userDoc = querySnapshot.docs.first;
      setState(() {
        userId = userDoc.get('id');
      });
    } else {
      print('No se encontró un usuario con el correo electrónico proporcionado.');
    }
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

}
