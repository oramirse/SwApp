import 'package:flutter/material.dart';
import 'package:swapp/classes/group_schedule.dart';

class GroupScheduleForm extends StatefulWidget {
  @override
  _GroupScheduleFormState createState() => _GroupScheduleFormState();
}

class _GroupScheduleFormState extends State<GroupScheduleForm> {
  var groupNameController = TextEditingController();
  List<TimeSlot> timeSlots = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Campo de texto para el nombre del grupo
        const Text(
          'Grupo',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                spreadRadius: 7,
                offset: const Offset(1, 1),
                color: Colors.grey.withOpacity(0.2),
              ),
            ],
          ),
          child: TextField(
            controller: groupNameController,
            decoration: InputDecoration(
              hintText: "Ingresa tu grupo",
              prefixIcon: const Icon(
                Icons.email,
                color: Colors.teal,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.white,
                  width: 1.0,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ),
        //Campo para el horario
        const Text(
          'Horario',
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.left,
        ),
        TimeSlotRowContainer()
      ],
    );
  }

  Widget TimeSlotRowContainer() {
    return ListView.separated(
      shrinkWrap: true,
      physics: ScrollPhysics(),
      itemCount: this.timeSlots.length,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
            Row(children: <Widget>[
              Flexible(
                fit: FlexFit.loose,
                child: TimeSlotRow(index),
              ),
            ]),
          ],
        );
      },
      separatorBuilder: (context, index) => Divider(),
    );
  }

  Widget TimeSlotRow(index) {
    return Row(
      children: [
        //Campo para seleccionar el dia
        DropdownButton<String>(
          value: timeSlots[index].day,
          onChanged: (newValue) {
            timeSlots[index].day = newValue;
          },
          items: ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sabado']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),

        const SizedBox(width: 8.0),

        // Widget para seleccionar la hora de inicio
        DropdownButton<String>(
          value: timeSlots[index].startTime,
          onChanged: (newValue) {
            timeSlots[index].startTime = newValue;
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
        ),

        SizedBox(width: 8.0),

        // Widget para seleccionar la hora de fin
        DropdownButton<String>(
          value: timeSlots[index].endTime,
          onChanged: (newValue) {
            timeSlots[index].endTime = newValue;
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
        ),
        //Boton de agregar
        Visibility(
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
          visible: index == this.timeSlots.length - 1,
        ),
        //Boton de eliminar
        Visibility(
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
          visible: index > 0,
        )
      ],
    );
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

  GroupSchedule getDataForm() {
    return GroupSchedule(groupNameController.text, timeSlots);
  }
}
