import 'package:checkfood/model/comida.dart';
import 'package:checkfood/model/ingrediente.dart';
import 'package:checkfood/model/repository/food_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Database Tests', () {
    late FoodRepository foodRepository;

    setUp(() {
      foodRepository = FoodRepository();
    });

    test('Insert and Read Comida and Ingredientes', () async {
      // 1. Create a Comida with Ingredientes
      final comidaId = const Uuid().v4();
      final now = DateTime.now();
      final ingrediente1 = Ingrediente(
        id: const Uuid().v4(),
        nome: 'Tomate',
        marcado: false,
        data_de_criacao: now,
        comida_id: comidaId,
      );
      final ingrediente2 = Ingrediente(
        id: const Uuid().v4(),
        nome: 'Cebola',
        marcado: true,
        data_de_criacao: now,
        data_de_aquisicao: now,
        comida_id: comidaId,
      );
      final comida = Comida(
        id: comidaId,
        o_que_e_a_comida: 'Molho de Tomate',
        tipo_da_comida: 'Molho',
        dia_para_fazer: now,
        ingredientes_faltando: 1,
        tem_todos_ingredientes: false,
        ingredientes: [ingrediente1, ingrediente2],
      );

      // 2. Insert into the database
      await foodRepository.addComida(comida);
      print('Inserido no banco de dados:');
      print('Comida: ${comida.o_que_e_a_comida}');
      comida.ingredientes.forEach((ing) => print('  - Ingrediente: ${ing.nome}'));

      // 3. Read from the database
      final comidasFromDb = await foodRepository.getComidas();
      final retrievedComida = comidasFromDb.firstWhere((c) => c.id == comidaId);

      print('\nLido do banco de dados:');
      print('Comida: ${retrievedComida.o_que_e_a_comida}');
      retrievedComida.ingredientes.forEach((ing) => print('  - Ingrediente: ${ing.nome}'));


      // 4. Verify the data
      expect(comidasFromDb.isNotEmpty, isTrue);
      expect(retrievedComida.o_que_e_a_comida, comida.o_que_e_a_comida);
      expect(retrievedComida.ingredientes.length, 2);
      expect(retrievedComida.ingredientes.any((ing) => ing.nome == 'Tomate'), isTrue);
      expect(retrievedComida.ingredientes.any((ing) => ing.nome == 'Cebola'), isTrue);

      print('\nTeste de persistência concluído com sucesso!');
    });

    test('Update Comida', () async {
      // 1. Create and insert a Comida
      final comidaId = const Uuid().v4();
      final now = DateTime.now();
      final comida = Comida(
        id: comidaId,
        o_que_e_a_comida: 'Original Name',
        tipo_da_comida: 'Tipo',
        dia_para_fazer: now,
        ingredientes_faltando: 0,
        tem_todos_ingredientes: true,
        ingredientes: [],
      );
      await foodRepository.addComida(comida);

      // 2. Update the Comida
      final updatedComida = Comida(
        id: comidaId,
        o_que_e_a_comida: 'Updated Name',
        tipo_da_comida: 'Tipo',
        dia_para_fazer: now,
        ingredientes_faltando: 0,
        tem_todos_ingredientes: true,
        ingredientes: [],
      );
      await foodRepository.updateComida(updatedComida);

      // 3. Read from the database
      final comidasFromDb = await foodRepository.getComidas();
      final retrievedComida = comidasFromDb.firstWhere((c) => c.id == comidaId);

      // 4. Verify the data
      expect(retrievedComida.o_que_e_a_comida, 'Updated Name');
    });

    test('Delete Comida', () async {
      // 1. Create and insert a Comida
      final comidaId = const Uuid().v4();
      final now = DateTime.now();
      final comida = Comida(
        id: comidaId,
        o_que_e_a_comida: 'To be deleted',
        tipo_da_comida: 'Tipo',
        dia_para_fazer: now,
        ingredientes_faltando: 0,
        tem_todos_ingredientes: true,
        ingredientes: [],
      );
      await foodRepository.addComida(comida);

      // 2. Delete the Comida
      await foodRepository.deleteComida(comidaId);

      // 3. Read from the database
      final comidasFromDb = await foodRepository.getComidas();

      // 4. Verify the data
      expect(comidasFromDb.any((c) => c.id == comidaId), isFalse);
    });

    test('Add Ingrediente', () async {
      // 1. Create and insert a Comida
      final comidaId = const Uuid().v4();
      final now = DateTime.now();
      final comida = Comida(
        id: comidaId,
        o_que_e_a_comida: 'Comida Test',
        tipo_da_comida: 'Tipo',
        dia_para_fazer: now,
        ingredientes_faltando: 1,
        tem_todos_ingredientes: false,
        ingredientes: [],
      );
      await foodRepository.addComida(comida);

      // 2. Add a new Ingrediente
      final ingrediente = Ingrediente(
        id: const Uuid().v4(),
        nome: 'New Ingrediente',
        marcado: false,
        data_de_criacao: now,
        comida_id: comidaId,
      );
      await foodRepository.addIngrediente(ingrediente);

      // 3. Read from the database
      final ingredientesFromDb = await foodRepository.getIngredientesPorComida(comidaId);

      // 4. Verify the data
      expect(ingredientesFromDb.any((ing) => ing.nome == 'New Ingrediente'), isTrue);
    });

    test('Update Ingrediente', () async {
      // 1. Create and insert a Comida with an Ingrediente
      final comidaId = const Uuid().v4();
      final now = DateTime.now();
      final ingredienteId = const Uuid().v4();
      final ingrediente = Ingrediente(
        id: ingredienteId,
        nome: 'Original Ingrediente',
        marcado: false,
        data_de_criacao: now,
        comida_id: comidaId,
      );
      final comida = Comida(
        id: comidaId,
        o_que_e_a_comida: 'Comida Test',
        tipo_da_comida: 'Tipo',
        dia_para_fazer: now,
        ingredientes_faltando: 1,
        tem_todos_ingredientes: false,
        ingredientes: [ingrediente],
      );
      await foodRepository.addComida(comida);

      // 2. Update the Ingrediente
      final updatedIngrediente = Ingrediente(
        id: ingredienteId,
        nome: 'Updated Ingrediente',
        marcado: true,
        data_de_criacao: now,
        comida_id: comidaId,
      );
      await foodRepository.updateIngrediente(updatedIngrediente);

      // 3. Read from the database
      final ingredientesFromDb = await foodRepository.getIngredientesPorComida(comidaId);
      final retrievedIngrediente = ingredientesFromDb.firstWhere((ing) => ing.id == ingredienteId);

      // 4. Verify the data
      expect(retrievedIngrediente.nome, 'Updated Ingrediente');
      expect(retrievedIngrediente.marcado, isTrue);
    });
  });
}
