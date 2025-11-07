import 'package:checkfood/model/comida.dart';
import 'package:checkfood/model/repository/food_repository.dart';
import 'package:flutter/material.dart';

// Provider para gerenciar o estado das comidas.
// Extende ChangeNotifier para notificar os widgets sobre as mudanças nos dados.
class FoodProvider extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  List<Comida> _comidas = [];

  // Getter para a lista de comidas.
  List<Comida> get comidas => _comidas;

  // Carrega a lista de comidas do repositório.
  Future<void> loadComidas() async {
    _comidas = await _foodRepository.getComidas();
    // Notifica os widgets que estão ouvindo sobre a mudança nos dados.
    notifyListeners();
  }

  // Adiciona uma nova comida ao repositório.
  Future<void> addComida(Comida comida) async {
    await _foodRepository.addComida(comida);
    // Recarrega a lista de comidas para refletir a adição.
    await loadComidas();
  }

  // Atualiza uma comida existente no repositório.
  Future<void> updateComida(Comida comida) async {
    await _foodRepository.updateComida(comida);
    // Recarrega a lista de comidas para refletir a atualização.
    await loadComidas();
  }

  // Exclui uma comida do repositório.
  Future<void> deleteComida(String id) async {
    await _foodRepository.deleteComida(id);
    // Recarrega a lista de comidas para refletir a exclusão.
    await loadComidas();
  }
}
