import 'package:checkfood/providers/food_provider.dart';
import 'package:checkfood/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ingredient_list_screen.dart';

// Tela principal que exibe a lista de comidas.
class FoodListScreen extends StatefulWidget {
  const FoodListScreen({Key? key}) : super(key: key);

  @override
  _FoodListScreenState createState() => _FoodListScreenState();
}

// Estado da tela FoodListScreen.
// WidgetsBindingObserver é usado para observar o ciclo de vida do aplicativo.
class _FoodListScreenState extends State<FoodListScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Adiciona o observer para o ciclo de vida do app.
    WidgetsBinding.instance.addObserver(this);
    // Carrega a lista de comidas ao iniciar a tela.
    Provider.of<FoodProvider>(context, listen: false).loadComidas();
  }

  @override
  void dispose() {
    // Remove o observer ao fechar a tela.
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Chamado quando o estado do ciclo de vida do app muda.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Se o app for retomado (voltando do background), recarrega a lista de comidas.
    if (state == AppLifecycleState.resumed) {
      Provider.of<FoodProvider>(context, listen: false).loadComidas();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CheckFood'),
        actions: [
          // Botão para alternar entre o tema claro e escuro.
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      // Consumer<FoodProvider> ouve as mudanças no FoodProvider e reconstrói a UI.
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          // Se a lista de comidas estiver vazia, exibe uma mensagem.
          if (foodProvider.comidas.isEmpty) {
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
            // Se a lista não estiver vazia, constrói um ListView.
            return ListView.builder(
              itemCount: foodProvider.comidas.length,
              itemBuilder: (context, index) {
                final food = foodProvider.comidas[index];
                // Dismissible permite que o item da lista seja arrastado para o lado para ser excluído.
                return Dismissible(
                  key: Key(food.id),
                  // Chamado quando o item é arrastado e descartado.
                  onDismissed: (direction) {
                    // Exclui a comida usando o FoodProvider.
                    Provider.of<FoodProvider>(context, listen: false).deleteComida(food.id);
                    // Exibe uma mensagem de confirmação.
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${food.o_que_e_a_comida} excluída')),
                    );
                  },
                  // Fundo que aparece ao arrastar o item.
                  background: Container(color: Colors.red),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
                    ),
                    child: ListTile(
                      title: Text(food.o_que_e_a_comida),
                      subtitle: Text('Tipo: ${food.tipo_da_comida}'),
                      // Ao tocar no item, navega para a tela de ingredientes.
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                IngredientListScreen(foodId: food.id, foodName: food.o_que_e_a_comida),
                          ),
                        );
                        // Recarrega a lista de comidas ao retornar da tela de ingredientes.
                        Provider.of<FoodProvider>(context, listen: false).loadComidas();
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Se todos os ingredientes estiverem marcados, exibe um ícone de check.
                          if (food.tem_todos_ingredientes)
                            Icon(Icons.check_circle, color: Colors.green),
                          // Botão para editar a comida.
                          IconButton(
                            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                            onPressed: () {
                              // Navega para a tela de nova comida, passando o ID da comida para edição.
                              Navigator.pushNamed(context, '/new-food', arguments: food.id);
                            },
                          ),
                          // Botão para excluir a comida.
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              // Exibe um diálogo de confirmação antes de excluir.
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Excluir Comida'),
                                  content: Text('Tem certeza que deseja excluir esta comida?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Provider.of<FoodProvider>(context, listen: false).deleteComida(food.id);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Excluir'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      // Botão flutuante para adicionar uma nova comida.
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Navega para a tela de nova comida.
              Navigator.pushNamed(context, '/new-food');
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