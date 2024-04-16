// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'secondPage.dart'; // Импортируем файл secondPage.dart

void main() => runApp(const HabitTrackerApp());

class HabitTrackerApp extends StatelessWidget {
  const HabitTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HabitTrackerHome(),
    );
  }
}

class HabitTrackerHome extends StatefulWidget {
  const HabitTrackerHome({Key? key}) : super(key: key);

  @override
  _HabitTrackerHomeState createState() => _HabitTrackerHomeState();
}

class _HabitTrackerHomeState extends State<HabitTrackerHome> {
  List<HabitModel> habits = [];
  TextEditingController habitController = TextEditingController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadHabits();
  }

  void loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      habits = HabitModel.fromJsonList(prefs.getStringList('habits') ?? []);
    });
  }

  void saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> habitsJson =
        habits.map((habit) => habit.toJson()).toList().cast<String>();
    prefs.setStringList('habits', habitsJson);
  }

  void addHabit(String habitName) {
    setState(() {
      habits.add(HabitModel(name: habitName, lastCompleted: null));
    });
    habitController.clear();
    saveHabits();
  }

  void editHabit(int index, String newName) {
    setState(() {
      habits[index].name = newName;
    });
    saveHabits();
  }

  void removeHabit(int index) {
    setState(() {
      habits.removeAt(index);
    });
    saveHabits();
  }

  void toggleCompletion(int index) {
    setState(() {
      habits[index].lastCompleted = DateTime.now();
    });
    saveHabits();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      body: _currentIndex == 0
          ? _buildHabitList()
          : const Center(child: Text('Statistics Page Content')),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _currentIndex,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.track_changes),
                  label: 'Tracker',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Statistics',
                ),
              ],
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SecondPage()),
                  );
                }
              },
            )
          : null,
    );
  }

  Widget _buildHabitList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              return HabitTile(
                habit: habits[index],
                onToggleCompletion: () => toggleCompletion(index),
                onEdit: (newName) => editHabit(index, newName),
                onDelete: () => removeHabit(index),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: habitController,
                  decoration: const InputDecoration(labelText: 'Enter Habit'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => addHabit(habitController.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HabitTile extends StatelessWidget {
  final HabitModel habit;
  final Function() onToggleCompletion;
  final Function(String) onEdit;
  final Function() onDelete;

  const HabitTile({Key? key, 
    required this.habit,
    required this.onToggleCompletion,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.lastCompleted != null;

    return ListTile(
      title: Text(habit.name),
      subtitle: isCompleted
          ? Text(
              'Last Completed: ${habit.lastCompleted!.toString().substring(0, 10)}')
          : const Text('Not Completed Yet'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            color: Colors.blue,
            onPressed: () async {
              String? newName = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return EditHabitDialog(initialValue: habit.name);
                },
              );
              if (newName != null && newName.isNotEmpty) {
                onEdit(newName);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: onDelete,
          ),
          IconButton(
            icon: const Icon(Icons.check_circle),
            color: isCompleted ? Colors.green : null,
            onPressed: onToggleCompletion,
          ),
        ],
      ),
    );
  }
}

class EditHabitDialog extends StatefulWidget {
  final String initialValue;

  const EditHabitDialog({Key? key, required this.initialValue}) : super(key: key);

  @override
  _EditHabitDialogState createState() => _EditHabitDialogState();
}

class _EditHabitDialogState extends State<EditHabitDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Habit'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(labelText: 'New Habit Name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            String newName = _controller.text.trim();
            if (newName.isNotEmpty) {
              Navigator.of(context).pop(newName);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class HabitModel {
  String name;
  DateTime? lastCompleted;

  HabitModel({required this.name, this.lastCompleted});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastCompleted': lastCompleted?.millisecondsSinceEpoch,
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      name: json['name'],
      lastCompleted: json['lastCompleted'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastCompleted'])
          : null,
    );
  }

  static List<HabitModel> fromJsonList(List<String> jsonList) {
    return jsonList
        .map((jsonString) => HabitModel.fromJson(Map<String, dynamic>.from(jsonString as Map)))
        .toList();
  }
}
