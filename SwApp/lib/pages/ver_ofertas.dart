import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class OfferPage extends StatefulWidget {
  final String postId;

  OfferPage({required this.postId});

  @override
  _OfferPageState createState() => _OfferPageState();
}

class _OfferPageState extends State<OfferPage> {
  String _phoneNumber = '';
  String _userName = '';
  String _userImage = '';
  Map<String, dynamic>? _offerData;

  Future<void> _confirmDialog(String offerUserId,
      Map<String, dynamic> offerData) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Aceptar oferta',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                  "Te redireccionaremos a WhatsApp para que te comuniques con:"),
              SizedBox(height: 16),
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(_userImage),
                ),
                title: Text(_userName),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Confirmar'),
              onPressed: () {
                setState(() {
                  _offerData = offerData;
                });
                sendNotification(offerUserId, widget.postId);
                acceptOffer();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ofertas de tu publicación',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('oferta')
            .where('id_publicacion', isEqualTo: widget.postId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No tienes ofertas para esta publicación.'),
            );
          }

          List<DocumentSnapshot> offers = snapshot.data!.docs;

          return ListView.builder(
            itemCount: offers.length,
            itemBuilder: (BuildContext context, int index) {
              var offerData = offers[index].data() as Map<String, dynamic>;


              var daysOrder = [
                'Lunes',
                'Martes',
                'Miércoles',
                'Jueves',
                'Viernes',
                'Sábado'
              ];
              String formattedSchedule = '';
              int i = 0;
              for (var day in daysOrder) {
                if (offerData['franja_horaria'].containsKey(day)) {
                  var schedule = offerData['franja_horaria'][day];
                  formattedSchedule +=
                  '$day: ${schedule['inicio']} - ${schedule['fin']}';
                  if (++i < offerData['franja_horaria'].keys.length) {
                    formattedSchedule += '\n';
                  }
                }
              }

              return FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(offerData['id_usuario'])
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data == null) {
                    return Text('Error al cargar los datos del usuario');
                  }

                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  if (userData == null || userData.isEmpty) {
                    return Text('Datos del usuario no encontrados');
                  }

                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Un usuario te ha ofrecido:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.group,
                                size: 30,
                                color: Colors.teal,
                              ),
                              SizedBox(width: 10),
                              Text('Grupo ${offerData['grupo_ofertado']}'),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 30,
                                color: Colors.teal,
                              ),
                              SizedBox(width: 10),
                              Text('$formattedSchedule'),
                            ],
                          ),
                          ButtonBar(
                            alignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF2D9DA0),
                                      Color(0xFF28D5D9)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _phoneNumber = userData['numeroTelefono'];
                                      _userName = userData['nombre'];
                                      _userImage = userData['image'];
                                    });
                                    _confirmDialog(
                                        offerData['id_usuario'], offerData);
                                  },
                                  child: Text(
                                    'Aceptar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF2D9DA0),
                                      Color(0xFF28D5D9)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: TextButton(
                                  onPressed: () async {
                                    rejectOfferNotification(offerData['id_usuario'], offerData);
                                    await FirebaseFirestore.instance
                                        .collection('oferta')
                                        .doc(offers[index].id)
                                        .delete();
                                    setState(() {});
                                  },
                                  child: Text(
                                    'Rechazar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void acceptOffer() async {
    String message = "Hola, te escribo desde SwApp. Me interesa tu oferta.";

    var whatsappUrl = "https://wa.me/$_phoneNumber?text=${Uri.encodeFull(
        message)}";

    try {
      await launch(whatsappUrl);
    } catch (e) {
      print('No se pudo abrir WhatsApp: $e');
    }
  }

  void sendNotification(String offerUserId, String postId) async {
    if (_offerData != null) {
      var postSnapshot = await FirebaseFirestore.instance
          .collection('publicaciones')
          .doc(postId)
          .get();

      if (postSnapshot.exists) {
        var postData = postSnapshot.data();
        String? asignatura = postData?['asignatura'];

        String postUserId = postData?['id_usuario'];

        var userSnapshot = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(postUserId)
            .get();

        if (userSnapshot.exists) {
          var userData = userSnapshot.data();
          String? nombreUsuario = userData?['nombre'];
          String message =
              '¡$nombreUsuario ha aceptado tu oferta del grupo ${_offerData?['grupo_ofertado']} para la asignatura $asignatura! Se comunicará contigo por medio de WhatsApp';

          var offerUserSnapshot = await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(offerUserId)
              .get();

          if (offerUserSnapshot.exists) {
            var offerUserData = offerUserSnapshot.data();
            String? offerUserDeviceToken = offerUserData?['deviceToken'];

            if (offerUserDeviceToken != null) {
              try {
                var response = await http.post(
                  Uri.parse('https://fcm.googleapis.com/fcm/send'),
                  headers: <String, String>{
                    'Content-Type': 'application/json',
                    'Authorization': 'key=AAAAjAnYaBM:APA91bHEctIdQqeibwrpA05g51PLO0Y4ehcjjRG8Knt_TE5NC3V5bp1IwZsCxKdsLTQ1CNx34RLBcP3e55v4IIIjFUcFzKm1u2GHXSegcHFnI-JkuLHIteI369X5ygwxwXg3dSxnoTpy',
                  },
                  body: jsonEncode(
                    <String, dynamic>{
                      'notification': <String, dynamic>{
                        'body': message,
                        'title': 'Oferta aceptada',
                      },
                      'priority': 'high',
                      'data': <String, dynamic>{
                        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                        'id': '1',
                        'status': 'done'
                      },
                      'to': offerUserDeviceToken,
                    },
                  ),
                );

                print('Respuesta de FCM: ${response.body}');
              } catch (e) {
                print('Error al enviar la notificación: $e');
              }
            } else {
              print(
                  'Token de dispositivo del usuario de la oferta no encontrado');
            }
          } else {
            print('Datos del usuario de la oferta no encontrados');
          }
        }
      }
    }
  }

  void rejectOfferNotification(String offerUserId,
      Map<String, dynamic> offerData) async {
    var offerUserSnapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(offerUserId)
        .get();

    if (offerUserSnapshot.exists) {
      var offerUserData = offerUserSnapshot.data();
      String? offerUserDeviceToken = offerUserData?['deviceToken'];

      if (offerUserDeviceToken != null) {
        var postSnapshot = await FirebaseFirestore.instance
            .collection('publicaciones')
            .doc(offerData['id_publicacion'])
            .get();

        if (postSnapshot.exists) {
          var postData = postSnapshot.data();
          String? asignatura = postData?['asignatura'];

          if (asignatura != null) {
            String message =
                'Tu oferta del grupo ${offerData['grupo_ofertado']} de la asignatura $asignatura ha sido rechazada.';

            try {
              var response = await http.post(
                Uri.parse('https://fcm.googleapis.com/fcm/send'),
                headers: <String, String>{
                  'Content-Type': 'application/json',
                  'Authorization': 'key=YOUR_SERVER_KEY',
                },
                body: jsonEncode(
                  <String, dynamic>{
                    'notification': <String, dynamic>{
                      'body': message,
                      'title': 'Oferta rechazada',
                    },
                    'priority': 'high',
                    'data': <String, dynamic>{
                      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                      'id': '1',
                      'status': 'rejected'
                    },
                    'to': offerUserDeviceToken,
                  },
                ),
              );

              print('Respuesta de FCM: ${response.body}');
            } catch (e) {
              print('Error al enviar la notificación: $e');
            }
          } else {
            print('Asignatura no encontrada en los datos de la publicación');
          }
        } else {
          print('Datos de la publicación no encontrados');
        }
      } else {
        print('Token de dispositivo del usuario de la oferta no encontrado');
      }
    } else {
      print('Datos del usuario de la oferta no encontrados');
    }
  }
}