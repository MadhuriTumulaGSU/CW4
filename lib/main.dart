import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class Plan {
  String name;
  String description;
  String status;

  Plan({
    required this.name,
    required this.description,
    required this.status,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Plan> adoptionPlans = [];
  List<Plan> travelPlans = [];
  int _selectedIndex = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _status = 'Pending';

  void _addPlan() {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) return;

    Plan newPlan = Plan(
      name: _nameController.text,
      description: _descriptionController.text,
      status: _status,
    );

    setState(() {
      if (_selectedIndex == 0) {
        adoptionPlans.add(newPlan);
      } else {
        travelPlans.add(newPlan);
      }
    });

    _nameController.clear();
    _descriptionController.clear();
  }

  void _showCreatePlanDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Create Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Plan Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Plan Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addPlan();
                Navigator.pop(context);
              },
              child: Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _toggleStatus(int index) {
    setState(() {
      if (_selectedIndex == 0) {
        adoptionPlans[index].status =
            adoptionPlans[index].status == 'Pending' ? 'Completed' : 'Pending';
      } else {
        travelPlans[index].status =
            travelPlans[index].status == 'Pending' ? 'Completed' : 'Pending';
      }
    });
  }

  void _removePlan(int index) {
    setState(() {
      if (_selectedIndex == 0) {
        adoptionPlans.removeAt(index);
      } else {
        travelPlans.removeAt(index);
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Plan> currentPlans = _selectedIndex == 0 ? adoptionPlans : travelPlans;

    return Scaffold(
      appBar: AppBar(
        title: Text('Plan Manager'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: currentPlans.length,
                itemBuilder: (context, index) {
                  Plan plan = currentPlans[index];
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
                        _toggleStatus(index);
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
                    child: ListTile(
                      title: Text(
                        plan.name,
                        style: TextStyle(
                          decoration: plan.status == 'Completed'
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Text('Status: ${plan.status}\n${plan.description}'),
                      trailing: Icon(
                        plan.status == 'Completed'
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: plan.status == 'Completed' ? Colors.green : Colors.red,
                      ),
                      onTap: () => _toggleStatus(index),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _showCreatePlanDialog,
              child: Text('Create Plan'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Adoption Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.airplane_ticket),
            label: 'Travel Plans',
          ),
        ],
      ),
    );
  }
}