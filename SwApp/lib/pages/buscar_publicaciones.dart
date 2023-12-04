import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:swapp/widgets/make_offer.dart';


class SearchPostsPage extends StatefulWidget {
  final String userEmail;
  SearchPostsPage({required this.userEmail});
  @override
  _SearchPostsPageState createState() => _SearchPostsPageState();
}

class _SearchPostsPageState extends State<SearchPostsPage> {
  String filterSubject = '';
  List<String> subjectList = [];

  @override
  void initState() {
    super.initState();
    obtenerAsignaturas();
  }

  Future<void> obtenerAsignaturas() async {
    CollectionReference asignaturasCollection =
    FirebaseFirestore.instance.collection('asignaturas');

    DocumentSnapshot doc =
    await asignaturasCollection.doc('lista_asignaturas').get();

    List<String> asignaturas = List<String>.from(doc['lista']);
    setState(() {
      subjectList = asignaturas;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Buscar publicaciones',
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ingresa el nombre de la asignatura',
                prefixIcon: Icon(
                    Icons.search,
                    color: Colors.teal,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.teal,
                    width: 1.0,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(
                    color: Colors.teal,
                    width: 1.0,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  filterSubject = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('publicaciones')
                  .where('email_usuario', isNotEqualTo: currentUser?.email)
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No hay publicaciones disponibles.'));
                }

                var filteredPosts = filterSubject.isEmpty
                    ? snapshot.data!.docs
                    : snapshot.data!.docs
                    .where((doc) => doc['asignatura'].toString().toLowerCase().startsWith(filterSubject))
                    .toList();

                return filteredPosts.isEmpty
                    ? Center(child: Text('No se encontraron publicaciones.'))
                    : ListView.builder(
                  itemCount: filteredPosts.length,
                  itemBuilder: (BuildContext context, int index) {
                    var postData = filteredPosts[index].data() as Map<String, dynamic>;
                    var daysOrder = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado'];
                    String formattedSchedule = '';

                    int i = 0;
                    for (var day in daysOrder) {
                      if (postData['franja_horaria'].containsKey(day)) {
                        var schedule = postData['franja_horaria'][day];
                        formattedSchedule += '$day: ${schedule['inicio']} - ${schedule['fin']}';
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
                                  fontWeight: FontWeight.w700
                              ),
                            )
                        ),
                        subtitle: Column(
                          children: [
                            Row(
                              children: [
                                Icon(Icons.group, size: 30, color: Colors.teal,),
                                SizedBox(width: 10),
                                Text('Grupo ${postData['grupo']}'),
                                Spacer(),
                                Icon(Icons.search, size: 30, color: Colors.teal,),
                                SizedBox(width: 10),
                                Text('Grupo ${postData['grupo_deseado']}'),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 30, color: Colors.teal,),
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
                                    MaterialPageRoute(builder: (context) => MakeOffer(userEmail: widget.userEmail)),
                                  );
                                },
                                child: Text(
                                  'Realizar oferta',
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
          ),
        ],
      ),
    );
  }
}