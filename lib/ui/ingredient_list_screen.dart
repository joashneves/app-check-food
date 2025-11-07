import 'package:checkfood/model/ingrediente.dart';
import 'package:checkfood/providers/ingredient_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// Tela que exibe a lista de ingredientes de uma comida específica.
class IngredientListScreen extends StatefulWidget {
  final String foodId;
  final String foodName;

  const IngredientListScreen({Key? key, required this.foodId, required this.foodName}) : super(key: key);

  @override
  _IngredientListScreenState createState() => _IngredientListScreenState();
}

class _IngredientListScreenState extends State<IngredientListScreen> {
  @override
  void initState() {
    super.initState();
    // Carrega a lista de ingredientes para a comida atual ao iniciar a tela.
    Provider.of<IngredientProvider>(context, listen: false).loadIngredientes(widget.foodId);
  }

  // Exibe um diálogo para adicionar um novo ingrediente.
  void _showAddIngredientDialog() {
    final _formKey = GlobalKey<FormState>();
    String _nome = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Novo Ingrediente'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(labelText: 'Nome'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira o nome';
                }
                return null;
              },
              onSaved: (value) {
                _nome = value!;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  final newIngredient = Ingrediente(
                    id: Uuid().v4(),
                    nome: _nome,
                    marcado: false,
                    data_de_criacao: DateTime.now(),
                    comida_id: widget.foodId,
                  );
                  // Adiciona o novo ingrediente usando o IngredientProvider.
                  await Provider.of<IngredientProvider>(context, listen: false).addIngrediente(newIngredient);
                  Navigator.pop(context);
                }
              },
              child: Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.foodName),
      ),
      // Consumer<IngredientProvider> ouve as mudanças no IngredientProvider e reconstrói a UI.
      body: Consumer<IngredientProvider>(
        builder: (context, ingredientProvider, child) {
          // Se a lista de ingredientes estiver vazia, exibe uma mensagem.
          if (ingredientProvider.ingredientes.isEmpty) {
            return const Center(child: Text('Nenhum ingrediente cadastrado.'));
          } else {
            // Se a lista não estiver vazia, constrói um ListView.
            return ListView.builder(
              itemCount: ingredientProvider.ingredientes.length,
              itemBuilder: (context, index) {
                final ingredient = ingredientProvider.ingredientes[index];
                return ListTile(
                  title: Text(ingredient.nome),
                  subtitle: Text(ingredient.marcado && ingredient.data_de_aquisicao != null
                      ? 'Adquirido em: ${ingredient.data_de_aquisicao!.toLocal().toString().split(' ')[0]}'
                      : 'Criado em: ${ingredient.data_de_criacao.toLocal().toString().split(' ')[0]}'),
                  // Checkbox para marcar o ingrediente como adquirido.
                  trailing: Checkbox(
                    value: ingredient.marcado,
                    onChanged: (bool? value) {
                      ingredient.marcado = value!;
                      if (ingredient.marcado) {
                        ingredient.data_de_aquisicao = DateTime.now();
                      } else {
                        ingredient.data_de_aquisicao = null;
                      }
                      // Atualiza o ingrediente usando o IngredientProvider.
                      Provider.of<IngredientProvider>(context, listen: false).updateIngrediente(ingredient);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      // Botão flutuante para adicionar um novo ingrediente.
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddIngredientDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}