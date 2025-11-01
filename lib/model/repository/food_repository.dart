
import 'package:checkfood/db/database_helper.dart';
import 'package:checkfood/model/comida.dart';
import 'package:checkfood/model/ingrediente.dart';

class FoodRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<void> addComida(Comida comida) async {
    await dbHelper.insertComida(comida);
    for (var ingrediente in comida.ingredientes) {
      await dbHelper.insertIngrediente(ingrediente);
    }
  }

  Future<List<Comida>> getComidas() async {
    final comidas = await dbHelper.getComidas();
    for (var comida in comidas) {
      comida.ingredientes = await dbHelper.getIngredientesPorComida(comida.id);
    }
    return comidas;
  }

  Future<Comida> getComidaComIngredientes(String comidaId) async {
    final List<Comida> comidas = await getComidas();
    final Comida comida = comidas.firstWhere((comida) => comida.id == comidaId);
    comida.ingredientes = await dbHelper.getIngredientesPorComida(comidaId);
    return comida;
  }

  Future<void> updateComida(Comida comida) async {
    await dbHelper.updateComida(comida);
  }

  Future<void> deleteComida(String id) async {
    await dbHelper.deleteComida(id);
  }

  Future<void> addIngrediente(Ingrediente ingrediente) async {
    await dbHelper.insertIngrediente(ingrediente);
  }

  Future<List<Ingrediente>> getIngredientesPorComida(String comidaId) async {
    return await dbHelper.getIngredientesPorComida(comidaId);
  }

  Future<List<Ingrediente>> getIngredientes() async {
    return await dbHelper.getIngredientes();
  }

  Future<void> updateIngrediente(Ingrediente ingrediente) async {
    await dbHelper.updateIngrediente(ingrediente);
  }

  Future<void> deleteIngrediente(String id) async {
    await dbHelper.deleteIngrediente(id);
  }
}
