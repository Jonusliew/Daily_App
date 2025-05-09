import 'package:flutter/material.dart';
import 'bmi_calculator.dart'; 
import 'recipe_screen.dart';  
import 'package:health_app/recipe_screen.dart'; 
import 'db_helper.dart';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initialize();
  final quotes = await loadQuotes(true);  // Load English quotes by default
  runApp(MyApp(quotes: quotes));
}

Future<List<Map<String, String>>> loadQuotes(bool isEnglish) async {
  // Load the appropriate CSV file based on language
  final filePath = isEnglish ? 'assets/quotesenglish.csv' : 'assets/quotes.csv';
  final csvString = await rootBundle.loadString(filePath);
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
  bool _isEnglish = true;  // Default to English

  // Function to switch between languages and load new quotes
  void _toggleLanguage() async {
    setState(() {
      _isEnglish = !_isEnglish;
    });
    // Reload quotes based on language selection
    final quotes = await loadQuotes(_isEnglish);
    setState(() {
      widget.quotes.clear();
      widget.quotes.addAll(quotes);
    });
  }

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
        body: Stack(
          children: [
            _selectedIndex == 0
                ? TodoListPage(
                    quotes: widget.quotes,
                    isEnglish: _isEnglish,
                    toggleLanguage: _toggleLanguage,
                  )
                : _selectedIndex == 1
                    ? RecipeScreen(isEnglish: _isEnglish)
                    : BMICalculatorScreen(
                        isEnglish: _isEnglish,
                        toggleLanguage: _toggleLanguage,
                      ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  onPressed: _toggleLanguage,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.language, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          selectedItemColor: Color(0xFF666666),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: _isEnglish ? 'Home' : '主頁',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fastfood),
              label: _isEnglish ? 'Recipes' : '食譜',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calculate),
              label: _isEnglish ? 'BMI' : 'BMI 計算機',
            ),
          ],
        ),
      ),
    );
  }
}

class TodoListPage extends StatefulWidget {
  final List<Map<String, String>> quotes;
  final bool isEnglish;
  final VoidCallback toggleLanguage;

  const TodoListPage({
    required this.quotes,
    required this.isEnglish,
    required this.toggleLanguage,
  });

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
          title: Text(
            widget.isEnglish
                ? (id == null ? 'Add a Task' : 'Edit Task')
                : (id == null ? '新增任務' : '編輯任務'),
          ),
          content: TextField(
            controller: taskController,
            decoration: InputDecoration(
              hintText: widget.isEnglish ? 'Enter task name' : '輸入任務名稱',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(widget.isEnglish ? 'Cancel' : '取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                widget.isEnglish
                    ? (id == null ? 'Save' : 'Update')
                    : (id == null ? '儲存' : '更新'),
              ),
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
        title: Text(
          widget.isEnglish ? 'Daily Tasks' : '每日任務',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[200],
        leading: IconButton(
          icon: Icon(Icons.poll, color: Color(0xFF666666)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SurveyPage(isEnglish: widget.isEnglish)),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.8,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                SelectableText(
                  _quote['quote'] ?? 'Loading...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  _quote['author'] ?? '',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
  final bool isEnglish;

  SurveyPage({required this.isEnglish});

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
              style: const TextStyle(
                fontSize: 18,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          actions: [
            TextButton(
              child: Text(isEnglish ? 'Close' : '關閉', style: TextStyle(fontSize: 18)),
              onPressed: () => Navigator.of(context).pop(),
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
        title: Text(isEnglish ? 'Survey' : '調查'),
        backgroundColor: Colors.blueGrey[200],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF666666)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(isEnglish ? 'Take the Survey (English)' : '參加調查 (中文)'),
            onTap: () => _showSurveyDialog(
              context,
              isEnglish ? 'English' : '中文',
              'https://www.surveymonkey.com/r/your-survey-link',
            ),
          ),
        ],
      ),
    );
  }
}
