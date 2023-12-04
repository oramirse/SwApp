import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserPostsPage extends StatefulWidget {
  final String userEmail;
  UserPostsPage({required this.userEmail});

  @override
  _UserPostsPageState createState() => _UserPostsPageState();
}

class _UserPostsPageState extends State<UserPostsPage> {
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
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No tienes publicaciones.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var postData =
              snapshot.data!.docs[index].data() as Map<String, dynamic>;
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
                  title: Center(
                    child: Text(
                      '${postData['asignatura']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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
