class GroupSchedule {
  String? nameGroup;
  List<TimeSlot>? timeSlots;

  GroupSchedule(this.nameGroup, this.timeSlots);
}

class TimeSlot {
  String? day;
  String? startTime;
  String? endTime;
}
