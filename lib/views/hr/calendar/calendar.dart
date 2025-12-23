import 'dart:convert';
import 'package:erp/model/countrymodel.dart';
import 'package:erp/model/employeemodel.dart';
import 'package:erp/model/global.dart' as globals;
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
List<CountryModel> countryList = [];
bool isLoadingCountry = false;
int? selectedEventType;
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
final Map<int, String> eventTypeMap = {
  1: 'Attendance',
  2: 'Leave',
  3: 'Holiday',
  4: 'Business Trip',
  5: 'Time Off',
  6: 'WFH',
};
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
  List<EmployeeModel> employeeList = [];
  EmployeeModel? selectedEmployee;
  CountryModel? selectedCountry;
  bool isLoadingEmployee = false;

  void _clearFilters(void Function(VoidCallback fn) setModalState) {
    setModalState(() {
      selectedCountry = null;
      selectedEmployee = null;
      selectedEventType = null;
      employeeList.clear();
    });
  }

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
    getCountryList();
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
    _getEvent(year, month);
  }

  Future<void> getCountryList() async {
    setState(() => isLoadingCountry = true);

    var obj = <String, String>{
      'UserCD': globals.userCD,
      'SystemCD': 'HR',
    };

    String res = await api.apiCall('CountryApi/GetCountry', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        countryList = jsonData.map((e) => CountryModel.fromJson(e)).toList();
        _events = _buildEvents();
      });
    }

    setState(() => isLoadingCountry = false);
  }

  Future<List<EmployeeModel>> getEmployeeByCountry(String countryCode) async {
    var obj = {'CountryCD': countryCode};

    String res = await api.apiCall('EmployeeApi/GetUserProfile', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      return jsonData
          .map<EmployeeModel>((e) => EmployeeModel.fromJson(e))
          .toList();
    }
    return [];
  }

  void _showFilterDialog(BuildContext context) {
    int selectedMonth = selectedmonth;
    int selectedYear = selectedyear;
    int? selectedEventTypeLocal = selectedEventType;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<CountryModel>(
                  initialValue: selectedCountry,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.flag),
                  ),
                  items: countryList.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c.name),
                    );
                  }).toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    setModalState(() {
                      selectedCountry = value;
                      employeeList.clear();
                      selectedEmployee = null;
                      isLoadingEmployee = true;
                    });

                    final employees = await getEmployeeByCountry(value.code);

                    setModalState(() {
                      employeeList = employees;
                      isLoadingEmployee = false;
                    });
                  },
                ),

                const SizedBox(height: 16),

                /// 👤 EMPLOYEE DROPDOWN
                isLoadingEmployee
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<EmployeeModel>(
                        initialValue: selectedEmployee,
                        decoration: const InputDecoration(
                          labelText: 'Employee',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items: employeeList.map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e.empName),
                          );
                        }).toList(),
                        onChanged: employeeList.isEmpty
                            ? null
                            : (val) {
                                setModalState(() {
                                  selectedEmployee = val;
                                });
                              },
                      ),

                const SizedBox(height: 16),

                // Month-Year Picker
                InkWell(
                  onTap: () {
                    DatePicker.showDatePicker(
                      context,
                      pickerTheme: const DateTimePickerTheme(
                        showTitle: true,
                        confirm:
                            Text('Done', style: TextStyle(color: Colors.blue)),
                        cancel:
                            Text('Cancel', style: TextStyle(color: Colors.red)),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color.fromARGB(255, 124, 124, 124)),
                      borderRadius: BorderRadius.circular(3),
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
                DropdownButtonFormField<int>(
                  initialValue: selectedEventTypeLocal,
                  decoration: const InputDecoration(
                    labelText: 'Event Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event),
                  ),
                  items: eventTypeMap.entries.map((entry) {
                    return DropdownMenuItem<int>(
                      value: entry.key, // ✅ numeric value
                      child: Text(entry.value), // ✅ display text
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedEventTypeLocal =
                          val; // store selected numeric value locally
                    });
                  },
                  hint: const Text('Select Event Type'),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear Filters'),
                        onPressed: () {
                          _clearFilters(setModalState);
                          Navigator.pop(context);
                          _applyFilters(
                            name: '',
                            month: _focusedDay.month,
                            year: _focusedDay.year,
                            country: '',
                            eventType: '',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Apply'),
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            selectedEventType = selectedEventTypeLocal;
                          });
                          _applyFilters(
                            name: selectedEmployee?.empId ?? '',
                            month: selectedMonth,
                            year: selectedYear,
                            country: selectedCountry?.code ?? '',
                            eventType: selectedEventTypeLocal?.toString() ?? '',
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        });
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

    if (eventType.isEmpty) {
      eventType = '1,2,3,4,5,6';
    }

    var obj = <String, String>{
      'Year': year.toString(),
      'Month': month.toString(),
      'UserCD': name,
      'CountryCD': country,
      'Type': eventType,
    };

    String res = await api.apiCall('CalendarApi/CalendarEventSelect', obj);
    dynamic jsonData = jsonDecode(jsonDecode(res));

    if (jsonData is List) {
      setState(() {
        dataList =
            jsonData.map((item) => CalendarEvent.fromJson(item)).toList();
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
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: const Row(
                children: [
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
          Container(
            color: Colors.white,
            child: TableCalendar<Event>(
              firstDay: DateTime.utc(2019, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _selectedEvents.value = _getEventsForDay(selectedDay);
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadEventsForMonth(focusedDay.year, focusedDay.month);
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() => _calendarFormat = format);
              },
              eventLoader: _getEventsForDay,
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  if (events.isEmpty) return const SizedBox();
                  return Positioned(
                    bottom: 4,
                    child: Row(
                      children: events.take(3).map((e) {
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: _getEventColor(e.type),
                            shape: BoxShape.circle,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
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
                      color: Colors.white,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getEventColor(event.type),
                          foregroundColor: Colors.white,
                          child: Text(event.type),
                        ),
                        title: Text(event.title),
                        subtitle: Text(event.description),
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
