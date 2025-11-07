import 'package:checkfood/db/database_helper.dart';
import 'package:checkfood/model/comida.dart';
import 'package:checkfood/model/ingrediente.dart';

// Repositório para gerenciar os dados de comidas e ingredientes.
// Abstrai a fonte de dados (neste caso, o DatabaseHelper) da UI e dos providers.
class FoodRepository {
  final dbHelper = DatabaseHelper.instance;

  // Adiciona uma nova comida e seus ingredientes ao banco de dados.
  Future<void> addComida(Comida comida) async {
    await dbHelper.insertComida(comida);
    for (var ingrediente in comida.ingredientes) {
      await dbHelper.insertIngrediente(ingrediente);
    }
  }

  // Obtém a lista de todas as comidas do banco de dados.
  Future<List<Comida>> getComidas() async {
    final comidas = await dbHelper.getComidas();
    // Para cada comida, carrega a lista de ingredientes correspondente.
    for (var comida in comidas) {
      comida.ingredientes = await dbHelper.getIngredientesPorComida(comida.id);
    }
    return comidas;
  }

  // Obtém uma comida específica com seus ingredientes.
  Future<Comida> getComidaComIngredientes(String comidaId) async {
    final List<Comida> comidas = await getComidas();
    final Comida comida = comidas.firstWhere((comida) => comida.id == comidaId);
    comida.ingredientes = await dbHelper.getIngredientesPorComida(comidaId);
    return comida;
  }

  // Atualiza uma comida existente no banco de dados.
  Future<void> updateComida(Comida comida) async {
    await dbHelper.updateComida(comida);
  }

  // Exclui uma comida do banco de dados.
  Future<void> deleteComida(String id) async {
    await dbHelper.deleteComida(id);
  }

  // Adiciona um novo ingrediente ao banco de dados.
  Future<void> addIngrediente(Ingrediente ingrediente) async {
    await dbHelper.insertIngrediente(ingrediente);
    // Atualiza o status da comida (se todos os ingredientes estão marcados).
    await updateComidaStatus(ingrediente.comida_id!);
  }

  // Obtém a lista de ingredientes de uma comida específica.
  Future<List<Ingrediente>> getIngredientesPorComida(String comidaId) async {
    return await dbHelper.getIngredientesPorComida(comidaId);
  }

  // Obtém a lista de todos os ingredientes.
  Future<List<Ingrediente>> getIngredientes() async {
    return await dbHelper.getIngredientes();
  }

  // Atualiza um ingrediente existente no banco de dados.
  Future<void> updateIngrediente(Ingrediente ingrediente) async {
    await dbHelper.updateIngrediente(ingrediente);
    // Atualiza o status da comida (se todos os ingredientes estão marcados).
    await updateComidaStatus(ingrediente.comida_id!);
  }

  // Exclui um ingrediente do banco de dados.
  Future<void> deleteIngrediente(String id, String comidaId) async {
    await dbHelper.deleteIngrediente(id);
    // Atualiza o status da comida (se todos os ingredientes estão marcados).
    await updateComidaStatus(comidaId);
  }

  // Atualiza o status de uma comida (se todos os ingredientes estão marcados).
  Future<void> updateComidaStatus(String comidaId) async {
    final comida = await getComidaComIngredientes(comidaId);
    final ingredientes = await getIngredientesPorComida(comidaId);
    // Verifica se todos os ingredientes estão marcados.
    final bool allMarked = ingredientes.every((ing) => ing.marcado);
    comida.tem_todos_ingredientes = allMarked;
    // Atualiza a comida no banco de dados com o novo status.
    await updateComida(comida);
  }
}
