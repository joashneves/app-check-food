import 'package:checkfood/db/database_helper.dart';
import 'package:checkfood/model/comida.dart';
import 'package:checkfood/providers/theme_provider.dart';
import 'package:checkfood/ui/new_food_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ingredient_list_screen.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  late Future<List<Comida>> _foodList;

  @override
  void initState() {
    super.initState();
    _refreshFoodList();
  }

  void _refreshFoodList() {
    setState(() {
      _foodList = DatabaseHelper.instance.getComidas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckFood'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Comida>>(
        future: _foodList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nenhuma comida cadastrada.'),
                  const SizedBox(height: 16),
                ],
              ),
            );
          } else {
            final foodList = snapshot.data!;
            return ListView.builder(
              itemCount: foodList.length,
              itemBuilder: (context, index) {
                final food = foodList[index];
                return ListTile(
                  title: Text(food.o_que_e_a_comida),
                  subtitle: Text('Tipo: ${food.tipo_da_comida}'),
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.list, color: Theme.of(context).colorScheme.primary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                IngredientListScreen(foodId: food.id, foodName: food.o_que_e_a_comida),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NewFoodScreen()),
              );
              _refreshFoodList();
            },
            child: const Icon(Icons.add),
            heroTag: 'addFood',
          ),
          SizedBox(height: 10),
          
        ],
      ),
    );
  }
}