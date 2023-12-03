import 'package:flutter/material.dart';
import 'package:swapp/widgets/group_schedule_form.dart';
import 'package:swapp/classes/group_schedule.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MakeOffer extends StatefulWidget {
  final String userEmail;

  const MakeOffer({required this.userEmail});

  @override
  _MakeOfferState createState() => _MakeOfferState();
}

class _MakeOfferState extends State<MakeOffer> {
  final key = GlobalKey<GroupScheduleFormState>();

  void _offert() {
    GroupSchedule? groupSchedule = key.currentState?.getDataForm();
    if (groupSchedule == null) {
      _showFailMessage();
    } else {
      registrarOfertar(groupSchedule);
    }
  }

  Future<void> registrarOfertar(GroupSchedule groupSchedule) async {
    _showSuccessMessage();
  }

  void _showFailMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Asegurese de registrar todos los campos'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Te has registrado con éxito'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: ShapeDecoration(
            color: Color(0xFFFFFEFE),
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 2, color: Color(0xFF408E90)),
              borderRadius: BorderRadius.circular(20),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x3F000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 16),
              Text("Realizar oferta",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center),
              SizedBox(height: 20),
              //Formulario para agregar el grupo con su horario
              GroupScheduleForm(key: key),
              SizedBox(height: 20),
              //Boton de realizar la oferta
              GestureDetector(
                onTap: () {
                  _offert();
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
                      'Ofertar',
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
          ),
        ));
  }
}
