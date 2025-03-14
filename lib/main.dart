import 'package:flutter/material.dart';
import 'bmi_calculator.dart';  // Import BMI calculator
import 'recipe_app.dart';  // Import Recipe App
import 'db_helper.dart';  // Your DB helper for managing todos
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initialize();

  // Load quotes from CSV
  final quotes = await loadQuotes();

  runApp(MyApp(quotes: quotes));
}

// Function to load quotes from CSV
Future<List<Map<String, String>>> loadQuotes() async {
  final csvString = await rootBundle.loadString('assets/quotes.csv');
  List<String> rows = csvString.split('\n');
  return rows.skip(1).map((row) {
    final parts = row.split(' - ');
    String quote = parts[0].trim();

    quote = quote.replaceAll('"', '').replaceAll('“', '').replaceAll('”', '');

    return {'quote': quote, 'author': parts.length > 1 ? parts[1].trim() : ''};
  }).toList();
}

class MyApp extends StatefulWidget {
  final List<Map<String, String>> quotes;

  const MyApp({required this.quotes});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App with Quotes',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.blueGrey[100],
        primarySwatch: Colors.blueGrey,
      ),
      home: Scaffold(
        body: _selectedIndex == 0
            ? TodoListPage(quotes: widget.quotes)  // Home page (Todo List with quotes)
            : _selectedIndex == 1
            ? RecipeApp()  // Navigate to Recipe page
            : BMICalculatorApp(),  // Navigate to BMI page
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,  // Set background color to pure white
          selectedItemColor: Color(0xFF666666),  // Set selected item color to lighter gray
          unselectedItemColor: Colors.grey,  // Set unselected item color to gray
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fastfood),
              label: 'Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: 'BMI',
            ),
          ],
        ),
      ),
    );
  }
}

// Your TodoListPage (updated based on previous code)
class TodoListPage extends StatefulWidget {
  final List<Map<String, String>> quotes;

  const TodoListPage({required this.quotes});

  @override
  _TodoListPageState createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _todoList = [];
  Map<String, String> _quote = {};

  @override
  void initState() {
    super.initState();
    _loadRandomDailyQuote();
    _fetchTodos();
  }

  void _loadRandomDailyQuote() {
    if (widget.quotes.isEmpty) {
      setState(() {
        _quote = {'quote': 'No quotes available.', 'author': ''};
      });
      return;
    }

    setState(() {
      _quote = widget.quotes[Random().nextInt(widget.quotes.length)];
    });
  }

  Future<void> _fetchTodos() async {
    try {
      final todos = _dbHelper.getTodos();
      setState(() {
        _todoList = todos;
      });
    } catch (e) {
      print('Error fetching todos: $e');
    }
  }

  Future<void> _addTodoItem(String task) async {
    if (task.isNotEmpty) {
      final newTodo = {"task": task, "isCompleted": false};
      await _dbHelper.insertTodo(newTodo);
      await _fetchTodos();
    }
  }

  Future<void> _editTodoItem(int id, String newTask) async {
    final updatedTodo = {"task": newTask, "isCompleted": false};
    await _dbHelper.updateTodo(id, updatedTodo);
    await _fetchTodos();
  }

  Future<void> _toggleTaskCompletion(int id, bool isCompleted) async {
    final todo = _todoList.firstWhere((element) => element['id'] == id);
    todo['isCompleted'] = isCompleted;
    await _dbHelper.updateTodo(id, todo);
    await _fetchTodos();
  }

  Future<void> _deleteTodoItem(int id) async {
    await _dbHelper.deleteTodoById(id);
    await _fetchTodos();
  }

  void _showAddTodoDialog({int? id, String? currentTask}) {
    TextEditingController taskController =
    TextEditingController(text: currentTask ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(id == null ? 'Add a Task' : 'Edit Task'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(hintText: 'Enter task name'),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (taskController.text.isNotEmpty) {
                  if (id == null) {
                    await _addTodoItem(taskController.text);
                  } else {
                    await _editTodoItem(id, taskController.text);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tasks', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[200],
        leading: IconButton(
          icon: Icon(Icons.poll, color: Color(0xFF666666)), // Apply gray color
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SurveyPage()),
            );
          },
        ),
      ),

      body: Column(
        children: [
          GestureDetector(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _quote['quote'] ?? 'Loading...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _quote['author'] ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                final todo = _todoList[index];
                return ListTile(
                  title: Text(
                    todo['task'],
                    style: TextStyle(
                      decoration: todo['isCompleted']
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  leading: Checkbox(
                    value: todo['isCompleted'],
                    onChanged: (bool? value) {
                      _toggleTaskCompletion(todo['id'], value!);
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showAddTodoDialog(
                          id: todo['id'],
                          currentTask: todo['task'],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTodoItem(todo['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(),
        backgroundColor: Colors.blueGrey[200],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SurveyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey'),
        backgroundColor: Colors.blueGrey[200],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Choose your survey language:',
              style: TextStyle(fontSize: 20), // Increased text size
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                _showSurveyDialog(context, 'Chinese', 'https://forms.gle/t9495FKS6CyPzUUj8');
              },
              child: Text(
                'Chinese',
                style: TextStyle(fontSize: 20, color: Colors.white), // Increased size, white text
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.blueGrey), // Button background color
            ),
            SizedBox(height: 10), // Space between buttons
            TextButton(
              onPressed: () {
                _showSurveyDialog(context, 'English', 'https://forms.gle/G4uJrdcN8hRj928P7');
              },
              child: Text(
                'English',
                style: TextStyle(fontSize: 20, color: Colors.white), // Increased size, white text
              ),
              style: TextButton.styleFrom(backgroundColor: Colors.blueGrey), // Button background color
            ),
          ],
        ),
      ),
    );
  }

  void _showSurveyDialog(BuildContext context, String language, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$language Survey'),
          content: GestureDetector(
            onTap: () async {
              Uri uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                throw 'Could not launch $url';
              }
            },
            child: Text(
              url,
              style: TextStyle(fontSize: 18, color: Colors.blue, decoration: TextDecoration.underline), // Increased size
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close', style: TextStyle(fontSize: 18)), // Increased size
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
