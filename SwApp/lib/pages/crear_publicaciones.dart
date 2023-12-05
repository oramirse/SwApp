import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:swapp/widgets/group_schedule_form.dart';
import 'package:swapp/classes/group_schedule.dart';

class MakePostsPage extends StatefulWidget {
  @override
  _MakePostsPageState createState() => _MakePostsPageState();
}

class _MakePostsPageState extends State<MakePostsPage> {
  final keyGroupScheduleForm = GlobalKey<GroupScheduleFormState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController desiredGroupNameController =
      TextEditingController();
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
                  //Titulo de la pagina
                  Text(
                    'Crear publicación',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  //Campo para buscar la asignatura
                ],
              )),
        ),
      ),
    );
  }
}
