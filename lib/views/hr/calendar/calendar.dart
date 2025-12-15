import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:erp/common/api.dart';
import 'package:erp/model/calendarmodel.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';

Api api = Api();
List<CalendarEvent> dataList = [];
Map<DateTime, List<Event>> _events = {};
String title = '';
String type = '';
String description = '';
DateTime end = DateTime.now();
DateTime start = DateTime.now();
int selectedyear = DateTime.now().year;
int selectedmonth = DateTime.now().month;
List<String> countryList = [];
String selectedCountry = '';
final List<String> monthAbbreviations = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec'
];
void main() {
  runApp(const Calendar());
}

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Calendar(),
    );
  }
}

class Event {
  final String title;
  final String type;
  final String description;

  Event({required this.title, required this.type, required this.description});
}

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime(selectedyear, selectedmonth, 1);
  DateTime? _selectedDay;

  void onTabTapped() {
    setState(() {
      _getEvent(selectedyear, selectedmonth);
    });
  }

  Future<void> _getEvent(int year, int month) async {
    _focusedDay = DateTime(year, month, 1);
    _selectedDay = _focusedDay;
    var obj = <String, String>{
      'Year': year.toString(),
      'Month': month.toString(),
      'Type': '1,2,3,4,5,',
    };

    String res = await api.apiCall('CalendarApi/CalendarEventSelect', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        dataList =
            jsonData.map((item) => CalendarEvent.fromJson(item)).toList();

        if (dataList.isNotEmpty) {
          start = DateTime.parse(dataList[0].start);
          end = DateTime.parse(dataList[0].end);
          title = dataList[0].title;
          description = dataList[0].description;
          type = dataList[0].type;
        }
        _events = _buildEvents();
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      });
    }
  }

  Map<DateTime, List<Event>> _buildEvents() {
    final Map<DateTime, List<Event>> map = {};

    for (var row in dataList) {
      final start = DateTime.parse(row.start.split('.').first);

      final dateKey = DateTime.utc(start.year, start.month, start.day);

      map.putIfAbsent(dateKey, () => []);

      map[dateKey]!.add(Event(
        title: row.title,
        type: row.type,
        description: row.description,
      ));
    }

    return map;
  }

  void showMonthYearPicker(BuildContext context) {
    DatePicker.showDatePicker(
      context,
      pickerTheme: const DateTimePickerTheme(
        showTitle: true,
        confirm: Text('Done', style: TextStyle(color: Colors.blue)),
        cancel: Text('Cancel', style: TextStyle(color: Colors.red)),
      ),
      minDateTime: DateTime(2000),
      maxDateTime: DateTime(2100),
      initialDateTime: DateTime.now(),
      dateFormat: 'MMM yyyy',
      locale: DateTimePickerLocale.en_us,
      onConfirm: (dateTime, List<int> index) async {
        setState(() {
          selectedyear = dateTime.year;
          selectedmonth = dateTime.month;
        });

        await _getEvent(selectedyear, selectedmonth);
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _selectedEvents.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadEventsForMonth(_focusedDay.year, _focusedDay.month);
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events[DateTime.utc(day.year, day.month, day.day)] ?? [];
  }

  Color _getEventColor(String type) {
    switch (type) {
      case "A":
        return Colors.blue;
      case "L":
        return Colors.green;
      case "H":
        return Colors.orange;
      case "T":
        return Colors.red;
      case "W":
        return Colors.purple;
      case "B":
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  void _loadEventsForMonth(int year, int month) async {
    setState(() {
      _getEvent(year, month);
    });
  }

//   void _showFilterDialog(BuildContext context) {
//   String selectedName = '';
//   int selectedMonth = selectedmonth;
//   int selectedYear = selectedyear;
//   String selectedCountry = '';
//   String selectedEventType = '';

//   showDialog(
//     context: context,
//     builder: (context) {
//       return AlertDialog(
//         title: const Text('Filter Events'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Name Input
//               TextField(
//                 decoration: const InputDecoration(labelText: 'Name'),
//                 onChanged: (val) {
//                   selectedName = val;
//                 },
//               ),
//               const SizedBox(height: 8),
              
//               // Month-Year Picker
//               InkWell(
//                 onTap: () {
//                   DatePicker.showDatePicker(
//                     context,
//                     pickerTheme: const DateTimePickerTheme(
//                       showTitle: true,
//                       confirm: Text('Done', style: TextStyle(color: Colors.blue)),
//                       cancel: Text('Cancel', style: TextStyle(color: Colors.red)),
//                     ),
//                     minDateTime: DateTime(2000),
//                     maxDateTime: DateTime(2100),
//                     initialDateTime: DateTime(selectedYear, selectedMonth),
//                     dateFormat: 'MMM yyyy',
//                     locale: DateTimePickerLocale.en_us,
//                     onConfirm: (dateTime, List<int> index) {
//                       setState(() {
//                         selectedYear = dateTime.year;
//                         selectedMonth = dateTime.month;
//                       });
//                     },
//                   );
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                   decoration: BoxDecoration(
//                       border: Border.all(color: Colors.grey),
//                       borderRadius: BorderRadius.circular(6)),
//                   child: Text("${monthAbbreviations[selectedMonth - 1]} $selectedYear"),
//                 ),
//               ),
//               const SizedBox(height: 8),

//               // Country Input
//               TextField(
//                 decoration: const InputDecoration(labelText: 'Country'),
//                 onChanged: (val) {
//                   selectedCountry = val;
//                 },
//               ),
//               const SizedBox(height: 8),

//               // Event Type Dropdown
//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(labelText: 'Event Type'),
//                 items: ['A', 'L', 'H', 'T', 'W', 'B']
//                     .map((e) => DropdownMenuItem(value: e, child: Text(e)))
//                     .toList(),
//                 onChanged: (val) {
//                   selectedEventType = val ?? '';
//                 },
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel', style: TextStyle(color: Colors.red)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // Apply filters
//               _applyFilters(
//                 name: selectedName,
//                 month: selectedMonth,
//                 year: selectedYear,
//                 country: selectedCountry,
//                 eventType: selectedEventType,
//               );
//             },
//             child: const Text('Apply'),
//           ),
//         ],
//       );
//     },
//   );
// }



// Future<void> _loadCountries() async {
//   try {
//     String res = await api.apiCall('YourApi/GetCountries', {});
//     dynamic jsonData = jsonDecode(jsonDecode(res));

//     if (jsonData is List) {
//       setState(() {
//         countryList = jsonData.map<String>((item) => item['CountryName'].toString()).toList();
//       });
//     }
//   } catch (e) {
//     print("Error loading countries: $e");
//   }
// }



void _showFilterDialog(BuildContext context) {
  String selectedName = '';
  int selectedMonth = selectedmonth;
  int selectedYear = selectedyear;
  String selectedCountry = '';
  String selectedEventType = '';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Text(
                'Filter Events',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20), 

              // Country Field
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Country',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                onChanged: (val) => selectedCountry = val,
              ),
              const SizedBox(height: 16),

              // Name Field
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (val) => selectedName = val,
              ),
              const SizedBox(height: 16),

              // Month-Year Picker
              InkWell(
                onTap: () {
                  DatePicker.showDatePicker(
                    context,
                    pickerTheme: const DateTimePickerTheme(
                      showTitle: true,
                      confirm: Text('Done', style: TextStyle(color: Colors.blue)),
                      cancel: Text('Cancel', style: TextStyle(color: Colors.red)),
                    ),
                    minDateTime: DateTime(2000),
                    maxDateTime: DateTime(2100),
                    initialDateTime: DateTime(selectedYear, selectedMonth),
                    dateFormat: 'MMM yyyy',
                    locale: DateTimePickerLocale.en_us,
                    onConfirm: (dateTime, List<int> index) {
                      setState(() {
                        selectedYear = dateTime.year;
                        selectedMonth = dateTime.month;
                      });
                    },
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${monthAbbreviations[selectedMonth - 1]} $selectedYear",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Icon(Icons.calendar_today, color: Colors.blue),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),


              // Event Type Dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Event Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                items: ['A', 'L', 'H', 'T', 'W', 'B']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => selectedEventType = val ?? '',
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyFilters(
                          name: selectedName,
                          month: selectedMonth,
                          year: selectedYear,
                          country: selectedCountry,
                          eventType: selectedEventType,
                        );
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    },
  );
}


Future<void> _applyFilters({
  required String name,
  required int month,
  required int year,
  required String country,
  required String eventType,
}) async {
  _focusedDay = DateTime(year, month, 1);
  _selectedDay = _focusedDay;

  var obj = <String, String>{
    'Year': year.toString(),
    'Month': month.toString(),
    'Name': name,
    'Country': country,
    'Type': eventType,
  };

  String res = await api.apiCall('CalendarApi/CalendarEventSelect', obj);
  dynamic jsonData = jsonDecode(jsonDecode(res));

  if (jsonData is List) {
    setState(() {
      dataList = jsonData.map((item) => CalendarEvent.fromJson(item)).toList();
      _events = _buildEvents();
      _selectedEvents.value = _getEventsForDay(_selectedDay!);
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          InkWell(
            onTap: () => _showFilterDialog(context),
            // showMonthYearPicker(context),
            // child: Container(
            //   decoration: BoxDecoration(
            //     color: Colors.white, // make selector stand out
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            //   child: Row(
            //     children: [
            //       const Icon(Icons.calendar_today, color: Colors.blue),
            //       const SizedBox(width: 8),
            //       Text(
            //         "${monthAbbreviations[selectedmonth - 1]} $selectedyear",
            //         style: const TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.black87,
            //         ),
            //       ),
            //       const Spacer(),
            //       const Icon(Icons.arrow_drop_down, color: Colors.black54),
            //     ],
            //   ),
            // ),
            child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: const Row(
      children:   [
        Icon(Icons.filter_list, color: Colors.blue),
        SizedBox(width: 8),
        Text(
          "Filter Events",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  ),
          ),
             const Padding(
      padding: EdgeInsets.only(top: 10), // ← SPACE
    ),

          TableCalendar<Event>(
            firstDay: DateTime.utc(2019, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay, 
             onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;  
              });  
              _loadEventsForMonth(focusedDay.year, focusedDay.month);
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _selectedEvents.value = _getEventsForDay(selectedDay);
            },
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: events.map((event) => Container()).toList(),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: ValueListenableBuilder<List<Event>>(
              valueListenable: _selectedEvents,
              builder: (context, value, _) {
                if (value.isEmpty) {
                  return const Center(
                      child: Text('No events for selected day.'));
                }
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final event = value[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getEventColor(event.type),
                          foregroundColor: Colors.white,
                          child: Text(event.type),
                        ),
                        title: Text(event.title),
                        subtitle: Text(event.description),
                        //trailing: Text(event.type),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
