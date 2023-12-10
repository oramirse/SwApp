class GroupSchedule {
  String? groupName;
  List<TimeSlot>? timeSlots;

  GroupSchedule(this.groupName, this.timeSlots);

  // Función para convertir las franjas horarias a un mapa
  Map<String, dynamic> convertirHorariosAMapa() {
    Map<String, dynamic> horariosMapa = {};

    // Verificar que timeSlots no sea nulo antes de iterar
    timeSlots?.forEach((timeSlot) {
      String dia = timeSlot.day ?? '';
      String inicio = timeSlot.startTime ?? '';
      String fin = timeSlot.endTime ?? '';

      if (dia.isNotEmpty && inicio.isNotEmpty && fin.isNotEmpty) {
        // Agregar el mapa al día correspondiente
        horariosMapa[dia] = {'inicio': inicio, 'fin': fin};
      }
    });

    return horariosMapa;
  }
}

class TimeSlot {
  String? day;
  String? startTime;
  String? endTime;

  TimeSlot() {
    day = null;
    startTime = null;
    endTime = null;
  }
}