import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

void main() {
  runApp(RecipeApp());
}

class RecipeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Recipe App',
      theme: ThemeData(primarySwatch: Colors.blueGrey),
      home: RecipeListScreen(),
    );
  }
}

class RecipeListScreen extends StatefulWidget {
  @override
  _RecipeListScreenState createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  List<Map<String, String>> recipes = [];

  @override
  void initState() {
    super.initState();
    loadRecipes();
  }

  Future<void> loadRecipes() async {
    print("Loading recipes...");

    try {
      final rawData = await rootBundle.loadString('assets/recipes.csv');
      print("Raw CSV data loaded");

      List<List<dynamic>> csvData = const CsvToListConverter(
        eol: '\n',
        fieldDelimiter: ',',
        textDelimiter: '"',
      ).convert(rawData);

      print("CSV Parsed: ${csvData.length} rows");

      if (csvData.isEmpty) {
        print("CSV is empty or incorrectly formatted.");
        return;
      }

      List<Map<String, String>> newRecipes = csvData.skip(1).map((row) {
        String recipeText = row[1].toString().trim();
        RegExp namePattern = RegExp(r'Name:\s*(.+)');
        String recipeName = namePattern.firstMatch(recipeText)?.group(1) ?? "Unknown Recipe";

        return {
          'ID': row[0].toString(),
          'Recipe Name': recipeName,
          'Recipe': recipeText,
        };
      }).toList();

      print("Recipes loaded successfully: ${newRecipes.length}");

      setState(() {
        recipes = newRecipes;
      });
    } catch (e) {
      print("Error loading recipes: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blueGrey[200], // Lighter AppBar color
      ),
      backgroundColor: Colors.blueGrey[100], // Light background color
      body: recipes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          String recipeId = recipes[index]['ID'] ?? '';
          String recipeName = recipes[index]['Recipe Name'] ?? 'Unknown Recipe';

          return ListTile(
            leading: Image.asset(
              'assets/images/$recipeId.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
              },
            ),
            title: Text(recipeName),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: recipes[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, String> recipe;

  RecipeDetailScreen({required this.recipe});

  @override
  Widget build(BuildContext context) {
    String recipeId = recipe['ID'] ?? '';
    String recipeText = recipe['Recipe'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe['Recipe Name'] ?? 'Unknown Recipe',
          style: TextStyle(color: Colors.white), // Title text color set to white
        ),
        backgroundColor: Colors.blueGrey[200], // Lighter AppBar color
      ),
      backgroundColor: Colors.blueGrey[100], // Light background color
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              'assets/images/$recipeId.png',
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Icon(Icons.image_not_supported, size: 100, color: Colors.grey),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              recipeText,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
