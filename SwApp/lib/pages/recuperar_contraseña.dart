import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordResetScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      // Envío de correo electrónico de restablecimiento exitoso
      // Muestra un mensaje al usuario informando que se ha enviado un correo para restablecer la contraseña.
    } catch (e) {
      // Manejar el error si ocurre alguno durante el envío del correo
      print("Error al enviar el correo de restablecimiento: $e");
      // Muestra un mensaje de error al usuario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3A9193),
                Color(0xFF28D5D9),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Text(
                'Recuperar contraseña',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontFamily: 'SF UI Text',
                  fontWeight: FontWeight.w700,
                  height: 0,
                ),
              ),
            ),
            SizedBox(height: 10.0), // Espacio entre el título y el siguiente texto
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Ingresa tu email para enviarte un correo de restablecimiento de tu contraseña',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black.withOpacity(0.56),
                  fontSize: 18,
                  fontFamily: 'SF UI Text',
                  fontWeight: FontWeight.w400,
                  height: 0,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                String email = _emailController.text.trim();
                if (email.isNotEmpty) {
                  _resetPassword(email);
                } else {
                  // Muestra un mensaje al usuario indicando que debe ingresar un correo electrónico válido
                }
              },
              child: Text('Enviar Correo de Recuperación'),
            ),
          ],
        ),
      ),
    );
  }
}

