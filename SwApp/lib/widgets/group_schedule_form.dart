import 'package:flutter/material.dart';
import 'package:swapp/classes/group_schedule.dart';

class GroupScheduleForm extends StatefulWidget {
  const GroupScheduleForm({required Key key}) : super(key: key);

  @override
  GroupScheduleFormState createState() => GroupScheduleFormState();
}

class GroupScheduleFormState extends State<GroupScheduleForm> {
  var groupNameController = TextEditingController();
  List<TimeSlot> timeSlots = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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

  GroupSchedule? getDataForm() {
    String group = groupNameController.text;
    bool hasTimeSlotsNull = timeSlots.any((timeSlot) =>
        timeSlot.day == null ||
        timeSlot.day!.isEmpty ||
        timeSlot.startTime == null ||
        timeSlot.startTime!.isEmpty ||
        timeSlot.endTime == null ||
        timeSlot.endTime!.isEmpty);
    if (group == null || group.isEmpty || hasTimeSlotsNull) {
      return null;
    }
    return GroupSchedule(groupNameController.text, timeSlots);
  }
}
