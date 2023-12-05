import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _confirmDialog() async {
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
              Text("Te redireccionaremos a WhatsApp para que te comuniques con:"),
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
              child: Text(
                  'Confirmar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                ),
              ),
              onPressed: () {
                acceptOffer();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                  'Cancelar',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                ),
              ),
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
                'lunes',
                'martes',
                'miércoles',
                'jueves',
                'viernes',
                'sábado'
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

                  var nombreUsuario =
                      userData['nombre'] ?? 'Nombre no disponible';
                  var imagenUsuario = userData['image'] ?? '';

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
                                    _confirmDialog();
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
}
