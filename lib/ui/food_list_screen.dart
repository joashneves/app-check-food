
import 'package:checkfood/ui/new_food_screen.dart';
import 'package:flutter/material.dart';

class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

class _FoodListScreenState extends State<FoodListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckFood'),
      ),
      body: ListView.builder(
        itemCount: 0, // Replace with actual data length
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Food Name'), // Replace with actual data
            subtitle: Text('Missing ingredients: 5'), // Replace with actual data
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NewFoodScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
