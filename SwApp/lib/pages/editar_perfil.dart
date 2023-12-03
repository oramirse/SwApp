import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class EditProfilePage extends StatefulWidget {
  final String userEmail;

  EditProfilePage({required this.userEmail});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  bool _isEditingPhone = false;
  bool _isEditingPassword = false;
  bool _isEditingName = false;

  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _nameController = TextEditingController();

  String _profileImageUrl = '';
  String nombre = '';
  String phoneNumber = '';
  String contrasena = '';

  File? _imageFile;
  late DocumentReference _userDocument;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _userDocument = FirebaseFirestore.instance.collection('usuarios').doc(user.uid);
        DocumentSnapshot userData = await _userDocument.get();
        setState(() {
          nombre = userData['nombre'];
          phoneNumber = userData['numeroTelefono'];
          _profileImageUrl = userData['image'];
          contrasena = userData['contraseña'];
        });
      }
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
    }
  }

  Future<void> saveChanges() async {
    try {
      if (_isEditingName) {
        setState(() {
          nombre = _nameController.text.trim();
          _isEditingName = false;
        });

        await _userDocument.update({'nombre': nombre});
      }

      String newPassword = _passwordController.text.trim();
      if (_isEditingPassword && newPassword.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          await user.updatePassword(newPassword);
        }
      }

      if (_imageFile != null) {
        String userId = FirebaseAuth.instance.currentUser!.uid;
        String fileName = 'perfil_$userId.jpg';

        firebase_storage.Reference ref =
        firebase_storage.FirebaseStorage.instance.ref().child('profile_images').child(fileName);

        await ref.putFile(_imageFile!);
        String downloadURL = await ref.getDownloadURL();

        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).update({
            'image': downloadURL,
          });
        }

        setState(() {
          _profileImageUrl = downloadURL;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cambios guardados correctamente.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar los cambios.'),
        ),
      );
      print('Error al guardar los cambios: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700
          ),
        ),
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
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60.0,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!) as ImageProvider<Object>?
                    : (_profileImageUrl.isNotEmpty ? NetworkImage(_profileImageUrl) as ImageProvider<Object>? : null),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              nombre,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            _buildInfoField(
              'Teléfono:',
              _isEditingPhone ? _phoneNumberController.text : phoneNumber,
              isEditable: _isEditingPhone,
              child: TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu número de teléfono',
                ),
              ),
              onSave: () {
                setState(() {
                  phoneNumber = _phoneNumberController.text.trim();
                  _isEditingPhone = false;
                });
              },
            ),
            _buildInfoField('Email:', widget.userEmail),
            _buildInfoField(
              'Contraseña:',
              _isEditingPassword ? _passwordController.text.replaceAll(RegExp(r'.'), '*') : '********',
              isEditable: _isEditingPassword,
              child: TextFormField(
                controller: _passwordController,
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu nueva contraseña',
                ),
              ),
              onSave: () {
                setState(() {
                  contrasena = _passwordController.text.trim();
                  _isEditingPassword = false;
                });
              },
            ),
            SizedBox(height: 16.0),
            Container(
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
              child: ElevatedButton(
                onPressed: saveChanges,
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  onPrimary: Colors.transparent,
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: Text(
                  'Confirmar Cambios',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value, {bool isEditable = false, Widget? child, Function()? onSave}) {
    IconData icon;
    switch (label) {
      case 'Teléfono:':
        icon = Icons.phone;
        break;
      case 'Email:':
        icon = Icons.email;
        break;
      case 'Contraseña:':
        icon = Icons.lock;
        break;
      default:
        icon = Icons.info;
    }

    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: isEditable ? child : Text(value),
      trailing: isEditable
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.check, color: Colors.green),
            onPressed: () {
              if (onSave != null) {
                onSave();
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.red),
            onPressed: () {
              setState(() {
                _isEditingPhone = false;
                _isEditingPassword = false;
              });
            },
          ),
        ],
      )
          : IconButton(
        icon: Icon(Icons.edit),
        onPressed: () {
          setState(() {
            _isEditingPhone = label.contains('Teléfono');
            _isEditingPassword = label.contains('Contraseña');
          });
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }
}
