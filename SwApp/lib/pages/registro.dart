import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController nombresController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController numeroTelefonoController =
      TextEditingController();
  File? profileImage;
  XFile? _image;

  @override
  void dispose() {
    nombresController.dispose();
    emailController.dispose();
    contrasenaController.dispose();
    numeroTelefonoController.dispose();
    super.dispose();
  }

  Future<void> verificarExistenciaUsuario(BuildContext context) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    QuerySnapshot querySnapshot = await firestore
        .collection('usuarios')
        .where('email', isEqualTo: emailController.text)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Ya existe una cuenta con esta dirección de correo electrónico.'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      registrarUsuario();
    }
  }

  Future<void> registrarUsuario() async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: contrasenaController.text.trim(),
      );

      String userId = userCredential.user!.uid;

      FirebaseFirestore firestore = FirebaseFirestore.instance;
      var usuarioRef = firestore.collection('usuarios').doc(userId);

      String? imageUrl = await uploadImageToFirebaseStorage();
      await usuarioRef.set({
        'id': userId,
        'nombre': nombresController.text.trim(),
        'email': emailController.text.trim(),
        'numeroTelefono': numeroTelefonoController.text.trim(),
        'image': imageUrl,
        'contraseña': contrasenaController.text,
      });

      _showSuccessMessage();
      _redirectToLoginPage();
    } catch (e) {
      print('Error al registrar usuario: $e');
    }
  }

  Future<String?> uploadImageToFirebaseStorage() async {
    ByteData imageData = await rootBundle.load('assets/profile.jpg');
    List<int> byteData = imageData.buffer.asUint8List();
    Uint8List uint8List = Uint8List.fromList(byteData);

    try {
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      firebase_storage.UploadTask uploadTask = ref.putData(uint8List);
      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error al cargar la imagen: $e');
      return null;
    }
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Te has registrado con éxito'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _redirectToLoginPage() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3A9193),
                Color(0xFF28D5D9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(25.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Registro',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.0),
                Text(
                  'Nombre',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: nombresController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu nombre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    } else if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
                      return 'Ingresa solo letras en este campo';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    }
                    final emailRegex = RegExp(
                        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Ingresa un email válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Teléfono',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: numeroTelefonoController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu número de teléfono',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    } else if (value.length != 10 ||
                        !(value.startsWith('30') ||
                            value.startsWith('31') ||
                            value.startsWith('32'))) {
                      return 'Ingresa un número de teléfono válido';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Text(
                  'Contraseña',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: contrasenaController,
                  decoration: InputDecoration(
                    hintText: 'Ingresa tu contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Este campo es obligatorio';
                    } else if (value.length < 8) {
                      return 'La contraseña debe tener al menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 32.0),
                GestureDetector(
                  onTap: () {
                    if (_formKey.currentState != null &&
                        _formKey.currentState!.validate()) {
                      verificarExistenciaUsuario(context);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30.0),
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF3A9193),
                          Color(0xFF28D5D9),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(
                    '¿Ya tienes una cuenta? Inicia sesión',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
