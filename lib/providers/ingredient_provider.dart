import 'package:checkfood/model/ingrediente.dart';
import 'package:checkfood/model/repository/food_repository.dart';
import 'package:flutter/material.dart';

// Provider para gerenciar o estado dos ingredientes.
// Extende ChangeNotifier para notificar os widgets sobre as mudanças nos dados.
class IngredientProvider extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  List<Ingrediente> _ingredientes = [];

  // Getter para a lista de ingredientes.
  List<Ingrediente> get ingredientes => _ingredientes;

  // Carrega a lista de ingredientes de uma comida específica do repositório.
  Future<void> loadIngredientes(String comidaId) async {
    _ingredientes = await _foodRepository.getIngredientesPorComida(comidaId);
    // Notifica os widgets que estão ouvindo sobre a mudança nos dados.
    notifyListeners();
  }

  // Adiciona um novo ingrediente ao repositório.
  Future<void> addIngrediente(Ingrediente ingrediente) async {
    await _foodRepository.addIngrediente(ingrediente);
    // Recarrega a lista de ingredientes para refletir a adição.
    await loadIngredientes(ingrediente.comida_id!);
  }

  // Atualiza um ingrediente existente no repositório.
  Future<void> updateIngrediente(Ingrediente ingrediente) async {
    await _foodRepository.updateIngrediente(ingrediente);
    // Recarrega a lista de ingredientes para refletir a atualização.
    await loadIngredientes(ingrediente.comida_id!);
  }

  // Exclui um ingrediente do repositório.
  Future<void> deleteIngrediente(String id, String comidaId) async {
    await _foodRepository.deleteIngrediente(id, comidaId);
    // Recarrega a lista de ingredientes para refletir a exclusão.
    await loadIngredientes(comidaId);
  }
}
