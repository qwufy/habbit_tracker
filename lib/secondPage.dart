// ignore_for_file: file_names, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts; // Make sure to import charts_flutter
import 'main.dart'; // Import main.dart to navigate to HabitTrackerHome

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Statistics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Habit Streak Calendar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Correct usage of TextStyle
            ),
            const SizedBox(height: 16),
            Container(
              height: isMobile ? 150 : 300, // Adjust height based on screen size
              child: const Placeholder(), // Placeholder for calendar widget
            ),
            const SizedBox(height: 32),
            const Text(
              'Habit Statistics',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Correct usage of TextStyle
            ),
            const SizedBox(height: 16),
            Expanded(
              child: charts.BarChart(
                _createSampleData(), // Call a function to create sample data
                animate: true,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: 1,
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
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HabitTrackerHome()),
                  );
                }
              },
            )
          : null,
    );
  }

  // Function to create sample data for the bar chart
  List<charts.Series<HabitData, String>> _createSampleData() {
    final data = [
      HabitData('Habit 1', 10),
      HabitData('Habit 2', 20),
      HabitData('Habit 3', 15),
    ];

    return [
      charts.Series<HabitData, String>(
        id: 'Habits',
        domainFn: (HabitData habit, _) => habit.habitName,
        measureFn: (HabitData habit, _) => habit.habitValue,
        data: data,
      ),
    ];
  }
}

// Model class for habit data
class HabitData {
  final String habitName;
  final int habitValue;

  HabitData(this.habitName, this.habitValue);
}
