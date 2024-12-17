import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../Services/database_service.dart';

class EntryPage extends StatefulWidget {
  const EntryPage({super.key});

  @override
  State<EntryPage> createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {
  final DatabaseService _databaseService = DatabaseService.instance;
  List<Map<String, dynamic>> _entries = [];
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _minutesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchEntries();
  }

  Future<void> _fetchEntries() async {
    final entries = await _databaseService.getEntries();
    setState(() {
      _entries = entries;
    });
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _addEntry() async {
    if (_hoursController.text.isNotEmpty && _minutesController.text.isNotEmpty) {
      int hours = int.parse(_hoursController.text);
      int minutes = int.parse(_minutesController.text);

      if (hours < 0 || minutes < 0 || minutes >= 60) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid hours and minutes!')),
        );
        return;
      }

      DateTime date = _selectedDate;
      await _databaseService.addEntry(
        date.year.toString(),
        date.month.toString(),
        weekNumberer(date).toString(),
        date.day.toString(),
        (60 * hours + minutes),
      );

      setState(() {
        _entries.insert(0, {
          'date': _selectedDate,
          'hours': hours,
          'minutes': minutes,
        });
        _entries.sort((a, b) => b['date'].compareTo(a['date']));
        _hoursController.clear();
        _minutesController.clear();
      });
    }
  }

  void _deleteEntry(int index) async {
    await _databaseService.deleteEntry(_entries[index]['Id']);
    setState(() {
      _entries.removeAt(index);
    });
  }

  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  int weekNumberer(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy = ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add New Entry',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected Date: ${DateFormat.yMMMMd().format(_selectedDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    TextButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Pick Date'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _hoursController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Hours',
                    hintText: 'e.g., 2',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _minutesController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Minutes',
                    hintText: 'e.g., 35',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _addEntry,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (query) {
                    setState(() {}); // Update the state when the search query changes
                  },
                  decoration: InputDecoration(
                    labelText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Entries',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Year', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Month', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Week', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Day', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Hours', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Minutes', style: TextStyle(fontWeight: FontWeight.bold))),
                  DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                ],
                rows: _entries
                    .where((entry) {
                      String query = _searchController.text.toLowerCase();
                      return entry['date'].toString().toLowerCase().contains(query) ||
                          entry['hours'].toString().toLowerCase().contains(query) ||
                          entry['minutes'].toString().toLowerCase().contains(query);
                    })
                    .map((entry) {
                      DateTime date = entry['date'] != null ? DateTime.parse(entry['date']) : DateTime.now();
                      int weekNumber = weekNumberer(date);
                      return DataRow(
                        cells: [
                          DataCell(Text('${date.year}')),
                          DataCell(Text('${date.month.toString().padLeft(2, '0')}')),
                          DataCell(Text('$weekNumber')),
                          DataCell(Text('${date.day}')),
                          DataCell(Text('${entry['hours']}')),
                          DataCell(Text('${entry['minutes']}')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editEntry(_entries.indexOf(entry)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteEntry(_entries.indexOf(entry)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _editEntry(int index) {
    setState(() {
      _selectedDate = _entries[index]['date'];
      _hoursController.text = _entries[index]['hours'].toString();
      _minutesController.text = _entries[index]['minutes'].toString();
      _deleteEntry(index);
    });
  }
}
