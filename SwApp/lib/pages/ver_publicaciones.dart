import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapp/pages/ver_ofertas.dart';

class UserPostsPage extends StatefulWidget {
  final String userEmail;
  UserPostsPage({required this.userEmail});

  @override
  _UserPostsPageState createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
  TextEditingController groupDesiredController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mis publicaciones',
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
            .collection('publicaciones')
            .where('email_usuario', isEqualTo: currentUser?.email)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tienes publicaciones.'));
          }

          List<DocumentSnapshot> userPosts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: userPosts.length,
            itemBuilder: (BuildContext context, int index) {
              var postData = userPosts[index].data() as Map<String, dynamic>;
              var postId = userPosts[index].id;
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
                if (postData['franja_horaria'].containsKey(day)) {
                  var schedule = postData['franja_horaria'][day];
                  formattedSchedule +=
                  '$day: ${schedule['inicio']} - ${schedule['fin']}';
                  if (++i < postData['franja_horaria'].keys.length) {
                    formattedSchedule += '\n';
                  }
                }
              }

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${postData['asignatura']}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        'Edita tu publicación',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                      ),
                                        textAlign: TextAlign.center,
                                    ),
                                    content: TextFormField(
                                      controller: groupDesiredController,
                                      decoration: InputDecoration(
                                        labelText: 'Grupo deseado',
                                      ),
                                    ),
                                    actions: <Widget>[
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
                                      TextButton(
                                        child: Text(
                                            'Guardar',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (currentUser != null) {
                                            await FirebaseFirestore.instance
                                                .collection('publicaciones')
                                                .doc(postId)
                                                .update({
                                              'grupo_deseado':
                                              groupDesiredController.text,
                                            });
                                          }
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              groupDesiredController.text =
                              postData['grupo_deseado'];
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                        'Elimina tu pulicación',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    content: Text(
                                      '¿Estás seguro de eliminar esta publicación?',
                                    ),
                                    actions: <Widget>[
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
                                      TextButton(
                                        child: Text(
                                            'Eliminar',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                        ),
                                        onPressed: () async {
                                          if (currentUser != null) {
                                            await FirebaseFirestore.instance
                                                .collection('publicaciones')
                                                .doc(postId)
                                                .delete();
                                          }
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
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
                          Text('Grupo ${postData['grupo']}'),
                          Spacer(),
                          Icon(
                            Icons.search,
                            size: 30,
                            color: Colors.teal,
                          ),
                          SizedBox(width: 10),
                          Text('Grupo ${postData['grupo_deseado']}'),
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
                      SizedBox(height: 30),
                      Container(
                        height: 30,
                        width: 150,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2D9DA0), Color(0xFF28D5D9)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OfferPage(postId: postId),
                              ),
                            );
                          },
                          child: Text(
                            'Ver ofertas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

