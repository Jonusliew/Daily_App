import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For loading files
import 'package:csv/csv.dart'; // CSV parsing

class RecipeScreen extends StatefulWidget {
  final bool isEnglish;

  RecipeScreen({required this.isEnglish});

  @override
  _RecipeScreenState createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  List<Map<String, String>> recipes = [];

  @override
  void initState() {
    super.initState();
    loadRecipes(); // Initial load of recipes
  }

  // Load recipes based on the current language setting
  Future<void> loadRecipes() async {
    print("Loading recipes...");

    // Choose the correct CSV file based on the language setting
    String fileName = widget.isEnglish ? 'assets/quotesenglish.csv' : 'assets/quotes.csv';

    try {
      final rawData = await rootBundle.loadString(fileName);
      print("Raw CSV data loaded");

      List<List<dynamic>> csvData = const CsvToListConverter().convert(rawData);

      print("CSV Parsed: ${csvData.length} rows");

      if (csvData.isEmpty) {
        print("CSV is empty or incorrectly formatted.");
        return;
      }

      List<Map<String, String>> newRecipes = csvData.skip(1).map((row) {
        String recipeText = row[1].toString().trim();

        // Check for both English and Chinese patterns
        RegExp englishPattern = RegExp(r'Name:\s*(.+)');
        RegExp chinesePattern = RegExp(r'名稱[:：]\s*(.+)');

        String? englishMatch = englishPattern.firstMatch(recipeText)?.group(1);
        String? chineseMatch = chinesePattern.firstMatch(recipeText)?.group(1);

        // Use the first matched pattern (Chinese or English) or default to "Unknown Recipe"
        String recipeName = chineseMatch ?? englishMatch ?? "Unknown Recipe";

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
        backgroundColor: Colors.blueGrey[200],
      ),
      backgroundColor: Colors.blueGrey[100],
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
    return Scaffold(
      appBar: AppBar(title: Text(recipe['Recipe Name'] ?? 'Recipe Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(recipe['Recipe'] ?? 'No details available'),
      ),
    );
  }
}
