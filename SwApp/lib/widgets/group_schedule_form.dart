import 'package:flutter/material.dart';
import 'package:swapp/classes/group_schedule.dart';

class GroupScheduleForm extends StatefulWidget {
  const GroupScheduleForm({required Key key}) : super(key: key);

  @override
  GroupScheduleFormState createState() => GroupScheduleFormState();
}

class GroupScheduleFormState extends State<GroupScheduleForm> {
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  var groupNameController = TextEditingController();
  List<TimeSlot> timeSlots = [];

  @override
  void initState() {
    super.initState();

    timeSlots.add(TimeSlot());
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.white,
        child: Form(
            key: globalKey,
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: 30),
                        // Campo de texto para el nombre del grupo
                        Text(
                          'Grupo',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                        ),
                        SizedBox(height: 20),
                        TextFormField(
                          controller: groupNameController,
                          decoration: InputDecoration(
                            hintText: 'Ingresa tu grupo',
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
                        SizedBox(height: 20),
                        //Campo para el horario
                        timeSlotRowContainer()
                      ],
                    )))));
  }

  Widget timeSlotRowContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            'Horario',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const ScrollPhysics(),
          itemCount: this.timeSlots.length,
          itemBuilder: (context, index) {
            return Column(
              children: <Widget>[
                Row(children: <Widget>[
                  Flexible(
                    fit: FlexFit.loose,
                    child: timeSlotRow(index),
                  ),
                ]),
              ],
            );
          },
          separatorBuilder: (context, index) => Divider(),
        ),
        //Boton de agregar
        Visibility(
          visible: this.timeSlots.length < 3,
          child: SizedBox(
            width: 35,
            child: IconButton(
              icon: Icon(
                Icons.add_circle,
                color: Colors.green,
              ),
              onPressed: () {
                _addTimeSlot();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget timeSlotRow(index) {
    return Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          children: [
            //Campo para seleccionar el dia
            /*
            Column(children: [
              Text(
                'Dia',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ]),
            */
            Expanded(
              child: DropdownButtonFormField<String>(
                value: timeSlots[index].day,
                onChanged: (newValue) {
                  setState(() {
                    timeSlots[index].day = newValue;
                  });
                },
                items: [
                  'Lunes',
                  'Martes',
                  'Miércoles',
                  'Jueves',
                  'Viernes',
                  'Sabado'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: 'Día',
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
            ),
            const SizedBox(width: 8.0),
            // Widget para seleccionar la hora de inicio
            /*
            Column(children: [
              Text(
                'Inicio',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ]),
            */
            Expanded(
              child: DropdownButtonFormField<String>(
                value: timeSlots[index].startTime,
                onChanged: (newValue) {
                  setState(() {
                    timeSlots[index].startTime = newValue;
                  });
                },
                items: [
                  '6:00 AM',
                  '7:00 AM',
                  '8:00 AM',
                  '9:00 AM',
                  '10:00 AM',
                  '11:00 AM',
                  '12:00 PM',
                  '1:00 PM',
                  '2:00 PM',
                  '3:00 PM',
                  '4:00 PM',
                  '5:00 PM',
                  '6:00 PM',
                  '7:00 PM',
                  '8:00 PM'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: 'Desde',
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
            ),
            SizedBox(width: 8.0),
            // Widget para seleccionar la hora de fin
            /*
            Column(children: [
              Text(
                'Fin',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ]),
            */
            Expanded(
              child: DropdownButtonFormField<String>(
                value: timeSlots[index].endTime,
                onChanged: (newValue) {
                  setState(() {
                    timeSlots[index].endTime = newValue;
                  });
                },
                items: [
                  '6:00 AM',
                  '7:00 AM',
                  '8:00 AM',
                  '9:00 AM',
                  '10:00 AM',
                  '11:00 AM',
                  '12:00 PM',
                  '1:00 PM',
                  '2:00 PM',
                  '3:00 PM',
                  '4:00 PM',
                  '5:00 PM',
                  '6:00 PM',
                  '7:00 PM',
                  '8:00 PM'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: 'Hasta',
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
            ),
            //Boton de eliminar
            Visibility(
              visible: index > 0,
              child: SizedBox(
                width: 35,
                child: IconButton(
                  icon: Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    _removeTimeSlot(index);
                  },
                ),
              ),
            )
          ],
        ));
  }

  void _addTimeSlot() {
    setState(() {
      this.timeSlots.add(TimeSlot());
    });
  }

  void _removeTimeSlot(index) {
    setState(() {
      if (this.timeSlots.length > 1) {
        this.timeSlots.removeAt(index);
      }
    });
  }

  //Funcion para obtener la informacion del formulario. Si algun campo esta vacio devuelve null
  GroupSchedule? getDataForm() {
    if (!globalKey.currentState!.validate()) {
      return null;
    }
    return GroupSchedule(groupNameController.text, timeSlots);
  }
}
