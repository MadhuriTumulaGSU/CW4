import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PlanManagerScreen(),
    );
  }
}

class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
  });
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];
  Map<DateTime, List<Plan>> plansByDate = {};

  DateTime _selectedDate = DateTime.now();

  void _addPlan(String name, String description, DateTime date) {
    setState(() {
      Plan newPlan = Plan(name: name, description: description, date: date);
      plans.add(newPlan);
      plansByDate.putIfAbsent(date, () => []).add(newPlan);
    });
  }

  void _updatePlan(int index, String name, String description, DateTime date) {
    setState(() {
      Plan oldPlan = plans[index];
      plans[index] = Plan(
        name: name,
        description: description,
        date: date,
        isCompleted: oldPlan.isCompleted,
      );
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      plans[index].isCompleted = !plans[index].isCompleted;
    });
  }

  void _removePlan(int index) {
    setState(() {
      plansByDate[plans[index].date]?.remove(plans[index]);
      plans.removeAt(index);
    });
  }

  void _showPlanDialog({int? index}) {
    String name = index != null ? plans[index].name : '';
    String description = index != null ? plans[index].description : '';
    DateTime date = index != null ? plans[index].date : _selectedDate;

    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController descriptionController = TextEditingController(text: description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(index == null ? 'Create Plan' : 'Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              ListTile(
                title: Text("Date: ${date.toLocal()}".split(' ')[0]),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null && picked != date) {
                    setState(() {
                      date = picked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (index == null) {
                  _addPlan(nameController.text, descriptionController.text, date);
                } else {
                  _updatePlan(index, nameController.text, descriptionController.text, date);
                }
                Navigator.pop(context);
              },
              child: Text('Save'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Plan Manager')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _selectedDate,
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            calendarFormat: CalendarFormat.week,
            selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDate = selectedDay;
              });
            },
            eventLoader: (day) => plansByDate[day] ?? [],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Dismissible(
                  key: Key(plan.name),
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.check, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      _toggleCompletion(index);
                      return false;
                    } else if (direction == DismissDirection.endToStart) {
                      return true;
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _removePlan(index);
                    }
                  },
                  child: GestureDetector(
                    onDoubleTap: () => _removePlan(index),
                    child: ListTile(
                      title: Text(
                        plan.name,
                        style: TextStyle(
                          decoration: plan.isCompleted ? TextDecoration.lineThrough : null,
                          color: plan.isCompleted ? Colors.green : Colors.black,
                        ),
                      ),
                      subtitle: Text(plan.description),
                      onLongPress: () => _showPlanDialog(index: index),
                      onTap: () => _toggleCompletion(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}