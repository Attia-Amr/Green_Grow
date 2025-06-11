
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  List<Map<String, dynamic>> tasks = [];
  TextEditingController taskController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  DateTime? selectedDate;
  DateTime? filterDate;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedTasks = prefs.getString('todo_tasks');
    if (savedTasks != null) {
      setState(() {
        tasks = List<Map<String, dynamic>>.from(
          json.decode(savedTasks),
        );
      });
    }
  }

  Future<void> saveTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encoded = json.encode(tasks);
    await prefs.setString('todo_tasks', encoded);
  }

  Future<void> selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        dueDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  void addTask() {
    if (taskController.text.isNotEmpty && dueDateController.text.isNotEmpty) {
      setState(() {
        tasks.add({
          'task': taskController.text,
          'dueDate': selectedDate != null ? selectedDate!.toIso8601String() : DateTime.now().toIso8601String(),
          'completed': false,
        });
        taskController.clear();
        dueDateController.clear();
        selectedDate = null;
      });
      saveTasks();
    }
  }

  Future<void> editDueDate(int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(tasks[index]['dueDate']),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        tasks[index]['dueDate'] = picked.toIso8601String();
      });
      saveTasks();
    }
  }

  List<Map<String, dynamic>> getFilteredTasks() {
    if (filterDate == null) {
      return tasks;
    } else {
      return tasks.where((task) {
        DateTime taskDate = DateTime.parse(task['dueDate']);
        return taskDate.isBefore(filterDate!) || taskDate.isAtSameMomentAs(filterDate!);
      }).toList();
    }
  }

  void markTaskAsCompleted(int index) {
    setState(() {
      tasks[index]['completed'] = true;
    });
    saveTasks();
  }

  void removeTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = getFilteredTasks();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 242, 242),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(85),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(top: 15),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
              ),
            ),
            title: const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                '🌱 My List',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(255, 238, 241, 240),
                  shadows: [
                    Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black)
                  ],
                ),
              ),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 15, 77, 48),
                    Color.fromARGB(255, 5, 14, 8),
                  ],
                  stops: [0.3, 6.0],
                  end: Alignment.topLeft,
                  begin: Alignment.bottomRight,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'Add New Task',
                fillColor: Colors.grey[200],
                filled: true,
                labelStyle: const TextStyle(color: Color.fromARGB(255, 24, 61, 26)),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 24, 61, 26)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 24, 61, 26)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 24, 61, 26), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: dueDateController,
              readOnly: true,
              onTap: () => selectDueDate(context),
              decoration: InputDecoration(
                labelText: 'Select Deadline',
                fillColor: Colors.grey[200],
                filled: true,
                suffixIcon: const Icon(Icons.calendar_today, color: Color.fromARGB(255, 24, 61, 26)),
                labelStyle: const TextStyle(color: Color.fromARGB(255, 24, 61, 26)),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 24, 61, 26)),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 24, 61, 26)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 24, 61, 26), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Add Task",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 24, 61, 26),
              ),
              onPressed: addTask,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: filteredTasks.isEmpty
                  ? const Center(child: Text("No tasks yet!"))
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Card(
                          color: const Color.fromARGB(255, 241, 241, 241),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          child: ListTile(
                            leading: Icon(
                              task['completed']
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: task['completed']
                                  ? const Color.fromARGB(255, 30, 82, 34)
                                  : Colors.grey,
                            ),
                            title: Text(
                              task['task'],
                              style: TextStyle(
                                decoration: task['completed']
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "Due: ${DateTime.parse(task['dueDate']).toLocal().toString().split(' ')[0]}",
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check),
                                  color: const Color.fromARGB(255, 40, 107, 44),
                                  onPressed: () => markTaskAsCompleted(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: const Color.fromARGB(255, 71, 148, 211),
                                  onPressed: () => editDueDate(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: const Color.fromARGB(255, 194, 68, 59),
                                  onPressed: () => removeTask(index),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

