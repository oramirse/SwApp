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
      _showMessageDialog('Asegúrate de registrar todos los campos');
    } else {
      registrarOfertar(groupSchedule);
    }
  }

  Future<void> registrarOfertar(GroupSchedule groupSchedule) async {
    _showMessageDialog('Oferta realizada con exito', pop: true);
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
              child: Text('OK'),
            ),
          ],
        );
      },
    ).then((_) {
      if (pop) Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      //Dar forma al contenedor
      padding: const EdgeInsets.all(16.0),
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //Titulo
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
