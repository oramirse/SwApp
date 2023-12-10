import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:swapp/widgets/group_schedule_form.dart';
import 'package:swapp/classes/group_schedule.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class MakePostsPage extends StatefulWidget {
  final String userEmail;
  const MakePostsPage({required this.userEmail});

  @override
  MakePostsPageState createState() => MakePostsPageState();
}

class MakePostsPageState extends State<MakePostsPage> {
  final GlobalKey<GroupScheduleFormState> _keyGroupScheduleForm =
  GlobalKey<GroupScheduleFormState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _desiredGroupNameController =
  TextEditingController();
  final TextEditingController _subjectFilterController =
  TextEditingController();

  List<String> subjectList = [];
  String? subjectName;

  @override
  void initState() {
    super.initState();
    obtenerAsignaturas();
  }

  void _makePost() {
    GroupSchedule? groupSchedule =
    _keyGroupScheduleForm.currentState?.getDataForm();
    if (!_formKey.currentState!.validate() || groupSchedule == null) {
      _showFailMessage();
    } else {
      _registrarPublicacion(groupSchedule);
    }
  }

  Future<void> _registrarPublicacion(GroupSchedule groupSchedule) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userID = user.uid;
        String? userEmail = user.email;

        Map<String, dynamic> publicacionData = {
          'asignatura': subjectName,
          'email_usuario': userEmail,
          'franja_horaria': groupSchedule.convertirHorariosAMapa(),
          'grupo': groupSchedule.groupName,
          'grupo_deseado': _desiredGroupNameController.text.trim(),
          'id_usuario': userID,
        };

        await FirebaseFirestore.instance
            .collection('publicaciones')
            .add(publicacionData);

        _showMessageDialog('Publicación creada con exito', pop: true);
      } else {
        _showMessageDialog('Error al obtener la informacion del usuario');
      }
    } catch (e) {
      _showMessageDialog(
          'Error al realizar la publicación, por favor intentelo mas tarde');
    }
  }

  void _showFailMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Asegurate de registrar correctamente todos los campos"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showMessageDialog(String message, {bool pop = false}) {
    showDialog(
      context: context,
      //Desactivar pulsasiones fuera del cuadro
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      if (pop) Navigator.pop(context);
    });
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
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
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
          padding: const EdgeInsets.all(25.0),
          child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //Titulo de la pagina
                  const Text(
                    'Crear publicación',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28.0),
                  //Campo para seleccionar la asignatura
                  const Text(
                    'Asignatura',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 8.0),
                  DropdownButtonFormField2<String>(
                    isExpanded: true,
                    isDense: true,
                    dropdownStyleData: DropdownStyleData(
                      maxHeight: 400,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    //hint: const Text("Selecciona la asignatura"),
                    items: subjectList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    value: subjectName,
                    onChanged: (value) {
                      setState(() {
                        subjectName = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Selecciona la asignatura',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: const BorderSide(
                          color: Colors.teal,
                          width: 1.0,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                    //Widget para habilitar el filtrado de la lista
                    dropdownSearchData: DropdownSearchData(
                      searchController: _subjectFilterController,
                      searchInnerWidgetHeight: 70,
                      searchInnerWidget: Container(
                        height: 70,
                        padding: const EdgeInsets.all(8),
                        child: TextFormField(
                          expands: true,
                          maxLines: null,
                          controller: _subjectFilterController,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'Buscar asignatura',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ),
                      searchMatchFn: (item, searchValue) {
                        return item.value
                            .toString()
                            .toLowerCase()
                            .contains(searchValue.toLowerCase());
                      },
                    ),
                    //Limpiar el valor de busqueda cuando se cierra el menu
                    onMenuStateChange: (isOpen) {
                      if (!isOpen) {
                        _subjectFilterController.clear();
                      }
                    },
                  ),
                  //Formulario para agregar el horario y el grupo
                  GroupScheduleForm(key: _keyGroupScheduleForm),
                  //Campo para el grupo deseado
                  const SizedBox(height: 20.0),
                  const Text(
                    'Grupo deseado',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _desiredGroupNameController,
                    decoration: InputDecoration(
                      hintText: 'Ingresa los grupos que deseas',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Este campo es obligatorio';
                      }
                      return null;
                    },
                  ),
                  //Boton para realizar la publicacion
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: () {
                      _makePost();
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30.0),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF3A9193),
                            Color(0xFF28D5D9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Publicar',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}