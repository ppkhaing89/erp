 
class CalendarEvent {
  // final String country;
  // final String staffName;
  final String type; // Attendance, Leave, Holiday, etc.
  final String title;
  final String start;
  final String end;
  final String description;

  CalendarEvent({
    // required this.country,
    // required this.staffName,
    required this.type,
    required this.title,
    required this.start,
    required this.end,
    required this.description,
  });

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
        type: json['mobiletype'] ?? '',
        title: json['mobiletitle'] ?? '',
        start: json['start'] ?? '',
        end: json['end'] ?? '',
        description: json['description'] ?? ''
    );
  }
}