import 'package:checkfood/model/comida.dart';
import 'package:checkfood/providers/food_provider.dart';
import 'package:checkfood/providers/ingredient_provider.dart';
import 'package:checkfood/providers/theme_provider.dart';
import 'package:checkfood/ui/food_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// 1. Crie um "Mock" (simulador) para o seu FoodProvider.
// Ele se comporta como o FoodProvider, mas usa uma lista em memória.
class MockFoodProvider extends FoodProvider {
  final List<Comida> _comidas = [];

  @override
  List<Comida> get comidas => _comidas;

  @override
  Future<void> loadComidas() async {
    // CORREÇÃO: Não chame notifyListeners() aqui.
    // O initState chama este método, e notificar durante o build causa um erro.
    // Os dados já são carregados no Consumer quando o widget é construído.
  }

  @override
  Future<void> addComida(Comida comida) async {
    _comidas.add(comida);
    notifyListeners();
  }

  // Você pode sobrescrever outros métodos se seus widgets os usarem.
}

void main() {
  // Não precisamos mais do sqflite aqui!

  late MockFoodProvider mockFoodProvider;
  late IngredientProvider ingredientProvider;

  setUp(() {
    // Use o MockFoodProvider nos seus testes
    mockFoodProvider = MockFoodProvider();
    ingredientProvider = IngredientProvider(); // Pode ser mockado também se necessário
  });

  testWidgets('FoodListScreen should display a list of foods', (WidgetTester tester) async {
    print('--- Teste: FoodListScreen should display a list of foods ---');
    // 1. Adicione uma comida diretamente ao mock provider
    final now = DateTime.now();
    final comida = Comida(
      id: '1', // ID simples para o teste
      o_que_e_a_comida: 'Comida de Teste',
      tipo_da_comida: 'Tipo Teste',
      dia_para_fazer: now,
      ingredientes_faltando: 0,
      tem_todos_ingredientes: true,
      ingredientes: [],
    );
    // Adicionamos a comida ANTES de construir o widget.
    mockFoodProvider.comidas.add(comida);

    // 2. Construa a árvore de widgets com o provider mockado
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // Especifique o tipo <FoodProvider> para que o widget o encontre.
          ChangeNotifierProvider<FoodProvider>.value(value: mockFoodProvider),
          ChangeNotifierProvider.value(value: ingredientProvider),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ],
        child: MaterialApp(
          home: FoodListScreen(),
        ),
      ),
    );

    // 3. Aguarde a UI ser construída
    await tester.pumpAndSettle();

    // 4. Verifique se a comida de teste aparece na tela
    expect(find.text('Comida de Teste'), findsOneWidget);
    // CORREÇÃO: O texto do subtítulo inclui "Tipo: ".
    expect(find.text('Tipo: Tipo Teste'), findsOneWidget);
    print('--- Teste: FoodListScreen should display a list of foods (Concluído) ---');
  });

  testWidgets('tapping add button navigates to new food screen', (WidgetTester tester) async {
    print('--- Teste: tapping add button navigates to new food screen ---');
    // 1. Construa a árvore de widgets
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          // Especifique o tipo <FoodProvider> aqui também.
          ChangeNotifierProvider<FoodProvider>.value(value: mockFoodProvider),
          ChangeNotifierProvider.value(value: ingredientProvider),
          ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ],
        child: MaterialApp(
          home: FoodListScreen(),
          // Defina a rota de destino para o teste de navegação
          routes: {
            '/new-food': (context) => Scaffold(body: Text('New Food Screen')),
          },
        ),
      ),
    );

    // 2. Toque no botão flutuante
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // 3. Verifique se a navegação para a nova tela ocorreu
    expect(find.text('New Food Screen'), findsOneWidget);
    print('--- Teste: tapping add button navigates to new food screen (Concluído) ---');
  });
}