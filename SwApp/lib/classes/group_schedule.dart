class GroupSchedule {
  String? nameGroup;
  List<TimeSlot>? timeSlots;

  GroupSchedule(this.nameGroup, this.timeSlots);
}

class TimeSlot {
  String? day;
  String? startTime;
  String? endTime;

  TimeSlot() {
    this.day = null;
    this.startTime = null;
    this.endTime = null;
  }
}
